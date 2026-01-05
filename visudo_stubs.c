/*
 * Stub variables for visudo - these are defined in sudo.c but 
 * visudo doesn't actually use them. We provide dummy definitions
 * to satisfy the linker.
 */

#include "config.h"
#include <sys/types.h>

/* Global variables from sudo.c that visudo doesn't use */
char *user = "";
char *cmnd = "";
char *host = "";
char *cwd = "";
char **Argv;
int Argc = 0;
uid_t uid = 0;
struct interface *interfaces;
int num_interfaces = 0;
char *epasswd = "";

/* Stub functions */
void be_root() {}
void be_user() {}
void be_full_user() {}
