BEGIN {
	print "Device (RCS)"
    print "{"
    print "	Name (_HID, "GPIO0003")"
    print "	Name (_CRS, ResourceTemplate ()"
    print "	{"
    idx = 0
}

{

// "// GPIO[0] = E[1] = IRQ_PM_CPM_N"

	if ($1 == "//" && $3 == "=" && $5 == "=") {
		snr_name = tolower($2)
		cpm_name = tolower($6)
		sub(/\s/, "", cpm_name)
		split($4,arr,/[\[\]]/)
		if (arr[1] == "W")
			community = 0
		else if (arr[1] == "E")
			community = 1
		else
			print "error, unknown community"

		pin = arr[2]
	}

// "// GPP_W[56] (FAN_TACH_0) = W[56] = MTC_SNR_TRST_N"
	if ($1 == "//" && $4 == "=" && $6 == "=") {
		snr_name = tolower($2)
		cpm_name = tolower($7)
		sub(/\s/, "", cpm_name)

		split($5,arr,/[\[\]]/)
		if (arr[1] == "W")
			community = 0
		else if (arr[1] == "E")
			community = 1
		else
			print "error, unknown community"

		pin = arr[2]
	}
}

{
# 	  {GPIO_CDF_GPP_L2 , { GpioPadModeGpio, GpioHostOwnGpio, GpioDirOut, GpioOutLow, GpioIntDis,  GpioHostDeepReset, GpioTermNone, GpioPadConfigLock}}, 

	if ($0 ~ /GpioPadModeGpio/) {
		printf "\n\t\t// %s = %c[%d] = %s\n", snr_name, community ? "E" : "W", pin, cpm_name 
		if ($0 ~ /GpioIntDis/) {

			printf "\t\tGpioInt (Edge, ActiveHigh, ExclusiveAndWake, PullUp, 0, \n"
			printf "\t\t\t\"\\_SB.PC00.GPIO\", %d, ResourceConsumer, ,) { %d }\n", community, pin

		} else {

#  {GPIO_CDF_GPP_L2 , { GpioPadModeGpio, GpioHostOwnGpio, GpioDirOut, GpioOutLow, GpioIntDis, GpioHostDeepReset, GpioTermNone, GpioPadConfigLock}}, 
#                GpioIo (Exclusive, PullDown, 0x0000, 0x0000, IoRestrictionOutputOnly, 

			printf "\t\tGpioIo (Exclusive, "
			if ($0 ~ /GpioOutLow/) printf "PullDown, "
			if ($0 ~ /GpioOutHigh/) printf "PullUp, "
			if ($0 ~ /GpioOutDefault/)  printf "PullNone, "
			if ($0 ~ /GpioDirOut/) printf "IoRestrictionOutputOnly, "
			if ($0 ~ /GpioDirIn/) printf "IoRestrictionInputOnly, "
			printf "\n\t\t\t\"\\_SB.PC00.GPIO\", %d, ResourceConsumer, ,) { %d }\n", community, pin
		}

		dsd[idx] = cpm_name
		idx++
	}
}

END {
	print "\t}"
	print "\tName (_DSD, Package ()"
    print "\t{"
    print "\t\tToUUID (\"daffd814-6eba-4d8c-8a91-bc9bbf4aa301\"),"

#               Package ()
#               {
#                   Package () { "irq_pm_cpm_n-gpio", Package () { RCS, 0, 0, 1 } } 
#					...
#				}, 

	print "\t\tPackage ()"
	print "\t\t{"

	for (i=0; i < idx; i++) {
		printf "\t\t\tPackage () { \"%s\", Package () { RCS, %d, 0, 1 } },\n", dsd[i], i
	}

	print "\t\t}, "
	print "\t}"
    print "}"
}