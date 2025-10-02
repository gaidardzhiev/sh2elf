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
	c8(c,0x48);
	c8(c,0xBF);
	bput(&c->code,&x,8);
}

static void mov_rsi_imm64(Code *c, uint64_t x) {
	c8(c,0x48);
	c8(c,0xBE);
	bput(&c->code,&x,8);
}

static void mov_rdx_imm64(Code *c, uint64_t x) {
	c8(c,0x48);
	c8(c,0xBA);
	bput(&c->code,&x,8);
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
} Stage;

typedef struct {
	Stage *v;
	int n, cap;
} Pipeline;

static void pl_push(Pipeline *p, Stage st) {
	if(p->n==p->cap) {
		p->cap=p->cap?2*p->cap:4;
		p->v=(Stage*)realloc(p->v,p->cap*sizeof(Stage));
	}
	p->v[p->n++]=st;
}

typedef struct {
	Pipeline *v;
	int n, cap;
} Script;

static void sc_push(Script *s, Pipeline p) {
	if(s->n==s->cap) {
		s->cap=s->cap?2*s->cap:4;
		s->v=(Pipeline*)realloc(s->v,s->cap*sizeof(Pipeline));
	}
	s->v[s->n++]=p;
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
	return c=='\0' || c==' ' || c=='\t' || c=='\r' || c=='\n' || c=='|' || c==';' || c=='<' || c=='>';
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
		if(st->in_redir || st->out_redir) parse_error("redirection without command");
		return;
	}
	pl_push(pl, *st);
	*st = (Stage){0};
}

static Script parse(const char *src) {
	Script sc = {0};
	Pipeline cur = {0};
	Stage st = {0};
	const char *p = src;
	int expect_stage = 0;
	while(*p) {
		skip_inline_ws(&p);
		if(*p=='\0') break;
		if(*p=='\n' || *p==';') {
			if(expect_stage) parse_error("pipeline stage missing command");
			if(st.argv.n>0) {
				finish_stage(&cur, &st);
			} else if(st.in_redir || st.out_redir) {
				parse_error("redirection without command");
			}
			if(cur.n>0) {
				sc_push(&sc, cur);
				cur = (Pipeline){0};
			}
			expect_stage = 0;
			while(*p=='\n' || *p==';') p++;
			continue;
		}
		if(*p=='|') {
			if(st.argv.n==0) parse_error("empty pipeline stage");
			finish_stage(&cur, &st);
			expect_stage = 1;
			p++;
			continue;
		}
		if(*p=='>' || *p=='<') {
			char op = *p++;
			int append = 0;
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
			} else {
				if(st.out_redir) free(st.out_redir);
				st.out_redir = target;
				st.out_append = append;
			}
			continue;
		}
		char *word = parse_word(&p);
		if(!word) parse_error("expected word");
		sv_push(&st.argv, word);
		expect_stage = 0;
	}
	if(expect_stage) parse_error("pipeline stage missing command");
	if(st.argv.n>0) {
		finish_stage(&cur, &st);
	} else if(st.in_redir || st.out_redir) {
		parse_error("redirection without command");
	}
	if(cur.n>0) sc_push(&sc, cur);
	return sc;
}

typedef struct {
	Code code;
	StrPool strs;
	Rels rels;
	size_t bss_base;
	size_t bss_off;
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

static void emit_redirs(Code *c, Gen *g, const char *in_redir, const char *out_redir, int append) {
	if(in_redir) {
		size_t sidx = add_str(g, in_redir);
		mov_rdi_imm64(c, (uint64_t)-100);
		mov_rsi_str(c,g,sidx);
		mov_rdx_imm64(c, 0);
		xor_r10_r10(c);
		sys_openat(c);
		mov_rdi_rax(c);
		mov_rsi_imm64(c, 0);
		sys_dup2(c);
		mov_rdi_rax(c);
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
		mov_rsi_imm64(c, 1);
		sys_dup2(c);
		mov_rdi_rax(c);
		sys_close(c);
	}
}

static int is_builtin(const char *cmd) {
	return (strcmp(cmd,"echo")==0) || (strcmp(cmd,"cd")==0) || (strcmp(cmd,"exit")==0);
}

static void emit_builtin(Code *c, Gen *g, Stage *st) {
	const char *cmd = st->argv.v[0];
	if(strcmp(cmd,"echo")==0) {
		for(int i=1; i<st->argv.n; i++) {
			write_literal(c,g, st->argv.v[i]);
			if(i+1<st->argv.n) write_literal(c,g, " ");
		}
		write_literal(c,g, "\n");
		return;
	}
	if(strcmp(cmd,"cd")==0) {
		if(st->argv.n>=2) {
			size_t sidx = add_str(g, st->argv.v[1]);
			mov_rdi_str(c,g,sidx);
			sys_chdir(c);
		}
		return;
	}
	if(strcmp(cmd,"exit")==0) {
		mov_rdi_imm64(c,0);
		sys_exit(c);
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
		char buf[256];
		snprintf(buf,sizeof(buf),"/bin/%s",cmd0);
		size_t s1 = add_str(g, buf);
		snprintf(buf,sizeof(buf),"/usr/bin/%s",cmd0);
		size_t s2 = add_str(g, buf);
		mov_rdi_str(c,g,s1);
		sys_execve(c);
		c8(c,0x48);
		c8(c,0x85);
		c8(c,0xC0);
		size_t jmp = jne_rel32(c);
		patch_here(c,jmp);
		mov_rdi_str(c,g,s2);
		sys_execve(c);
		write_literal(c,g,"exec failed\n");
		mov_rdi_imm64(c,127);
		sys_exit(c);
		free(sidxv);
		return;
	}
}

static void emit_simple_cmd(Code *c, Gen *g, Stage *st, size_t argv_area_off, size_t envp_off) {
	if(is_builtin(st->argv.v[0])) {
		emit_builtin(c,g,st);
		return;
	}
	sys_fork(c);
	c8(c,0x48);
	c8(c,0x83);
	c8(c,0xF8);
	c8(c,0x00);
	size_t jnz_parent = jne_rel32(c);
	emit_redirs(c,g, st->in_redir, st->out_redir, st->out_append);
	emit_exec(c,g,st,argv_area_off,envp_off);
	patch_here(c, jnz_parent);
	c8(c,0x48);
	c8(c,0x89);
	c8(c,0xC7);
	xor_rsi_rsi(c);
	xor_rdx_rdx(c);
	xor_r10_r10(c);
	sys_wait4(c);
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
		emit_redirs(c,g, pl->v[i].in_redir, pl->v[i].out_redir, pl->v[i].out_append);
		if(is_builtin(pl->v[i].argv.v[0])) {
			emit_builtin(c,g, &pl->v[i]);
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
		xor_rsi_rsi(c);
		xor_rdx_rdx(c);
		xor_r10_r10(c);
		sys_wait4(c);
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
	for(int i=0; i<sc->n; i++) {
		Pipeline *pl=&sc->v[i];
		if(pl->n==1) {
			Stage *st=&pl->v[0];
			if(is_builtin(st->argv.v[0])) {
				emit_builtin(&g->code,g,st);
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
