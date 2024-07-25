
user/_find:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <find>:
#include "kernel/fs.h"

//get from ls.c
void
find(char *path,char *name)
{
   0:	d9010113          	addi	sp,sp,-624
   4:	26113423          	sd	ra,616(sp)
   8:	26813023          	sd	s0,608(sp)
   c:	24913c23          	sd	s1,600(sp)
  10:	25213823          	sd	s2,592(sp)
  14:	25313423          	sd	s3,584(sp)
  18:	25413023          	sd	s4,576(sp)
  1c:	23513c23          	sd	s5,568(sp)
  20:	23613823          	sd	s6,560(sp)
  24:	1c80                	addi	s0,sp,624
  26:	892a                	mv	s2,a0
  28:	89ae                	mv	s3,a1
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;
    if((fd = open(path, 0)) < 0){
  2a:	4581                	li	a1,0
  2c:	00000097          	auipc	ra,0x0
  30:	492080e7          	jalr	1170(ra) # 4be <open>
  34:	10054063          	bltz	a0,134 <find+0x134>
  38:	84aa                	mv	s1,a0
        fprintf(2, "find: cannot open %s\n", path);
        return;
    }

    if(fstat(fd, &st) < 0){
  3a:	d9840593          	addi	a1,s0,-616
  3e:	00000097          	auipc	ra,0x0
  42:	498080e7          	jalr	1176(ra) # 4d6 <fstat>
  46:	10054263          	bltz	a0,14a <find+0x14a>
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        return;
    }
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
  4a:	854a                	mv	a0,s2
  4c:	00000097          	auipc	ra,0x0
  50:	20e080e7          	jalr	526(ra) # 25a <strlen>
  54:	2541                	addiw	a0,a0,16
  56:	20000793          	li	a5,512
  5a:	10a7e863          	bltu	a5,a0,16a <find+0x16a>
      printf("find: path too long\n");
      return;
    }
    strcpy(buf, path);
  5e:	85ca                	mv	a1,s2
  60:	dc040513          	addi	a0,s0,-576
  64:	00000097          	auipc	ra,0x0
  68:	1ae080e7          	jalr	430(ra) # 212 <strcpy>
    p = buf+strlen(buf);
  6c:	dc040513          	addi	a0,s0,-576
  70:	00000097          	auipc	ra,0x0
  74:	1ea080e7          	jalr	490(ra) # 25a <strlen>
  78:	1502                	slli	a0,a0,0x20
  7a:	9101                	srli	a0,a0,0x20
  7c:	dc040793          	addi	a5,s0,-576
  80:	00a78933          	add	s2,a5,a0
    *p++ = '/';
  84:	00190b13          	addi	s6,s2,1
  88:	02f00793          	li	a5,47
  8c:	00f90023          	sb	a5,0(s2)
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      //prevent 
      if(!strcmp(de.name,".")||!strcmp(de.name,".."))
  90:	00001a17          	auipc	s4,0x1
  94:	950a0a13          	addi	s4,s4,-1712 # 9e0 <malloc+0x130>
  98:	00001a97          	auipc	s5,0x1
  9c:	950a8a93          	addi	s5,s5,-1712 # 9e8 <malloc+0x138>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
  a0:	4641                	li	a2,16
  a2:	db040593          	addi	a1,s0,-592
  a6:	8526                	mv	a0,s1
  a8:	00000097          	auipc	ra,0x0
  ac:	3ee080e7          	jalr	1006(ra) # 496 <read>
  b0:	47c1                	li	a5,16
  b2:	0ef51863          	bne	a0,a5,1a2 <find+0x1a2>
      if(de.inum == 0)
  b6:	db045783          	lhu	a5,-592(s0)
  ba:	d3fd                	beqz	a5,a0 <find+0xa0>
      if(!strcmp(de.name,".")||!strcmp(de.name,".."))
  bc:	85d2                	mv	a1,s4
  be:	db240513          	addi	a0,s0,-590
  c2:	00000097          	auipc	ra,0x0
  c6:	16c080e7          	jalr	364(ra) # 22e <strcmp>
  ca:	d979                	beqz	a0,a0 <find+0xa0>
  cc:	85d6                	mv	a1,s5
  ce:	db240513          	addi	a0,s0,-590
  d2:	00000097          	auipc	ra,0x0
  d6:	15c080e7          	jalr	348(ra) # 22e <strcmp>
  da:	d179                	beqz	a0,a0 <find+0xa0>
        continue;
      memmove(p, de.name, DIRSIZ);
  dc:	4639                	li	a2,14
  de:	db240593          	addi	a1,s0,-590
  e2:	855a                	mv	a0,s6
  e4:	00000097          	auipc	ra,0x0
  e8:	2e8080e7          	jalr	744(ra) # 3cc <memmove>
      p[DIRSIZ] = 0;
  ec:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
  f0:	d9840593          	addi	a1,s0,-616
  f4:	dc040513          	addi	a0,s0,-576
  f8:	00000097          	auipc	ra,0x0
  fc:	246080e7          	jalr	582(ra) # 33e <stat>
 100:	06054e63          	bltz	a0,17c <find+0x17c>
        printf("find: cannot stat %s\n", buf);
        continue;
      }
      //check type
      if(st.type==T_DIR)
 104:	da041703          	lh	a4,-608(s0)
 108:	4785                	li	a5,1
 10a:	08f70463          	beq	a4,a5,192 <find+0x192>
      {
        find(buf,name);
      }
      else
        //add name comparision
      if(!strcmp(de.name,name))
 10e:	85ce                	mv	a1,s3
 110:	db240513          	addi	a0,s0,-590
 114:	00000097          	auipc	ra,0x0
 118:	11a080e7          	jalr	282(ra) # 22e <strcmp>
 11c:	f151                	bnez	a0,a0 <find+0xa0>
        printf("%s\n", buf);
 11e:	dc040593          	addi	a1,s0,-576
 122:	00001517          	auipc	a0,0x1
 126:	8ce50513          	addi	a0,a0,-1842 # 9f0 <malloc+0x140>
 12a:	00000097          	auipc	ra,0x0
 12e:	6ce080e7          	jalr	1742(ra) # 7f8 <printf>
 132:	b7bd                	j	a0 <find+0xa0>
        fprintf(2, "find: cannot open %s\n", path);
 134:	864a                	mv	a2,s2
 136:	00001597          	auipc	a1,0x1
 13a:	86258593          	addi	a1,a1,-1950 # 998 <malloc+0xe8>
 13e:	4509                	li	a0,2
 140:	00000097          	auipc	ra,0x0
 144:	68a080e7          	jalr	1674(ra) # 7ca <fprintf>
        return;
 148:	a095                	j	1ac <find+0x1ac>
        fprintf(2, "find: cannot stat %s\n", path);
 14a:	864a                	mv	a2,s2
 14c:	00001597          	auipc	a1,0x1
 150:	86458593          	addi	a1,a1,-1948 # 9b0 <malloc+0x100>
 154:	4509                	li	a0,2
 156:	00000097          	auipc	ra,0x0
 15a:	674080e7          	jalr	1652(ra) # 7ca <fprintf>
        close(fd);
 15e:	8526                	mv	a0,s1
 160:	00000097          	auipc	ra,0x0
 164:	346080e7          	jalr	838(ra) # 4a6 <close>
        return;
 168:	a091                	j	1ac <find+0x1ac>
      printf("find: path too long\n");
 16a:	00001517          	auipc	a0,0x1
 16e:	85e50513          	addi	a0,a0,-1954 # 9c8 <malloc+0x118>
 172:	00000097          	auipc	ra,0x0
 176:	686080e7          	jalr	1670(ra) # 7f8 <printf>
      return;
 17a:	a80d                	j	1ac <find+0x1ac>
        printf("find: cannot stat %s\n", buf);
 17c:	dc040593          	addi	a1,s0,-576
 180:	00001517          	auipc	a0,0x1
 184:	83050513          	addi	a0,a0,-2000 # 9b0 <malloc+0x100>
 188:	00000097          	auipc	ra,0x0
 18c:	670080e7          	jalr	1648(ra) # 7f8 <printf>
        continue;
 190:	bf01                	j	a0 <find+0xa0>
        find(buf,name);
 192:	85ce                	mv	a1,s3
 194:	dc040513          	addi	a0,s0,-576
 198:	00000097          	auipc	ra,0x0
 19c:	e68080e7          	jalr	-408(ra) # 0 <find>
 1a0:	b701                	j	a0 <find+0xa0>
    }
    close(fd);
 1a2:	8526                	mv	a0,s1
 1a4:	00000097          	auipc	ra,0x0
 1a8:	302080e7          	jalr	770(ra) # 4a6 <close>
}
 1ac:	26813083          	ld	ra,616(sp)
 1b0:	26013403          	ld	s0,608(sp)
 1b4:	25813483          	ld	s1,600(sp)
 1b8:	25013903          	ld	s2,592(sp)
 1bc:	24813983          	ld	s3,584(sp)
 1c0:	24013a03          	ld	s4,576(sp)
 1c4:	23813a83          	ld	s5,568(sp)
 1c8:	23013b03          	ld	s6,560(sp)
 1cc:	27010113          	addi	sp,sp,624
 1d0:	8082                	ret

00000000000001d2 <main>:

int
main(int argc, char *argv[])
{
 1d2:	1141                	addi	sp,sp,-16
 1d4:	e406                	sd	ra,8(sp)
 1d6:	e022                	sd	s0,0(sp)
 1d8:	0800                	addi	s0,sp,16
  if(argc!=3){
 1da:	470d                	li	a4,3
 1dc:	00e50f63          	beq	a0,a4,1fa <main+0x28>
    printf("Please watch out your parameters!");
 1e0:	00001517          	auipc	a0,0x1
 1e4:	81850513          	addi	a0,a0,-2024 # 9f8 <malloc+0x148>
 1e8:	00000097          	auipc	ra,0x0
 1ec:	610080e7          	jalr	1552(ra) # 7f8 <printf>
    exit(1);
 1f0:	4505                	li	a0,1
 1f2:	00000097          	auipc	ra,0x0
 1f6:	28c080e7          	jalr	652(ra) # 47e <exit>
 1fa:	87ae                	mv	a5,a1
  }
  find(argv[1],argv[2]);
 1fc:	698c                	ld	a1,16(a1)
 1fe:	6788                	ld	a0,8(a5)
 200:	00000097          	auipc	ra,0x0
 204:	e00080e7          	jalr	-512(ra) # 0 <find>
  exit(0);
 208:	4501                	li	a0,0
 20a:	00000097          	auipc	ra,0x0
 20e:	274080e7          	jalr	628(ra) # 47e <exit>

0000000000000212 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 218:	87aa                	mv	a5,a0
 21a:	0585                	addi	a1,a1,1
 21c:	0785                	addi	a5,a5,1
 21e:	fff5c703          	lbu	a4,-1(a1)
 222:	fee78fa3          	sb	a4,-1(a5)
 226:	fb75                	bnez	a4,21a <strcpy+0x8>
    ;
  return os;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	addi	sp,sp,16
 22c:	8082                	ret

000000000000022e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb91                	beqz	a5,24c <strcmp+0x1e>
 23a:	0005c703          	lbu	a4,0(a1)
 23e:	00f71763          	bne	a4,a5,24c <strcmp+0x1e>
    p++, q++;
 242:	0505                	addi	a0,a0,1
 244:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 246:	00054783          	lbu	a5,0(a0)
 24a:	fbe5                	bnez	a5,23a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 24c:	0005c503          	lbu	a0,0(a1)
}
 250:	40a7853b          	subw	a0,a5,a0
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret

000000000000025a <strlen>:

uint
strlen(const char *s)
{
 25a:	1141                	addi	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 260:	00054783          	lbu	a5,0(a0)
 264:	cf91                	beqz	a5,280 <strlen+0x26>
 266:	0505                	addi	a0,a0,1
 268:	87aa                	mv	a5,a0
 26a:	4685                	li	a3,1
 26c:	9e89                	subw	a3,a3,a0
 26e:	00f6853b          	addw	a0,a3,a5
 272:	0785                	addi	a5,a5,1
 274:	fff7c703          	lbu	a4,-1(a5)
 278:	fb7d                	bnez	a4,26e <strlen+0x14>
    ;
  return n;
}
 27a:	6422                	ld	s0,8(sp)
 27c:	0141                	addi	sp,sp,16
 27e:	8082                	ret
  for(n = 0; s[n]; n++)
 280:	4501                	li	a0,0
 282:	bfe5                	j	27a <strlen+0x20>

0000000000000284 <memset>:

void*
memset(void *dst, int c, uint n)
{
 284:	1141                	addi	sp,sp,-16
 286:	e422                	sd	s0,8(sp)
 288:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28a:	ca19                	beqz	a2,2a0 <memset+0x1c>
 28c:	87aa                	mv	a5,a0
 28e:	1602                	slli	a2,a2,0x20
 290:	9201                	srli	a2,a2,0x20
 292:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 296:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 29a:	0785                	addi	a5,a5,1
 29c:	fee79de3          	bne	a5,a4,296 <memset+0x12>
  }
  return dst;
}
 2a0:	6422                	ld	s0,8(sp)
 2a2:	0141                	addi	sp,sp,16
 2a4:	8082                	ret

00000000000002a6 <strchr>:

char*
strchr(const char *s, char c)
{
 2a6:	1141                	addi	sp,sp,-16
 2a8:	e422                	sd	s0,8(sp)
 2aa:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2ac:	00054783          	lbu	a5,0(a0)
 2b0:	cb99                	beqz	a5,2c6 <strchr+0x20>
    if(*s == c)
 2b2:	00f58763          	beq	a1,a5,2c0 <strchr+0x1a>
  for(; *s; s++)
 2b6:	0505                	addi	a0,a0,1
 2b8:	00054783          	lbu	a5,0(a0)
 2bc:	fbfd                	bnez	a5,2b2 <strchr+0xc>
      return (char*)s;
  return 0;
 2be:	4501                	li	a0,0
}
 2c0:	6422                	ld	s0,8(sp)
 2c2:	0141                	addi	sp,sp,16
 2c4:	8082                	ret
  return 0;
 2c6:	4501                	li	a0,0
 2c8:	bfe5                	j	2c0 <strchr+0x1a>

00000000000002ca <gets>:

char*
gets(char *buf, int max)
{
 2ca:	711d                	addi	sp,sp,-96
 2cc:	ec86                	sd	ra,88(sp)
 2ce:	e8a2                	sd	s0,80(sp)
 2d0:	e4a6                	sd	s1,72(sp)
 2d2:	e0ca                	sd	s2,64(sp)
 2d4:	fc4e                	sd	s3,56(sp)
 2d6:	f852                	sd	s4,48(sp)
 2d8:	f456                	sd	s5,40(sp)
 2da:	f05a                	sd	s6,32(sp)
 2dc:	ec5e                	sd	s7,24(sp)
 2de:	1080                	addi	s0,sp,96
 2e0:	8baa                	mv	s7,a0
 2e2:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2e4:	892a                	mv	s2,a0
 2e6:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2e8:	4aa9                	li	s5,10
 2ea:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2ec:	89a6                	mv	s3,s1
 2ee:	2485                	addiw	s1,s1,1
 2f0:	0344d863          	bge	s1,s4,320 <gets+0x56>
    cc = read(0, &c, 1);
 2f4:	4605                	li	a2,1
 2f6:	faf40593          	addi	a1,s0,-81
 2fa:	4501                	li	a0,0
 2fc:	00000097          	auipc	ra,0x0
 300:	19a080e7          	jalr	410(ra) # 496 <read>
    if(cc < 1)
 304:	00a05e63          	blez	a0,320 <gets+0x56>
    buf[i++] = c;
 308:	faf44783          	lbu	a5,-81(s0)
 30c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 310:	01578763          	beq	a5,s5,31e <gets+0x54>
 314:	0905                	addi	s2,s2,1
 316:	fd679be3          	bne	a5,s6,2ec <gets+0x22>
  for(i=0; i+1 < max; ){
 31a:	89a6                	mv	s3,s1
 31c:	a011                	j	320 <gets+0x56>
 31e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 320:	99de                	add	s3,s3,s7
 322:	00098023          	sb	zero,0(s3)
  return buf;
}
 326:	855e                	mv	a0,s7
 328:	60e6                	ld	ra,88(sp)
 32a:	6446                	ld	s0,80(sp)
 32c:	64a6                	ld	s1,72(sp)
 32e:	6906                	ld	s2,64(sp)
 330:	79e2                	ld	s3,56(sp)
 332:	7a42                	ld	s4,48(sp)
 334:	7aa2                	ld	s5,40(sp)
 336:	7b02                	ld	s6,32(sp)
 338:	6be2                	ld	s7,24(sp)
 33a:	6125                	addi	sp,sp,96
 33c:	8082                	ret

000000000000033e <stat>:

int
stat(const char *n, struct stat *st)
{
 33e:	1101                	addi	sp,sp,-32
 340:	ec06                	sd	ra,24(sp)
 342:	e822                	sd	s0,16(sp)
 344:	e426                	sd	s1,8(sp)
 346:	e04a                	sd	s2,0(sp)
 348:	1000                	addi	s0,sp,32
 34a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 34c:	4581                	li	a1,0
 34e:	00000097          	auipc	ra,0x0
 352:	170080e7          	jalr	368(ra) # 4be <open>
  if(fd < 0)
 356:	02054563          	bltz	a0,380 <stat+0x42>
 35a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 35c:	85ca                	mv	a1,s2
 35e:	00000097          	auipc	ra,0x0
 362:	178080e7          	jalr	376(ra) # 4d6 <fstat>
 366:	892a                	mv	s2,a0
  close(fd);
 368:	8526                	mv	a0,s1
 36a:	00000097          	auipc	ra,0x0
 36e:	13c080e7          	jalr	316(ra) # 4a6 <close>
  return r;
}
 372:	854a                	mv	a0,s2
 374:	60e2                	ld	ra,24(sp)
 376:	6442                	ld	s0,16(sp)
 378:	64a2                	ld	s1,8(sp)
 37a:	6902                	ld	s2,0(sp)
 37c:	6105                	addi	sp,sp,32
 37e:	8082                	ret
    return -1;
 380:	597d                	li	s2,-1
 382:	bfc5                	j	372 <stat+0x34>

0000000000000384 <atoi>:

int
atoi(const char *s)
{
 384:	1141                	addi	sp,sp,-16
 386:	e422                	sd	s0,8(sp)
 388:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 38a:	00054683          	lbu	a3,0(a0)
 38e:	fd06879b          	addiw	a5,a3,-48
 392:	0ff7f793          	zext.b	a5,a5
 396:	4625                	li	a2,9
 398:	02f66863          	bltu	a2,a5,3c8 <atoi+0x44>
 39c:	872a                	mv	a4,a0
  n = 0;
 39e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3a0:	0705                	addi	a4,a4,1
 3a2:	0025179b          	slliw	a5,a0,0x2
 3a6:	9fa9                	addw	a5,a5,a0
 3a8:	0017979b          	slliw	a5,a5,0x1
 3ac:	9fb5                	addw	a5,a5,a3
 3ae:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3b2:	00074683          	lbu	a3,0(a4)
 3b6:	fd06879b          	addiw	a5,a3,-48
 3ba:	0ff7f793          	zext.b	a5,a5
 3be:	fef671e3          	bgeu	a2,a5,3a0 <atoi+0x1c>
  return n;
}
 3c2:	6422                	ld	s0,8(sp)
 3c4:	0141                	addi	sp,sp,16
 3c6:	8082                	ret
  n = 0;
 3c8:	4501                	li	a0,0
 3ca:	bfe5                	j	3c2 <atoi+0x3e>

00000000000003cc <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3cc:	1141                	addi	sp,sp,-16
 3ce:	e422                	sd	s0,8(sp)
 3d0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3d2:	02b57463          	bgeu	a0,a1,3fa <memmove+0x2e>
    while(n-- > 0)
 3d6:	00c05f63          	blez	a2,3f4 <memmove+0x28>
 3da:	1602                	slli	a2,a2,0x20
 3dc:	9201                	srli	a2,a2,0x20
 3de:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3e2:	872a                	mv	a4,a0
      *dst++ = *src++;
 3e4:	0585                	addi	a1,a1,1
 3e6:	0705                	addi	a4,a4,1
 3e8:	fff5c683          	lbu	a3,-1(a1)
 3ec:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3f0:	fee79ae3          	bne	a5,a4,3e4 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 3f4:	6422                	ld	s0,8(sp)
 3f6:	0141                	addi	sp,sp,16
 3f8:	8082                	ret
    dst += n;
 3fa:	00c50733          	add	a4,a0,a2
    src += n;
 3fe:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 400:	fec05ae3          	blez	a2,3f4 <memmove+0x28>
 404:	fff6079b          	addiw	a5,a2,-1
 408:	1782                	slli	a5,a5,0x20
 40a:	9381                	srli	a5,a5,0x20
 40c:	fff7c793          	not	a5,a5
 410:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 412:	15fd                	addi	a1,a1,-1
 414:	177d                	addi	a4,a4,-1
 416:	0005c683          	lbu	a3,0(a1)
 41a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 41e:	fee79ae3          	bne	a5,a4,412 <memmove+0x46>
 422:	bfc9                	j	3f4 <memmove+0x28>

0000000000000424 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 424:	1141                	addi	sp,sp,-16
 426:	e422                	sd	s0,8(sp)
 428:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 42a:	ca05                	beqz	a2,45a <memcmp+0x36>
 42c:	fff6069b          	addiw	a3,a2,-1
 430:	1682                	slli	a3,a3,0x20
 432:	9281                	srli	a3,a3,0x20
 434:	0685                	addi	a3,a3,1
 436:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 438:	00054783          	lbu	a5,0(a0)
 43c:	0005c703          	lbu	a4,0(a1)
 440:	00e79863          	bne	a5,a4,450 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 444:	0505                	addi	a0,a0,1
    p2++;
 446:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 448:	fed518e3          	bne	a0,a3,438 <memcmp+0x14>
  }
  return 0;
 44c:	4501                	li	a0,0
 44e:	a019                	j	454 <memcmp+0x30>
      return *p1 - *p2;
 450:	40e7853b          	subw	a0,a5,a4
}
 454:	6422                	ld	s0,8(sp)
 456:	0141                	addi	sp,sp,16
 458:	8082                	ret
  return 0;
 45a:	4501                	li	a0,0
 45c:	bfe5                	j	454 <memcmp+0x30>

000000000000045e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 45e:	1141                	addi	sp,sp,-16
 460:	e406                	sd	ra,8(sp)
 462:	e022                	sd	s0,0(sp)
 464:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 466:	00000097          	auipc	ra,0x0
 46a:	f66080e7          	jalr	-154(ra) # 3cc <memmove>
}
 46e:	60a2                	ld	ra,8(sp)
 470:	6402                	ld	s0,0(sp)
 472:	0141                	addi	sp,sp,16
 474:	8082                	ret

0000000000000476 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 476:	4885                	li	a7,1
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <exit>:
.global exit
exit:
 li a7, SYS_exit
 47e:	4889                	li	a7,2
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <wait>:
.global wait
wait:
 li a7, SYS_wait
 486:	488d                	li	a7,3
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 48e:	4891                	li	a7,4
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <read>:
.global read
read:
 li a7, SYS_read
 496:	4895                	li	a7,5
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <write>:
.global write
write:
 li a7, SYS_write
 49e:	48c1                	li	a7,16
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <close>:
.global close
close:
 li a7, SYS_close
 4a6:	48d5                	li	a7,21
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <kill>:
.global kill
kill:
 li a7, SYS_kill
 4ae:	4899                	li	a7,6
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4b6:	489d                	li	a7,7
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <open>:
.global open
open:
 li a7, SYS_open
 4be:	48bd                	li	a7,15
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4c6:	48c5                	li	a7,17
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4ce:	48c9                	li	a7,18
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4d6:	48a1                	li	a7,8
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <link>:
.global link
link:
 li a7, SYS_link
 4de:	48cd                	li	a7,19
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4e6:	48d1                	li	a7,20
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4ee:	48a5                	li	a7,9
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 4f6:	48a9                	li	a7,10
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 4fe:	48ad                	li	a7,11
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 506:	48b1                	li	a7,12
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 50e:	48b5                	li	a7,13
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 516:	48b9                	li	a7,14
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 51e:	1101                	addi	sp,sp,-32
 520:	ec06                	sd	ra,24(sp)
 522:	e822                	sd	s0,16(sp)
 524:	1000                	addi	s0,sp,32
 526:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 52a:	4605                	li	a2,1
 52c:	fef40593          	addi	a1,s0,-17
 530:	00000097          	auipc	ra,0x0
 534:	f6e080e7          	jalr	-146(ra) # 49e <write>
}
 538:	60e2                	ld	ra,24(sp)
 53a:	6442                	ld	s0,16(sp)
 53c:	6105                	addi	sp,sp,32
 53e:	8082                	ret

0000000000000540 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 540:	7139                	addi	sp,sp,-64
 542:	fc06                	sd	ra,56(sp)
 544:	f822                	sd	s0,48(sp)
 546:	f426                	sd	s1,40(sp)
 548:	f04a                	sd	s2,32(sp)
 54a:	ec4e                	sd	s3,24(sp)
 54c:	0080                	addi	s0,sp,64
 54e:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 550:	c299                	beqz	a3,556 <printint+0x16>
 552:	0805c963          	bltz	a1,5e4 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 556:	2581                	sext.w	a1,a1
  neg = 0;
 558:	4881                	li	a7,0
 55a:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 55e:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 560:	2601                	sext.w	a2,a2
 562:	00000517          	auipc	a0,0x0
 566:	51e50513          	addi	a0,a0,1310 # a80 <digits>
 56a:	883a                	mv	a6,a4
 56c:	2705                	addiw	a4,a4,1
 56e:	02c5f7bb          	remuw	a5,a1,a2
 572:	1782                	slli	a5,a5,0x20
 574:	9381                	srli	a5,a5,0x20
 576:	97aa                	add	a5,a5,a0
 578:	0007c783          	lbu	a5,0(a5)
 57c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 580:	0005879b          	sext.w	a5,a1
 584:	02c5d5bb          	divuw	a1,a1,a2
 588:	0685                	addi	a3,a3,1
 58a:	fec7f0e3          	bgeu	a5,a2,56a <printint+0x2a>
  if(neg)
 58e:	00088c63          	beqz	a7,5a6 <printint+0x66>
    buf[i++] = '-';
 592:	fd070793          	addi	a5,a4,-48
 596:	00878733          	add	a4,a5,s0
 59a:	02d00793          	li	a5,45
 59e:	fef70823          	sb	a5,-16(a4)
 5a2:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5a6:	02e05863          	blez	a4,5d6 <printint+0x96>
 5aa:	fc040793          	addi	a5,s0,-64
 5ae:	00e78933          	add	s2,a5,a4
 5b2:	fff78993          	addi	s3,a5,-1
 5b6:	99ba                	add	s3,s3,a4
 5b8:	377d                	addiw	a4,a4,-1
 5ba:	1702                	slli	a4,a4,0x20
 5bc:	9301                	srli	a4,a4,0x20
 5be:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5c2:	fff94583          	lbu	a1,-1(s2)
 5c6:	8526                	mv	a0,s1
 5c8:	00000097          	auipc	ra,0x0
 5cc:	f56080e7          	jalr	-170(ra) # 51e <putc>
  while(--i >= 0)
 5d0:	197d                	addi	s2,s2,-1
 5d2:	ff3918e3          	bne	s2,s3,5c2 <printint+0x82>
}
 5d6:	70e2                	ld	ra,56(sp)
 5d8:	7442                	ld	s0,48(sp)
 5da:	74a2                	ld	s1,40(sp)
 5dc:	7902                	ld	s2,32(sp)
 5de:	69e2                	ld	s3,24(sp)
 5e0:	6121                	addi	sp,sp,64
 5e2:	8082                	ret
    x = -xx;
 5e4:	40b005bb          	negw	a1,a1
    neg = 1;
 5e8:	4885                	li	a7,1
    x = -xx;
 5ea:	bf85                	j	55a <printint+0x1a>

00000000000005ec <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5ec:	7119                	addi	sp,sp,-128
 5ee:	fc86                	sd	ra,120(sp)
 5f0:	f8a2                	sd	s0,112(sp)
 5f2:	f4a6                	sd	s1,104(sp)
 5f4:	f0ca                	sd	s2,96(sp)
 5f6:	ecce                	sd	s3,88(sp)
 5f8:	e8d2                	sd	s4,80(sp)
 5fa:	e4d6                	sd	s5,72(sp)
 5fc:	e0da                	sd	s6,64(sp)
 5fe:	fc5e                	sd	s7,56(sp)
 600:	f862                	sd	s8,48(sp)
 602:	f466                	sd	s9,40(sp)
 604:	f06a                	sd	s10,32(sp)
 606:	ec6e                	sd	s11,24(sp)
 608:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 60a:	0005c903          	lbu	s2,0(a1)
 60e:	18090f63          	beqz	s2,7ac <vprintf+0x1c0>
 612:	8aaa                	mv	s5,a0
 614:	8b32                	mv	s6,a2
 616:	00158493          	addi	s1,a1,1
  state = 0;
 61a:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 61c:	02500a13          	li	s4,37
 620:	4c55                	li	s8,21
 622:	00000c97          	auipc	s9,0x0
 626:	406c8c93          	addi	s9,s9,1030 # a28 <malloc+0x178>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 62a:	02800d93          	li	s11,40
  putc(fd, 'x');
 62e:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 630:	00000b97          	auipc	s7,0x0
 634:	450b8b93          	addi	s7,s7,1104 # a80 <digits>
 638:	a839                	j	656 <vprintf+0x6a>
        putc(fd, c);
 63a:	85ca                	mv	a1,s2
 63c:	8556                	mv	a0,s5
 63e:	00000097          	auipc	ra,0x0
 642:	ee0080e7          	jalr	-288(ra) # 51e <putc>
 646:	a019                	j	64c <vprintf+0x60>
    } else if(state == '%'){
 648:	01498d63          	beq	s3,s4,662 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 64c:	0485                	addi	s1,s1,1
 64e:	fff4c903          	lbu	s2,-1(s1)
 652:	14090d63          	beqz	s2,7ac <vprintf+0x1c0>
    if(state == 0){
 656:	fe0999e3          	bnez	s3,648 <vprintf+0x5c>
      if(c == '%'){
 65a:	ff4910e3          	bne	s2,s4,63a <vprintf+0x4e>
        state = '%';
 65e:	89d2                	mv	s3,s4
 660:	b7f5                	j	64c <vprintf+0x60>
      if(c == 'd'){
 662:	11490c63          	beq	s2,s4,77a <vprintf+0x18e>
 666:	f9d9079b          	addiw	a5,s2,-99
 66a:	0ff7f793          	zext.b	a5,a5
 66e:	10fc6e63          	bltu	s8,a5,78a <vprintf+0x19e>
 672:	f9d9079b          	addiw	a5,s2,-99
 676:	0ff7f713          	zext.b	a4,a5
 67a:	10ec6863          	bltu	s8,a4,78a <vprintf+0x19e>
 67e:	00271793          	slli	a5,a4,0x2
 682:	97e6                	add	a5,a5,s9
 684:	439c                	lw	a5,0(a5)
 686:	97e6                	add	a5,a5,s9
 688:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 68a:	008b0913          	addi	s2,s6,8
 68e:	4685                	li	a3,1
 690:	4629                	li	a2,10
 692:	000b2583          	lw	a1,0(s6)
 696:	8556                	mv	a0,s5
 698:	00000097          	auipc	ra,0x0
 69c:	ea8080e7          	jalr	-344(ra) # 540 <printint>
 6a0:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b765                	j	64c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6a6:	008b0913          	addi	s2,s6,8
 6aa:	4681                	li	a3,0
 6ac:	4629                	li	a2,10
 6ae:	000b2583          	lw	a1,0(s6)
 6b2:	8556                	mv	a0,s5
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e8c080e7          	jalr	-372(ra) # 540 <printint>
 6bc:	8b4a                	mv	s6,s2
      state = 0;
 6be:	4981                	li	s3,0
 6c0:	b771                	j	64c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6c2:	008b0913          	addi	s2,s6,8
 6c6:	4681                	li	a3,0
 6c8:	866a                	mv	a2,s10
 6ca:	000b2583          	lw	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	e70080e7          	jalr	-400(ra) # 540 <printint>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bf85                	j	64c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 6de:	008b0793          	addi	a5,s6,8
 6e2:	f8f43423          	sd	a5,-120(s0)
 6e6:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	e2e080e7          	jalr	-466(ra) # 51e <putc>
  putc(fd, 'x');
 6f8:	07800593          	li	a1,120
 6fc:	8556                	mv	a0,s5
 6fe:	00000097          	auipc	ra,0x0
 702:	e20080e7          	jalr	-480(ra) # 51e <putc>
 706:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 708:	03c9d793          	srli	a5,s3,0x3c
 70c:	97de                	add	a5,a5,s7
 70e:	0007c583          	lbu	a1,0(a5)
 712:	8556                	mv	a0,s5
 714:	00000097          	auipc	ra,0x0
 718:	e0a080e7          	jalr	-502(ra) # 51e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 71c:	0992                	slli	s3,s3,0x4
 71e:	397d                	addiw	s2,s2,-1
 720:	fe0914e3          	bnez	s2,708 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 724:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 728:	4981                	li	s3,0
 72a:	b70d                	j	64c <vprintf+0x60>
        s = va_arg(ap, char*);
 72c:	008b0913          	addi	s2,s6,8
 730:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 734:	02098163          	beqz	s3,756 <vprintf+0x16a>
        while(*s != 0){
 738:	0009c583          	lbu	a1,0(s3)
 73c:	c5ad                	beqz	a1,7a6 <vprintf+0x1ba>
          putc(fd, *s);
 73e:	8556                	mv	a0,s5
 740:	00000097          	auipc	ra,0x0
 744:	dde080e7          	jalr	-546(ra) # 51e <putc>
          s++;
 748:	0985                	addi	s3,s3,1
        while(*s != 0){
 74a:	0009c583          	lbu	a1,0(s3)
 74e:	f9e5                	bnez	a1,73e <vprintf+0x152>
        s = va_arg(ap, char*);
 750:	8b4a                	mv	s6,s2
      state = 0;
 752:	4981                	li	s3,0
 754:	bde5                	j	64c <vprintf+0x60>
          s = "(null)";
 756:	00000997          	auipc	s3,0x0
 75a:	2ca98993          	addi	s3,s3,714 # a20 <malloc+0x170>
        while(*s != 0){
 75e:	85ee                	mv	a1,s11
 760:	bff9                	j	73e <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 762:	008b0913          	addi	s2,s6,8
 766:	000b4583          	lbu	a1,0(s6)
 76a:	8556                	mv	a0,s5
 76c:	00000097          	auipc	ra,0x0
 770:	db2080e7          	jalr	-590(ra) # 51e <putc>
 774:	8b4a                	mv	s6,s2
      state = 0;
 776:	4981                	li	s3,0
 778:	bdd1                	j	64c <vprintf+0x60>
        putc(fd, c);
 77a:	85d2                	mv	a1,s4
 77c:	8556                	mv	a0,s5
 77e:	00000097          	auipc	ra,0x0
 782:	da0080e7          	jalr	-608(ra) # 51e <putc>
      state = 0;
 786:	4981                	li	s3,0
 788:	b5d1                	j	64c <vprintf+0x60>
        putc(fd, '%');
 78a:	85d2                	mv	a1,s4
 78c:	8556                	mv	a0,s5
 78e:	00000097          	auipc	ra,0x0
 792:	d90080e7          	jalr	-624(ra) # 51e <putc>
        putc(fd, c);
 796:	85ca                	mv	a1,s2
 798:	8556                	mv	a0,s5
 79a:	00000097          	auipc	ra,0x0
 79e:	d84080e7          	jalr	-636(ra) # 51e <putc>
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	b565                	j	64c <vprintf+0x60>
        s = va_arg(ap, char*);
 7a6:	8b4a                	mv	s6,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	b54d                	j	64c <vprintf+0x60>
    }
  }
}
 7ac:	70e6                	ld	ra,120(sp)
 7ae:	7446                	ld	s0,112(sp)
 7b0:	74a6                	ld	s1,104(sp)
 7b2:	7906                	ld	s2,96(sp)
 7b4:	69e6                	ld	s3,88(sp)
 7b6:	6a46                	ld	s4,80(sp)
 7b8:	6aa6                	ld	s5,72(sp)
 7ba:	6b06                	ld	s6,64(sp)
 7bc:	7be2                	ld	s7,56(sp)
 7be:	7c42                	ld	s8,48(sp)
 7c0:	7ca2                	ld	s9,40(sp)
 7c2:	7d02                	ld	s10,32(sp)
 7c4:	6de2                	ld	s11,24(sp)
 7c6:	6109                	addi	sp,sp,128
 7c8:	8082                	ret

00000000000007ca <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7ca:	715d                	addi	sp,sp,-80
 7cc:	ec06                	sd	ra,24(sp)
 7ce:	e822                	sd	s0,16(sp)
 7d0:	1000                	addi	s0,sp,32
 7d2:	e010                	sd	a2,0(s0)
 7d4:	e414                	sd	a3,8(s0)
 7d6:	e818                	sd	a4,16(s0)
 7d8:	ec1c                	sd	a5,24(s0)
 7da:	03043023          	sd	a6,32(s0)
 7de:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e2:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e6:	8622                	mv	a2,s0
 7e8:	00000097          	auipc	ra,0x0
 7ec:	e04080e7          	jalr	-508(ra) # 5ec <vprintf>
}
 7f0:	60e2                	ld	ra,24(sp)
 7f2:	6442                	ld	s0,16(sp)
 7f4:	6161                	addi	sp,sp,80
 7f6:	8082                	ret

00000000000007f8 <printf>:

void
printf(const char *fmt, ...)
{
 7f8:	711d                	addi	sp,sp,-96
 7fa:	ec06                	sd	ra,24(sp)
 7fc:	e822                	sd	s0,16(sp)
 7fe:	1000                	addi	s0,sp,32
 800:	e40c                	sd	a1,8(s0)
 802:	e810                	sd	a2,16(s0)
 804:	ec14                	sd	a3,24(s0)
 806:	f018                	sd	a4,32(s0)
 808:	f41c                	sd	a5,40(s0)
 80a:	03043823          	sd	a6,48(s0)
 80e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	00840613          	addi	a2,s0,8
 816:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 81a:	85aa                	mv	a1,a0
 81c:	4505                	li	a0,1
 81e:	00000097          	auipc	ra,0x0
 822:	dce080e7          	jalr	-562(ra) # 5ec <vprintf>
}
 826:	60e2                	ld	ra,24(sp)
 828:	6442                	ld	s0,16(sp)
 82a:	6125                	addi	sp,sp,96
 82c:	8082                	ret

000000000000082e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 82e:	1141                	addi	sp,sp,-16
 830:	e422                	sd	s0,8(sp)
 832:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 834:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 838:	00000797          	auipc	a5,0x0
 83c:	2607b783          	ld	a5,608(a5) # a98 <freep>
 840:	a02d                	j	86a <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 842:	4618                	lw	a4,8(a2)
 844:	9f2d                	addw	a4,a4,a1
 846:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	6398                	ld	a4,0(a5)
 84c:	6310                	ld	a2,0(a4)
 84e:	a83d                	j	88c <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 850:	ff852703          	lw	a4,-8(a0)
 854:	9f31                	addw	a4,a4,a2
 856:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 858:	ff053683          	ld	a3,-16(a0)
 85c:	a091                	j	8a0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 85e:	6398                	ld	a4,0(a5)
 860:	00e7e463          	bltu	a5,a4,868 <free+0x3a>
 864:	00e6ea63          	bltu	a3,a4,878 <free+0x4a>
{
 868:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 86a:	fed7fae3          	bgeu	a5,a3,85e <free+0x30>
 86e:	6398                	ld	a4,0(a5)
 870:	00e6e463          	bltu	a3,a4,878 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 874:	fee7eae3          	bltu	a5,a4,868 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 878:	ff852583          	lw	a1,-8(a0)
 87c:	6390                	ld	a2,0(a5)
 87e:	02059813          	slli	a6,a1,0x20
 882:	01c85713          	srli	a4,a6,0x1c
 886:	9736                	add	a4,a4,a3
 888:	fae60de3          	beq	a2,a4,842 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 88c:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 890:	4790                	lw	a2,8(a5)
 892:	02061593          	slli	a1,a2,0x20
 896:	01c5d713          	srli	a4,a1,0x1c
 89a:	973e                	add	a4,a4,a5
 89c:	fae68ae3          	beq	a3,a4,850 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8a0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8a2:	00000717          	auipc	a4,0x0
 8a6:	1ef73b23          	sd	a5,502(a4) # a98 <freep>
}
 8aa:	6422                	ld	s0,8(sp)
 8ac:	0141                	addi	sp,sp,16
 8ae:	8082                	ret

00000000000008b0 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8b0:	7139                	addi	sp,sp,-64
 8b2:	fc06                	sd	ra,56(sp)
 8b4:	f822                	sd	s0,48(sp)
 8b6:	f426                	sd	s1,40(sp)
 8b8:	f04a                	sd	s2,32(sp)
 8ba:	ec4e                	sd	s3,24(sp)
 8bc:	e852                	sd	s4,16(sp)
 8be:	e456                	sd	s5,8(sp)
 8c0:	e05a                	sd	s6,0(sp)
 8c2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c4:	02051493          	slli	s1,a0,0x20
 8c8:	9081                	srli	s1,s1,0x20
 8ca:	04bd                	addi	s1,s1,15
 8cc:	8091                	srli	s1,s1,0x4
 8ce:	0014899b          	addiw	s3,s1,1
 8d2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d4:	00000517          	auipc	a0,0x0
 8d8:	1c453503          	ld	a0,452(a0) # a98 <freep>
 8dc:	c515                	beqz	a0,908 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8de:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e0:	4798                	lw	a4,8(a5)
 8e2:	02977f63          	bgeu	a4,s1,920 <malloc+0x70>
 8e6:	8a4e                	mv	s4,s3
 8e8:	0009871b          	sext.w	a4,s3
 8ec:	6685                	lui	a3,0x1
 8ee:	00d77363          	bgeu	a4,a3,8f4 <malloc+0x44>
 8f2:	6a05                	lui	s4,0x1
 8f4:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f8:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8fc:	00000917          	auipc	s2,0x0
 900:	19c90913          	addi	s2,s2,412 # a98 <freep>
  if(p == (char*)-1)
 904:	5afd                	li	s5,-1
 906:	a895                	j	97a <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 908:	00000797          	auipc	a5,0x0
 90c:	19878793          	addi	a5,a5,408 # aa0 <base>
 910:	00000717          	auipc	a4,0x0
 914:	18f73423          	sd	a5,392(a4) # a98 <freep>
 918:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 91e:	b7e1                	j	8e6 <malloc+0x36>
      if(p->s.size == nunits)
 920:	02e48c63          	beq	s1,a4,958 <malloc+0xa8>
        p->s.size -= nunits;
 924:	4137073b          	subw	a4,a4,s3
 928:	c798                	sw	a4,8(a5)
        p += p->s.size;
 92a:	02071693          	slli	a3,a4,0x20
 92e:	01c6d713          	srli	a4,a3,0x1c
 932:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 934:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 938:	00000717          	auipc	a4,0x0
 93c:	16a73023          	sd	a0,352(a4) # a98 <freep>
      return (void*)(p + 1);
 940:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 944:	70e2                	ld	ra,56(sp)
 946:	7442                	ld	s0,48(sp)
 948:	74a2                	ld	s1,40(sp)
 94a:	7902                	ld	s2,32(sp)
 94c:	69e2                	ld	s3,24(sp)
 94e:	6a42                	ld	s4,16(sp)
 950:	6aa2                	ld	s5,8(sp)
 952:	6b02                	ld	s6,0(sp)
 954:	6121                	addi	sp,sp,64
 956:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 958:	6398                	ld	a4,0(a5)
 95a:	e118                	sd	a4,0(a0)
 95c:	bff1                	j	938 <malloc+0x88>
  hp->s.size = nu;
 95e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 962:	0541                	addi	a0,a0,16
 964:	00000097          	auipc	ra,0x0
 968:	eca080e7          	jalr	-310(ra) # 82e <free>
  return freep;
 96c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 970:	d971                	beqz	a0,944 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 972:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 974:	4798                	lw	a4,8(a5)
 976:	fa9775e3          	bgeu	a4,s1,920 <malloc+0x70>
    if(p == freep)
 97a:	00093703          	ld	a4,0(s2)
 97e:	853e                	mv	a0,a5
 980:	fef719e3          	bne	a4,a5,972 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 984:	8552                	mv	a0,s4
 986:	00000097          	auipc	ra,0x0
 98a:	b80080e7          	jalr	-1152(ra) # 506 <sbrk>
  if(p == (char*)-1)
 98e:	fd5518e3          	bne	a0,s5,95e <malloc+0xae>
        return 0;
 992:	4501                	li	a0,0
 994:	bf45                	j	944 <malloc+0x94>
