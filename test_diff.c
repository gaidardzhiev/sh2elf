#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h>

static int run_cmd(const char *cmd) {
	int status = system(cmd);
	if(WIFEXITED(status)) return WEXITSTATUS(status);
	return -1;
}

static char *read_file(const char *path) {
	FILE *f = fopen(path, "rb");
	if(!f) return strdup("");
	fseek(f, 0, SEEK_END);
	long len = ftell(f);
	fseek(f, 0, SEEK_SET);
	char *buf = (char*)malloc(len + 1);
	if(!buf) { fclose(f); return strdup(""); }
	size_t r = fread(buf, 1, len, f);
	buf[r] = '\0';
	fclose(f);
	return buf;
}

int main(void) {
	DIR *dir = opendir("scripts");
	if(!dir) {
		perror("opendir scripts");
		return 1;
	}
	struct dirent *entry;
	int total = 0, passed = 0, failed = 0;
	while((entry = readdir(dir)) != NULL) {
		if(strncmp(entry->d_name, "test_", 5) == 0 && strstr(entry->d_name, ".sh") != NULL) {
			total++;
			char script_path[512], elf_path[512], cmd_bash[1024], cmd_sh2elf[1024], cmd_elf[1024];
			snprintf(script_path, sizeof(script_path), "scripts/%s", entry->d_name);
			snprintf(elf_path, sizeof(elf_path), "/tmp/%s.elf", entry->d_name);
			snprintf(cmd_bash, sizeof(cmd_bash), "bash %s > /tmp/ref.out 2>&1", script_path);
			snprintf(cmd_sh2elf, sizeof(cmd_sh2elf), "./sh2elf %s -o %s > /dev/null 2>&1", script_path, elf_path);
			snprintf(cmd_elf, sizeof(cmd_elf), "%s > /tmp/elf.out 2>&1", elf_path);

			int ref_code = run_cmd(cmd_bash);
			int compile_code = run_cmd(cmd_sh2elf);
			if(compile_code != 0) {
				printf("Test %-30s [COMPILE FAIL]\n", entry->d_name);
				failed++;
				continue;
			}
			int elf_code = run_cmd(cmd_elf);

			char *ref_out = read_file("/tmp/ref.out");
			char *elf_out = read_file("/tmp/elf.out");

			int match = (ref_code == elf_code) && (strcmp(ref_out, elf_out) == 0);
			if(match) {
				printf("Test %-30s [PASS]\n", entry->d_name);
				passed++;
			} else {
				printf("Test %-30s [DIFF FAIL] (ref_exit=%d elf_exit=%d)\n", entry->d_name, ref_code, elf_code);
				failed++;
			}
			free(ref_out);
			free(elf_out);
			unlink(elf_path);
		}
	}
	closedir(dir);
	unlink("/tmp/ref.out");
	unlink("/tmp/elf.out");
	printf("\nDifferential Harness Results: %d Passed, %d Failed (Total %d)\n", passed, failed, total);
	return failed ? 1 : 0;
}
