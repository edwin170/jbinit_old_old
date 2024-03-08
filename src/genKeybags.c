#include <stdio.h>
#include <stdbool.h>
#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>

bool checkKeybagExistance() {
    
    int fd = open("/private/var/keybags/systembag.kb", O_RDONLY, 0);
    
    if (fd > -1) {
        
        close(fd);
        return true;
        
    } else {
        close(fd);
        return false;
    }
    
}

void generateKeybag() {
    int fd_console = open("/dev/console",O_RDWR,0);
    dprintf(fd_console, "\n\n\n\n\n\n\n\n");
    dprintf(fd_console, "*******************************");
    dprintf(fd_console, "we are on generateKeybag function...\n");
    dprintf(fd_console, "*******************************");
    dprintf(fd_console, "\n\n\n\n\n\n\n\n");

    int (*MKBKeyBagCreateSystem)(int x, char* path);
    
    void *handle = dlopen("/System/Library/PrivateFrameworks/MobileKeyBag.framework/MobileKeyBag", RTLD_LAZY);
    MKBKeyBagCreateSystem = dlsym(handle, "MKBKeyBagCreateSystem");
    MKBKeyBagCreateSystem(0, "/private/var");
    
    if (checkKeybagExistance()) {
        
        dprintf(fd_console, "it generated correctly, nice...");
        
    } else {
        dprintf(fd_console, "Something went wrong...\n");
    }
    close(fd_console);

}