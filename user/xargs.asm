
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/param.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
   0:	710d                	addi	sp,sp,-352
   2:	ee86                	sd	ra,344(sp)
   4:	eaa2                	sd	s0,336(sp)
   6:	e6a6                	sd	s1,328(sp)
   8:	e2ca                	sd	s2,320(sp)
   a:	fe4e                	sd	s3,312(sp)
   c:	fa52                	sd	s4,304(sp)
   e:	f656                	sd	s5,296(sp)
  10:	1280                	addi	s0,sp,352
    if(argc <2){
  12:	4785                	li	a5,1
  14:	04a7da63          	bge	a5,a0,68 <main+0x68>
  18:	892a                	mv	s2,a0
  1a:	89ae                	mv	s3,a1
        exit(1);
    }
    int p[2];
    char s;
    char *newargv[MAXARG];
    pipe(p);
  1c:	fb840513          	addi	a0,s0,-72
  20:	00000097          	auipc	ra,0x0
  24:	454080e7          	jalr	1108(ra) # 474 <pipe>
    if(fork()==0){
  28:	00000097          	auipc	ra,0x0
  2c:	434080e7          	jalr	1076(ra) # 45c <fork>
  30:	8a2a                	mv	s4,a0
  32:	e565                	bnez	a0,11a <main+0x11a>
        int i=0,j=1;
        close(p[1]);
  34:	fbc42503          	lw	a0,-68(s0)
  38:	00000097          	auipc	ra,0x0
  3c:	454080e7          	jalr	1108(ra) # 48c <close>
        newargv[0]=malloc(32);
  40:	02000513          	li	a0,32
  44:	00001097          	auipc	ra,0x1
  48:	852080e7          	jalr	-1966(ra) # 896 <malloc>
  4c:	eaa43823          	sd	a0,-336(s0)
        newargv[1]=malloc(32);
  50:	02000513          	li	a0,32
  54:	00001097          	auipc	ra,0x1
  58:	842080e7          	jalr	-1982(ra) # 896 <malloc>
  5c:	eaa43c23          	sd	a0,-328(s0)
        int i=0,j=1;
  60:	84d2                	mv	s1,s4
  62:	4905                	li	s2,1
        int t;
        //get
        while(read(p[0],&t,1)!=0){
            if(t!='\n'){
  64:	4aa9                	li	s5,10
        while(read(p[0],&t,1)!=0){
  66:	a0b9                	j	b4 <main+0xb4>
        printf("Please change your parameter numbers!");
  68:	00001517          	auipc	a0,0x1
  6c:	91850513          	addi	a0,a0,-1768 # 980 <malloc+0xea>
  70:	00000097          	auipc	ra,0x0
  74:	76e080e7          	jalr	1902(ra) # 7de <printf>
        exit(1);
  78:	4505                	li	a0,1
  7a:	00000097          	auipc	ra,0x0
  7e:	3ea080e7          	jalr	1002(ra) # 464 <exit>
                newargv[j][i++]=t;
            }
            else{
                newargv[j][i]='\0';
  82:	00391793          	slli	a5,s2,0x3
  86:	fc078793          	addi	a5,a5,-64
  8a:	97a2                	add	a5,a5,s0
  8c:	ef07b783          	ld	a5,-272(a5)
  90:	97a6                	add	a5,a5,s1
  92:	00078023          	sb	zero,0(a5)
                j++;
  96:	2905                	addiw	s2,s2,1
                newargv[j]=malloc(32);
  98:	02000513          	li	a0,32
  9c:	00000097          	auipc	ra,0x0
  a0:	7fa080e7          	jalr	2042(ra) # 896 <malloc>
  a4:	00391793          	slli	a5,s2,0x3
  a8:	fc078793          	addi	a5,a5,-64
  ac:	97a2                	add	a5,a5,s0
  ae:	eea7b823          	sd	a0,-272(a5)
                i=0;
  b2:	84d2                	mv	s1,s4
        while(read(p[0],&t,1)!=0){
  b4:	4605                	li	a2,1
  b6:	eac40593          	addi	a1,s0,-340
  ba:	fb842503          	lw	a0,-72(s0)
  be:	00000097          	auipc	ra,0x0
  c2:	3be080e7          	jalr	958(ra) # 47c <read>
  c6:	c10d                	beqz	a0,e8 <main+0xe8>
            if(t!='\n'){
  c8:	eac42703          	lw	a4,-340(s0)
  cc:	fb570be3          	beq	a4,s5,82 <main+0x82>
                newargv[j][i++]=t;
  d0:	00391793          	slli	a5,s2,0x3
  d4:	fc078793          	addi	a5,a5,-64
  d8:	97a2                	add	a5,a5,s0
  da:	ef07b783          	ld	a5,-272(a5)
  de:	97a6                	add	a5,a5,s1
  e0:	00e78023          	sb	a4,0(a5)
  e4:	2485                	addiw	s1,s1,1
  e6:	b7f9                	j	b4 <main+0xb4>
            }
        }
        exec(argv[1],newargv);
  e8:	eb040593          	addi	a1,s0,-336
  ec:	0089b503          	ld	a0,8(s3)
  f0:	00000097          	auipc	ra,0x0
  f4:	3ac080e7          	jalr	940(ra) # 49c <exec>
        free(newargv);
  f8:	eb040513          	addi	a0,s0,-336
  fc:	00000097          	auipc	ra,0x0
 100:	718080e7          	jalr	1816(ra) # 814 <free>
        close(p[0]);
 104:	fb842503          	lw	a0,-72(s0)
 108:	00000097          	auipc	ra,0x0
 10c:	384080e7          	jalr	900(ra) # 48c <close>
        }
        write(p[1],"\n",1);
        close(p[1]);
        wait(0);
    }
    exit(0);
 110:	4501                	li	a0,0
 112:	00000097          	auipc	ra,0x0
 116:	352080e7          	jalr	850(ra) # 464 <exit>
        close(p[0]);
 11a:	fb842503          	lw	a0,-72(s0)
 11e:	00000097          	auipc	ra,0x0
 122:	36e080e7          	jalr	878(ra) # 48c <close>
        for(int i=2;i<argc;i++){
 126:	4789                	li	a5,2
 128:	0527db63          	bge	a5,s2,17e <main+0x17e>
 12c:	01098493          	addi	s1,s3,16
 130:	3975                	addiw	s2,s2,-3
 132:	02091793          	slli	a5,s2,0x20
 136:	01d7d913          	srli	s2,a5,0x1d
 13a:	09e1                	addi	s3,s3,24
 13c:	994e                	add	s2,s2,s3
            write(p[1],"\n",1);
 13e:	00001a97          	auipc	s5,0x1
 142:	86aa8a93          	addi	s5,s5,-1942 # 9a8 <malloc+0x112>
            write(p[1],argv[i],strlen(argv[i]));
 146:	fbc42a03          	lw	s4,-68(s0)
 14a:	0004b983          	ld	s3,0(s1)
 14e:	854e                	mv	a0,s3
 150:	00000097          	auipc	ra,0x0
 154:	0f0080e7          	jalr	240(ra) # 240 <strlen>
 158:	0005061b          	sext.w	a2,a0
 15c:	85ce                	mv	a1,s3
 15e:	8552                	mv	a0,s4
 160:	00000097          	auipc	ra,0x0
 164:	324080e7          	jalr	804(ra) # 484 <write>
            write(p[1],"\n",1);
 168:	4605                	li	a2,1
 16a:	85d6                	mv	a1,s5
 16c:	fbc42503          	lw	a0,-68(s0)
 170:	00000097          	auipc	ra,0x0
 174:	314080e7          	jalr	788(ra) # 484 <write>
        for(int i=2;i<argc;i++){
 178:	04a1                	addi	s1,s1,8
 17a:	fd2496e3          	bne	s1,s2,146 <main+0x146>
            if(s==' ')
 17e:	02000493          	li	s1,32
                write(p[1],"\n",1);
 182:	00001917          	auipc	s2,0x1
 186:	82690913          	addi	s2,s2,-2010 # 9a8 <malloc+0x112>
 18a:	a811                	j	19e <main+0x19e>
                write(p[1],&s,1);
 18c:	4605                	li	a2,1
 18e:	fb740593          	addi	a1,s0,-73
 192:	fbc42503          	lw	a0,-68(s0)
 196:	00000097          	auipc	ra,0x0
 19a:	2ee080e7          	jalr	750(ra) # 484 <write>
        while(read(0,&s,1)!=0){
 19e:	4605                	li	a2,1
 1a0:	fb740593          	addi	a1,s0,-73
 1a4:	4501                	li	a0,0
 1a6:	00000097          	auipc	ra,0x0
 1aa:	2d6080e7          	jalr	726(ra) # 47c <read>
 1ae:	cd11                	beqz	a0,1ca <main+0x1ca>
            if(s==' ')
 1b0:	fb744783          	lbu	a5,-73(s0)
 1b4:	fc979ce3          	bne	a5,s1,18c <main+0x18c>
                write(p[1],"\n",1);
 1b8:	4605                	li	a2,1
 1ba:	85ca                	mv	a1,s2
 1bc:	fbc42503          	lw	a0,-68(s0)
 1c0:	00000097          	auipc	ra,0x0
 1c4:	2c4080e7          	jalr	708(ra) # 484 <write>
 1c8:	bfd9                	j	19e <main+0x19e>
        write(p[1],"\n",1);
 1ca:	4605                	li	a2,1
 1cc:	00000597          	auipc	a1,0x0
 1d0:	7dc58593          	addi	a1,a1,2012 # 9a8 <malloc+0x112>
 1d4:	fbc42503          	lw	a0,-68(s0)
 1d8:	00000097          	auipc	ra,0x0
 1dc:	2ac080e7          	jalr	684(ra) # 484 <write>
        close(p[1]);
 1e0:	fbc42503          	lw	a0,-68(s0)
 1e4:	00000097          	auipc	ra,0x0
 1e8:	2a8080e7          	jalr	680(ra) # 48c <close>
        wait(0);
 1ec:	4501                	li	a0,0
 1ee:	00000097          	auipc	ra,0x0
 1f2:	27e080e7          	jalr	638(ra) # 46c <wait>
 1f6:	bf29                	j	110 <main+0x110>

00000000000001f8 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 1f8:	1141                	addi	sp,sp,-16
 1fa:	e422                	sd	s0,8(sp)
 1fc:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1fe:	87aa                	mv	a5,a0
 200:	0585                	addi	a1,a1,1
 202:	0785                	addi	a5,a5,1
 204:	fff5c703          	lbu	a4,-1(a1)
 208:	fee78fa3          	sb	a4,-1(a5)
 20c:	fb75                	bnez	a4,200 <strcpy+0x8>
    ;
  return os;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret

0000000000000214 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 214:	1141                	addi	sp,sp,-16
 216:	e422                	sd	s0,8(sp)
 218:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 21a:	00054783          	lbu	a5,0(a0)
 21e:	cb91                	beqz	a5,232 <strcmp+0x1e>
 220:	0005c703          	lbu	a4,0(a1)
 224:	00f71763          	bne	a4,a5,232 <strcmp+0x1e>
    p++, q++;
 228:	0505                	addi	a0,a0,1
 22a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 22c:	00054783          	lbu	a5,0(a0)
 230:	fbe5                	bnez	a5,220 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 232:	0005c503          	lbu	a0,0(a1)
}
 236:	40a7853b          	subw	a0,a5,a0
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret

0000000000000240 <strlen>:

uint
strlen(const char *s)
{
 240:	1141                	addi	sp,sp,-16
 242:	e422                	sd	s0,8(sp)
 244:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 246:	00054783          	lbu	a5,0(a0)
 24a:	cf91                	beqz	a5,266 <strlen+0x26>
 24c:	0505                	addi	a0,a0,1
 24e:	87aa                	mv	a5,a0
 250:	4685                	li	a3,1
 252:	9e89                	subw	a3,a3,a0
 254:	00f6853b          	addw	a0,a3,a5
 258:	0785                	addi	a5,a5,1
 25a:	fff7c703          	lbu	a4,-1(a5)
 25e:	fb7d                	bnez	a4,254 <strlen+0x14>
    ;
  return n;
}
 260:	6422                	ld	s0,8(sp)
 262:	0141                	addi	sp,sp,16
 264:	8082                	ret
  for(n = 0; s[n]; n++)
 266:	4501                	li	a0,0
 268:	bfe5                	j	260 <strlen+0x20>

000000000000026a <memset>:

void*
memset(void *dst, int c, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 270:	ca19                	beqz	a2,286 <memset+0x1c>
 272:	87aa                	mv	a5,a0
 274:	1602                	slli	a2,a2,0x20
 276:	9201                	srli	a2,a2,0x20
 278:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 27c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 280:	0785                	addi	a5,a5,1
 282:	fee79de3          	bne	a5,a4,27c <memset+0x12>
  }
  return dst;
}
 286:	6422                	ld	s0,8(sp)
 288:	0141                	addi	sp,sp,16
 28a:	8082                	ret

000000000000028c <strchr>:

char*
strchr(const char *s, char c)
{
 28c:	1141                	addi	sp,sp,-16
 28e:	e422                	sd	s0,8(sp)
 290:	0800                	addi	s0,sp,16
  for(; *s; s++)
 292:	00054783          	lbu	a5,0(a0)
 296:	cb99                	beqz	a5,2ac <strchr+0x20>
    if(*s == c)
 298:	00f58763          	beq	a1,a5,2a6 <strchr+0x1a>
  for(; *s; s++)
 29c:	0505                	addi	a0,a0,1
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	fbfd                	bnez	a5,298 <strchr+0xc>
      return (char*)s;
  return 0;
 2a4:	4501                	li	a0,0
}
 2a6:	6422                	ld	s0,8(sp)
 2a8:	0141                	addi	sp,sp,16
 2aa:	8082                	ret
  return 0;
 2ac:	4501                	li	a0,0
 2ae:	bfe5                	j	2a6 <strchr+0x1a>

00000000000002b0 <gets>:

char*
gets(char *buf, int max)
{
 2b0:	711d                	addi	sp,sp,-96
 2b2:	ec86                	sd	ra,88(sp)
 2b4:	e8a2                	sd	s0,80(sp)
 2b6:	e4a6                	sd	s1,72(sp)
 2b8:	e0ca                	sd	s2,64(sp)
 2ba:	fc4e                	sd	s3,56(sp)
 2bc:	f852                	sd	s4,48(sp)
 2be:	f456                	sd	s5,40(sp)
 2c0:	f05a                	sd	s6,32(sp)
 2c2:	ec5e                	sd	s7,24(sp)
 2c4:	1080                	addi	s0,sp,96
 2c6:	8baa                	mv	s7,a0
 2c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ca:	892a                	mv	s2,a0
 2cc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2ce:	4aa9                	li	s5,10
 2d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2d2:	89a6                	mv	s3,s1
 2d4:	2485                	addiw	s1,s1,1
 2d6:	0344d863          	bge	s1,s4,306 <gets+0x56>
    cc = read(0, &c, 1);
 2da:	4605                	li	a2,1
 2dc:	faf40593          	addi	a1,s0,-81
 2e0:	4501                	li	a0,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	19a080e7          	jalr	410(ra) # 47c <read>
    if(cc < 1)
 2ea:	00a05e63          	blez	a0,306 <gets+0x56>
    buf[i++] = c;
 2ee:	faf44783          	lbu	a5,-81(s0)
 2f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2f6:	01578763          	beq	a5,s5,304 <gets+0x54>
 2fa:	0905                	addi	s2,s2,1
 2fc:	fd679be3          	bne	a5,s6,2d2 <gets+0x22>
  for(i=0; i+1 < max; ){
 300:	89a6                	mv	s3,s1
 302:	a011                	j	306 <gets+0x56>
 304:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 306:	99de                	add	s3,s3,s7
 308:	00098023          	sb	zero,0(s3)
  return buf;
}
 30c:	855e                	mv	a0,s7
 30e:	60e6                	ld	ra,88(sp)
 310:	6446                	ld	s0,80(sp)
 312:	64a6                	ld	s1,72(sp)
 314:	6906                	ld	s2,64(sp)
 316:	79e2                	ld	s3,56(sp)
 318:	7a42                	ld	s4,48(sp)
 31a:	7aa2                	ld	s5,40(sp)
 31c:	7b02                	ld	s6,32(sp)
 31e:	6be2                	ld	s7,24(sp)
 320:	6125                	addi	sp,sp,96
 322:	8082                	ret

0000000000000324 <stat>:

int
stat(const char *n, struct stat *st)
{
 324:	1101                	addi	sp,sp,-32
 326:	ec06                	sd	ra,24(sp)
 328:	e822                	sd	s0,16(sp)
 32a:	e426                	sd	s1,8(sp)
 32c:	e04a                	sd	s2,0(sp)
 32e:	1000                	addi	s0,sp,32
 330:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 332:	4581                	li	a1,0
 334:	00000097          	auipc	ra,0x0
 338:	170080e7          	jalr	368(ra) # 4a4 <open>
  if(fd < 0)
 33c:	02054563          	bltz	a0,366 <stat+0x42>
 340:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 342:	85ca                	mv	a1,s2
 344:	00000097          	auipc	ra,0x0
 348:	178080e7          	jalr	376(ra) # 4bc <fstat>
 34c:	892a                	mv	s2,a0
  close(fd);
 34e:	8526                	mv	a0,s1
 350:	00000097          	auipc	ra,0x0
 354:	13c080e7          	jalr	316(ra) # 48c <close>
  return r;
}
 358:	854a                	mv	a0,s2
 35a:	60e2                	ld	ra,24(sp)
 35c:	6442                	ld	s0,16(sp)
 35e:	64a2                	ld	s1,8(sp)
 360:	6902                	ld	s2,0(sp)
 362:	6105                	addi	sp,sp,32
 364:	8082                	ret
    return -1;
 366:	597d                	li	s2,-1
 368:	bfc5                	j	358 <stat+0x34>

000000000000036a <atoi>:

int
atoi(const char *s)
{
 36a:	1141                	addi	sp,sp,-16
 36c:	e422                	sd	s0,8(sp)
 36e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 370:	00054683          	lbu	a3,0(a0)
 374:	fd06879b          	addiw	a5,a3,-48
 378:	0ff7f793          	zext.b	a5,a5
 37c:	4625                	li	a2,9
 37e:	02f66863          	bltu	a2,a5,3ae <atoi+0x44>
 382:	872a                	mv	a4,a0
  n = 0;
 384:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 386:	0705                	addi	a4,a4,1
 388:	0025179b          	slliw	a5,a0,0x2
 38c:	9fa9                	addw	a5,a5,a0
 38e:	0017979b          	slliw	a5,a5,0x1
 392:	9fb5                	addw	a5,a5,a3
 394:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 398:	00074683          	lbu	a3,0(a4)
 39c:	fd06879b          	addiw	a5,a3,-48
 3a0:	0ff7f793          	zext.b	a5,a5
 3a4:	fef671e3          	bgeu	a2,a5,386 <atoi+0x1c>
  return n;
}
 3a8:	6422                	ld	s0,8(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret
  n = 0;
 3ae:	4501                	li	a0,0
 3b0:	bfe5                	j	3a8 <atoi+0x3e>

00000000000003b2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3b2:	1141                	addi	sp,sp,-16
 3b4:	e422                	sd	s0,8(sp)
 3b6:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3b8:	02b57463          	bgeu	a0,a1,3e0 <memmove+0x2e>
    while(n-- > 0)
 3bc:	00c05f63          	blez	a2,3da <memmove+0x28>
 3c0:	1602                	slli	a2,a2,0x20
 3c2:	9201                	srli	a2,a2,0x20
 3c4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3c8:	872a                	mv	a4,a0
      *dst++ = *src++;
 3ca:	0585                	addi	a1,a1,1
 3cc:	0705                	addi	a4,a4,1
 3ce:	fff5c683          	lbu	a3,-1(a1)
 3d2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3d6:	fee79ae3          	bne	a5,a4,3ca <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3da:	6422                	ld	s0,8(sp)
 3dc:	0141                	addi	sp,sp,16
 3de:	8082                	ret
    dst += n;
 3e0:	00c50733          	add	a4,a0,a2
    src += n;
 3e4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 3e6:	fec05ae3          	blez	a2,3da <memmove+0x28>
 3ea:	fff6079b          	addiw	a5,a2,-1
 3ee:	1782                	slli	a5,a5,0x20
 3f0:	9381                	srli	a5,a5,0x20
 3f2:	fff7c793          	not	a5,a5
 3f6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3f8:	15fd                	addi	a1,a1,-1
 3fa:	177d                	addi	a4,a4,-1
 3fc:	0005c683          	lbu	a3,0(a1)
 400:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 404:	fee79ae3          	bne	a5,a4,3f8 <memmove+0x46>
 408:	bfc9                	j	3da <memmove+0x28>

000000000000040a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 40a:	1141                	addi	sp,sp,-16
 40c:	e422                	sd	s0,8(sp)
 40e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 410:	ca05                	beqz	a2,440 <memcmp+0x36>
 412:	fff6069b          	addiw	a3,a2,-1
 416:	1682                	slli	a3,a3,0x20
 418:	9281                	srli	a3,a3,0x20
 41a:	0685                	addi	a3,a3,1
 41c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 41e:	00054783          	lbu	a5,0(a0)
 422:	0005c703          	lbu	a4,0(a1)
 426:	00e79863          	bne	a5,a4,436 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 42a:	0505                	addi	a0,a0,1
    p2++;
 42c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 42e:	fed518e3          	bne	a0,a3,41e <memcmp+0x14>
  }
  return 0;
 432:	4501                	li	a0,0
 434:	a019                	j	43a <memcmp+0x30>
      return *p1 - *p2;
 436:	40e7853b          	subw	a0,a5,a4
}
 43a:	6422                	ld	s0,8(sp)
 43c:	0141                	addi	sp,sp,16
 43e:	8082                	ret
  return 0;
 440:	4501                	li	a0,0
 442:	bfe5                	j	43a <memcmp+0x30>

0000000000000444 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 444:	1141                	addi	sp,sp,-16
 446:	e406                	sd	ra,8(sp)
 448:	e022                	sd	s0,0(sp)
 44a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 44c:	00000097          	auipc	ra,0x0
 450:	f66080e7          	jalr	-154(ra) # 3b2 <memmove>
}
 454:	60a2                	ld	ra,8(sp)
 456:	6402                	ld	s0,0(sp)
 458:	0141                	addi	sp,sp,16
 45a:	8082                	ret

000000000000045c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 45c:	4885                	li	a7,1
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <exit>:
.global exit
exit:
 li a7, SYS_exit
 464:	4889                	li	a7,2
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <wait>:
.global wait
wait:
 li a7, SYS_wait
 46c:	488d                	li	a7,3
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 474:	4891                	li	a7,4
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <read>:
.global read
read:
 li a7, SYS_read
 47c:	4895                	li	a7,5
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <write>:
.global write
write:
 li a7, SYS_write
 484:	48c1                	li	a7,16
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <close>:
.global close
close:
 li a7, SYS_close
 48c:	48d5                	li	a7,21
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <kill>:
.global kill
kill:
 li a7, SYS_kill
 494:	4899                	li	a7,6
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <exec>:
.global exec
exec:
 li a7, SYS_exec
 49c:	489d                	li	a7,7
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <open>:
.global open
open:
 li a7, SYS_open
 4a4:	48bd                	li	a7,15
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4ac:	48c5                	li	a7,17
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4b4:	48c9                	li	a7,18
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4bc:	48a1                	li	a7,8
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <link>:
.global link
link:
 li a7, SYS_link
 4c4:	48cd                	li	a7,19
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4cc:	48d1                	li	a7,20
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4d4:	48a5                	li	a7,9
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <dup>:
.global dup
dup:
 li a7, SYS_dup
 4dc:	48a9                	li	a7,10
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4e4:	48ad                	li	a7,11
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 4ec:	48b1                	li	a7,12
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4f4:	48b5                	li	a7,13
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4fc:	48b9                	li	a7,14
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 504:	1101                	addi	sp,sp,-32
 506:	ec06                	sd	ra,24(sp)
 508:	e822                	sd	s0,16(sp)
 50a:	1000                	addi	s0,sp,32
 50c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 510:	4605                	li	a2,1
 512:	fef40593          	addi	a1,s0,-17
 516:	00000097          	auipc	ra,0x0
 51a:	f6e080e7          	jalr	-146(ra) # 484 <write>
}
 51e:	60e2                	ld	ra,24(sp)
 520:	6442                	ld	s0,16(sp)
 522:	6105                	addi	sp,sp,32
 524:	8082                	ret

0000000000000526 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 526:	7139                	addi	sp,sp,-64
 528:	fc06                	sd	ra,56(sp)
 52a:	f822                	sd	s0,48(sp)
 52c:	f426                	sd	s1,40(sp)
 52e:	f04a                	sd	s2,32(sp)
 530:	ec4e                	sd	s3,24(sp)
 532:	0080                	addi	s0,sp,64
 534:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 536:	c299                	beqz	a3,53c <printint+0x16>
 538:	0805c963          	bltz	a1,5ca <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 53c:	2581                	sext.w	a1,a1
  neg = 0;
 53e:	4881                	li	a7,0
 540:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 544:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 546:	2601                	sext.w	a2,a2
 548:	00000517          	auipc	a0,0x0
 54c:	4c850513          	addi	a0,a0,1224 # a10 <digits>
 550:	883a                	mv	a6,a4
 552:	2705                	addiw	a4,a4,1
 554:	02c5f7bb          	remuw	a5,a1,a2
 558:	1782                	slli	a5,a5,0x20
 55a:	9381                	srli	a5,a5,0x20
 55c:	97aa                	add	a5,a5,a0
 55e:	0007c783          	lbu	a5,0(a5)
 562:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 566:	0005879b          	sext.w	a5,a1
 56a:	02c5d5bb          	divuw	a1,a1,a2
 56e:	0685                	addi	a3,a3,1
 570:	fec7f0e3          	bgeu	a5,a2,550 <printint+0x2a>
  if(neg)
 574:	00088c63          	beqz	a7,58c <printint+0x66>
    buf[i++] = '-';
 578:	fd070793          	addi	a5,a4,-48
 57c:	00878733          	add	a4,a5,s0
 580:	02d00793          	li	a5,45
 584:	fef70823          	sb	a5,-16(a4)
 588:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 58c:	02e05863          	blez	a4,5bc <printint+0x96>
 590:	fc040793          	addi	a5,s0,-64
 594:	00e78933          	add	s2,a5,a4
 598:	fff78993          	addi	s3,a5,-1
 59c:	99ba                	add	s3,s3,a4
 59e:	377d                	addiw	a4,a4,-1
 5a0:	1702                	slli	a4,a4,0x20
 5a2:	9301                	srli	a4,a4,0x20
 5a4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5a8:	fff94583          	lbu	a1,-1(s2)
 5ac:	8526                	mv	a0,s1
 5ae:	00000097          	auipc	ra,0x0
 5b2:	f56080e7          	jalr	-170(ra) # 504 <putc>
  while(--i >= 0)
 5b6:	197d                	addi	s2,s2,-1
 5b8:	ff3918e3          	bne	s2,s3,5a8 <printint+0x82>
}
 5bc:	70e2                	ld	ra,56(sp)
 5be:	7442                	ld	s0,48(sp)
 5c0:	74a2                	ld	s1,40(sp)
 5c2:	7902                	ld	s2,32(sp)
 5c4:	69e2                	ld	s3,24(sp)
 5c6:	6121                	addi	sp,sp,64
 5c8:	8082                	ret
    x = -xx;
 5ca:	40b005bb          	negw	a1,a1
    neg = 1;
 5ce:	4885                	li	a7,1
    x = -xx;
 5d0:	bf85                	j	540 <printint+0x1a>

00000000000005d2 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5d2:	7119                	addi	sp,sp,-128
 5d4:	fc86                	sd	ra,120(sp)
 5d6:	f8a2                	sd	s0,112(sp)
 5d8:	f4a6                	sd	s1,104(sp)
 5da:	f0ca                	sd	s2,96(sp)
 5dc:	ecce                	sd	s3,88(sp)
 5de:	e8d2                	sd	s4,80(sp)
 5e0:	e4d6                	sd	s5,72(sp)
 5e2:	e0da                	sd	s6,64(sp)
 5e4:	fc5e                	sd	s7,56(sp)
 5e6:	f862                	sd	s8,48(sp)
 5e8:	f466                	sd	s9,40(sp)
 5ea:	f06a                	sd	s10,32(sp)
 5ec:	ec6e                	sd	s11,24(sp)
 5ee:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5f0:	0005c903          	lbu	s2,0(a1)
 5f4:	18090f63          	beqz	s2,792 <vprintf+0x1c0>
 5f8:	8aaa                	mv	s5,a0
 5fa:	8b32                	mv	s6,a2
 5fc:	00158493          	addi	s1,a1,1
  state = 0;
 600:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 602:	02500a13          	li	s4,37
 606:	4c55                	li	s8,21
 608:	00000c97          	auipc	s9,0x0
 60c:	3b0c8c93          	addi	s9,s9,944 # 9b8 <malloc+0x122>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 610:	02800d93          	li	s11,40
  putc(fd, 'x');
 614:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 616:	00000b97          	auipc	s7,0x0
 61a:	3fab8b93          	addi	s7,s7,1018 # a10 <digits>
 61e:	a839                	j	63c <vprintf+0x6a>
        putc(fd, c);
 620:	85ca                	mv	a1,s2
 622:	8556                	mv	a0,s5
 624:	00000097          	auipc	ra,0x0
 628:	ee0080e7          	jalr	-288(ra) # 504 <putc>
 62c:	a019                	j	632 <vprintf+0x60>
    } else if(state == '%'){
 62e:	01498d63          	beq	s3,s4,648 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 632:	0485                	addi	s1,s1,1
 634:	fff4c903          	lbu	s2,-1(s1)
 638:	14090d63          	beqz	s2,792 <vprintf+0x1c0>
    if(state == 0){
 63c:	fe0999e3          	bnez	s3,62e <vprintf+0x5c>
      if(c == '%'){
 640:	ff4910e3          	bne	s2,s4,620 <vprintf+0x4e>
        state = '%';
 644:	89d2                	mv	s3,s4
 646:	b7f5                	j	632 <vprintf+0x60>
      if(c == 'd'){
 648:	11490c63          	beq	s2,s4,760 <vprintf+0x18e>
 64c:	f9d9079b          	addiw	a5,s2,-99
 650:	0ff7f793          	zext.b	a5,a5
 654:	10fc6e63          	bltu	s8,a5,770 <vprintf+0x19e>
 658:	f9d9079b          	addiw	a5,s2,-99
 65c:	0ff7f713          	zext.b	a4,a5
 660:	10ec6863          	bltu	s8,a4,770 <vprintf+0x19e>
 664:	00271793          	slli	a5,a4,0x2
 668:	97e6                	add	a5,a5,s9
 66a:	439c                	lw	a5,0(a5)
 66c:	97e6                	add	a5,a5,s9
 66e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 670:	008b0913          	addi	s2,s6,8
 674:	4685                	li	a3,1
 676:	4629                	li	a2,10
 678:	000b2583          	lw	a1,0(s6)
 67c:	8556                	mv	a0,s5
 67e:	00000097          	auipc	ra,0x0
 682:	ea8080e7          	jalr	-344(ra) # 526 <printint>
 686:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 688:	4981                	li	s3,0
 68a:	b765                	j	632 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	008b0913          	addi	s2,s6,8
 690:	4681                	li	a3,0
 692:	4629                	li	a2,10
 694:	000b2583          	lw	a1,0(s6)
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e8c080e7          	jalr	-372(ra) # 526 <printint>
 6a2:	8b4a                	mv	s6,s2
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	b771                	j	632 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6a8:	008b0913          	addi	s2,s6,8
 6ac:	4681                	li	a3,0
 6ae:	866a                	mv	a2,s10
 6b0:	000b2583          	lw	a1,0(s6)
 6b4:	8556                	mv	a0,s5
 6b6:	00000097          	auipc	ra,0x0
 6ba:	e70080e7          	jalr	-400(ra) # 526 <printint>
 6be:	8b4a                	mv	s6,s2
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bf85                	j	632 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6c4:	008b0793          	addi	a5,s6,8
 6c8:	f8f43423          	sd	a5,-120(s0)
 6cc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6d0:	03000593          	li	a1,48
 6d4:	8556                	mv	a0,s5
 6d6:	00000097          	auipc	ra,0x0
 6da:	e2e080e7          	jalr	-466(ra) # 504 <putc>
  putc(fd, 'x');
 6de:	07800593          	li	a1,120
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	e20080e7          	jalr	-480(ra) # 504 <putc>
 6ec:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6ee:	03c9d793          	srli	a5,s3,0x3c
 6f2:	97de                	add	a5,a5,s7
 6f4:	0007c583          	lbu	a1,0(a5)
 6f8:	8556                	mv	a0,s5
 6fa:	00000097          	auipc	ra,0x0
 6fe:	e0a080e7          	jalr	-502(ra) # 504 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 702:	0992                	slli	s3,s3,0x4
 704:	397d                	addiw	s2,s2,-1
 706:	fe0914e3          	bnez	s2,6ee <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 70a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 70e:	4981                	li	s3,0
 710:	b70d                	j	632 <vprintf+0x60>
        s = va_arg(ap, char*);
 712:	008b0913          	addi	s2,s6,8
 716:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 71a:	02098163          	beqz	s3,73c <vprintf+0x16a>
        while(*s != 0){
 71e:	0009c583          	lbu	a1,0(s3)
 722:	c5ad                	beqz	a1,78c <vprintf+0x1ba>
          putc(fd, *s);
 724:	8556                	mv	a0,s5
 726:	00000097          	auipc	ra,0x0
 72a:	dde080e7          	jalr	-546(ra) # 504 <putc>
          s++;
 72e:	0985                	addi	s3,s3,1
        while(*s != 0){
 730:	0009c583          	lbu	a1,0(s3)
 734:	f9e5                	bnez	a1,724 <vprintf+0x152>
        s = va_arg(ap, char*);
 736:	8b4a                	mv	s6,s2
      state = 0;
 738:	4981                	li	s3,0
 73a:	bde5                	j	632 <vprintf+0x60>
          s = "(null)";
 73c:	00000997          	auipc	s3,0x0
 740:	27498993          	addi	s3,s3,628 # 9b0 <malloc+0x11a>
        while(*s != 0){
 744:	85ee                	mv	a1,s11
 746:	bff9                	j	724 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 748:	008b0913          	addi	s2,s6,8
 74c:	000b4583          	lbu	a1,0(s6)
 750:	8556                	mv	a0,s5
 752:	00000097          	auipc	ra,0x0
 756:	db2080e7          	jalr	-590(ra) # 504 <putc>
 75a:	8b4a                	mv	s6,s2
      state = 0;
 75c:	4981                	li	s3,0
 75e:	bdd1                	j	632 <vprintf+0x60>
        putc(fd, c);
 760:	85d2                	mv	a1,s4
 762:	8556                	mv	a0,s5
 764:	00000097          	auipc	ra,0x0
 768:	da0080e7          	jalr	-608(ra) # 504 <putc>
      state = 0;
 76c:	4981                	li	s3,0
 76e:	b5d1                	j	632 <vprintf+0x60>
        putc(fd, '%');
 770:	85d2                	mv	a1,s4
 772:	8556                	mv	a0,s5
 774:	00000097          	auipc	ra,0x0
 778:	d90080e7          	jalr	-624(ra) # 504 <putc>
        putc(fd, c);
 77c:	85ca                	mv	a1,s2
 77e:	8556                	mv	a0,s5
 780:	00000097          	auipc	ra,0x0
 784:	d84080e7          	jalr	-636(ra) # 504 <putc>
      state = 0;
 788:	4981                	li	s3,0
 78a:	b565                	j	632 <vprintf+0x60>
        s = va_arg(ap, char*);
 78c:	8b4a                	mv	s6,s2
      state = 0;
 78e:	4981                	li	s3,0
 790:	b54d                	j	632 <vprintf+0x60>
    }
  }
}
 792:	70e6                	ld	ra,120(sp)
 794:	7446                	ld	s0,112(sp)
 796:	74a6                	ld	s1,104(sp)
 798:	7906                	ld	s2,96(sp)
 79a:	69e6                	ld	s3,88(sp)
 79c:	6a46                	ld	s4,80(sp)
 79e:	6aa6                	ld	s5,72(sp)
 7a0:	6b06                	ld	s6,64(sp)
 7a2:	7be2                	ld	s7,56(sp)
 7a4:	7c42                	ld	s8,48(sp)
 7a6:	7ca2                	ld	s9,40(sp)
 7a8:	7d02                	ld	s10,32(sp)
 7aa:	6de2                	ld	s11,24(sp)
 7ac:	6109                	addi	sp,sp,128
 7ae:	8082                	ret

00000000000007b0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7b0:	715d                	addi	sp,sp,-80
 7b2:	ec06                	sd	ra,24(sp)
 7b4:	e822                	sd	s0,16(sp)
 7b6:	1000                	addi	s0,sp,32
 7b8:	e010                	sd	a2,0(s0)
 7ba:	e414                	sd	a3,8(s0)
 7bc:	e818                	sd	a4,16(s0)
 7be:	ec1c                	sd	a5,24(s0)
 7c0:	03043023          	sd	a6,32(s0)
 7c4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7c8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7cc:	8622                	mv	a2,s0
 7ce:	00000097          	auipc	ra,0x0
 7d2:	e04080e7          	jalr	-508(ra) # 5d2 <vprintf>
}
 7d6:	60e2                	ld	ra,24(sp)
 7d8:	6442                	ld	s0,16(sp)
 7da:	6161                	addi	sp,sp,80
 7dc:	8082                	ret

00000000000007de <printf>:

void
printf(const char *fmt, ...)
{
 7de:	711d                	addi	sp,sp,-96
 7e0:	ec06                	sd	ra,24(sp)
 7e2:	e822                	sd	s0,16(sp)
 7e4:	1000                	addi	s0,sp,32
 7e6:	e40c                	sd	a1,8(s0)
 7e8:	e810                	sd	a2,16(s0)
 7ea:	ec14                	sd	a3,24(s0)
 7ec:	f018                	sd	a4,32(s0)
 7ee:	f41c                	sd	a5,40(s0)
 7f0:	03043823          	sd	a6,48(s0)
 7f4:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7f8:	00840613          	addi	a2,s0,8
 7fc:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 800:	85aa                	mv	a1,a0
 802:	4505                	li	a0,1
 804:	00000097          	auipc	ra,0x0
 808:	dce080e7          	jalr	-562(ra) # 5d2 <vprintf>
}
 80c:	60e2                	ld	ra,24(sp)
 80e:	6442                	ld	s0,16(sp)
 810:	6125                	addi	sp,sp,96
 812:	8082                	ret

0000000000000814 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 814:	1141                	addi	sp,sp,-16
 816:	e422                	sd	s0,8(sp)
 818:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 81a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 81e:	00000797          	auipc	a5,0x0
 822:	20a7b783          	ld	a5,522(a5) # a28 <freep>
 826:	a02d                	j	850 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 828:	4618                	lw	a4,8(a2)
 82a:	9f2d                	addw	a4,a4,a1
 82c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 830:	6398                	ld	a4,0(a5)
 832:	6310                	ld	a2,0(a4)
 834:	a83d                	j	872 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 836:	ff852703          	lw	a4,-8(a0)
 83a:	9f31                	addw	a4,a4,a2
 83c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 83e:	ff053683          	ld	a3,-16(a0)
 842:	a091                	j	886 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 844:	6398                	ld	a4,0(a5)
 846:	00e7e463          	bltu	a5,a4,84e <free+0x3a>
 84a:	00e6ea63          	bltu	a3,a4,85e <free+0x4a>
{
 84e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 850:	fed7fae3          	bgeu	a5,a3,844 <free+0x30>
 854:	6398                	ld	a4,0(a5)
 856:	00e6e463          	bltu	a3,a4,85e <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85a:	fee7eae3          	bltu	a5,a4,84e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 85e:	ff852583          	lw	a1,-8(a0)
 862:	6390                	ld	a2,0(a5)
 864:	02059813          	slli	a6,a1,0x20
 868:	01c85713          	srli	a4,a6,0x1c
 86c:	9736                	add	a4,a4,a3
 86e:	fae60de3          	beq	a2,a4,828 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 876:	4790                	lw	a2,8(a5)
 878:	02061593          	slli	a1,a2,0x20
 87c:	01c5d713          	srli	a4,a1,0x1c
 880:	973e                	add	a4,a4,a5
 882:	fae68ae3          	beq	a3,a4,836 <free+0x22>
    p->s.ptr = bp->s.ptr;
 886:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 888:	00000717          	auipc	a4,0x0
 88c:	1af73023          	sd	a5,416(a4) # a28 <freep>
}
 890:	6422                	ld	s0,8(sp)
 892:	0141                	addi	sp,sp,16
 894:	8082                	ret

0000000000000896 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 896:	7139                	addi	sp,sp,-64
 898:	fc06                	sd	ra,56(sp)
 89a:	f822                	sd	s0,48(sp)
 89c:	f426                	sd	s1,40(sp)
 89e:	f04a                	sd	s2,32(sp)
 8a0:	ec4e                	sd	s3,24(sp)
 8a2:	e852                	sd	s4,16(sp)
 8a4:	e456                	sd	s5,8(sp)
 8a6:	e05a                	sd	s6,0(sp)
 8a8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8aa:	02051493          	slli	s1,a0,0x20
 8ae:	9081                	srli	s1,s1,0x20
 8b0:	04bd                	addi	s1,s1,15
 8b2:	8091                	srli	s1,s1,0x4
 8b4:	0014899b          	addiw	s3,s1,1
 8b8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8ba:	00000517          	auipc	a0,0x0
 8be:	16e53503          	ld	a0,366(a0) # a28 <freep>
 8c2:	c515                	beqz	a0,8ee <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c6:	4798                	lw	a4,8(a5)
 8c8:	02977f63          	bgeu	a4,s1,906 <malloc+0x70>
 8cc:	8a4e                	mv	s4,s3
 8ce:	0009871b          	sext.w	a4,s3
 8d2:	6685                	lui	a3,0x1
 8d4:	00d77363          	bgeu	a4,a3,8da <malloc+0x44>
 8d8:	6a05                	lui	s4,0x1
 8da:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8de:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8e2:	00000917          	auipc	s2,0x0
 8e6:	14690913          	addi	s2,s2,326 # a28 <freep>
  if(p == (char*)-1)
 8ea:	5afd                	li	s5,-1
 8ec:	a895                	j	960 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8ee:	00000797          	auipc	a5,0x0
 8f2:	14278793          	addi	a5,a5,322 # a30 <base>
 8f6:	00000717          	auipc	a4,0x0
 8fa:	12f73923          	sd	a5,306(a4) # a28 <freep>
 8fe:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 900:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 904:	b7e1                	j	8cc <malloc+0x36>
      if(p->s.size == nunits)
 906:	02e48c63          	beq	s1,a4,93e <malloc+0xa8>
        p->s.size -= nunits;
 90a:	4137073b          	subw	a4,a4,s3
 90e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 910:	02071693          	slli	a3,a4,0x20
 914:	01c6d713          	srli	a4,a3,0x1c
 918:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 91a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 91e:	00000717          	auipc	a4,0x0
 922:	10a73523          	sd	a0,266(a4) # a28 <freep>
      return (void*)(p + 1);
 926:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 92a:	70e2                	ld	ra,56(sp)
 92c:	7442                	ld	s0,48(sp)
 92e:	74a2                	ld	s1,40(sp)
 930:	7902                	ld	s2,32(sp)
 932:	69e2                	ld	s3,24(sp)
 934:	6a42                	ld	s4,16(sp)
 936:	6aa2                	ld	s5,8(sp)
 938:	6b02                	ld	s6,0(sp)
 93a:	6121                	addi	sp,sp,64
 93c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 93e:	6398                	ld	a4,0(a5)
 940:	e118                	sd	a4,0(a0)
 942:	bff1                	j	91e <malloc+0x88>
  hp->s.size = nu;
 944:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 948:	0541                	addi	a0,a0,16
 94a:	00000097          	auipc	ra,0x0
 94e:	eca080e7          	jalr	-310(ra) # 814 <free>
  return freep;
 952:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 956:	d971                	beqz	a0,92a <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 958:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 95a:	4798                	lw	a4,8(a5)
 95c:	fa9775e3          	bgeu	a4,s1,906 <malloc+0x70>
    if(p == freep)
 960:	00093703          	ld	a4,0(s2)
 964:	853e                	mv	a0,a5
 966:	fef719e3          	bne	a4,a5,958 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 96a:	8552                	mv	a0,s4
 96c:	00000097          	auipc	ra,0x0
 970:	b80080e7          	jalr	-1152(ra) # 4ec <sbrk>
  if(p == (char*)-1)
 974:	fd5518e3          	bne	a0,s5,944 <malloc+0xae>
        return 0;
 978:	4501                	li	a0,0
 97a:	bf45                	j	92a <malloc+0x94>
