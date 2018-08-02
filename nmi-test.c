/* Generate an NMI using the TCO on Intel machines, from Linux userspace
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/io.h>

static __inline void
dbg_outb (unsigned char __value, unsigned short int __port)
{
	printf("outb(0x%x,0x%x)\n", __value, __port);
	outb(__value, __port);
}

static __inline unsigned char
dbg_inb (unsigned short int __port)
{
	unsigned char val8 = inb(__port);
	printf("inb(0x%x) -> 0x%x\n", __port, val8);
	return val8;
}

static __inline void
dbg_outw (unsigned short int __value, unsigned short int __port)
{
	printf("outw(0x%x,0x%x)\n", __value, __port);
	outb(__value, __port);
}

static __inline unsigned short int
dbg_inw (unsigned short int __port)
{
	unsigned short int val16 = inw(__port);
	printf("inw(0x%x) -> 0x%x\n", __port, val16);
	return val16;
}

int locate_base(unsigned short *tcobase)
{
	unsigned int val;
	FILE *pci_config = fopen("/sys/bus/pci/devices/0000:00:1f.0/config",
				"r");
	if (!pci_config)
		goto err;

	if (fread((void*)&val, sizeof(val), 1, pci_config) != 1)
		goto err;

	printf("Vendor:Device = %04x:%04x\n", val & 0xffff, val >> 16);
	switch (val) {
		case 0x3b098086:  /* ICH5 */
		case 0x29188086:  /* ICH9 */
		case 0x3b148086:
			if (fseek(pci_config, 0x40, SEEK_SET) != 0)
				goto err;
			if (fread((void*)&val, sizeof(val), 1, pci_config) != 1)
				goto err;
			if (tcobase)
				*tcobase = (val & 0xff00) + 0x60;
			break;
		case 0x18dc8086:  /* SNR */
			fclose(pci_config);
			pci_config = fopen("/sys/bus/pci/devices/0000:00:1f.4/config",
						"r");
			if (!pci_config)
				goto err;

			if (fseek(pci_config, 0x50, SEEK_SET) != 0)
				goto err;
			if (fread((void*)&val, sizeof(val), 1, pci_config) != 1)
				goto err;
			if (tcobase)
				*tcobase = val & 0xff00;
			break;
		default:
			fprintf(stderr, "Unknown device %x\n", val);
			goto err;
	}

	printf("TCOBASE=%04x\n", *tcobase);
	return 0;

err:
	perror("Unable to determine base address for TCO");
	if (pci_config)
		fclose(pci_config);
	return -1;
}

#define R_PCH_NMI_EN	0x70
#define R_TCO1_CNT(tcobase) ((tcobase)+0x8)
#define B_NMI2SMI_EN (1<<9)
#define B_NMI_NOW (1<<8)

void generatenmi(unsigned short tcobase)
{
	unsigned char val8;
	unsigned val16;

	/* Enable NMI_EN */
	dbg_outb(0x8f, R_PCH_NMI_EN);
	dbg_outb(0x0f, R_PCH_NMI_EN);

	/* Clear NMI2SMI_EN */
	val16 = dbg_inw(R_TCO1_CNT(tcobase));
	dbg_outw(val16 & ~B_NMI2SMI_EN, R_TCO1_CNT(tcobase));
	/* Set NMI_NOW */
	val16 = dbg_inw(R_TCO1_CNT(tcobase));
	dbg_outw(val16 | B_NMI_NOW, R_TCO1_CNT(tcobase));
}

int main(int argc, char **argv)
{
	unsigned short tcobase;
	if (locate_base(&tcobase) < 0) {
		exit(EXIT_FAILURE);
	}

	/* Raise our privilege level. */
	if (iopl (3) == -1) {
		fprintf(stderr, "iopl failed: You may need to run as root or give the process the CAP_SYS_RAWIO\n"
			"capability. On non-x86 architectures, this operation probably isn't possible.\n");
		perror("iopl");
		exit (EXIT_FAILURE);
	}

	generatenmi(tcobase);
}
