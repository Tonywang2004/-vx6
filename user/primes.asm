
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <getnewprime>:
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void getnewprime(int p){
   0:	7139                	addi	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	0080                	addi	s0,sp,64
   e:	892a                	mv	s2,a0
    //represent prime and data. 
    int current,nex;
    read(p,&current,sizeof(current));
  10:	4611                	li	a2,4
  12:	fcc40593          	addi	a1,s0,-52
  16:	00000097          	auipc	ra,0x0
  1a:	3d0080e7          	jalr	976(ra) # 3e6 <read>
    printf("prime %d\n",current);
  1e:	fcc42583          	lw	a1,-52(s0)
  22:	00001517          	auipc	a0,0x1
  26:	8c650513          	addi	a0,a0,-1850 # 8e8 <malloc+0xe8>
  2a:	00000097          	auipc	ra,0x0
  2e:	71e080e7          	jalr	1822(ra) # 748 <printf>
    int i=0;
  32:	4481                	li	s1,0
void getnewprime(int p){
  34:	4985                	li	s3,1
    int sec[2];
    while(read(p,&nex,sizeof(nex))){
  36:	a835                	j	72 <getnewprime+0x72>
        if(i==0){
            pipe(sec);
  38:	fc040513          	addi	a0,s0,-64
  3c:	00000097          	auipc	ra,0x0
  40:	3a2080e7          	jalr	930(ra) # 3de <pipe>
            //fork only once
            i=1;
            if(fork()==0){
  44:	00000097          	auipc	ra,0x0
  48:	382080e7          	jalr	898(ra) # 3c6 <fork>
  4c:	ed0d                	bnez	a0,86 <getnewprime+0x86>
                close(sec[1]);
  4e:	fc442503          	lw	a0,-60(s0)
  52:	00000097          	auipc	ra,0x0
  56:	3a4080e7          	jalr	932(ra) # 3f6 <close>
                getnewprime(sec[0]);
  5a:	fc042503          	lw	a0,-64(s0)
  5e:	00000097          	auipc	ra,0x0
  62:	fa2080e7          	jalr	-94(ra) # 0 <getnewprime>
                exit(0);
  66:	4501                	li	a0,0
  68:	00000097          	auipc	ra,0x0
  6c:	366080e7          	jalr	870(ra) # 3ce <exit>
void getnewprime(int p){
  70:	84ce                	mv	s1,s3
    while(read(p,&nex,sizeof(nex))){
  72:	4611                	li	a2,4
  74:	fc840593          	addi	a1,s0,-56
  78:	854a                	mv	a0,s2
  7a:	00000097          	auipc	ra,0x0
  7e:	36c080e7          	jalr	876(ra) # 3e6 <read>
  82:	c11d                	beqz	a0,a8 <getnewprime+0xa8>
        if(i==0){
  84:	d8d5                	beqz	s1,38 <getnewprime+0x38>
            }
        }
        if(nex%current!=0)
  86:	fc842783          	lw	a5,-56(s0)
  8a:	fcc42703          	lw	a4,-52(s0)
  8e:	02e7e7bb          	remw	a5,a5,a4
  92:	dff9                	beqz	a5,70 <getnewprime+0x70>
            write(sec[1],&nex,sizeof(nex));
  94:	4611                	li	a2,4
  96:	fc840593          	addi	a1,s0,-56
  9a:	fc442503          	lw	a0,-60(s0)
  9e:	00000097          	auipc	ra,0x0
  a2:	350080e7          	jalr	848(ra) # 3ee <write>
  a6:	b7e9                	j	70 <getnewprime+0x70>
    }
    close(sec[1]);
  a8:	fc442503          	lw	a0,-60(s0)
  ac:	00000097          	auipc	ra,0x0
  b0:	34a080e7          	jalr	842(ra) # 3f6 <close>
    wait(0);
  b4:	4501                	li	a0,0
  b6:	00000097          	auipc	ra,0x0
  ba:	320080e7          	jalr	800(ra) # 3d6 <wait>
}
  be:	70e2                	ld	ra,56(sp)
  c0:	7442                	ld	s0,48(sp)
  c2:	74a2                	ld	s1,40(sp)
  c4:	7902                	ld	s2,32(sp)
  c6:	69e2                	ld	s3,24(sp)
  c8:	6121                	addi	sp,sp,64
  ca:	8082                	ret

00000000000000cc <main>:


int main(int argc, char *argv[])
{
  cc:	7179                	addi	sp,sp,-48
  ce:	f406                	sd	ra,40(sp)
  d0:	f022                	sd	s0,32(sp)
  d2:	ec26                	sd	s1,24(sp)
  d4:	1800                	addi	s0,sp,48
    
    //create pipeline
    int fir[2];
    pipe(fir);
  d6:	fd840513          	addi	a0,s0,-40
  da:	00000097          	auipc	ra,0x0
  de:	304080e7          	jalr	772(ra) # 3de <pipe>
    if(fork()>0){
  e2:	00000097          	auipc	ra,0x0
  e6:	2e4080e7          	jalr	740(ra) # 3c6 <fork>
  ea:	04a05f63          	blez	a0,148 <main+0x7c>
        //write all number 
        //init
        close(fir[0]);
  ee:	fd842503          	lw	a0,-40(s0)
  f2:	00000097          	auipc	ra,0x0
  f6:	304080e7          	jalr	772(ra) # 3f6 <close>
        for(int i=2;i<=35;i++)
  fa:	4789                	li	a5,2
  fc:	fcf42a23          	sw	a5,-44(s0)
 100:	02300493          	li	s1,35
            write(fir[1],&i,sizeof(int));
 104:	4611                	li	a2,4
 106:	fd440593          	addi	a1,s0,-44
 10a:	fdc42503          	lw	a0,-36(s0)
 10e:	00000097          	auipc	ra,0x0
 112:	2e0080e7          	jalr	736(ra) # 3ee <write>
        for(int i=2;i<=35;i++)
 116:	fd442783          	lw	a5,-44(s0)
 11a:	2785                	addiw	a5,a5,1
 11c:	0007871b          	sext.w	a4,a5
 120:	fcf42a23          	sw	a5,-44(s0)
 124:	fee4d0e3          	bge	s1,a4,104 <main+0x38>
        close(fir[1]);
 128:	fdc42503          	lw	a0,-36(s0)
 12c:	00000097          	auipc	ra,0x0
 130:	2ca080e7          	jalr	714(ra) # 3f6 <close>
        wait(0);
 134:	4501                	li	a0,0
 136:	00000097          	auipc	ra,0x0
 13a:	2a0080e7          	jalr	672(ra) # 3d6 <wait>
    }
    else{
        close(fir[1]);
        getnewprime(fir[0]);
    }
    exit(0);
 13e:	4501                	li	a0,0
 140:	00000097          	auipc	ra,0x0
 144:	28e080e7          	jalr	654(ra) # 3ce <exit>
        close(fir[1]);
 148:	fdc42503          	lw	a0,-36(s0)
 14c:	00000097          	auipc	ra,0x0
 150:	2aa080e7          	jalr	682(ra) # 3f6 <close>
        getnewprime(fir[0]);
 154:	fd842503          	lw	a0,-40(s0)
 158:	00000097          	auipc	ra,0x0
 15c:	ea8080e7          	jalr	-344(ra) # 0 <getnewprime>
 160:	bff9                	j	13e <main+0x72>

0000000000000162 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 162:	1141                	addi	sp,sp,-16
 164:	e422                	sd	s0,8(sp)
 166:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 168:	87aa                	mv	a5,a0
 16a:	0585                	addi	a1,a1,1
 16c:	0785                	addi	a5,a5,1
 16e:	fff5c703          	lbu	a4,-1(a1)
 172:	fee78fa3          	sb	a4,-1(a5)
 176:	fb75                	bnez	a4,16a <strcpy+0x8>
    ;
  return os;
}
 178:	6422                	ld	s0,8(sp)
 17a:	0141                	addi	sp,sp,16
 17c:	8082                	ret

000000000000017e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 17e:	1141                	addi	sp,sp,-16
 180:	e422                	sd	s0,8(sp)
 182:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 184:	00054783          	lbu	a5,0(a0)
 188:	cb91                	beqz	a5,19c <strcmp+0x1e>
 18a:	0005c703          	lbu	a4,0(a1)
 18e:	00f71763          	bne	a4,a5,19c <strcmp+0x1e>
    p++, q++;
 192:	0505                	addi	a0,a0,1
 194:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 196:	00054783          	lbu	a5,0(a0)
 19a:	fbe5                	bnez	a5,18a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 19c:	0005c503          	lbu	a0,0(a1)
}
 1a0:	40a7853b          	subw	a0,a5,a0
 1a4:	6422                	ld	s0,8(sp)
 1a6:	0141                	addi	sp,sp,16
 1a8:	8082                	ret

00000000000001aa <strlen>:

uint
strlen(const char *s)
{
 1aa:	1141                	addi	sp,sp,-16
 1ac:	e422                	sd	s0,8(sp)
 1ae:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1b0:	00054783          	lbu	a5,0(a0)
 1b4:	cf91                	beqz	a5,1d0 <strlen+0x26>
 1b6:	0505                	addi	a0,a0,1
 1b8:	87aa                	mv	a5,a0
 1ba:	4685                	li	a3,1
 1bc:	9e89                	subw	a3,a3,a0
 1be:	00f6853b          	addw	a0,a3,a5
 1c2:	0785                	addi	a5,a5,1
 1c4:	fff7c703          	lbu	a4,-1(a5)
 1c8:	fb7d                	bnez	a4,1be <strlen+0x14>
    ;
  return n;
}
 1ca:	6422                	ld	s0,8(sp)
 1cc:	0141                	addi	sp,sp,16
 1ce:	8082                	ret
  for(n = 0; s[n]; n++)
 1d0:	4501                	li	a0,0
 1d2:	bfe5                	j	1ca <strlen+0x20>

00000000000001d4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d4:	1141                	addi	sp,sp,-16
 1d6:	e422                	sd	s0,8(sp)
 1d8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1da:	ca19                	beqz	a2,1f0 <memset+0x1c>
 1dc:	87aa                	mv	a5,a0
 1de:	1602                	slli	a2,a2,0x20
 1e0:	9201                	srli	a2,a2,0x20
 1e2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1e6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ea:	0785                	addi	a5,a5,1
 1ec:	fee79de3          	bne	a5,a4,1e6 <memset+0x12>
  }
  return dst;
}
 1f0:	6422                	ld	s0,8(sp)
 1f2:	0141                	addi	sp,sp,16
 1f4:	8082                	ret

00000000000001f6 <strchr>:

char*
strchr(const char *s, char c)
{
 1f6:	1141                	addi	sp,sp,-16
 1f8:	e422                	sd	s0,8(sp)
 1fa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1fc:	00054783          	lbu	a5,0(a0)
 200:	cb99                	beqz	a5,216 <strchr+0x20>
    if(*s == c)
 202:	00f58763          	beq	a1,a5,210 <strchr+0x1a>
  for(; *s; s++)
 206:	0505                	addi	a0,a0,1
 208:	00054783          	lbu	a5,0(a0)
 20c:	fbfd                	bnez	a5,202 <strchr+0xc>
      return (char*)s;
  return 0;
 20e:	4501                	li	a0,0
}
 210:	6422                	ld	s0,8(sp)
 212:	0141                	addi	sp,sp,16
 214:	8082                	ret
  return 0;
 216:	4501                	li	a0,0
 218:	bfe5                	j	210 <strchr+0x1a>

000000000000021a <gets>:

char*
gets(char *buf, int max)
{
 21a:	711d                	addi	sp,sp,-96
 21c:	ec86                	sd	ra,88(sp)
 21e:	e8a2                	sd	s0,80(sp)
 220:	e4a6                	sd	s1,72(sp)
 222:	e0ca                	sd	s2,64(sp)
 224:	fc4e                	sd	s3,56(sp)
 226:	f852                	sd	s4,48(sp)
 228:	f456                	sd	s5,40(sp)
 22a:	f05a                	sd	s6,32(sp)
 22c:	ec5e                	sd	s7,24(sp)
 22e:	1080                	addi	s0,sp,96
 230:	8baa                	mv	s7,a0
 232:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 234:	892a                	mv	s2,a0
 236:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 238:	4aa9                	li	s5,10
 23a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 23c:	89a6                	mv	s3,s1
 23e:	2485                	addiw	s1,s1,1
 240:	0344d863          	bge	s1,s4,270 <gets+0x56>
    cc = read(0, &c, 1);
 244:	4605                	li	a2,1
 246:	faf40593          	addi	a1,s0,-81
 24a:	4501                	li	a0,0
 24c:	00000097          	auipc	ra,0x0
 250:	19a080e7          	jalr	410(ra) # 3e6 <read>
    if(cc < 1)
 254:	00a05e63          	blez	a0,270 <gets+0x56>
    buf[i++] = c;
 258:	faf44783          	lbu	a5,-81(s0)
 25c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 260:	01578763          	beq	a5,s5,26e <gets+0x54>
 264:	0905                	addi	s2,s2,1
 266:	fd679be3          	bne	a5,s6,23c <gets+0x22>
  for(i=0; i+1 < max; ){
 26a:	89a6                	mv	s3,s1
 26c:	a011                	j	270 <gets+0x56>
 26e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 270:	99de                	add	s3,s3,s7
 272:	00098023          	sb	zero,0(s3)
  return buf;
}
 276:	855e                	mv	a0,s7
 278:	60e6                	ld	ra,88(sp)
 27a:	6446                	ld	s0,80(sp)
 27c:	64a6                	ld	s1,72(sp)
 27e:	6906                	ld	s2,64(sp)
 280:	79e2                	ld	s3,56(sp)
 282:	7a42                	ld	s4,48(sp)
 284:	7aa2                	ld	s5,40(sp)
 286:	7b02                	ld	s6,32(sp)
 288:	6be2                	ld	s7,24(sp)
 28a:	6125                	addi	sp,sp,96
 28c:	8082                	ret

000000000000028e <stat>:

int
stat(const char *n, struct stat *st)
{
 28e:	1101                	addi	sp,sp,-32
 290:	ec06                	sd	ra,24(sp)
 292:	e822                	sd	s0,16(sp)
 294:	e426                	sd	s1,8(sp)
 296:	e04a                	sd	s2,0(sp)
 298:	1000                	addi	s0,sp,32
 29a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 29c:	4581                	li	a1,0
 29e:	00000097          	auipc	ra,0x0
 2a2:	170080e7          	jalr	368(ra) # 40e <open>
  if(fd < 0)
 2a6:	02054563          	bltz	a0,2d0 <stat+0x42>
 2aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2ac:	85ca                	mv	a1,s2
 2ae:	00000097          	auipc	ra,0x0
 2b2:	178080e7          	jalr	376(ra) # 426 <fstat>
 2b6:	892a                	mv	s2,a0
  close(fd);
 2b8:	8526                	mv	a0,s1
 2ba:	00000097          	auipc	ra,0x0
 2be:	13c080e7          	jalr	316(ra) # 3f6 <close>
  return r;
}
 2c2:	854a                	mv	a0,s2
 2c4:	60e2                	ld	ra,24(sp)
 2c6:	6442                	ld	s0,16(sp)
 2c8:	64a2                	ld	s1,8(sp)
 2ca:	6902                	ld	s2,0(sp)
 2cc:	6105                	addi	sp,sp,32
 2ce:	8082                	ret
    return -1;
 2d0:	597d                	li	s2,-1
 2d2:	bfc5                	j	2c2 <stat+0x34>

00000000000002d4 <atoi>:

int
atoi(const char *s)
{
 2d4:	1141                	addi	sp,sp,-16
 2d6:	e422                	sd	s0,8(sp)
 2d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2da:	00054683          	lbu	a3,0(a0)
 2de:	fd06879b          	addiw	a5,a3,-48
 2e2:	0ff7f793          	zext.b	a5,a5
 2e6:	4625                	li	a2,9
 2e8:	02f66863          	bltu	a2,a5,318 <atoi+0x44>
 2ec:	872a                	mv	a4,a0
  n = 0;
 2ee:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2f0:	0705                	addi	a4,a4,1
 2f2:	0025179b          	slliw	a5,a0,0x2
 2f6:	9fa9                	addw	a5,a5,a0
 2f8:	0017979b          	slliw	a5,a5,0x1
 2fc:	9fb5                	addw	a5,a5,a3
 2fe:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 302:	00074683          	lbu	a3,0(a4)
 306:	fd06879b          	addiw	a5,a3,-48
 30a:	0ff7f793          	zext.b	a5,a5
 30e:	fef671e3          	bgeu	a2,a5,2f0 <atoi+0x1c>
  return n;
}
 312:	6422                	ld	s0,8(sp)
 314:	0141                	addi	sp,sp,16
 316:	8082                	ret
  n = 0;
 318:	4501                	li	a0,0
 31a:	bfe5                	j	312 <atoi+0x3e>

000000000000031c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 322:	02b57463          	bgeu	a0,a1,34a <memmove+0x2e>
    while(n-- > 0)
 326:	00c05f63          	blez	a2,344 <memmove+0x28>
 32a:	1602                	slli	a2,a2,0x20
 32c:	9201                	srli	a2,a2,0x20
 32e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 332:	872a                	mv	a4,a0
      *dst++ = *src++;
 334:	0585                	addi	a1,a1,1
 336:	0705                	addi	a4,a4,1
 338:	fff5c683          	lbu	a3,-1(a1)
 33c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 340:	fee79ae3          	bne	a5,a4,334 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 344:	6422                	ld	s0,8(sp)
 346:	0141                	addi	sp,sp,16
 348:	8082                	ret
    dst += n;
 34a:	00c50733          	add	a4,a0,a2
    src += n;
 34e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 350:	fec05ae3          	blez	a2,344 <memmove+0x28>
 354:	fff6079b          	addiw	a5,a2,-1
 358:	1782                	slli	a5,a5,0x20
 35a:	9381                	srli	a5,a5,0x20
 35c:	fff7c793          	not	a5,a5
 360:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 362:	15fd                	addi	a1,a1,-1
 364:	177d                	addi	a4,a4,-1
 366:	0005c683          	lbu	a3,0(a1)
 36a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 36e:	fee79ae3          	bne	a5,a4,362 <memmove+0x46>
 372:	bfc9                	j	344 <memmove+0x28>

0000000000000374 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 374:	1141                	addi	sp,sp,-16
 376:	e422                	sd	s0,8(sp)
 378:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 37a:	ca05                	beqz	a2,3aa <memcmp+0x36>
 37c:	fff6069b          	addiw	a3,a2,-1
 380:	1682                	slli	a3,a3,0x20
 382:	9281                	srli	a3,a3,0x20
 384:	0685                	addi	a3,a3,1
 386:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 388:	00054783          	lbu	a5,0(a0)
 38c:	0005c703          	lbu	a4,0(a1)
 390:	00e79863          	bne	a5,a4,3a0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 394:	0505                	addi	a0,a0,1
    p2++;
 396:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 398:	fed518e3          	bne	a0,a3,388 <memcmp+0x14>
  }
  return 0;
 39c:	4501                	li	a0,0
 39e:	a019                	j	3a4 <memcmp+0x30>
      return *p1 - *p2;
 3a0:	40e7853b          	subw	a0,a5,a4
}
 3a4:	6422                	ld	s0,8(sp)
 3a6:	0141                	addi	sp,sp,16
 3a8:	8082                	ret
  return 0;
 3aa:	4501                	li	a0,0
 3ac:	bfe5                	j	3a4 <memcmp+0x30>

00000000000003ae <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b6:	00000097          	auipc	ra,0x0
 3ba:	f66080e7          	jalr	-154(ra) # 31c <memmove>
}
 3be:	60a2                	ld	ra,8(sp)
 3c0:	6402                	ld	s0,0(sp)
 3c2:	0141                	addi	sp,sp,16
 3c4:	8082                	ret

00000000000003c6 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c6:	4885                	li	a7,1
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <exit>:
.global exit
exit:
 li a7, SYS_exit
 3ce:	4889                	li	a7,2
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d6:	488d                	li	a7,3
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3de:	4891                	li	a7,4
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <read>:
.global read
read:
 li a7, SYS_read
 3e6:	4895                	li	a7,5
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <write>:
.global write
write:
 li a7, SYS_write
 3ee:	48c1                	li	a7,16
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <close>:
.global close
close:
 li a7, SYS_close
 3f6:	48d5                	li	a7,21
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fe:	4899                	li	a7,6
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exec>:
.global exec
exec:
 li a7, SYS_exec
 406:	489d                	li	a7,7
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <open>:
.global open
open:
 li a7, SYS_open
 40e:	48bd                	li	a7,15
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 416:	48c5                	li	a7,17
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41e:	48c9                	li	a7,18
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 426:	48a1                	li	a7,8
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <link>:
.global link
link:
 li a7, SYS_link
 42e:	48cd                	li	a7,19
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 436:	48d1                	li	a7,20
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43e:	48a5                	li	a7,9
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <dup>:
.global dup
dup:
 li a7, SYS_dup
 446:	48a9                	li	a7,10
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44e:	48ad                	li	a7,11
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 456:	48b1                	li	a7,12
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 45e:	48b5                	li	a7,13
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 466:	48b9                	li	a7,14
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46e:	1101                	addi	sp,sp,-32
 470:	ec06                	sd	ra,24(sp)
 472:	e822                	sd	s0,16(sp)
 474:	1000                	addi	s0,sp,32
 476:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47a:	4605                	li	a2,1
 47c:	fef40593          	addi	a1,s0,-17
 480:	00000097          	auipc	ra,0x0
 484:	f6e080e7          	jalr	-146(ra) # 3ee <write>
}
 488:	60e2                	ld	ra,24(sp)
 48a:	6442                	ld	s0,16(sp)
 48c:	6105                	addi	sp,sp,32
 48e:	8082                	ret

0000000000000490 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 490:	7139                	addi	sp,sp,-64
 492:	fc06                	sd	ra,56(sp)
 494:	f822                	sd	s0,48(sp)
 496:	f426                	sd	s1,40(sp)
 498:	f04a                	sd	s2,32(sp)
 49a:	ec4e                	sd	s3,24(sp)
 49c:	0080                	addi	s0,sp,64
 49e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4a0:	c299                	beqz	a3,4a6 <printint+0x16>
 4a2:	0805c963          	bltz	a1,534 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a6:	2581                	sext.w	a1,a1
  neg = 0;
 4a8:	4881                	li	a7,0
 4aa:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4ae:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4b0:	2601                	sext.w	a2,a2
 4b2:	00000517          	auipc	a0,0x0
 4b6:	4a650513          	addi	a0,a0,1190 # 958 <digits>
 4ba:	883a                	mv	a6,a4
 4bc:	2705                	addiw	a4,a4,1
 4be:	02c5f7bb          	remuw	a5,a1,a2
 4c2:	1782                	slli	a5,a5,0x20
 4c4:	9381                	srli	a5,a5,0x20
 4c6:	97aa                	add	a5,a5,a0
 4c8:	0007c783          	lbu	a5,0(a5)
 4cc:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4d0:	0005879b          	sext.w	a5,a1
 4d4:	02c5d5bb          	divuw	a1,a1,a2
 4d8:	0685                	addi	a3,a3,1
 4da:	fec7f0e3          	bgeu	a5,a2,4ba <printint+0x2a>
  if(neg)
 4de:	00088c63          	beqz	a7,4f6 <printint+0x66>
    buf[i++] = '-';
 4e2:	fd070793          	addi	a5,a4,-48
 4e6:	00878733          	add	a4,a5,s0
 4ea:	02d00793          	li	a5,45
 4ee:	fef70823          	sb	a5,-16(a4)
 4f2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4f6:	02e05863          	blez	a4,526 <printint+0x96>
 4fa:	fc040793          	addi	a5,s0,-64
 4fe:	00e78933          	add	s2,a5,a4
 502:	fff78993          	addi	s3,a5,-1
 506:	99ba                	add	s3,s3,a4
 508:	377d                	addiw	a4,a4,-1
 50a:	1702                	slli	a4,a4,0x20
 50c:	9301                	srli	a4,a4,0x20
 50e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 512:	fff94583          	lbu	a1,-1(s2)
 516:	8526                	mv	a0,s1
 518:	00000097          	auipc	ra,0x0
 51c:	f56080e7          	jalr	-170(ra) # 46e <putc>
  while(--i >= 0)
 520:	197d                	addi	s2,s2,-1
 522:	ff3918e3          	bne	s2,s3,512 <printint+0x82>
}
 526:	70e2                	ld	ra,56(sp)
 528:	7442                	ld	s0,48(sp)
 52a:	74a2                	ld	s1,40(sp)
 52c:	7902                	ld	s2,32(sp)
 52e:	69e2                	ld	s3,24(sp)
 530:	6121                	addi	sp,sp,64
 532:	8082                	ret
    x = -xx;
 534:	40b005bb          	negw	a1,a1
    neg = 1;
 538:	4885                	li	a7,1
    x = -xx;
 53a:	bf85                	j	4aa <printint+0x1a>

000000000000053c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53c:	7119                	addi	sp,sp,-128
 53e:	fc86                	sd	ra,120(sp)
 540:	f8a2                	sd	s0,112(sp)
 542:	f4a6                	sd	s1,104(sp)
 544:	f0ca                	sd	s2,96(sp)
 546:	ecce                	sd	s3,88(sp)
 548:	e8d2                	sd	s4,80(sp)
 54a:	e4d6                	sd	s5,72(sp)
 54c:	e0da                	sd	s6,64(sp)
 54e:	fc5e                	sd	s7,56(sp)
 550:	f862                	sd	s8,48(sp)
 552:	f466                	sd	s9,40(sp)
 554:	f06a                	sd	s10,32(sp)
 556:	ec6e                	sd	s11,24(sp)
 558:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 55a:	0005c903          	lbu	s2,0(a1)
 55e:	18090f63          	beqz	s2,6fc <vprintf+0x1c0>
 562:	8aaa                	mv	s5,a0
 564:	8b32                	mv	s6,a2
 566:	00158493          	addi	s1,a1,1
  state = 0;
 56a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 56c:	02500a13          	li	s4,37
 570:	4c55                	li	s8,21
 572:	00000c97          	auipc	s9,0x0
 576:	38ec8c93          	addi	s9,s9,910 # 900 <malloc+0x100>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 57a:	02800d93          	li	s11,40
  putc(fd, 'x');
 57e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 580:	00000b97          	auipc	s7,0x0
 584:	3d8b8b93          	addi	s7,s7,984 # 958 <digits>
 588:	a839                	j	5a6 <vprintf+0x6a>
        putc(fd, c);
 58a:	85ca                	mv	a1,s2
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	ee0080e7          	jalr	-288(ra) # 46e <putc>
 596:	a019                	j	59c <vprintf+0x60>
    } else if(state == '%'){
 598:	01498d63          	beq	s3,s4,5b2 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 59c:	0485                	addi	s1,s1,1
 59e:	fff4c903          	lbu	s2,-1(s1)
 5a2:	14090d63          	beqz	s2,6fc <vprintf+0x1c0>
    if(state == 0){
 5a6:	fe0999e3          	bnez	s3,598 <vprintf+0x5c>
      if(c == '%'){
 5aa:	ff4910e3          	bne	s2,s4,58a <vprintf+0x4e>
        state = '%';
 5ae:	89d2                	mv	s3,s4
 5b0:	b7f5                	j	59c <vprintf+0x60>
      if(c == 'd'){
 5b2:	11490c63          	beq	s2,s4,6ca <vprintf+0x18e>
 5b6:	f9d9079b          	addiw	a5,s2,-99
 5ba:	0ff7f793          	zext.b	a5,a5
 5be:	10fc6e63          	bltu	s8,a5,6da <vprintf+0x19e>
 5c2:	f9d9079b          	addiw	a5,s2,-99
 5c6:	0ff7f713          	zext.b	a4,a5
 5ca:	10ec6863          	bltu	s8,a4,6da <vprintf+0x19e>
 5ce:	00271793          	slli	a5,a4,0x2
 5d2:	97e6                	add	a5,a5,s9
 5d4:	439c                	lw	a5,0(a5)
 5d6:	97e6                	add	a5,a5,s9
 5d8:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5da:	008b0913          	addi	s2,s6,8
 5de:	4685                	li	a3,1
 5e0:	4629                	li	a2,10
 5e2:	000b2583          	lw	a1,0(s6)
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	ea8080e7          	jalr	-344(ra) # 490 <printint>
 5f0:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f2:	4981                	li	s3,0
 5f4:	b765                	j	59c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f6:	008b0913          	addi	s2,s6,8
 5fa:	4681                	li	a3,0
 5fc:	4629                	li	a2,10
 5fe:	000b2583          	lw	a1,0(s6)
 602:	8556                	mv	a0,s5
 604:	00000097          	auipc	ra,0x0
 608:	e8c080e7          	jalr	-372(ra) # 490 <printint>
 60c:	8b4a                	mv	s6,s2
      state = 0;
 60e:	4981                	li	s3,0
 610:	b771                	j	59c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 612:	008b0913          	addi	s2,s6,8
 616:	4681                	li	a3,0
 618:	866a                	mv	a2,s10
 61a:	000b2583          	lw	a1,0(s6)
 61e:	8556                	mv	a0,s5
 620:	00000097          	auipc	ra,0x0
 624:	e70080e7          	jalr	-400(ra) # 490 <printint>
 628:	8b4a                	mv	s6,s2
      state = 0;
 62a:	4981                	li	s3,0
 62c:	bf85                	j	59c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 62e:	008b0793          	addi	a5,s6,8
 632:	f8f43423          	sd	a5,-120(s0)
 636:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 63a:	03000593          	li	a1,48
 63e:	8556                	mv	a0,s5
 640:	00000097          	auipc	ra,0x0
 644:	e2e080e7          	jalr	-466(ra) # 46e <putc>
  putc(fd, 'x');
 648:	07800593          	li	a1,120
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	e20080e7          	jalr	-480(ra) # 46e <putc>
 656:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 658:	03c9d793          	srli	a5,s3,0x3c
 65c:	97de                	add	a5,a5,s7
 65e:	0007c583          	lbu	a1,0(a5)
 662:	8556                	mv	a0,s5
 664:	00000097          	auipc	ra,0x0
 668:	e0a080e7          	jalr	-502(ra) # 46e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66c:	0992                	slli	s3,s3,0x4
 66e:	397d                	addiw	s2,s2,-1
 670:	fe0914e3          	bnez	s2,658 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 674:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 678:	4981                	li	s3,0
 67a:	b70d                	j	59c <vprintf+0x60>
        s = va_arg(ap, char*);
 67c:	008b0913          	addi	s2,s6,8
 680:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 684:	02098163          	beqz	s3,6a6 <vprintf+0x16a>
        while(*s != 0){
 688:	0009c583          	lbu	a1,0(s3)
 68c:	c5ad                	beqz	a1,6f6 <vprintf+0x1ba>
          putc(fd, *s);
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	dde080e7          	jalr	-546(ra) # 46e <putc>
          s++;
 698:	0985                	addi	s3,s3,1
        while(*s != 0){
 69a:	0009c583          	lbu	a1,0(s3)
 69e:	f9e5                	bnez	a1,68e <vprintf+0x152>
        s = va_arg(ap, char*);
 6a0:	8b4a                	mv	s6,s2
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	bde5                	j	59c <vprintf+0x60>
          s = "(null)";
 6a6:	00000997          	auipc	s3,0x0
 6aa:	25298993          	addi	s3,s3,594 # 8f8 <malloc+0xf8>
        while(*s != 0){
 6ae:	85ee                	mv	a1,s11
 6b0:	bff9                	j	68e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 6b2:	008b0913          	addi	s2,s6,8
 6b6:	000b4583          	lbu	a1,0(s6)
 6ba:	8556                	mv	a0,s5
 6bc:	00000097          	auipc	ra,0x0
 6c0:	db2080e7          	jalr	-590(ra) # 46e <putc>
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	bdd1                	j	59c <vprintf+0x60>
        putc(fd, c);
 6ca:	85d2                	mv	a1,s4
 6cc:	8556                	mv	a0,s5
 6ce:	00000097          	auipc	ra,0x0
 6d2:	da0080e7          	jalr	-608(ra) # 46e <putc>
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	b5d1                	j	59c <vprintf+0x60>
        putc(fd, '%');
 6da:	85d2                	mv	a1,s4
 6dc:	8556                	mv	a0,s5
 6de:	00000097          	auipc	ra,0x0
 6e2:	d90080e7          	jalr	-624(ra) # 46e <putc>
        putc(fd, c);
 6e6:	85ca                	mv	a1,s2
 6e8:	8556                	mv	a0,s5
 6ea:	00000097          	auipc	ra,0x0
 6ee:	d84080e7          	jalr	-636(ra) # 46e <putc>
      state = 0;
 6f2:	4981                	li	s3,0
 6f4:	b565                	j	59c <vprintf+0x60>
        s = va_arg(ap, char*);
 6f6:	8b4a                	mv	s6,s2
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	b54d                	j	59c <vprintf+0x60>
    }
  }
}
 6fc:	70e6                	ld	ra,120(sp)
 6fe:	7446                	ld	s0,112(sp)
 700:	74a6                	ld	s1,104(sp)
 702:	7906                	ld	s2,96(sp)
 704:	69e6                	ld	s3,88(sp)
 706:	6a46                	ld	s4,80(sp)
 708:	6aa6                	ld	s5,72(sp)
 70a:	6b06                	ld	s6,64(sp)
 70c:	7be2                	ld	s7,56(sp)
 70e:	7c42                	ld	s8,48(sp)
 710:	7ca2                	ld	s9,40(sp)
 712:	7d02                	ld	s10,32(sp)
 714:	6de2                	ld	s11,24(sp)
 716:	6109                	addi	sp,sp,128
 718:	8082                	ret

000000000000071a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71a:	715d                	addi	sp,sp,-80
 71c:	ec06                	sd	ra,24(sp)
 71e:	e822                	sd	s0,16(sp)
 720:	1000                	addi	s0,sp,32
 722:	e010                	sd	a2,0(s0)
 724:	e414                	sd	a3,8(s0)
 726:	e818                	sd	a4,16(s0)
 728:	ec1c                	sd	a5,24(s0)
 72a:	03043023          	sd	a6,32(s0)
 72e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 732:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 736:	8622                	mv	a2,s0
 738:	00000097          	auipc	ra,0x0
 73c:	e04080e7          	jalr	-508(ra) # 53c <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6161                	addi	sp,sp,80
 746:	8082                	ret

0000000000000748 <printf>:

void
printf(const char *fmt, ...)
{
 748:	711d                	addi	sp,sp,-96
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	addi	s0,sp,32
 750:	e40c                	sd	a1,8(s0)
 752:	e810                	sd	a2,16(s0)
 754:	ec14                	sd	a3,24(s0)
 756:	f018                	sd	a4,32(s0)
 758:	f41c                	sd	a5,40(s0)
 75a:	03043823          	sd	a6,48(s0)
 75e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	00840613          	addi	a2,s0,8
 766:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76a:	85aa                	mv	a1,a0
 76c:	4505                	li	a0,1
 76e:	00000097          	auipc	ra,0x0
 772:	dce080e7          	jalr	-562(ra) # 53c <vprintf>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret

000000000000077e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	1141                	addi	sp,sp,-16
 780:	e422                	sd	s0,8(sp)
 782:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 784:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00000797          	auipc	a5,0x0
 78c:	1e87b783          	ld	a5,488(a5) # 970 <freep>
 790:	a02d                	j	7ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 792:	4618                	lw	a4,8(a2)
 794:	9f2d                	addw	a4,a4,a1
 796:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	6310                	ld	a2,0(a4)
 79e:	a83d                	j	7dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9f31                	addw	a4,a4,a2
 7a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053683          	ld	a3,-16(a0)
 7ac:	a091                	j	7f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e7e463          	bltu	a5,a4,7b8 <free+0x3a>
 7b4:	00e6ea63          	bltu	a3,a4,7c8 <free+0x4a>
{
 7b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	fed7fae3          	bgeu	a5,a3,7ae <free+0x30>
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e6e463          	bltu	a3,a4,7c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	fee7eae3          	bltu	a5,a4,7b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7c8:	ff852583          	lw	a1,-8(a0)
 7cc:	6390                	ld	a2,0(a5)
 7ce:	02059813          	slli	a6,a1,0x20
 7d2:	01c85713          	srli	a4,a6,0x1c
 7d6:	9736                	add	a4,a4,a3
 7d8:	fae60de3          	beq	a2,a4,792 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e0:	4790                	lw	a2,8(a5)
 7e2:	02061593          	slli	a1,a2,0x20
 7e6:	01c5d713          	srli	a4,a1,0x1c
 7ea:	973e                	add	a4,a4,a5
 7ec:	fae68ae3          	beq	a3,a4,7a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f2:	00000717          	auipc	a4,0x0
 7f6:	16f73f23          	sd	a5,382(a4) # 970 <freep>
}
 7fa:	6422                	ld	s0,8(sp)
 7fc:	0141                	addi	sp,sp,16
 7fe:	8082                	ret

0000000000000800 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 800:	7139                	addi	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f426                	sd	s1,40(sp)
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	e852                	sd	s4,16(sp)
 80e:	e456                	sd	s5,8(sp)
 810:	e05a                	sd	s6,0(sp)
 812:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 814:	02051493          	slli	s1,a0,0x20
 818:	9081                	srli	s1,s1,0x20
 81a:	04bd                	addi	s1,s1,15
 81c:	8091                	srli	s1,s1,0x4
 81e:	0014899b          	addiw	s3,s1,1
 822:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 824:	00000517          	auipc	a0,0x0
 828:	14c53503          	ld	a0,332(a0) # 970 <freep>
 82c:	c515                	beqz	a0,858 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 830:	4798                	lw	a4,8(a5)
 832:	02977f63          	bgeu	a4,s1,870 <malloc+0x70>
 836:	8a4e                	mv	s4,s3
 838:	0009871b          	sext.w	a4,s3
 83c:	6685                	lui	a3,0x1
 83e:	00d77363          	bgeu	a4,a3,844 <malloc+0x44>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84c:	00000917          	auipc	s2,0x0
 850:	12490913          	addi	s2,s2,292 # 970 <freep>
  if(p == (char*)-1)
 854:	5afd                	li	s5,-1
 856:	a895                	j	8ca <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 858:	00000797          	auipc	a5,0x0
 85c:	12078793          	addi	a5,a5,288 # 978 <base>
 860:	00000717          	auipc	a4,0x0
 864:	10f73823          	sd	a5,272(a4) # 970 <freep>
 868:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86e:	b7e1                	j	836 <malloc+0x36>
      if(p->s.size == nunits)
 870:	02e48c63          	beq	s1,a4,8a8 <malloc+0xa8>
        p->s.size -= nunits;
 874:	4137073b          	subw	a4,a4,s3
 878:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87a:	02071693          	slli	a3,a4,0x20
 87e:	01c6d713          	srli	a4,a3,0x1c
 882:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 884:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 888:	00000717          	auipc	a4,0x0
 88c:	0ea73423          	sd	a0,232(a4) # 970 <freep>
      return (void*)(p + 1);
 890:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 894:	70e2                	ld	ra,56(sp)
 896:	7442                	ld	s0,48(sp)
 898:	74a2                	ld	s1,40(sp)
 89a:	7902                	ld	s2,32(sp)
 89c:	69e2                	ld	s3,24(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	6121                	addi	sp,sp,64
 8a6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a8:	6398                	ld	a4,0(a5)
 8aa:	e118                	sd	a4,0(a0)
 8ac:	bff1                	j	888 <malloc+0x88>
  hp->s.size = nu;
 8ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b2:	0541                	addi	a0,a0,16
 8b4:	00000097          	auipc	ra,0x0
 8b8:	eca080e7          	jalr	-310(ra) # 77e <free>
  return freep;
 8bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c0:	d971                	beqz	a0,894 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	fa9775e3          	bgeu	a4,s1,870 <malloc+0x70>
    if(p == freep)
 8ca:	00093703          	ld	a4,0(s2)
 8ce:	853e                	mv	a0,a5
 8d0:	fef719e3          	bne	a4,a5,8c2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8d4:	8552                	mv	a0,s4
 8d6:	00000097          	auipc	ra,0x0
 8da:	b80080e7          	jalr	-1152(ra) # 456 <sbrk>
  if(p == (char*)-1)
 8de:	fd5518e3          	bne	a0,s5,8ae <malloc+0xae>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	bf45                	j	894 <malloc+0x94>
