#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static void send_response(const char *json_body) {
	size_t len = strlen(json_body);
	printf("Content-Length: %zu\r\n\r\n%s", len, json_body);
	fflush(stdout);
}

static void handle_initialize(int id) {
	char buf[1024];
	snprintf(buf, sizeof(buf),
		"{\"jsonrpc\":\"2.0\",\"id\":%d,\"result\":{\"capabilities\":{"
		"\"textDocumentSync\":1,"
		"\"hoverProvider\":true,"
		"\"codeLensProvider\":{\"resolveProvider\":false}"
		"}}}", id);
	send_response(buf);
}

static void handle_hover(int id, const char *word) {
	char buf[1024];
	snprintf(buf, sizeof(buf),
		"{\"jsonrpc\":\"2.0\",\"id\":%d,\"result\":{\"contents\":{"
		"\"kind\":\"markdown\",\"value\":\"**sh2elf Built-in**: `%s`\\n\\nCompiles directly into native x86_64 Linux kernel system calls without process overhead.\""
		"}}}", id, word ? word : "builtin");
	send_response(buf);
}

int main(void) {
	char header[256];
	while(fgets(header, sizeof(header), stdin)) {
		if(strncmp(header, "Content-Length:", 15) == 0) {
			int len = atoi(header + 15);
			while(fgets(header, sizeof(header), stdin)) {
				if(strcmp(header, "\r\n") == 0 || strcmp(header, "\n") == 0) break;
			}
			char *body = (char*)malloc(len + 1);
			if(!body) break;
			size_t read_bytes = fread(body, 1, len, stdin);
			body[read_bytes] = '\0';

			if(strstr(body, "\"method\":\"initialize\"")) {
				handle_initialize(1);
			} else if(strstr(body, "\"method\":\"textDocument/hover\"")) {
				handle_hover(2, "cmd");
			} else if(strstr(body, "\"method\":\"shutdown\"")) {
				send_response("{\"jsonrpc\":\"2.0\",\"id\":3,\"result\":null}");
				free(body);
				break;
			}
			free(body);
		}
	}
	return 0;
}
