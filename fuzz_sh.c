#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/wait.h>

static int rand_int(int min, int max) {
	return min + rand() % (max - min + 1);
}

static void gen_random_script(FILE *f, int depth) {
	static const char *cmds[] = {"echo", "true", "false", "pwd", "basename foo.txt", "dirname /tmp/bar.txt", "printf hello"};
	static const char *vars[] = {"VAR1", "VAR2", "FOO", "BAR"};
	static const char *vals[] = {"hello", "world", "123", "alpha"};

	int statements = rand_int(2, 6);
	for(int i = 0; i < statements; i++) {
		int type = rand_int(1, 5);
		if(type == 1) {
			const char *v = vars[rand_int(0, 3)];
			const char *val = vals[rand_int(0, 3)];
			fprintf(f, "%s=\"%s\"\n", v, val);
		} else if(type == 2) {
			const char *c = cmds[rand_int(0, 6)];
			fprintf(f, "%s\n", c);
		} else if(type == 3) {
			const char *v = vars[rand_int(0, 3)];
			fprintf(f, "echo \"${%s}\"\n", v);
		} else if(type == 4) {
			fprintf(f, "if true; then\n");
			const char *c = cmds[rand_int(0, 6)];
			fprintf(f, "  %s\n", c);
			fprintf(f, "fi\n");
		} else if(type == 5) {
			fprintf(f, "for i in 1 2; do\n");
			fprintf(f, "  echo \"loop_$i\"\n");
			fprintf(f, "done\n");
		}
	}
}

int main(int argc, char **argv) {
	int iterations = 20;
	if(argc > 1) iterations = atoi(argv[1]);
	srand((unsigned int)time(NULL));

	int passed = 0, failed = 0;
	for(int i = 0; i < iterations; i++) {
		FILE *f = fopen("/tmp/fuzz_test.sh", "w");
		if(!f) continue;
		gen_random_script(f, 0);
		fclose(f);

		system("./sh2elf /tmp/fuzz_test.sh -o /tmp/fuzz_elf > /dev/null 2>&1");
		int ref_res = system("bash /tmp/fuzz_test.sh > /tmp/fuzz_ref.out 2>&1");
		int elf_res = system("/tmp/fuzz_elf > /tmp/fuzz_elf.out 2>&1");

		FILE *fr = fopen("/tmp/fuzz_ref.out", "rb");
		FILE *fe = fopen("/tmp/fuzz_elf.out", "rb");
		int match = (ref_res == elf_res);
		if(fr && fe) {
			char b1[256] = {0}, b2[256] = {0};
			size_t r1 = fread(b1, 1, sizeof(b1), fr);
			size_t r2 = fread(b2, 1, sizeof(b2), fe);
			if(r1 != r2 || memcmp(b1, b2, r1) != 0) match = 0;
		}
		if(fr) fclose(fr);
		if(fe) fclose(fe);

		if(match) {
			passed++;
		} else {
			failed++;
			if(failed == 1) {
				printf("=== FIRST FUZZER FAILURE ===\n");
				printf("--- Script ---\n");
				system("cat /tmp/fuzz_test.sh");
				printf("--- Bash Output (code %d) ---\n", ref_res);
				system("cat /tmp/fuzz_ref.out");
				printf("--- ELF Output (code %d) ---\n", elf_res);
				system("cat /tmp/fuzz_elf.out");
				printf("=============================\n");
			}
		}
		unlink("/tmp/fuzz_test.sh");
		unlink("/tmp/fuzz_elf");
		unlink("/tmp/fuzz_ref.out");
		unlink("/tmp/fuzz_elf.out");
	}
	printf("Fuzzer Results (%d iterations): %d Passed, %d Failed\n", iterations, passed, failed);
	return failed ? 1 : 0;
}
