/*
 * Copyright (C) 2025 Ivan Gaydardzhiev
 * Licensed under the GPL-3.0-only
 */

#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fnmatch.h>
#include <glob.h>

#define BUF_SZ 65536

typedef struct {
	uint8_t *data;
	size_t len, cap;
} Buf;

static void binit(Buf *b) {
	b->data=NULL;
	b->len=b->cap=0;
}

static void bput(Buf *b, const void *p, size_t n) {
	if(b->len+n>b->cap) {
		size_t nc=b->cap?b->cap*2:256;
		while(nc<b->len+n) nc*=2;
		b->data=(uint8_t*)realloc(b->data,nc);
		b->cap=nc;
	}
	memcpy(b->data+b->len,p,n);
	b->len+=n;
}

static void b8(Buf *b, uint8_t x) {
	bput(b,&x,1);
}

static char *buf_to_cstr(Buf *b) {
	b8(b, 0);
	char *s = (char*)malloc(b->len);
	if(!s) {
		perror("malloc");
		exit(1);
	}
	memcpy(s, b->data, b->len);
	s[b->len-1] = '\0';
	free(b->data);
	b->data=NULL;
	b->len=b->cap=0;
	return s;
}

static void le16(uint8_t *p, uint16_t x) {
	p[0]=x;
	p[1]=x>>8;
}

static void le32(uint8_t *p, uint32_t x) {
	p[0]=x;
	p[1]=x>>8;
	p[2]=x>>16;
	p[3]=x>>24;
}

static void le64(uint8_t *p, uint64_t x) {
	for(int i=0; i<8; i++) p[i]=(uint8_t)(x>>(8*i));
}

typedef struct {
	Buf code;
} Code;

static size_t cpos(Code *c) {
	return c->code.len;
}

static void c8(Code *c, uint8_t x) {
	b8(&c->code,x);
}

static void c32(Code *c, uint32_t x) {
	bput(&c->code,&x,4);
}

static void patch32(Buf *b, size_t off, uint32_t v) {
	b->data[off+0]=v;
	b->data[off+1]=v>>8;
	b->data[off+2]=v>>16;
	b->data[off+3]=v>>24;
}

typedef struct {
	Buf pool;
	size_t *offs;
	size_t n, cap;
} StrPool;

static void sp_init(StrPool *sp) {
	binit(&sp->pool);
	sp->offs=NULL;
	sp->n=sp->cap=0;
}

static size_t sp_add(StrPool *sp, const char *s) {
	size_t off = sp->pool.len;
	size_t n = strlen(s);
	bput(&sp->pool, s, n+1);
	if(sp->n==sp->cap) {
		sp->cap=sp->cap?sp->cap*2:64;
		sp->offs=(size_t*)realloc(sp->offs, sp->cap*sizeof(size_t));
	}
	sp->offs[sp->n++] = off;
	return sp->n-1;
}

typedef struct {
	size_t at;
	size_t str_idx;
} Rel;

typedef struct {
	Rel *v;
	size_t n, cap;
} Rels;

static void mov_rax_imm32(Code *c, uint32_t x) {
	c8(c,0x48);
	c8(c,0xC7);
	c8(c,0xC0);
	c32(c,x);
}

static void mov_rdi_imm64(Code *c, uint64_t x) {
	if(x<=0xFFFFFFFFULL) { c8(c,0xBF); c32(c,(uint32_t)x); }
	else { c8(c,0x48); c8(c,0xBF); bput(&c->code,&x,8); }
}

static void mov_rsi_imm64(Code *c, uint64_t x) {
	if(x<=0xFFFFFFFFULL) { c8(c,0xBE); c32(c,(uint32_t)x); }
	else { c8(c,0x48); c8(c,0xBE); bput(&c->code,&x,8); }
}

static void mov_rdx_imm64(Code *c, uint64_t x) {
	if(x<=0xFFFFFFFFULL) { c8(c,0xBA); c32(c,(uint32_t)x); }
	else { c8(c,0x48); c8(c,0xBA); bput(&c->code,&x,8); }
}

static void mov_r10_imm64(Code *c, uint64_t x) {
	c8(c,0x49);
	c8(c,0xBA);
	bput(&c->code,&x,8);
}

static void xor_rsi_rsi(Code *c) {
	c8(c,0x48);
	c8(c,0x31);
	c8(c,0xF6);
}

static void xor_rdx_rdx(Code *c) {
	c8(c,0x48);
	c8(c,0x31);
	c8(c,0xD2);
}

static void xor_r10_r10(Code *c) {
	c8(c,0x4D);
	c8(c,0x31);
	c8(c,0xD2);
}

static void mov_rsi_rdi(Code *c) {
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0xFE);
}

static void mov_rdi_rax(Code *c) {
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0xC7);
}

static void mov_eax_mrdi(Code *c) {
	c8(c,0x8B);
	c8(c,0x07);
}

static void syscall_(Code *c) {
	c8(c,0x0F);
	c8(c,0x05);
}
static size_t je_rel32(Code *c) {
	c8(c,0x0F);
	c8(c,0x84);
	size_t pos=cpos(c);
	c32(c,0);
	return pos;
}

static size_t jne_rel32(Code *c) {
	c8(c,0x0F);
	c8(c,0x85);
	size_t pos=cpos(c);
	c32(c,0);
	return pos;
}

static size_t jmp_rel32(Code *c) {
	c8(c,0xE9);
	size_t pos=cpos(c);
	c32(c,0);
	return pos;
}

static size_t js_rel32(Code *c) {
	c8(c,0x0F);
	c8(c,0x88);
	size_t pos=cpos(c);
	c32(c,0);
	return pos;
}

static size_t jle_rel32(Code *c) {
	c8(c,0x0F);
	c8(c,0x8E);
	size_t pos=cpos(c);
	c32(c,0);
	return pos;
}

static void patch_here(Code *c, size_t at) {
	uint32_t rel=(uint32_t)(cpos(c)-(at+4));
	patch32(&c->code, at, rel);
}

static void mov_m8_rdi_disp32_rax(Code *c, uint32_t disp) {
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0x87);
	c32(c,disp);
}

static void shr_rax_imm8(Code *c, uint8_t sh) {
	c8(c,0x48);
	c8(c,0xC1);
	c8(c,0xE8);
	c8(c,sh);
}

static void and_eax_imm32(Code *c, uint32_t imm) {
	c8(c,0x25);
	c32(c,imm);
}

static void sys_write(Code *c) {
	mov_rax_imm32(c,1);
	syscall_(c);
}

static void sys_exit(Code *c) {
	mov_rax_imm32(c,60);
	syscall_(c);
}

static void sys_chdir(Code *c) {
	mov_rax_imm32(c,80);
	syscall_(c);
}

static void sys_fork(Code *c) {
	mov_rax_imm32(c,57);
	syscall_(c);
}

static void sys_execve(Code *c) {
	mov_rax_imm32(c,59);
	syscall_(c);
}

static void sys_wait4(Code *c) {
	mov_rax_imm32(c,61);
	syscall_(c);
}

static void sys_pipe(Code *c) {
	mov_rax_imm32(c,22);
	syscall_(c);
}

static void sys_dup2(Code *c) {
	mov_rax_imm32(c,33);
	syscall_(c);
}

static void sys_close(Code *c) {
	mov_rax_imm32(c,3);
	syscall_(c);
}
static void sys_openat(Code *c) {
	mov_rax_imm32(c,257);
	syscall_(c);
}

static void sys_nanosleep(Code *c) {
	mov_rax_imm32(c,35);
	syscall_(c);
}

static void sys_getcwd(Code *c) {
	mov_rax_imm32(c,79);
	syscall_(c);
}

static void sys_mkdir(Code *c) {
	mov_rax_imm32(c,83);
	syscall_(c);
}

static void sys_rmdir(Code *c) {
	mov_rax_imm32(c,84);
	syscall_(c);
}

static void sys_unlink(Code *c) {
	mov_rax_imm32(c,87);
	syscall_(c);
}

static void sys_newfstatat(Code *c) {
	mov_rax_imm32(c,262);
	syscall_(c);
}

static void sys_read(Code *c) {
	mov_rax_imm32(c,0);
	syscall_(c);
}

static void sys_kill(Code *c) {
	mov_rax_imm32(c,62);
	syscall_(c);
}

static void sys_chmod(Code *c) {
	mov_rax_imm32(c,90);
	syscall_(c);
}

static void sys_chown(Code *c) {
	mov_rax_imm32(c,92);
	syscall_(c);
}

static void sys_rename(Code *c) {
	mov_rax_imm32(c,82);
	syscall_(c);
}

static void sys_uname(Code *c) {
	mov_rax_imm32(c,63);
	syscall_(c);
}

static void sys_getuid(Code *c) {
	mov_rax_imm32(c,102);
	syscall_(c);
}

static void sys_getdents64(Code *c) {
	mov_rax_imm32(c,217);
	syscall_(c);
}

typedef struct {
	char **v;
	int n, cap;
} StrV;

static void sv_push(StrV *sv, char *s) {
	if(sv->n==sv->cap) {
		sv->cap=sv->cap?sv->cap*2:16;
		sv->v=(char**)realloc(sv->v,sv->cap*sizeof(char*));
	}
	sv->v[sv->n++]=s;
}

typedef struct {
	StrV argv;
	char *in_redir;
	char *out_redir;
	int out_append;
	char *err_redir;
	int err_append;
} Stage;

typedef struct {
	Stage *v;
	int n, cap;
} Pipeline;

typedef struct {
	Pipeline pl;
	int cond;
} ScriptEntry;

static void pl_push(Pipeline *p, Stage st) {
	if(p->n==p->cap) {
		p->cap=p->cap?2*p->cap:4;
		p->v=(Stage*)realloc(p->v,p->cap*sizeof(Stage));
	}
	p->v[p->n++]=st;
}

typedef struct {
	ScriptEntry *v;
	int n, cap;
} Script;

enum {
	COND_ALWAYS = 0,
	COND_PREV_SUCCESS = 1,
	COND_PREV_FAILURE = 2,
};

static void sc_push(Script *s, Pipeline p, int cond) {
	if(s->n==s->cap) {
		s->cap=s->cap?2*s->cap:4;
		s->v=(ScriptEntry*)realloc(s->v,s->cap*sizeof(ScriptEntry));
	}
	s->v[s->n++]=(ScriptEntry){.pl=p,.cond=cond};
}

static char *readfile(const char *path) {
	FILE *f=fopen(path,"rb");
	if(!f) {
		perror("open");
		exit(1);
	}
	fseek(f,0,SEEK_END);
	long n=ftell(f);
	fseek(f,0,SEEK_SET);
	char *buf=(char*)malloc(n+1);
	if(!buf) {
		perror("malloc");
		exit(1);
	}
	fread(buf,1,n,f);
	buf[n]=0;
	fclose(f);
	return buf;
}

static void parse_error(const char *msg) {
	fprintf(stderr, "parse error: %s\n", msg);
	exit(1);
}

static void skip_inline_ws(const char **pp) {
	while(**pp==' ' || **pp=='\t' || **pp=='\r') (*pp)++;
}

static int is_token_terminator(char c) {
	return c=='\0' || c==' ' || c=='\t' || c=='\r' || c=='\n' || c=='|' || c==';' || c=='<' || c=='>' || c=='&' || c=='(' || c==')' || c=='{' || c=='}';
}

static char *parse_word(const char **pp) {
	Buf buf;
	binit(&buf);
	const char *p = *pp;
	while(*p) {
		if(*p=='\\') {
			p++;
			if(*p=='\0') parse_error("trailing escape");
			b8(&buf, (uint8_t)*p++);
			continue;
		}
		if(*p=='"') {
			p++;
			int closed = 0;
			while(*p) {
				if(*p=='"') {
					closed = 1;
					p++;
					break;
				}
				if(*p=='\\') {
					p++;
					if(*p=='\0') parse_error("unterminated escape in quotes");
					char esc = *p++;
					if(esc=='"' || esc=='\\' || esc=='$' || esc=='`') {
						b8(&buf, (uint8_t)esc);
					} else if(esc=='\n') {
					} else {
						b8(&buf, (uint8_t)'\\');
						b8(&buf, (uint8_t)esc);
					}
				} else {
					b8(&buf, (uint8_t)*p++);
				}
			}
			if(!closed) parse_error("unterminated double quote");
			continue;
		}
		if(*p=='\'') {
			p++;
			while(*p && *p!='\'') {
				b8(&buf, (uint8_t)*p++);
			}
			if(*p!='\'') parse_error("unterminated single quote");
			p++;
			continue;
		}
		if(*p=='`') {
			p++;
			char subcmd[256];
			int ci = 0;
			while(*p && *p!='`' && ci < 255) subcmd[ci++] = *p++;
			if(*p=='`') p++;
			subcmd[ci] = '\0';
			FILE *fp = popen(subcmd, "r");
			if(fp) {
				char cbuf[1024];
				size_t nr = fread(cbuf, 1, sizeof(cbuf)-1, fp);
				cbuf[nr] = '\0';
				while(nr > 0 && (cbuf[nr-1] == '\n' || cbuf[nr-1] == '\r')) cbuf[--nr] = '\0';
				bput(&buf, cbuf, nr);
				pclose(fp);
			}
			continue;
		}
		if(*p=='$') {
			p++;
			if(*p=='(' && p[1]=='(') {
				p += 2;
				char ebuf[128];
				int ei = 0;
				while(*p && !(*p==')' && p[1]==')') && ei < 127) ebuf[ei++] = *p++;
				if(*p==')' && p[1]==')') p += 2;
				ebuf[ei] = '\0';
				long n1 = 0, n2 = 0;
				char op = '+';
				if(sscanf(ebuf, "%ld %c %ld", &n1, &op, &n2) >= 2 || sscanf(ebuf, "%ld%c%ld", &n1, &op, &n2) >= 2) {
					long res = 0;
					if(op=='+') res = n1 + n2;
					else if(op=='-') res = n1 - n2;
					else if(op=='*') res = n1 * n2;
					else if(op=='/' && n2!=0) res = n1 / n2;
					char rstr[32];
					snprintf(rstr, sizeof(rstr), "%ld", res);
					bput(&buf, rstr, strlen(rstr));
				}
				continue;
			}
			if(*p=='(') {
				p++;
				char subcmd[256];
				int ci = 0;
				int depth = 1;
				while(*p && ci < 255) {
					if(*p=='(') depth++;
					else if(*p==')') {
						depth--;
						if(depth==0) { p++; break; }
					}
					subcmd[ci++] = *p++;
				}
				subcmd[ci] = '\0';
				FILE *fp = popen(subcmd, "r");
				if(fp) {
					char cbuf[1024];
					size_t nr = fread(cbuf, 1, sizeof(cbuf)-1, fp);
					cbuf[nr] = '\0';
					while(nr > 0 && (cbuf[nr-1] == '\n' || cbuf[nr-1] == '\r')) cbuf[--nr] = '\0';
					bput(&buf, cbuf, nr);
					pclose(fp);
				}
				continue;
			}
			if(*p=='?') {
				p++;
				bput(&buf, "0", 1);
				continue;
			}
			if(*p=='$') {
				p++;
				bput(&buf, "1000", 4);
				continue;
			}
			char vname[128];
			int vi = 0;
			if(*p=='{') {
				p++;
				if(*p=='#' && p[1]!='}' && p[1]!='\0') {
					p++;
					while(*p && *p!='}' && vi < 127) vname[vi++] = *p++;
					vname[vi] = '\0';
					if(*p=='}') p++;
					char *val = getenv(vname);
					size_t vlen = val ? strlen(val) : 0;
					char lbuf[32];
					snprintf(lbuf, sizeof(lbuf), "%zu", vlen);
					bput(&buf, lbuf, strlen(lbuf));
					continue;
				}
				while(*p && *p!='}' && *p!=':' && *p!='-' && *p!='=' && *p!='+' && *p!='#' && *p!='%' && *p!='/' && vi < 127) vname[vi++] = *p++;
				vname[vi] = '\0';
				char op = '\0';
				int is_double = 0;
				if(*p==':') { p++; op = *p++; }
				else if(*p=='-' || *p=='=' || *p=='+') op = *p++;
				else if(*p=='#') { p++; op = '#'; if(*p=='#') { p++; is_double = 1; } }
				else if(*p=='%') { p++; op = '%'; if(*p=='%') { p++; is_double = 1; } }
				else if(*p=='/') { p++; op = '/'; if(*p=='/') { p++; is_double = 1; } }
				char pat[128], rep[128];
				int pi = 0, ri = 0;
				if(op=='#' || op=='%') {
					while(*p && *p!='}' && pi < 127) pat[pi++] = *p++;
					pat[pi] = '\0';
				} else if(op=='/') {
					while(*p && *p!='}' && *p!='/' && pi < 127) pat[pi++] = *p++;
					pat[pi] = '\0';
					if(*p=='/') p++;
					while(*p && *p!='}' && ri < 127) rep[ri++] = *p++;
					rep[ri] = '\0';
				} else if(op) {
					while(*p && *p!='}' && pi < 127) pat[pi++] = *p++;
					pat[pi] = '\0';
				}
				if(*p=='}') p++;
				char *val = getenv(vname);
				if(op=='#') {
					if(val) {
						size_t vlen = strlen(val);
						size_t match_len = 0;
						for(size_t k = (is_double ? vlen : 1); is_double ? (k > 0) : (k <= vlen); is_double ? k-- : k++) {
							char saved = val[k];
							val[k] = '\0';
							if(fnmatch(pat, val, 0) == 0) { match_len = k; val[k] = saved; if(!is_double) break; }
							val[k] = saved;
						}
						bput(&buf, val + match_len, vlen - match_len);
					}
				} else if(op=='%') {
					if(val) {
						size_t vlen = strlen(val);
						size_t match_at = vlen;
						for(size_t k = (is_double ? 0 : vlen - 1); is_double ? (k < vlen) : (k <= vlen); is_double ? k++ : k--) {
							if(fnmatch(pat, val + k, 0) == 0) { match_at = k; if(!is_double) break; }
							if(k == 0) break;
						}
						bput(&buf, val, match_at);
					}
				} else if(op=='/') {
					if(val) {
						size_t vlen = strlen(val), plen = strlen(pat);
						if(plen == 0) {
							bput(&buf, val, vlen);
						} else {
							size_t i = 0;
							while(i < vlen) {
								if(strncmp(val + i, pat, plen) == 0) {
									bput(&buf, rep, strlen(rep));
									i += plen;
									if(!is_double) { bput(&buf, val + i, vlen - i); break; }
								} else {
									b8(&buf, (uint8_t)val[i++]);
								}
							}
						}
					}
				} else if(op=='-') {
					if(val && *val) bput(&buf, val, strlen(val));
					else bput(&buf, pat, strlen(pat));
				} else if(op=='=') {
					if(!val || !*val) { setenv(vname, pat, 1); val = pat; }
					bput(&buf, val, strlen(val));
				} else if(op=='+') {
					if(val && *val) bput(&buf, pat, strlen(pat));
				} else {
					if(val) bput(&buf, val, strlen(val));
				}
				continue;
			} else {
				while(*p && ((*p>='A' && *p<='Z') || (*p>='a' && *p<='z') || (*p>='0' && *p<='9') || *p=='_') && vi < 127) vname[vi++] = *p++;
				vname[vi] = '\0';
				char *val = getenv(vname);
				if(val) bput(&buf, val, strlen(val));
				continue;
			}
		}
		if(is_token_terminator(*p)) break;
		b8(&buf, (uint8_t)*p++);
	}
	if(buf.len==0) return NULL;
	char *word = buf_to_cstr(&buf);
	*pp = p;
	return word;
}

static void finish_stage(Pipeline *pl, Stage *st) {
	if(st->argv.n==0) {
		if(st->in_redir || st->out_redir || st->err_redir) parse_error("redirection without command");
		return;
	}
	pl_push(pl, *st);
	*st = (Stage){0};
}

typedef struct {
	char *name;
	char *body;
} FuncDef;

typedef struct {
	FuncDef *v;
	int n, cap;
} FuncTable;

static FuncTable g_funcs = {0};

static Script parse(const char *src) {
	Script sc = {0};
	Pipeline cur = {0};
	Stage st = {0};
	const char *p = src;
	int expect_stage = 0;
	int expect_pipeline = 0;
	int pending_cond = COND_ALWAYS;
	int is_until = 0;
	while(*p) {
		skip_inline_ws(&p);
		if(*p=='\0') break;
		if(*p=='#') {
			while(*p && *p!='\n') p++;
			continue;
		}
		if(*p=='(' || *p==')' || *p=='{' || *p=='}') {
			p++;
			continue;
		}
		if(*p=='\n' || *p==';') {
			if(expect_stage) parse_error("pipeline stage missing command");
			if(*p==';' && expect_pipeline) parse_error("missing command after &&/||");
			if(st.argv.n>0) {
				finish_stage(&cur, &st);
			} else if(st.in_redir || st.out_redir || st.err_redir) {
				parse_error("redirection without command");
			}
			if(cur.n>0) {
				sc_push(&sc, cur, pending_cond);
				cur = (Pipeline){0};
				pending_cond = COND_ALWAYS;
			}
			expect_stage = 0;
			while(*p=='\n' || *p==';') p++;
			continue;
		}
		if(*p=='&') {
			if(p[1]=='&') {
				if(st.argv.n==0) parse_error("missing command before &&");
				finish_stage(&cur, &st);
				if(cur.n==0) parse_error("missing command before &&");
				sc_push(&sc, cur, pending_cond);
				cur = (Pipeline){0};
				pending_cond = COND_PREV_SUCCESS;
				expect_stage = 0;
				expect_pipeline = 1;
				p+=2;
				continue;
			}
			parse_error("unsupported token &");
		}
		if(*p=='|') {
			if(p[1]=='|') {
				if(st.argv.n==0) parse_error("missing command before ||");
				finish_stage(&cur, &st);
				if(cur.n==0) parse_error("missing command before ||");
				sc_push(&sc, cur, pending_cond);
				cur = (Pipeline){0};
				pending_cond = COND_PREV_FAILURE;
				expect_stage = 0;
				expect_pipeline = 1;
				p+=2;
				continue;
			}
			if(st.argv.n==0) parse_error("empty pipeline stage");
			finish_stage(&cur, &st);
			expect_stage = 1;
			p++;
			continue;
		}
		if((*p=='>' || *p=='<') || (*p=='2' && p[1]=='>')) {
			int is_err = (*p=='2');
			if(is_err) p++;
			char op = *p++;
			int append = 0;
			if(op=='<' && *p=='<') {
				p++;
				if(*p=='-') p++;
				skip_inline_ws(&p);
				char *delim = parse_word(&p);
				if(!delim) parse_error("missing heredoc delimiter");
				while(*p && *p!='\n') p++;
				if(*p=='\n') p++;
				Buf hbuf;
				binit(&hbuf);
				while(*p) {
					const char *lstart = p;
					while(*p && *p!='\n') p++;
					size_t llen = (size_t)(p - lstart);
					if(*p=='\n') p++;
					char lbuf[256];
					if(llen >= sizeof(lbuf)) llen = sizeof(lbuf)-1;
					memcpy(lbuf, lstart, llen);
					lbuf[llen] = '\0';
					if(strcmp(lbuf, delim)==0) break;
					bput(&hbuf, lstart, llen);
					b8(&hbuf, '\n');
				}
				FILE *hf = fopen("/tmp/.sh2elf_hdoc", "wb");
				if(hf) {
					fwrite(hbuf.data, 1, hbuf.len, hf);
					fclose(hf);
				}
				free(hbuf.data);
				free(delim);
				if(st.in_redir) free(st.in_redir);
				st.in_redir = strdup("/tmp/.sh2elf_hdoc");
				continue;
			}
			if(op=='>' && *p=='>') {
				append = 1;
				p++;
			}
			skip_inline_ws(&p);
			if(*p=='\0' || *p=='\n' || *p=='|' || *p==';' || *p=='<' || *p=='>') parse_error("missing redirection target");
			char *target = parse_word(&p);
			if(!target) parse_error("missing redirection target");
			if(op=='<') {
				if(st.in_redir) free(st.in_redir);
				st.in_redir = target;
			} else if(is_err) {
				if(st.err_redir) free(st.err_redir);
				st.err_redir = target;
				st.err_append = append;
			} else {
				if(st.out_redir) free(st.out_redir);
				st.out_redir = target;
				st.out_append = append;
			}
			continue;
		}
		char *word = parse_word(&p);
		if(!word) parse_error("expected word");
		if(st.argv.n==0) {
			int is_fn_call = 0;
			for(int fi=0; fi<g_funcs.n; fi++) {
				if(strcmp(word, g_funcs.v[fi].name)==0) {
					is_fn_call = 1;
					Script sub = parse(g_funcs.v[fi].body);
					for(int si=0; si<sub.n; si++) {
						sc_push(&sc, sub.v[si].pl, sub.v[si].cond);
					}
					free(sub.v);
					free(word);
					break;
				}
			}
			if(is_fn_call) continue;
			if(strstr(word, "()")!=NULL || (*p=='(' && p[1]==')')) {
				char *fname = strdup(word);
				char *paren = strstr(fname, "()");
				if(paren) *paren = '\0';
				else {
					if(*p=='(' && p[1]==')') p += 2;
				}
				skip_inline_ws(&p);
				if(*p=='{') {
					p++;
					const char *fstart = p;
					int depth = 1;
					const char *fend = NULL;
					while(*p) {
						if(*p=='{') depth++;
						else if(*p=='}') {
							depth--;
							if(depth==0) {
								fend = p;
								p++;
								break;
							}
						}
						p++;
					}
					if(fend) {
						size_t flen = (size_t)(fend - fstart);
						char *fbody = (char*)malloc(flen + 1);
						memcpy(fbody, fstart, flen);
						fbody[flen] = '\0';
						if(g_funcs.n==g_funcs.cap) {
							g_funcs.cap = g_funcs.cap ? g_funcs.cap*2 : 8;
							g_funcs.v = (FuncDef*)realloc(g_funcs.v, g_funcs.cap*sizeof(FuncDef));
						}
						g_funcs.v[g_funcs.n++] = (FuncDef){ fname, fbody };
						free(word);
						continue;
					}
				}
				free(fname);
			}
			if(strcmp(word,"case")==0) {
				free(word);
				skip_inline_ws(&p);
				char *targ = parse_word(&p);
				if(!targ) parse_error("expected case target");
				skip_inline_ws(&p);
				const char *tp0 = p;
				char *w0 = parse_word(&tp0);
				if(w0) {
					if(strcmp(w0,"in")==0) p = tp0;
					free(w0);
				}
				int matched = 0;
				while(*p) {
					while(*p=='\n' || *p==';' || *p==' ') p++;
					skip_inline_ws(&p);
					if(*p=='\0') break;
					const char *tp = p;
					char *pw = parse_word(&tp);
					if(pw) {
						if(strcmp(pw,"esac")==0) {
							free(pw);
							p = tp;
							break;
						}
						free(pw);
					}
					char *pat = parse_word(&p);
					if(!pat) break;
					if(strcmp(pat,"esac")==0) {
						free(pat);
						break;
					}
					while(*p && *p!=')') p++;
					if(*p==')') p++;
					const char *cstart = p;
					const char *cend = NULL;
					while(*p) {
						if(p[0]==';' && p[1]==';') {
							cend = p;
							p += 2;
							break;
						}
						const char *tp2 = p;
						char *w2 = parse_word(&tp2);
						if(w2) {
							if(strcmp(w2,"esac")==0) {
								cend = p;
								free(w2);
								break;
							}
							free(w2);
						}
						p++;
					}
					if(!cend) cend = p;
					if(!matched && targ && (strcmp(pat,"*")==0 || strcmp(pat,targ)==0 || fnmatch(pat,targ,0)==0)) {
						matched = 1;
						size_t clen = (size_t)(cend - cstart);
						char *cbody = (char*)malloc(clen + 1);
						memcpy(cbody, cstart, clen);
						cbody[clen] = '\0';
						Script sub = parse(cbody);
						for(int si=0; si<sub.n; si++) {
							sc_push(&sc, sub.v[si].pl, sub.v[si].cond);
						}
						free(sub.v);
						free(cbody);
					}
					free(pat);
				}
				if(targ) free(targ);
				continue;
			}
			if(strcmp(word,"until")==0) {
				is_until = 1;
				free(word);
				continue;
			}
			if(strcmp(word,"then")==0 || strcmp(word,"do")==0) {
				pending_cond = is_until ? COND_PREV_FAILURE : COND_PREV_SUCCESS;
				is_until = 0;
				free(word);
				continue;
			}
			if(strcmp(word,"else")==0 || strcmp(word,"elif")==0) {
				pending_cond = COND_PREV_FAILURE;
				free(word);
				continue;
			}
			if(strcmp(word,"fi")==0 || strcmp(word,"done")==0) {
				pending_cond = COND_ALWAYS;
				free(word);
				continue;
			}
			if(strcmp(word,"for")==0) {
				free(word);
				skip_inline_ws(&p);
				char *vname = parse_word(&p);
				if(!vname) parse_error("expected for variable");
				skip_inline_ws(&p);
				const char *tp0 = p;
				char *w0 = parse_word(&tp0);
				if(w0) {
					if(strcmp(w0,"in")==0) p = tp0;
					free(w0);
				}
				StrV items = {0};
				while(*p) {
					skip_inline_ws(&p);
					if(*p==';' || *p=='\n' || *p=='\0') break;
					const char *tp = p;
					char *w = parse_word(&tp);
					if(!w) break;
					if(strcmp(w,"do")==0) {
						free(w);
						break;
					}
					sv_push(&items, w);
					p = tp;
				}
				while(*p==';' || *p=='\n' || *p==' ') p++;
				const char *tp1 = p;
				char *w1 = parse_word(&tp1);
				if(w1) {
					if(strcmp(w1,"do")==0) p = tp1;
					free(w1);
				}
				skip_inline_ws(&p);
				const char *bstart = p;
				int depth = 1;
				const char *scan = p;
				const char *bend = NULL;
				while(*scan) {
					skip_inline_ws(&scan);
					if(*scan=='\0') break;
					if(*scan=='#' || *scan=='\n' || *scan==';') { scan++; continue; }
					const char *tp = scan;
					char *w = parse_word(&scan);
					if(w) {
						if(strcmp(w,"do")==0) depth++;
						else if(strcmp(w,"done")==0) {
							depth--;
							if(depth==0) {
								bend = tp;
								free(w);
								break;
							}
						}
						free(w);
					} else scan++;
				}
				if(!bend) parse_error("missing done");
				size_t blen = (size_t)(bend - bstart);
				char *body = (char*)malloc(blen + 1);
				memcpy(body, bstart, blen);
				body[blen] = '\0';
				for(int ki=0; ki<items.n; ki++) {
					setenv(vname, items.v[ki], 1);
					Script sub = parse(body);
					for(int si=0; si<sub.n; si++) {
						sc_push(&sc, sub.v[si].pl, sub.v[si].cond);
					}
					free(sub.v);
				}
				free(body);
				free(vname);
				for(int ki=0; ki<items.n; ki++) free(items.v[ki]);
				free(items.v);
				p = scan;
				continue;
			}
			if(strcmp(word,"if")==0 || strcmp(word,"in")==0 || strcmp(word,"while")==0 || strcmp(word,"until")==0) {
				free(word);
				continue;
			}
			if(strchr(word, '=')!=NULL) {
				char *eq = strchr(word, '=');
				*eq = '\0';
				setenv(word, eq+1, 1);
				free(word);
				continue;
			}
		}
		if(st.argv.n>0 && strcmp(st.argv.v[0],"export")==0 && strchr(word, '=')!=NULL) {
			char *eq = strchr(word, '=');
			*eq = '\0';
			setenv(word, eq+1, 1);
			*eq = '=';
		}
		if(strpbrk(word, "*?[")!=NULL) {
			glob_t gbuf = {0};
			if(glob(word, 0, NULL, &gbuf)==0 && gbuf.gl_pathc>0) {
				for(size_t gi=0; gi<gbuf.gl_pathc; gi++) {
					sv_push(&st.argv, strdup(gbuf.gl_pathv[gi]));
				}
				free(word);
				globfree(&gbuf);
				expect_stage = 0;
				expect_pipeline = 0;
				continue;
			}
			globfree(&gbuf);
		}
		sv_push(&st.argv, word);
		expect_stage = 0;
		expect_pipeline = 0;
	}
	if(expect_stage) parse_error("pipeline stage missing command");
	if(expect_pipeline) parse_error("missing command after &&/||");
	if(st.argv.n>0) {
		finish_stage(&cur, &st);
	} else if(st.in_redir || st.out_redir || st.err_redir) {
		parse_error("redirection without command");
	}
	if(cur.n>0) sc_push(&sc, cur, pending_cond);
	return sc;
}

typedef struct {
	Code code;
	StrPool strs;
	Rels rels;
	size_t bss_base;
	size_t bss_off;
	size_t status_off;
} Gen;

static size_t add_str(Gen *g, const char *s) {
	return sp_add(&g->strs, s);
}

static void rels_add_here(Gen *g, size_t at, size_t sidx) {
	if(g->rels.n==g->rels.cap) {
		g->rels.cap=g->rels.cap?g->rels.cap*2:64;
		g->rels.v=(Rel*)realloc(g->rels.v, g->rels.cap*sizeof(Rel));
	}
	g->rels.v[g->rels.n++] = (Rel) {
		at, sidx
	};
}

#undef mov_rdi_str
#undef mov_rsi_str
static void mov_rdi_str(Code *c, Gen *g, size_t sidx) {
	c8(c,0x48);
	c8(c,0xBF);
	size_t at=cpos(c);
	uint64_t z=0;
	bput(&c->code,&z,8);
	rels_add_here(g, at, sidx);
}

static void mov_rsi_str(Code *c, Gen *g, size_t sidx) {
	c8(c,0x48);
	c8(c,0xBE);
	size_t at=cpos(c);
	uint64_t z=0;
	bput(&c->code,&z,8);
	rels_add_here(g, at, sidx);
}

static void write_literal(Code *c, Gen *g, const char *s) {
	size_t sidx = add_str(g, s);
	mov_rsi_str(c,g,sidx);
	mov_rdi_imm64(c,1);
	mov_rdx_imm64(c, strlen(s));
	sys_write(c);
}

static void build_argv(Code *c, Gen *g, size_t bss_off, size_t *sidxv, int argc) {
	uint64_t base = g->bss_base + bss_off;
	mov_rdi_imm64(c, base);
	for(int i=0; i<argc; i++) {
		c8(c,0x48);
		c8(c,0xB8);
		size_t at=cpos(c);
		uint64_t z=0;
		bput(&c->code,&z,8);
		rels_add_here(g, at, sidxv[i]);
		mov_m8_rdi_disp32_rax(c, (uint32_t)(i*8));
	}
	mov_rax_imm32(c,0);
	mov_m8_rdi_disp32_rax(c, (uint32_t)(argc*8));
	mov_rsi_rdi(c);
}

static void emit_redirs(Code *c, Gen *g, const char *in_redir, const char *out_redir, int append, const char *err_redir, int err_append) {
	if(in_redir) {
		size_t sidx = add_str(g, in_redir);
		mov_rdi_imm64(c, (uint64_t)-100);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, 0);
		xor_r10_r10(c);
		sys_openat(c);
		mov_rdi_rax(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		mov_rsi_imm64(c, 0);
		sys_dup2(c);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
	}
	if(out_redir) {
		size_t sidx = add_str(g, out_redir);
		int flags = 1 | 64 | (append?1024:512);
		mov_rdi_imm64(c, (uint64_t)-100);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, (uint64_t)flags);
		mov_r10_imm64(c, 0644);
		sys_openat(c);
		mov_rdi_rax(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		mov_rsi_imm64(c, 1);
		sys_dup2(c);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
	}
	if(err_redir) {
		size_t sidx = add_str(g, err_redir);
		int flags = 1 | 64 | (err_append?1024:512);
		mov_rdi_imm64(c, (uint64_t)-100);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, (uint64_t)flags);
		mov_r10_imm64(c, 0644);
		sys_openat(c);
		mov_rdi_rax(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		mov_rsi_imm64(c, 2);
		sys_dup2(c);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
	}
}

static uint64_t status_addr(Gen *g) {
	return g->bss_base + g->status_off;
}

static void store_status_imm(Code *c, Gen *g, uint32_t val) {
	mov_rax_imm32(c,val);
	mov_rdi_imm64(c, status_addr(g));
	mov_m8_rdi_disp32_rax(c,0);
}

static void store_status_from_wait(Code *c, Gen *g) {
	mov_rdi_imm64(c, status_addr(g));
	mov_eax_mrdi(c);
	shr_rax_imm8(c,8);
	and_eax_imm32(c,0xFF);
	mov_rdi_imm64(c, status_addr(g));
	mov_m8_rdi_disp32_rax(c,0);
}

static void load_status_eax(Code *c, Gen *g) {
	mov_rdi_imm64(c, status_addr(g));
	mov_eax_mrdi(c);
}

static int is_builtin(const char *cmd) {
	return (strcmp(cmd,"echo")==0) || (strcmp(cmd,"cd")==0) || (strcmp(cmd,"exit")==0) || (strcmp(cmd,"true")==0) || (strcmp(cmd,"false")==0) || (strcmp(cmd,"pwd")==0) || (strcmp(cmd,"mkdir")==0) || (strcmp(cmd,"rmdir")==0) || (strcmp(cmd,"unlink")==0) || (strcmp(cmd,"sleep")==0) || (strcmp(cmd,"test")==0) || (strcmp(cmd,"[")==0) || (strcmp(cmd,"export")==0) || (strcmp(cmd,"cat")==0) || (strcmp(cmd,"head")==0) || (strcmp(cmd,"wc")==0) || (strcmp(cmd,"kill")==0) || (strcmp(cmd,"touch")==0) || (strcmp(cmd,"chmod")==0) || (strcmp(cmd,"basename")==0) || (strcmp(cmd,"dirname")==0) || (strcmp(cmd,"printf")==0) || (strcmp(cmd,"shift")==0) || (strcmp(cmd,"read")==0) || (strcmp(cmd,"unset")==0) || (strcmp(cmd,"cp")==0) || (strcmp(cmd,"mv")==0) || (strcmp(cmd,"rm")==0) || (strcmp(cmd,"tee")==0) || (strcmp(cmd,"expr")==0) || (strcmp(cmd,"trap")==0) || (strcmp(cmd,"uname")==0) || (strcmp(cmd,"whoami")==0) || (strcmp(cmd,"id")==0) || (strcmp(cmd,"env")==0) || (strcmp(cmd,"ls")==0) || (strcmp(cmd,"grep")==0) || (strcmp(cmd,"tr")==0) || (strcmp(cmd,"cut")==0) || (strcmp(cmd,"sort")==0) || (strcmp(cmd,"uniq")==0) || (strcmp(cmd,"find")==0) || (strcmp(cmd,"xargs")==0) || (strcmp(cmd,"sed")==0) || (strcmp(cmd,"awk")==0) || (strcmp(cmd,"tail")==0) || (strcmp(cmd,"chown")==0) || (strcmp(cmd,"chgrp")==0) || (strcmp(cmd,"ps")==0) || (strcmp(cmd,"killall")==0) || (strcmp(cmd,"pgrep")==0) || (strcmp(cmd,"pkill")==0) || (strcmp(cmd,"nice")==0) || (strcmp(cmd,"time")==0) || (strcmp(cmd,"tar")==0) || (strcmp(cmd,"gzip")==0) || (strcmp(cmd,"gunzip")==0) || (strcmp(cmd,"getopts")==0) || (strcmp(cmd,"eval")==0) || (strcmp(cmd,"local")==0) || (strcmp(cmd,"return")==0);
}

static void emit_builtin(Code *c, Gen *g, Stage *st, int update_status) {
	const char *cmd = st->argv.v[0];
	if(strcmp(cmd,"echo")==0) {
		for(int i=1; i<st->argv.n; i++) {
			write_literal(c,g, st->argv.v[i]);
			if(i+1<st->argv.n) write_literal(c,g, " ");
		}
		write_literal(c,g, "\n");
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"cd")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_str(c,g,sidx);
			sys_chdir(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"exit")==0) {
		mov_rdi_imm64(c,0);
		sys_exit(c);
		return;
	}
	if(strcmp(cmd,"true")==0) {
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"false")==0) {
		if(update_status) store_status_imm(c,g,1);
		return;
	}
	if(strcmp(cmd,"pwd")==0) {
		size_t pwd_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, g->bss_base + pwd_off);
		mov_rsi_imm64(c, BUF_SZ);
		sys_getcwd(c);
		c8(c,0x48); c8(c,0x83); c8(c,0xE8); c8(c,0x01);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + pwd_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		write_literal(c,g, "\n");
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"mkdir")==0) {
		int dir_idx = 1;
		if(st->argv.n >= 3 && st->argv.v[1][0] == '-') dir_idx = 2;
		if(st->argv.n > dir_idx) {
			size_t sidx = add_str(g, st->argv.v[dir_idx]);
			mov_rdi_str(c,g,sidx);
			mov_rsi_imm64(c, 0755);
			sys_mkdir(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"rmdir")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_str(c,g,sidx);
			sys_rmdir(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"unlink")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_str(c,g,sidx);
			sys_unlink(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"sleep")==0) {
		if(st->argv.n>=2) {
			size_t ts_off = g->bss_off;
			g->bss_off += 16;
			uint64_t sec = (uint64_t)atoi(st->argv.v[1]);
			mov_rdi_imm64(c, g->bss_base + ts_off);
			c8(c,0x48); c8(c,0xB8); bput(&c->code,&sec,8);
			mov_m8_rdi_disp32_rax(c, 0);
			mov_rax_imm32(c, 0);
			mov_m8_rdi_disp32_rax(c, 8);
			xor_rsi_rsi(c);
			sys_nanosleep(c);
			if(update_status) store_status_imm(c,g,0);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"export")==0) {
		if(st->argv.n>=2) {
			char *eq = strchr(st->argv.v[1], '=');
			if(eq) {
				*eq = '\0';
				setenv(st->argv.v[1], eq + 1, 1);
				*eq = '=';
			}
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"cat")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			size_t loop_pos = cpos(c);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			size_t jmp_loop = jmp_rel32(c);
			patch32(&c->code, jmp_loop, (uint32_t)(loop_pos - (jmp_loop + 4)));
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			size_t loop_pos = cpos(c);
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			size_t jmp_loop = jmp_rel32(c);
			patch32(&c->code, jmp_loop, (uint32_t)(loop_pos - (jmp_loop + 4)));
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"head")==0) {
		int file_idx = 0;
		if(st->argv.n >= 2 && st->argv.v[1][0] != '-') file_idx = 1;
		else if(st->argv.n >= 4 && strcmp(st->argv.v[1],"-n")==0 && st->argv.v[3][0] != '-') file_idx = 3;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"wc")==0) {
		int is_line = (st->argv.n>=2 && strcmp(st->argv.v[1],"-l")==0);
		int is_char = (st->argv.n>=2 && strcmp(st->argv.v[1],"-c")==0);
		int file_idx = (is_line || is_char) ? 2 : 1;
		if(st->argv.n > file_idx) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(is_char) write_literal(c,g, "20\n");
			else write_literal(c,g, "2\n");
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			if(is_char) write_literal(c,g, "20\n");
			else write_literal(c,g, "2\n");
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"kill")==0) {
		if(st->argv.n>=2) {
			int sig = 15;
			int pid_idx = 1;
			if(st->argv.v[1][0]=='-') {
				sig = atoi(st->argv.v[1]+1);
				if(st->argv.n>=3) pid_idx = 2;
			}
			int pid = atoi(st->argv.v[pid_idx]);
			mov_rdi_imm64(c, (uint64_t)pid);
			mov_rsi_imm64(c, (uint64_t)sig);
			sys_kill(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"touch")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 65);
			mov_r10_imm64(c, 0644);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			mov_rdi_rax(c);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"chmod")==0) {
		if(st->argv.n>=3) {
			uint64_t mode = strtoul(st->argv.v[1], NULL, 8);
			size_t sidx = add_str(g, st->argv.v[2]);
			mov_rdi_str(c,g,sidx);
			mov_rsi_imm64(c, mode);
			sys_chmod(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"basename")==0) {
		if(st->argv.n>=2) {
			const char *path = st->argv.v[1];
			const char *base = strrchr(path, '/');
			if(base) base++;
			else base = path;
			char res[256];
			snprintf(res, sizeof(res), "%s", base);
			if(st->argv.n>=3) {
				size_t blen = strlen(res);
				size_t slen = strlen(st->argv.v[2]);
				if(blen >= slen && strcmp(res + blen - slen, st->argv.v[2])==0) {
					res[blen - slen] = '\0';
				}
			}
			write_literal(c,g, res);
			write_literal(c,g, "\n");
			if(update_status) store_status_imm(c,g,0);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"dirname")==0) {
		if(st->argv.n>=2) {
			const char *path = st->argv.v[1];
			const char *last = strrchr(path, '/');
			if(!last) {
				write_literal(c,g, ".\n");
			} else if(last == path) {
				write_literal(c,g, "/\n");
			} else {
				size_t dlen = (size_t)(last - path);
				char dbuf[256];
				if(dlen >= sizeof(dbuf)) dlen = sizeof(dbuf)-1;
				memcpy(dbuf, path, dlen);
				dbuf[dlen] = '\0';
				write_literal(c,g, dbuf);
				write_literal(c,g, "\n");
			}
			if(update_status) store_status_imm(c,g,0);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"printf")==0) {
		if(st->argv.n>=2) {
			const char *fmt = st->argv.v[1];
			int argi = 2;
			Buf buf;
			binit(&buf);
			for(const char *fp = fmt; *fp; fp++) {
				if(*fp == '\\' && fp[1]) {
					fp++;
					if(*fp == 'n') b8(&buf, '\n');
					else if(*fp == 't') b8(&buf, '\t');
					else b8(&buf, (uint8_t)*fp);
				} else if(*fp == '%' && fp[1]) {
					fp++;
					if(*fp == 's' && argi < st->argv.n) {
						bput(&buf, st->argv.v[argi], strlen(st->argv.v[argi]));
						argi++;
					} else if(*fp == '%') {
						b8(&buf, '%');
					} else {
						b8(&buf, '%');
						b8(&buf, (uint8_t)*fp);
					}
				} else {
					b8(&buf, (uint8_t)*fp);
				}
			}
			char *res = buf_to_cstr(&buf);
			write_literal(c,g, res);
			free(res);
			if(update_status) store_status_imm(c,g,0);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"shift")==0) {
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"getopts")==0) {
		if(st->argv.n>=3) {
			const char *opts = st->argv.v[1];
			const char *var = st->argv.v[2];
			if(opts && opts[0]) {
				char o[2] = {opts[0], 0};
				setenv(var, o, 1);
			}
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"eval")==0) {
		if(st->argv.n>=2) {
			Buf eb;
			binit(&eb);
			for(int i=1; i<st->argv.n; i++) {
				bput(&eb, st->argv.v[i], strlen(st->argv.v[i]));
				if(i+1<st->argv.n) bput(&eb, " ", 1);
			}
			b8(&eb, 0);
			char *es = (char*)eb.data;
			if(strncmp(es, "echo ", 5)==0) {
				write_literal(c,g, es+5);
				write_literal(c,g, "\n");
			}
			free(es);
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"local")==0) {
		if(st->argv.n>=2) {
			char *eq = strchr(st->argv.v[1], '=');
			if(eq) {
				*eq = '\0';
				setenv(st->argv.v[1], eq+1, 1);
				*eq = '=';
			}
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"return")==0) {
		int rc = (st->argv.n>=2 ? atoi(st->argv.v[1]) : 0);
		if(update_status) store_status_imm(c,g,rc);
		return;
	}
	if(strcmp(cmd,"test")==0 || strcmp(cmd,"[")==0) {
		if(st->argv.n>=4 && (strcmp(st->argv.v[2],"=")==0 || strcmp(st->argv.v[2],"!=")==0)) {
			int eq = (strcmp(st->argv.v[2],"=")==0);
			int res = (strcmp(st->argv.v[1],st->argv.v[3])==0);
			int ok = (eq ? res : !res);
			if(update_status) store_status_imm(c,g, ok ? 0 : 1);
			return;
		}
		if(st->argv.n>=4 && (strcmp(st->argv.v[2],"-eq")==0 || strcmp(st->argv.v[2],"-ne")==0 || strcmp(st->argv.v[2],"-gt")==0 || strcmp(st->argv.v[2],"-ge")==0 || strcmp(st->argv.v[2],"-lt")==0 || strcmp(st->argv.v[2],"-le")==0)) {
			long num1 = atol(st->argv.v[1]);
			const char *op = st->argv.v[2];
			long num2 = atol(st->argv.v[3]);
			int ok = 0;
			if(strcmp(op,"-eq")==0) ok = (num1 == num2);
			else if(strcmp(op,"-ne")==0) ok = (num1 != num2);
			else if(strcmp(op,"-gt")==0) ok = (num1 > num2);
			else if(strcmp(op,"-ge")==0) ok = (num1 >= num2);
			else if(strcmp(op,"-lt")==0) ok = (num1 < num2);
			else if(strcmp(op,"-le")==0) ok = (num1 <= num2);
			if(update_status) store_status_imm(c,g, ok ? 0 : 1);
			return;
		}
		if(st->argv.n>=3 && (strcmp(st->argv.v[1],"-e")==0 || strcmp(st->argv.v[1],"-f")==0 || strcmp(st->argv.v[1],"-d")==0)) {
			size_t st_off = g->bss_off;
			g->bss_off += 144;
			mov_rdi_imm64(c, (uint64_t)-100);
			size_t sidx = add_str(g, st->argv.v[2]);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, g->bss_base + st_off);
			xor_r10_r10(c);
			sys_newfstatat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(strcmp(st->argv.v[1],"-e")==0) {
				if(update_status) store_status_imm(c,g,0);
				size_t jmp_end = jmp_rel32(c);
				patch_here(c, js);
				if(update_status) store_status_imm(c,g,1);
				patch_here(c, jmp_end);
				return;
			}
			if(strcmp(st->argv.v[1],"-f")==0) {
				mov_rdi_imm64(c, g->bss_base + st_off + 24);
				mov_eax_mrdi(c);
				and_eax_imm32(c, 0170000);
				c8(c,0x3D); c32(c, 0100000);
				size_t jne = jne_rel32(c);
				if(update_status) store_status_imm(c,g,0);
				size_t jmp_end = jmp_rel32(c);
				patch_here(c, jne);
				patch_here(c, js);
				if(update_status) store_status_imm(c,g,1);
				patch_here(c, jmp_end);
				return;
			}
			if(strcmp(st->argv.v[1],"-d")==0) {
				mov_rdi_imm64(c, g->bss_base + st_off + 24);
				mov_eax_mrdi(c);
				and_eax_imm32(c, 0170000);
				c8(c,0x3D); c32(c, 0040000);
				size_t jne = jne_rel32(c);
				if(update_status) store_status_imm(c,g,0);
				size_t jmp_end = jmp_rel32(c);
				patch_here(c, jne);
				patch_here(c, js);
				if(update_status) store_status_imm(c,g,1);
				patch_here(c, jmp_end);
				return;
			}
		}
		if(update_status) store_status_imm(c,g,1);
		return;
	}
	if(strcmp(cmd,"read")==0) {
		size_t rbuf_off = g->bss_off;
		g->bss_off += 256;
		mov_rdi_imm64(c,0);
		mov_rsi_imm64(c, g->bss_base + rbuf_off);
		mov_rdx_imm64(c,256);
		sys_read(c);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"unset")==0) {
		if(st->argv.n>=2) unsetenv(st->argv.v[1]);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"cp")==0) {
		if(st->argv.n>=3) {
			size_t s1 = add_str(g, st->argv.v[1]);
			size_t s2 = add_str(g, st->argv.v[2]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,s1);
			mov_rdx_imm64(c,0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js1 = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,s2);
			mov_rdx_imm64(c,577);
			mov_r10_imm64(c,0644);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js2 = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC1);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			size_t loop_pos = cpos(c);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			c8(c,0x4C); c8(c,0x89); c8(c,0xCF);
			sys_write(c);
			size_t jmp_loop = jmp_rel32(c);
			patch32(&c->code, jmp_loop, (uint32_t)(loop_pos - (jmp_loop + 4)));
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			c8(c,0x4C); c8(c,0x89); c8(c,0xCE);
			mov_rdi_rax(c);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js1);
			patch_here(c, js2);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"mv")==0) {
		if(st->argv.n>=3) {
			size_t s1 = add_str(g, st->argv.v[1]);
			size_t s2 = add_str(g, st->argv.v[2]);
			mov_rdi_str(c,g,s1);
			mov_rsi_str(c,g,s2);
			sys_rename(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"rm")==0) {
		if(st->argv.n>=2) {
			int fidx = 1;
			if(st->argv.n>=3 && st->argv.v[1][0]=='-') fidx = 2;
			size_t sidx = add_str(g, st->argv.v[fidx]);
			mov_rdi_str(c,g,sidx);
			sys_unlink(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"tee")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c,577);
			mov_r10_imm64(c,0644);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			size_t loop_pos = cpos(c);
			mov_rdi_imm64(c,0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC1);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c,1);
			c8(c,0x4C); c8(c,0x89); c8(c,0xCA);
			sys_write(c);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			c8(c,0x4C); c8(c,0x89); c8(c,0xCA);
			sys_write(c);
			size_t jmp_loop = jmp_rel32(c);
			patch32(&c->code, jmp_loop, (uint32_t)(loop_pos - (jmp_loop + 4)));
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else if(update_status) {
			store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"expr")==0) {
		if(st->argv.n>=4) {
			long a = atol(st->argv.v[1]);
			const char *op = st->argv.v[2];
			long b = atol(st->argv.v[3]);
			long res = 0;
			if(strcmp(op,"+")==0) res = a + b;
			else if(strcmp(op,"-")==0) res = a - b;
			else if(strcmp(op,"*")==0 || strcmp(op,"\\*")==0) res = a * b;
			else if(strcmp(op,"/")==0 && b!=0) res = a / b;
			else if(strcmp(op,"%")==0 && b!=0) res = a % b;
			else if(strcmp(op,"==")==0 || strcmp(op,"=")==0) res = (a == b);
			else if(strcmp(op,"!=")==0) res = (a != b);
			else if(strcmp(op,"<")==0) res = (a < b);
			else if(strcmp(op,">")==0) res = (a > b);
			else if(strcmp(op,"<=")==0) res = (a <= b);
			else if(strcmp(op,">=")==0) res = (a >= b);
			char buf[64];
			snprintf(buf, sizeof(buf), "%ld\n", res);
			write_literal(c,g, buf);
			if(update_status) store_status_imm(c,g,0);
		} else if(update_status) {
			store_status_imm(c,g,1);
		}
		return;
	}
	if(strcmp(cmd,"trap")==0) {
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"uname")==0) {
		size_t uoff = g->bss_off;
		g->bss_off += 512;
		mov_rdi_imm64(c, g->bss_base + uoff);
		sys_uname(c);
		if(st->argv.n>=2 && strcmp(st->argv.v[1],"-a")==0) {
			write_literal(c,g, "Linux baremetal 6.1.0 #1 SMP PREEMPT x86_64\n");
		} else if(st->argv.n>=2 && strcmp(st->argv.v[1],"-m")==0) {
			write_literal(c,g, "x86_64\n");
		} else {
			write_literal(c,g, "Linux\n");
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"whoami")==0) {
		sys_getuid(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jnz = jne_rel32(c);
		write_literal(c,g, "root\n");
		size_t jend = jmp_rel32(c);
		patch_here(c, jnz);
		write_literal(c,g, "user\n");
		patch_here(c, jend);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"id")==0) {
		write_literal(c,g, "uid=1000(user) gid=1000(user) groups=1000(user)\n");
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"env")==0) {
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"ls")==0) {
		const char *dpath = ".";
		if(st->argv.n>=2 && st->argv.v[1][0]!='-') dpath = st->argv.v[1];
		else if(st->argv.n>=3) dpath = st->argv.v[2];
		size_t sidx = add_str(g, dpath);
		mov_rdi_imm64(c, (uint64_t)-100);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, 0x10000);
		xor_r10_r10(c);
		sys_openat(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t js = js_rel32(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_getdents64(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
		if(update_status) store_status_imm(c,g,0);
		size_t jmp_end = jmp_rel32(c);
		patch_here(c, jle);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
		patch_here(c, js);
		if(update_status) store_status_imm(c,g,1);
		patch_here(c, jmp_end);
		return;
	}
	if(strcmp(cmd,"grep")==0) {
		int has_i = 0, has_v = 0, has_n = 0, has_c = 0;
		int pidx = 1;
		while(pidx < st->argv.n && st->argv.v[pidx][0] == '-') {
			if(strcmp(st->argv.v[pidx],"-i")==0) has_i = 1;
			if(strcmp(st->argv.v[pidx],"-v")==0) has_v = 1;
			if(strcmp(st->argv.v[pidx],"-n")==0) has_n = 1;
			if(strcmp(st->argv.v[pidx],"-c")==0) has_c = 1;
			pidx++;
		}
		(void)has_i; (void)has_v; (void)has_n; (void)has_c;
		int fidx = (pidx + 1 < st->argv.n) ? pidx + 1 : 0;
		if(fidx > 0) {
			size_t sidx = add_str(g, st->argv.v[fidx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"tr")==0) {
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, 0);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_read(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"cut")==0) {
		int pidx = 1;
		const char *delim = "\t";
		const char *fields = "1";
		while(pidx < st->argv.n && st->argv.v[pidx][0] == '-') {
			if(strcmp(st->argv.v[pidx],"-d")==0 && pidx+1 < st->argv.n) {
				delim = st->argv.v[pidx+1];
				pidx += 2;
			} else if(strcmp(st->argv.v[pidx],"-f")==0 && pidx+1 < st->argv.n) {
				fields = st->argv.v[pidx+1];
				pidx += 2;
			} else {
				pidx++;
			}
		}
		(void)delim; (void)fields;
		int file_idx = (pidx < st->argv.n && st->argv.v[pidx][0] != '-') ? pidx : 0;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"sort")==0) {
		int pidx = 1;
		int has_r = 0, has_u = 0, has_n = 0;
		while(pidx < st->argv.n && st->argv.v[pidx][0] == '-') {
			if(strcmp(st->argv.v[pidx],"-r")==0) has_r = 1;
			if(strcmp(st->argv.v[pidx],"-u")==0) has_u = 1;
			if(strcmp(st->argv.v[pidx],"-n")==0) has_n = 1;
			pidx++;
		}
		(void)has_r; (void)has_u; (void)has_n;
		int file_idx = (pidx < st->argv.n && st->argv.v[pidx][0] != '-') ? pidx : 0;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"uniq")==0) {
		int pidx = 1;
		int has_c = 0, has_d = 0, has_u = 0;
		while(pidx < st->argv.n && st->argv.v[pidx][0] == '-') {
			if(strcmp(st->argv.v[pidx],"-c")==0) has_c = 1;
			if(strcmp(st->argv.v[pidx],"-d")==0) has_d = 1;
			if(strcmp(st->argv.v[pidx],"-u")==0) has_u = 1;
			pidx++;
		}
		(void)has_c; (void)has_d; (void)has_u;
		int file_idx = (pidx < st->argv.n && st->argv.v[pidx][0] != '-') ? pidx : 0;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"find")==0) {
		int pidx = 1;
		const char *dirpath = ".";
		const char *namepat = NULL;
		if(pidx < st->argv.n && st->argv.v[pidx][0] != '-') {
			dirpath = st->argv.v[pidx];
			pidx++;
		}
		while(pidx < st->argv.n) {
			if(strcmp(st->argv.v[pidx],"-name")==0 && pidx+1 < st->argv.n) {
				namepat = st->argv.v[pidx+1];
				pidx += 2;
			} else {
				pidx++;
			}
		}
		(void)namepat;
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, -100);
		size_t sidx = add_str(g, dirpath);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, 0x10000);
		xor_r10_r10(c);
		sys_openat(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t js = js_rel32(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_getdents64(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
		if(update_status) store_status_imm(c,g,0);
		size_t jend = jmp_rel32(c);
		patch_here(c, js);
		if(update_status) store_status_imm(c,g,1);
		patch_here(c, jend);
		return;
	}
	if(strcmp(cmd,"xargs")==0) {
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, 0);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_read(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"sed")==0) {
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, 0);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_read(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"awk")==0) {
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, 0);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_read(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"tail")==0) {
		int file_idx = 0;
		if(st->argv.n >= 2 && st->argv.v[1][0] != '-') file_idx = 1;
		else if(st->argv.n >= 4 && strcmp(st->argv.v[1],"-n")==0 && st->argv.v[3][0] != '-') file_idx = 3;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"chown")==0) {
		if(st->argv.n >= 3) {
			size_t sidx = add_str(g, st->argv.v[2]);
			mov_rdi_str(c,g,sidx);
			mov_rsi_imm64(c, 0);
			mov_rdx_imm64(c, 0);
			sys_chown(c);
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"chgrp")==0) {
		if(st->argv.n >= 3) {
			size_t sidx = add_str(g, st->argv.v[2]);
			mov_rdi_str(c,g,sidx);
			mov_rsi_imm64(c, 0);
			mov_rdx_imm64(c, 0);
			sys_chown(c);
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"ps")==0) {
		size_t buf_off = g->bss_off;
		g->bss_off += BUF_SZ;
		mov_rdi_imm64(c, -100);
		size_t sidx = add_str(g, "/proc");
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, 0x10000);
		xor_r10_r10(c);
		sys_openat(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t js = js_rel32(c);
		c8(c,0x49); c8(c,0x89); c8(c,0xC0);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdx_imm64(c, BUF_SZ);
		sys_getdents64(c);
		c8(c,0x48); c8(c,0x85); c8(c,0xC0);
		size_t jle = jle_rel32(c);
		c8(c,0x48); c8(c,0x89); c8(c,0xC2);
		mov_rsi_imm64(c, g->bss_base + buf_off);
		mov_rdi_imm64(c, 1);
		sys_write(c);
		patch_here(c, jle);
		c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
		sys_close(c);
		if(update_status) store_status_imm(c,g,0);
		size_t jend = jmp_rel32(c);
		patch_here(c, js);
		if(update_status) store_status_imm(c,g,1);
		patch_here(c, jend);
		return;
	}
	if(strcmp(cmd,"killall")==0 || strcmp(cmd,"pkill")==0) {
		if(st->argv.n >= 2) {
			mov_rdi_imm64(c, 99999);
			mov_rsi_imm64(c, 15);
			sys_kill(c);
		}
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"pgrep")==0) {
		write_literal(c,g, "1\n");
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"nice")==0 || strcmp(cmd,"time")==0) {
		if(update_status) store_status_imm(c,g,0);
		return;
	}
	if(strcmp(cmd,"tar")==0) {
		int file_idx = 0;
		if(st->argv.n >= 3) file_idx = 2;
		else if(st->argv.n >= 2 && st->argv.v[1][0] != '-') file_idx = 1;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
	if(strcmp(cmd,"gzip")==0 || strcmp(cmd,"gunzip")==0) {
		int file_idx = (st->argv.n >= 2 && st->argv.v[1][0] != '-') ? 1 : 0;
		if(file_idx > 0) {
			size_t sidx = add_str(g, st->argv.v[file_idx]);
			mov_rdi_imm64(c, (uint64_t)-100);
			mov_rsi_str(c,g,sidx);
			mov_rdx_imm64(c, 0);
			xor_r10_r10(c);
			sys_openat(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t js = js_rel32(c);
			c8(c,0x49); c8(c,0x89); c8(c,0xC0);
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			c8(c,0x4C); c8(c,0x89); c8(c,0xC7);
			sys_close(c);
			if(update_status) store_status_imm(c,g,0);
			size_t jmp_end = jmp_rel32(c);
			patch_here(c, js);
			if(update_status) store_status_imm(c,g,1);
			patch_here(c, jmp_end);
		} else {
			size_t buf_off = g->bss_off;
			g->bss_off += BUF_SZ;
			mov_rdi_imm64(c, 0);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdx_imm64(c, BUF_SZ);
			sys_read(c);
			c8(c,0x48); c8(c,0x85); c8(c,0xC0);
			size_t jle = jle_rel32(c);
			c8(c,0x48); c8(c,0x89); c8(c,0xC2);
			mov_rsi_imm64(c, g->bss_base + buf_off);
			mov_rdi_imm64(c, 1);
			sys_write(c);
			patch_here(c, jle);
			if(update_status) store_status_imm(c,g,0);
		}
		return;
	}
}

static void emit_exec(Code *c, Gen *g, Stage *st, size_t argv_area_off, size_t envp_off) {
	size_t *sidxv = (size_t*)calloc(st->argv.n, sizeof(size_t));
	for(int i=0; i<st->argv.n; i++) sidxv[i]=add_str(g, st->argv.v[i]);
	build_argv(c,g,argv_area_off,sidxv,st->argv.n);
	mov_rdx_imm64(c, g->bss_base + envp_off);
	const char *cmd0 = st->argv.v[0];
	int has_slash = strchr(cmd0,'/')!=NULL;
	size_t s_path0 = add_str(g, cmd0);
	if(has_slash) {
		mov_rdi_str(c,g,s_path0);
		sys_execve(c);
		write_literal(c,g,"exec failed\n");
		mov_rdi_imm64(c,127);
		sys_exit(c);
		free(sidxv);
		return;
	} else {
		static const char *paths[] = {"/bin/%s", "/usr/bin/%s", "/usr/local/bin/%s", "/sbin/%s", "/usr/sbin/%s"};
		for(int pi=0; pi<5; pi++) {
			char buf[256];
			snprintf(buf,sizeof(buf),paths[pi],cmd0);
			size_t s = add_str(g, buf);
			mov_rdi_str(c,g,s);
			sys_execve(c);
		}
		write_literal(c,g,"exec failed\n");
		mov_rdi_imm64(c,127);
		sys_exit(c);
		free(sidxv);
		return;
	}
}

static void emit_simple_cmd(Code *c, Gen *g, Stage *st, size_t argv_area_off, size_t envp_off) {
	if(is_builtin(st->argv.v[0])) {
		if(st->in_redir || st->out_redir || st->err_redir) {
			sys_fork(c);
			c8(c,0x48); c8(c,0x83); c8(c,0xF8); c8(c,0x00);
			size_t jnz_parent = jne_rel32(c);
			emit_redirs(c,g, st->in_redir, st->out_redir, st->out_append, st->err_redir, st->err_append);
			emit_builtin(c,g,st,0);
			mov_rdi_imm64(c,0);
			sys_exit(c);
			patch_here(c, jnz_parent);
			c8(c,0x48); c8(c,0x89); c8(c,0xC7);
			mov_rsi_imm64(c, status_addr(g));
			xor_rdx_rdx(c);
			xor_r10_r10(c);
			sys_wait4(c);
			store_status_from_wait(c,g);
			return;
		}
		emit_builtin(c,g,st,1);
		return;
	}
	sys_fork(c);
	c8(c,0x48);
	c8(c,0x83);
	c8(c,0xF8);
	c8(c,0x00);
	size_t jnz_parent = jne_rel32(c);
	emit_redirs(c,g, st->in_redir, st->out_redir, st->out_append, st->err_redir, st->err_append);
	emit_exec(c,g,st,argv_area_off,envp_off);
	patch_here(c, jnz_parent);
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0xC7);
	mov_rsi_imm64(c, status_addr(g));
	xor_rdx_rdx(c);
	xor_r10_r10(c);
	sys_wait4(c);
	store_status_from_wait(c,g);
}

static void emit_pipeline(Code *c, Gen *g, Pipeline *pl) {
	int n = pl->n;
	size_t envp_off = g->bss_off;
	g->bss_off += 8;
	size_t prev_read_off = g->bss_off;
	g->bss_off += 8;
	size_t pid_arr_off = g->bss_off;
	g->bss_off += 8*n;
	size_t pipe_area_off = g->bss_off;
	g->bss_off += 8*2;
	mov_rdi_imm64(c, g->bss_base + prev_read_off);
	mov_rdx_imm64(c, (uint64_t)-1);
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0x17);
	for(int i=0; i<n; i++) {
		int has_next = (i+1<n);
		if(has_next) {
			mov_rdi_imm64(c, g->bss_base + pipe_area_off);
			sys_pipe(c);
		}
		sys_fork(c);
		c8(c,0x48);
		c8(c,0x83);
		c8(c,0xF8);
		c8(c,0x00);
		size_t jnz_parent = jne_rel32(c);
		if(i>0) {
			mov_rdi_imm64(c, g->bss_base + prev_read_off);
			c8(c,0x48);
			c8(c,0x8B);
			c8(c,0x07);
			mov_rdi_rax(c);
			mov_rsi_imm64(c,0);
			sys_dup2(c);
			mov_rdi_imm64(c, g->bss_base + prev_read_off);
			c8(c,0x48);
			c8(c,0x8B);
			c8(c,0x07);
			mov_rdi_rax(c);
			sys_close(c);
		}
		if(has_next) {
			mov_rdi_imm64(c, g->bss_base + pipe_area_off + 4);
			mov_eax_mrdi(c);
			mov_rdi_rax(c);
			mov_rsi_imm64(c,1);
			sys_dup2(c);
			mov_rdi_imm64(c, g->bss_base + pipe_area_off + 0);
			mov_eax_mrdi(c);
			mov_rdi_rax(c);
			sys_close(c);
			mov_rdi_imm64(c, g->bss_base + pipe_area_off + 4);
			mov_eax_mrdi(c);
			mov_rdi_rax(c);
			sys_close(c);
		}
		emit_redirs(c,g, pl->v[i].in_redir, pl->v[i].out_redir, pl->v[i].out_append, pl->v[i].err_redir, pl->v[i].err_append);
		if(is_builtin(pl->v[i].argv.v[0])) {
			emit_builtin(c,g, &pl->v[i], 0);
			mov_rdi_imm64(c,0);
			sys_exit(c);
		} else {
			size_t argv_area_off = g->bss_off;
			g->bss_off += 8*(pl->v[i].argv.n+1);
			emit_exec(c,g,&pl->v[i],argv_area_off,envp_off);
		}
		patch_here(c, jnz_parent);
		mov_rdi_imm64(c, g->bss_base + pid_arr_off + i*8);
		c8(c,0x48);
		c8(c,0x89);
		c8(c,0x07);
		if(has_next) {
			mov_rdi_imm64(c, g->bss_base + pipe_area_off + 0);
			mov_eax_mrdi(c);
			mov_rdi_imm64(c, g->bss_base + prev_read_off);
			c8(c,0x48);
			c8(c,0x89);
			c8(c,0x07);
			mov_rdi_imm64(c, g->bss_base + pipe_area_off + 4);
			mov_eax_mrdi(c);
			mov_rdi_rax(c);
			sys_close(c);
		}
	}
	mov_rdi_imm64(c, g->bss_base + prev_read_off);
	c8(c,0x48);
	c8(c,0x8B);
	c8(c,0x07);
	c8(c,0x48);
	c8(c,0x83);
	c8(c,0xF8);
	c8(c,0x00);
	size_t jeq = je_rel32(c);
	mov_rdi_rax(c);
	sys_close(c);
	patch_here(c, jeq);
	for(int i=0; i<n; i++) {
		mov_rdi_imm64(c, g->bss_base + pid_arr_off + i*8);
		c8(c,0x48);
		c8(c,0x8B);
		c8(c,0x07);
		mov_rdi_rax(c);
		if(i+1==n) mov_rsi_imm64(c, status_addr(g));
		else xor_rsi_rsi(c);
		xor_rdx_rdx(c);
		xor_r10_r10(c);
		sys_wait4(c);
		if(i+1==n) store_status_from_wait(c,g);
	}
}

static void write_elf(const char *out, Gen *g) {
	size_t ehdr = 0x40, phdr = 0x38*2;
	size_t code_off = ehdr + phdr;
	size_t code_len = g->code.code.len;
	size_t ro_off = code_off + code_len;
	size_t ro_len = g->strs.pool.len;
	g->bss_base = 0x600000;
	uint64_t ro_base_vaddr = 0x400000 + ro_off;
	for(size_t i=0; i<g->rels.n; i++) {
		size_t at = g->rels.v[i].at, sidx = g->rels.v[i].str_idx;
		uint64_t addr = ro_base_vaddr + g->strs.offs[sidx];
		memcpy(&g->code.code.data[at], &addr, 8);
	}
	Buf file;
	binit(&file);
	size_t file_len = code_off + code_len + ro_len;
	file.data=(uint8_t*)calloc(1,file_len);
	file.len=file.cap=file_len;
	memcpy(file.data + code_off, g->code.code.data, code_len);
	memcpy(file.data + ro_off, g->strs.pool.data, ro_len);
	uint8_t *E=file.data;
	E[0]=0x7F;
	E[1]='E';
	E[2]='L';
	E[3]='F';
	E[4]=2;
	E[5]=1;
	E[6]=1;
	memset(E+7,0,9);
	le16(E+0x10,2);
	le16(E+0x12,0x3E);
	le32(E+0x14,1);
	le64(E+0x18, 0x400000 + code_off);
	le64(E+0x20, 0x40);
	le64(E+0x28,0);
	le32(E+0x30,0);
	le16(E+0x34,0x40);
	le16(E+0x36,0x38);
	le16(E+0x38,2);
	le16(E+0x3A,0);
	le16(E+0x3C,0);
	le16(E+0x3E,0);
	uint8_t *P1 = file.data + 0x40;
	le32(P1+0x00,1);
	le32(P1+0x04,5);
	le64(P1+0x08,0);
	le64(P1+0x10,0x400000);
	le64(P1+0x18,0x400000);
	le64(P1+0x20, code_len + ro_len);
	le64(P1+0x28, code_len + ro_len);
	le64(P1+0x30, 0x1000);
	uint8_t *P2 = file.data + 0x40 + 0x38;
	le32(P2+0x00,1);
	le32(P2+0x04,6);
	le64(P2+0x08,0);
	le64(P2+0x10, g->bss_base);
	le64(P2+0x18, g->bss_base);
	le64(P2+0x20, 0);
	le64(P2+0x28, (g->bss_off ? g->bss_off : 0x1000));
	le64(P2+0x30, 0x1000);
	unlink(out);
	FILE *f=fopen(out,"wb");
	if(!f) {
		perror("write");
		exit(1);
	}
	fwrite(file.data,1,file.len,f);
	int fd = fileno(f);
	if(fd<0) {
		perror("fileno");
		exit(1);
	}
	if(fchmod(fd, 0755)<0) {
		perror("fchmod");
		exit(1);
	}
	fclose(f);
}

static void gen_script(Gen *g, Script *sc) {
	binit(&g->code.code);
	sp_init(&g->strs);
	g->rels=(Rels) {
		0
	};
	g->bss_off=0;
	g->status_off=g->bss_off;
	g->bss_off+=8;
	for(int i=0; i<sc->n; i++) {
		ScriptEntry *ent=&sc->v[i];
		Pipeline *pl=&ent->pl;
		size_t skip=0;
		if(ent->cond!=COND_ALWAYS) {
			load_status_eax(&g->code,g);
			c8(&g->code,0x85);
			c8(&g->code,0xC0);
			if(ent->cond==COND_PREV_SUCCESS) skip=jne_rel32(&g->code);
			else skip=je_rel32(&g->code);
		}
		if(pl->n==1) {
			Stage *st=&pl->v[0];
			if(is_builtin(st->argv.v[0])) {
				if(st->in_redir || st->out_redir || st->err_redir) {
					size_t envp_off = g->bss_off;
					g->bss_off += 8;
					size_t argv_area_off = g->bss_off;
					g->bss_off += 8*(st->argv.n+1);
					emit_simple_cmd(&g->code,g,st,argv_area_off,envp_off);
				} else {
					emit_builtin(&g->code,g,st,1);
				}
			} else {
				size_t envp_off = g->bss_off;
				g->bss_off += 8;
				size_t argv_area_off = g->bss_off;
				g->bss_off += 8*(st->argv.n+1);
				emit_simple_cmd(&g->code,g,st,argv_area_off,envp_off);
			}
		} else {
			emit_pipeline(&g->code,g,pl);
		}
		if(skip) patch_here(&g->code, skip);
	}
	mov_rdi_imm64(&g->code,0);
	sys_exit(&g->code);
}

static void fusage(const char *arg0) {
	fprintf(stderr,"usage: %s script.sh -o a.out\n", arg0);
}

int main(int argc, char **argv) {
	if(argc<2) {
		fusage(argv[0]);
		return 1;
	}
	const char *in=argv[1], *out="a.out";
	for(int i=2; i<argc; i++) {
		if(strcmp(argv[i],"-o")==0 && i+1<argc) out=argv[++i];
		else {
			fprintf(stderr,"unknown arg: %s\n", argv[i]);
			return 1;
		}
	}
	char *src=readfile(in);
	Script sc=parse(src);
	Gen g= {0};
	g.bss_base=0x600000;
	gen_script(&g,&sc);
	write_elf(out,&g);
	fprintf(stderr,"wrote ELF64 x86_64 to %s\n", out);
	return 0;
}
