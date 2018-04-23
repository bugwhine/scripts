#include <stdio.h>
#include <X11/X.h>
#include <X11/XKBlib.h>

int capsstate(Display *display)
{
    XkbStateRec xkb_state;
    Status status = XkbGetState(display, XkbUseCoreKbd, &xkb_state);
    if (status) {
        fprintf(stderr, "XkbGetState returned %d\n", status);
        return 1;
    }

#if 0
    printf("state.mods=%02x\n", xkb_state.mods);
    printf("state.group=%02x\n", xkb_state.group);
    printf("state.locked_group=%02x\n", xkb_state.locked_group);
    printf("state.base_group=%02x\n", xkb_state.base_group);
    printf("state.latched_group=%02x\n", xkb_state.latched_group);
    printf("state.base_mods=%02x\n", xkb_state.base_mods);
    printf("state.latched_mods=%02x\n", xkb_state.latched_mods);
    printf("state.locked_mods=%02x\n", xkb_state.locked_mods);
    printf("state.compat_state=%02x\n", xkb_state.compat_state);
    printf("state.grab_mods=%02x\n", xkb_state.grab_mods);
    printf("state.compat_grab_mods=%02x\n", xkb_state.compat_grab_mods);
    printf("state.lookup_mods=%02x\n", xkb_state.lookup_mods);
    printf("state.compat_lookup_mods=%02x\n", xkb_state.compat_lookup_mods);
    printf("state.ptr_buttons=%02x\n", xkb_state.ptr_buttons);
#endif

    return xkb_state.mods & 0x2;
}

int main()
{
    Display *display = XOpenDisplay(NULL);
    if (display == NULL) {
        fprintf(stderr, "Couldn't open display\n");
        return 2;
    }

    printf("Caps Lock currently %s\n", capsstate(display) ? "On" : "Off");

    Bool sent = XkbLockModifiers(display, XkbUseCoreKbd, LockMask, 0);
    if (!sent) {
        fprintf(stderr, "Couldn't send LatchLockState\n");
        return 1;
    }

    printf("Caps Lock currently %s\n", capsstate(display) ? "On" : "Off");

    int err = XCloseDisplay(display);
    if (err) {
        fprintf(stderr, "XCloseDisplay returned %d\n", err);
        return 1;
    }
    return 0;
}