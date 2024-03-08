#include "idownload/CFUserNotification.h"
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include "support/libarchive.h"
#include "idownload/support.h"
#import <spawn.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <termios.h>
#include <sys/clonefile.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <mach/mach.h>

extern int generateKeybag();

int loadDaemons(void){
  DIR *d = NULL;
  struct dirent *dir = NULL;

  if (!(d = opendir("/Library/LaunchDaemons/"))){
    printf("Failed to open dir with err=%d (%s)\n",errno,strerror(errno));
    return -1;
  }

  while ((dir = readdir(d))) { //remove all subdirs and files
      if (strcmp(dir->d_name, ".") == 0 || strcmp(dir->d_name, "..") == 0) {
          continue;
      }
      char *pp = NULL;
      asprintf(&pp,"/Library/LaunchDaemons/%s",dir->d_name);

      {
        const char *args[] = {
          "/bin/launchctl",
          "load",
          pp,
          NULL
        };
        run(args[0], args);
      }
      free(pp);
  }
  closedir(d);
  return 0;
}

int enable_ssh(void* __unused _) {
    chown("/jbin/binpack/Library/LaunchDaemons/dropbear.plist", 0, 0); // just in case it doesn't have correct perm
    
  if (access("/jbin/binpack/dropbear_rsa_host_key", F_OK) != 0) {
    char* dropbearkey_argv[] = { "/jbin/binpack/usr/bin/dropbearkey", "-f", "/jbin/binpack/dropbear_rsa_host_key", "-t", "rsa", "-s", "4096", NULL };
    run(dropbearkey_argv[0], dropbearkey_argv);
  }
  char* launchctl_argv[] = { "/jbin/binpack/bin/launchctl", "load", "-w", "/jbin/binpack/Library/LaunchDaemons/dropbear.plist", NULL };
  run(launchctl_argv[0], launchctl_argv);
  return 0;
}

int uicache_loader(char* app)
{
  run("/jbin/binpack/usr/bin/uicache", (char*[]){
    "/jbin/binpack/usr/bin/uicache",
    "-p",
    app,
    NULL});
  return 0;
}

int uicache_all()
{
    run("/usr/bin/uicache", (char*[]){
      "/usr/bin/uicache",
      "-a",
      NULL});

  return 0;
}

int remount_rootRW()
{

  run("/sbin/mount", (char*[]){
    "/sbin/mount",
    "-uw",
    "/",
    NULL});

  return 0;
}

int activate_tweaks() {
    if (access("/private/etc/rc.d/substitute-launcher", F_OK) != -1) {
      run("/private/etc/rc.d/substitute-launcher", (char*[]){
        "/private/etc/rc.d/substitute-launcher",
        NULL});
    }
    return 0;
}

int respring() {
  run("/jbin/binpack/usr/bin/killall", (char*[]){
      "/jbin/binpack/usr/bin/killall",
      "backboardd",
      NULL});
  return 0;
}

int doAll() {
  uicache_all();
  loadDaemons();
  activate_tweaks();
  respring();
  return 0;
}


int main(int argc, char **argv){
    setvbuf(stdout, NULL, _IONBF, 0);

    if (argc >= 1) {
      if (argv[1] != NULL) {
        if (strcmp(argv[1], "-k") == 0) { // generate keybags, currently not working
          int fd_console = open("/dev/console",O_RDWR,0);
          dprintf(fd_console, "\n\n\n\n\n\n\n\n");
          dprintf(fd_console, "*******************************");
          dprintf(fd_console, "Generating keybags...\n");
          dprintf(fd_console, "*******************************");
          dprintf(fd_console, "\n\n\n\n\n\n\n\n");
          close(fd_console);
          generateKeybag();

          return 0;
        }
      }
    }

    int fd_console = open("/dev/console",O_RDWR,0);
    dprintf(fd_console, "\n\n\n\n\n\n\n\n");
    dprintf(fd_console, "*******************************");
    dprintf(fd_console, "Starting jbloader ..........\n");
    dprintf(fd_console, "*******************************");
    dprintf(fd_console, "\n\n\n\n\n\n\n\n");
    close(fd_console);

    remount_rootRW();
    uicache_loader("/Applications/dualra1n-loader.app");
    enable_ssh(NULL);

    showSimpleMessage(@"HI!", @"i am jbinit, and if you see this it means that i am working well.\n\n\n HAVE FUN!");
    if (access("/.procursus_strapped", F_OK) != -1)
    {
      doAll();
    }

    printf("DONE.\n");
    return 0;
}