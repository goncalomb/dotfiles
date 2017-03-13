#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <dlfcn.h>
#include <pwd.h>

extern char *program_invocation_name;
extern char *program_invocation_short_name;

typedef struct passwd *(*pwd_getpwnam) (const char *name);
typedef struct passwd *(*pwd_getpwuid) (__uid_t uid);

void spoof_pw(struct passwd *pw, const char *fn) {
	char *home = getenv("HOME");
	char *debug = getenv("HOME_SPOOFING_DEBUG");
	if (home && home[0] != '\0' && pw->pw_uid == geteuid()) {
		if (debug && debug[0] != '\0') {
			printf("[home-spoofing] Intercepting '%s' call, spoofing home:\n", fn);
			printf("[home-spoofing] '%s' -> '%s'\n", pw->pw_dir, home);
		}
		pw->pw_dir = home;
	}
}

struct passwd *getpwnam(const char *name) {
	pwd_getpwnam getpwnam_orig = dlsym(RTLD_NEXT, "getpwnam");
	struct passwd *pw = getpwnam_orig(name);
	if (pw) {
		spoof_pw(pw, "getpwnam");
	}
	return pw;
}

struct passwd *getpwuid(__uid_t uid) {
	pwd_getpwuid getpwuid_orig = dlsym(RTLD_NEXT, "getpwuid");
	struct passwd *pw = getpwuid_orig(uid);
	if (pw) {
		spoof_pw(pw, "getpwuid");
	}
	return pw;
}
