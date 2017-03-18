#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <dlfcn.h>
#include <pwd.h>

extern char *program_invocation_name;

typedef struct passwd *(*pwd_getpwent) ();
typedef struct passwd *(*pwd_getpwnam) (const char *name);
typedef struct passwd *(*pwd_getpwuid) (__uid_t uid);

void spoof_pw(struct passwd *pw, const char *fn) {
	if (!pw) return;
	char *home = getenv("HOME");
	char *debug = getenv("HOME_SPOOFING_DEBUG");
	if (home && home[0] != '\0' && pw->pw_uid == getuid()) {
		if (debug && debug[0] != '\0') {
			printf("[home-spoofing|%s] Intercepting '%s' call, spoofing home:\n", program_invocation_name, fn);
			printf("[home-spoofing|%s] '%s' -> '%s'\n", program_invocation_name, pw->pw_dir, home);
		}
		pw->pw_dir = home;
	}
}

#define INTERCEPT_PW_FUNC(fn, param_type, param) \
	struct passwd *fn(param_type param) { \
		pwd_##fn orig = dlsym(RTLD_NEXT, #fn); \
		struct passwd *pw = orig(param); \
		spoof_pw(pw, #fn); \
		return pw; \
	}

INTERCEPT_PW_FUNC(getpwent,,);
INTERCEPT_PW_FUNC(getpwnam, const char *, name);
INTERCEPT_PW_FUNC(getpwuid, __uid_t, uid);
