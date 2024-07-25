
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	88013103          	ld	sp,-1920(sp) # 80008880 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	070000ef          	jal	ra,80000086 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80000026:	0037969b          	slliw	a3,a5,0x3
    8000002a:	02004737          	lui	a4,0x2004
    8000002e:	96ba                	add	a3,a3,a4
    80000030:	0200c737          	lui	a4,0x200c
    80000034:	ff873603          	ld	a2,-8(a4) # 200bff8 <_entry-0x7dff4008>
    80000038:	000f4737          	lui	a4,0xf4
    8000003c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000040:	963a                	add	a2,a2,a4
    80000042:	e290                	sd	a2,0(a3)

  // prepare information in scratch[] for timervec.
  // scratch[0..3] : space for timervec to save registers.
  // scratch[4] : address of CLINT MTIMECMP register.
  // scratch[5] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &mscratch0[32 * id];
    80000044:	0057979b          	slliw	a5,a5,0x5
    80000048:	078e                	slli	a5,a5,0x3
    8000004a:	00009617          	auipc	a2,0x9
    8000004e:	fe660613          	addi	a2,a2,-26 # 80009030 <mscratch0>
    80000052:	97b2                	add	a5,a5,a2
  scratch[4] = CLINT_MTIMECMP(id);
    80000054:	f394                	sd	a3,32(a5)
  scratch[5] = interval;
    80000056:	f798                	sd	a4,40(a5)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    80000058:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    8000005c:	00006797          	auipc	a5,0x6
    80000060:	d2478793          	addi	a5,a5,-732 # 80005d80 <timervec>
    80000064:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    8000006c:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000070:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000074:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    80000078:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    8000007c:	30479073          	csrw	mie,a5
}
    80000080:	6422                	ld	s0,8(sp)
    80000082:	0141                	addi	sp,sp,16
    80000084:	8082                	ret

0000000080000086 <start>:
{
    80000086:	1141                	addi	sp,sp,-16
    80000088:	e406                	sd	ra,8(sp)
    8000008a:	e022                	sd	s0,0(sp)
    8000008c:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008e:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000092:	7779                	lui	a4,0xffffe
    80000094:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd77ff>
    80000098:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    8000009a:	6705                	lui	a4,0x1
    8000009c:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a2:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000a6:	00001797          	auipc	a5,0x1
    800000aa:	e6078793          	addi	a5,a5,-416 # 80000f06 <main>
    800000ae:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b2:	4781                	li	a5,0
    800000b4:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000b8:	67c1                	lui	a5,0x10
    800000ba:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000bc:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c0:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000c4:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000c8:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000cc:	10479073          	csrw	sie,a5
  timerinit();
    800000d0:	00000097          	auipc	ra,0x0
    800000d4:	f4c080e7          	jalr	-180(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000d8:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000dc:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000de:	823e                	mv	tp,a5
  asm volatile("mret");
    800000e0:	30200073          	mret
}
    800000e4:	60a2                	ld	ra,8(sp)
    800000e6:	6402                	ld	s0,0(sp)
    800000e8:	0141                	addi	sp,sp,16
    800000ea:	8082                	ret

00000000800000ec <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000ec:	715d                	addi	sp,sp,-80
    800000ee:	e486                	sd	ra,72(sp)
    800000f0:	e0a2                	sd	s0,64(sp)
    800000f2:	fc26                	sd	s1,56(sp)
    800000f4:	f84a                	sd	s2,48(sp)
    800000f6:	f44e                	sd	s3,40(sp)
    800000f8:	f052                	sd	s4,32(sp)
    800000fa:	ec56                	sd	s5,24(sp)
    800000fc:	0880                	addi	s0,sp,80
    800000fe:	8a2a                	mv	s4,a0
    80000100:	84ae                	mv	s1,a1
    80000102:	89b2                	mv	s3,a2
  int i;

  acquire(&cons.lock);
    80000104:	00011517          	auipc	a0,0x11
    80000108:	72c50513          	addi	a0,a0,1836 # 80011830 <cons>
    8000010c:	00001097          	auipc	ra,0x1
    80000110:	b50080e7          	jalr	-1200(ra) # 80000c5c <acquire>
  for(i = 0; i < n; i++){
    80000114:	05305c63          	blez	s3,8000016c <consolewrite+0x80>
    80000118:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011a:	5afd                	li	s5,-1
    8000011c:	4685                	li	a3,1
    8000011e:	8626                	mv	a2,s1
    80000120:	85d2                	mv	a1,s4
    80000122:	fbf40513          	addi	a0,s0,-65
    80000126:	00002097          	auipc	ra,0x2
    8000012a:	416080e7          	jalr	1046(ra) # 8000253c <either_copyin>
    8000012e:	01550d63          	beq	a0,s5,80000148 <consolewrite+0x5c>
      break;
    uartputc(c);
    80000132:	fbf44503          	lbu	a0,-65(s0)
    80000136:	00000097          	auipc	ra,0x0
    8000013a:	7f6080e7          	jalr	2038(ra) # 8000092c <uartputc>
  for(i = 0; i < n; i++){
    8000013e:	2905                	addiw	s2,s2,1
    80000140:	0485                	addi	s1,s1,1
    80000142:	fd299de3          	bne	s3,s2,8000011c <consolewrite+0x30>
    80000146:	894e                	mv	s2,s3
  }
  release(&cons.lock);
    80000148:	00011517          	auipc	a0,0x11
    8000014c:	6e850513          	addi	a0,a0,1768 # 80011830 <cons>
    80000150:	00001097          	auipc	ra,0x1
    80000154:	bc0080e7          	jalr	-1088(ra) # 80000d10 <release>

  return i;
}
    80000158:	854a                	mv	a0,s2
    8000015a:	60a6                	ld	ra,72(sp)
    8000015c:	6406                	ld	s0,64(sp)
    8000015e:	74e2                	ld	s1,56(sp)
    80000160:	7942                	ld	s2,48(sp)
    80000162:	79a2                	ld	s3,40(sp)
    80000164:	7a02                	ld	s4,32(sp)
    80000166:	6ae2                	ld	s5,24(sp)
    80000168:	6161                	addi	sp,sp,80
    8000016a:	8082                	ret
  for(i = 0; i < n; i++){
    8000016c:	4901                	li	s2,0
    8000016e:	bfe9                	j	80000148 <consolewrite+0x5c>

0000000080000170 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000170:	7159                	addi	sp,sp,-112
    80000172:	f486                	sd	ra,104(sp)
    80000174:	f0a2                	sd	s0,96(sp)
    80000176:	eca6                	sd	s1,88(sp)
    80000178:	e8ca                	sd	s2,80(sp)
    8000017a:	e4ce                	sd	s3,72(sp)
    8000017c:	e0d2                	sd	s4,64(sp)
    8000017e:	fc56                	sd	s5,56(sp)
    80000180:	f85a                	sd	s6,48(sp)
    80000182:	f45e                	sd	s7,40(sp)
    80000184:	f062                	sd	s8,32(sp)
    80000186:	ec66                	sd	s9,24(sp)
    80000188:	e86a                	sd	s10,16(sp)
    8000018a:	1880                	addi	s0,sp,112
    8000018c:	8aaa                	mv	s5,a0
    8000018e:	8a2e                	mv	s4,a1
    80000190:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000192:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000196:	00011517          	auipc	a0,0x11
    8000019a:	69a50513          	addi	a0,a0,1690 # 80011830 <cons>
    8000019e:	00001097          	auipc	ra,0x1
    800001a2:	abe080e7          	jalr	-1346(ra) # 80000c5c <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800001a6:	00011497          	auipc	s1,0x11
    800001aa:	68a48493          	addi	s1,s1,1674 # 80011830 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ae:	00011917          	auipc	s2,0x11
    800001b2:	71a90913          	addi	s2,s2,1818 # 800118c8 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800001b6:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001b8:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ba:	4ca9                	li	s9,10
  while(n > 0){
    800001bc:	07305863          	blez	s3,8000022c <consoleread+0xbc>
    while(cons.r == cons.w){
    800001c0:	0984a783          	lw	a5,152(s1)
    800001c4:	09c4a703          	lw	a4,156(s1)
    800001c8:	02f71463          	bne	a4,a5,800001f0 <consoleread+0x80>
      if(myproc()->killed){
    800001cc:	00002097          	auipc	ra,0x2
    800001d0:	85c080e7          	jalr	-1956(ra) # 80001a28 <myproc>
    800001d4:	591c                	lw	a5,48(a0)
    800001d6:	e7b5                	bnez	a5,80000242 <consoleread+0xd2>
      sleep(&cons.r, &cons.lock);
    800001d8:	85a6                	mv	a1,s1
    800001da:	854a                	mv	a0,s2
    800001dc:	00002097          	auipc	ra,0x2
    800001e0:	0b0080e7          	jalr	176(ra) # 8000228c <sleep>
    while(cons.r == cons.w){
    800001e4:	0984a783          	lw	a5,152(s1)
    800001e8:	09c4a703          	lw	a4,156(s1)
    800001ec:	fef700e3          	beq	a4,a5,800001cc <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF];
    800001f0:	0017871b          	addiw	a4,a5,1
    800001f4:	08e4ac23          	sw	a4,152(s1)
    800001f8:	07f7f713          	andi	a4,a5,127
    800001fc:	9726                	add	a4,a4,s1
    800001fe:	01874703          	lbu	a4,24(a4)
    80000202:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000206:	077d0563          	beq	s10,s7,80000270 <consoleread+0x100>
    cbuf = c;
    8000020a:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000020e:	4685                	li	a3,1
    80000210:	f9f40613          	addi	a2,s0,-97
    80000214:	85d2                	mv	a1,s4
    80000216:	8556                	mv	a0,s5
    80000218:	00002097          	auipc	ra,0x2
    8000021c:	2ce080e7          	jalr	718(ra) # 800024e6 <either_copyout>
    80000220:	01850663          	beq	a0,s8,8000022c <consoleread+0xbc>
    dst++;
    80000224:	0a05                	addi	s4,s4,1
    --n;
    80000226:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000228:	f99d1ae3          	bne	s10,s9,800001bc <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    8000022c:	00011517          	auipc	a0,0x11
    80000230:	60450513          	addi	a0,a0,1540 # 80011830 <cons>
    80000234:	00001097          	auipc	ra,0x1
    80000238:	adc080e7          	jalr	-1316(ra) # 80000d10 <release>

  return target - n;
    8000023c:	413b053b          	subw	a0,s6,s3
    80000240:	a811                	j	80000254 <consoleread+0xe4>
        release(&cons.lock);
    80000242:	00011517          	auipc	a0,0x11
    80000246:	5ee50513          	addi	a0,a0,1518 # 80011830 <cons>
    8000024a:	00001097          	auipc	ra,0x1
    8000024e:	ac6080e7          	jalr	-1338(ra) # 80000d10 <release>
        return -1;
    80000252:	557d                	li	a0,-1
}
    80000254:	70a6                	ld	ra,104(sp)
    80000256:	7406                	ld	s0,96(sp)
    80000258:	64e6                	ld	s1,88(sp)
    8000025a:	6946                	ld	s2,80(sp)
    8000025c:	69a6                	ld	s3,72(sp)
    8000025e:	6a06                	ld	s4,64(sp)
    80000260:	7ae2                	ld	s5,56(sp)
    80000262:	7b42                	ld	s6,48(sp)
    80000264:	7ba2                	ld	s7,40(sp)
    80000266:	7c02                	ld	s8,32(sp)
    80000268:	6ce2                	ld	s9,24(sp)
    8000026a:	6d42                	ld	s10,16(sp)
    8000026c:	6165                	addi	sp,sp,112
    8000026e:	8082                	ret
      if(n < target){
    80000270:	0009871b          	sext.w	a4,s3
    80000274:	fb677ce3          	bgeu	a4,s6,8000022c <consoleread+0xbc>
        cons.r--;
    80000278:	00011717          	auipc	a4,0x11
    8000027c:	64f72823          	sw	a5,1616(a4) # 800118c8 <cons+0x98>
    80000280:	b775                	j	8000022c <consoleread+0xbc>

0000000080000282 <consputc>:
{
    80000282:	1141                	addi	sp,sp,-16
    80000284:	e406                	sd	ra,8(sp)
    80000286:	e022                	sd	s0,0(sp)
    80000288:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000028a:	10000793          	li	a5,256
    8000028e:	00f50a63          	beq	a0,a5,800002a2 <consputc+0x20>
    uartputc_sync(c);
    80000292:	00000097          	auipc	ra,0x0
    80000296:	5bc080e7          	jalr	1468(ra) # 8000084e <uartputc_sync>
}
    8000029a:	60a2                	ld	ra,8(sp)
    8000029c:	6402                	ld	s0,0(sp)
    8000029e:	0141                	addi	sp,sp,16
    800002a0:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    800002a2:	4521                	li	a0,8
    800002a4:	00000097          	auipc	ra,0x0
    800002a8:	5aa080e7          	jalr	1450(ra) # 8000084e <uartputc_sync>
    800002ac:	02000513          	li	a0,32
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	59e080e7          	jalr	1438(ra) # 8000084e <uartputc_sync>
    800002b8:	4521                	li	a0,8
    800002ba:	00000097          	auipc	ra,0x0
    800002be:	594080e7          	jalr	1428(ra) # 8000084e <uartputc_sync>
    800002c2:	bfe1                	j	8000029a <consputc+0x18>

00000000800002c4 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002c4:	1101                	addi	sp,sp,-32
    800002c6:	ec06                	sd	ra,24(sp)
    800002c8:	e822                	sd	s0,16(sp)
    800002ca:	e426                	sd	s1,8(sp)
    800002cc:	e04a                	sd	s2,0(sp)
    800002ce:	1000                	addi	s0,sp,32
    800002d0:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d2:	00011517          	auipc	a0,0x11
    800002d6:	55e50513          	addi	a0,a0,1374 # 80011830 <cons>
    800002da:	00001097          	auipc	ra,0x1
    800002de:	982080e7          	jalr	-1662(ra) # 80000c5c <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	0af48663          	beq	s1,a5,80000390 <consoleintr+0xcc>
    800002e8:	0297ca63          	blt	a5,s1,8000031c <consoleintr+0x58>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48763          	beq	s1,a5,800003dc <consoleintr+0x118>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49a63          	bne	s1,a5,80000408 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f8:	00002097          	auipc	ra,0x2
    800002fc:	29a080e7          	jalr	666(ra) # 80002592 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80000300:	00011517          	auipc	a0,0x11
    80000304:	53050513          	addi	a0,a0,1328 # 80011830 <cons>
    80000308:	00001097          	auipc	ra,0x1
    8000030c:	a08080e7          	jalr	-1528(ra) # 80000d10 <release>
}
    80000310:	60e2                	ld	ra,24(sp)
    80000312:	6442                	ld	s0,16(sp)
    80000314:	64a2                	ld	s1,8(sp)
    80000316:	6902                	ld	s2,0(sp)
    80000318:	6105                	addi	sp,sp,32
    8000031a:	8082                	ret
  switch(c){
    8000031c:	07f00793          	li	a5,127
    80000320:	0af48e63          	beq	s1,a5,800003dc <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000324:	00011717          	auipc	a4,0x11
    80000328:	50c70713          	addi	a4,a4,1292 # 80011830 <cons>
    8000032c:	0a072783          	lw	a5,160(a4)
    80000330:	09872703          	lw	a4,152(a4)
    80000334:	9f99                	subw	a5,a5,a4
    80000336:	07f00713          	li	a4,127
    8000033a:	fcf763e3          	bltu	a4,a5,80000300 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    8000033e:	47b5                	li	a5,13
    80000340:	0cf48763          	beq	s1,a5,8000040e <consoleintr+0x14a>
      consputc(c);
    80000344:	8526                	mv	a0,s1
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	f3c080e7          	jalr	-196(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000034e:	00011797          	auipc	a5,0x11
    80000352:	4e278793          	addi	a5,a5,1250 # 80011830 <cons>
    80000356:	0a07a703          	lw	a4,160(a5)
    8000035a:	0017069b          	addiw	a3,a4,1
    8000035e:	0006861b          	sext.w	a2,a3
    80000362:	0ad7a023          	sw	a3,160(a5)
    80000366:	07f77713          	andi	a4,a4,127
    8000036a:	97ba                	add	a5,a5,a4
    8000036c:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80000370:	47a9                	li	a5,10
    80000372:	0cf48563          	beq	s1,a5,8000043c <consoleintr+0x178>
    80000376:	4791                	li	a5,4
    80000378:	0cf48263          	beq	s1,a5,8000043c <consoleintr+0x178>
    8000037c:	00011797          	auipc	a5,0x11
    80000380:	54c7a783          	lw	a5,1356(a5) # 800118c8 <cons+0x98>
    80000384:	0807879b          	addiw	a5,a5,128
    80000388:	f6f61ce3          	bne	a2,a5,80000300 <consoleintr+0x3c>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    8000038c:	863e                	mv	a2,a5
    8000038e:	a07d                	j	8000043c <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000390:	00011717          	auipc	a4,0x11
    80000394:	4a070713          	addi	a4,a4,1184 # 80011830 <cons>
    80000398:	0a072783          	lw	a5,160(a4)
    8000039c:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003a0:	00011497          	auipc	s1,0x11
    800003a4:	49048493          	addi	s1,s1,1168 # 80011830 <cons>
    while(cons.e != cons.w &&
    800003a8:	4929                	li	s2,10
    800003aa:	f4f70be3          	beq	a4,a5,80000300 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    800003ae:	37fd                	addiw	a5,a5,-1
    800003b0:	07f7f713          	andi	a4,a5,127
    800003b4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b6:	01874703          	lbu	a4,24(a4)
    800003ba:	f52703e3          	beq	a4,s2,80000300 <consoleintr+0x3c>
      cons.e--;
    800003be:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003c2:	10000513          	li	a0,256
    800003c6:	00000097          	auipc	ra,0x0
    800003ca:	ebc080e7          	jalr	-324(ra) # 80000282 <consputc>
    while(cons.e != cons.w &&
    800003ce:	0a04a783          	lw	a5,160(s1)
    800003d2:	09c4a703          	lw	a4,156(s1)
    800003d6:	fcf71ce3          	bne	a4,a5,800003ae <consoleintr+0xea>
    800003da:	b71d                	j	80000300 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003dc:	00011717          	auipc	a4,0x11
    800003e0:	45470713          	addi	a4,a4,1108 # 80011830 <cons>
    800003e4:	0a072783          	lw	a5,160(a4)
    800003e8:	09c72703          	lw	a4,156(a4)
    800003ec:	f0f70ae3          	beq	a4,a5,80000300 <consoleintr+0x3c>
      cons.e--;
    800003f0:	37fd                	addiw	a5,a5,-1
    800003f2:	00011717          	auipc	a4,0x11
    800003f6:	4cf72f23          	sw	a5,1246(a4) # 800118d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003fa:	10000513          	li	a0,256
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	e84080e7          	jalr	-380(ra) # 80000282 <consputc>
    80000406:	bded                	j	80000300 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80000408:	ee048ce3          	beqz	s1,80000300 <consoleintr+0x3c>
    8000040c:	bf21                	j	80000324 <consoleintr+0x60>
      consputc(c);
    8000040e:	4529                	li	a0,10
    80000410:	00000097          	auipc	ra,0x0
    80000414:	e72080e7          	jalr	-398(ra) # 80000282 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80000418:	00011797          	auipc	a5,0x11
    8000041c:	41878793          	addi	a5,a5,1048 # 80011830 <cons>
    80000420:	0a07a703          	lw	a4,160(a5)
    80000424:	0017069b          	addiw	a3,a4,1
    80000428:	0006861b          	sext.w	a2,a3
    8000042c:	0ad7a023          	sw	a3,160(a5)
    80000430:	07f77713          	andi	a4,a4,127
    80000434:	97ba                	add	a5,a5,a4
    80000436:	4729                	li	a4,10
    80000438:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    8000043c:	00011797          	auipc	a5,0x11
    80000440:	48c7a823          	sw	a2,1168(a5) # 800118cc <cons+0x9c>
        wakeup(&cons.r);
    80000444:	00011517          	auipc	a0,0x11
    80000448:	48450513          	addi	a0,a0,1156 # 800118c8 <cons+0x98>
    8000044c:	00002097          	auipc	ra,0x2
    80000450:	fc0080e7          	jalr	-64(ra) # 8000240c <wakeup>
    80000454:	b575                	j	80000300 <consoleintr+0x3c>

0000000080000456 <consoleinit>:

void
consoleinit(void)
{
    80000456:	1141                	addi	sp,sp,-16
    80000458:	e406                	sd	ra,8(sp)
    8000045a:	e022                	sd	s0,0(sp)
    8000045c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00011517          	auipc	a0,0x11
    8000046a:	3ca50513          	addi	a0,a0,970 # 80011830 <cons>
    8000046e:	00000097          	auipc	ra,0x0
    80000472:	75e080e7          	jalr	1886(ra) # 80000bcc <initlock>

  uartinit();
    80000476:	00000097          	auipc	ra,0x0
    8000047a:	388080e7          	jalr	904(ra) # 800007fe <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000047e:	00022797          	auipc	a5,0x22
    80000482:	f3278793          	addi	a5,a5,-206 # 800223b0 <devsw>
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	cea70713          	addi	a4,a4,-790 # 80000170 <consoleread>
    8000048e:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000490:	00000717          	auipc	a4,0x0
    80000494:	c5c70713          	addi	a4,a4,-932 # 800000ec <consolewrite>
    80000498:	ef98                	sd	a4,24(a5)
}
    8000049a:	60a2                	ld	ra,8(sp)
    8000049c:	6402                	ld	s0,0(sp)
    8000049e:	0141                	addi	sp,sp,16
    800004a0:	8082                	ret

00000000800004a2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    800004a2:	7179                	addi	sp,sp,-48
    800004a4:	f406                	sd	ra,40(sp)
    800004a6:	f022                	sd	s0,32(sp)
    800004a8:	ec26                	sd	s1,24(sp)
    800004aa:	e84a                	sd	s2,16(sp)
    800004ac:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004ae:	c219                	beqz	a2,800004b4 <printint+0x12>
    800004b0:	08054763          	bltz	a0,8000053e <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004b4:	2501                	sext.w	a0,a0
    800004b6:	4881                	li	a7,0
    800004b8:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004bc:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004be:	2581                	sext.w	a1,a1
    800004c0:	00008617          	auipc	a2,0x8
    800004c4:	b8860613          	addi	a2,a2,-1144 # 80008048 <digits>
    800004c8:	883a                	mv	a6,a4
    800004ca:	2705                	addiw	a4,a4,1
    800004cc:	02b577bb          	remuw	a5,a0,a1
    800004d0:	1782                	slli	a5,a5,0x20
    800004d2:	9381                	srli	a5,a5,0x20
    800004d4:	97b2                	add	a5,a5,a2
    800004d6:	0007c783          	lbu	a5,0(a5)
    800004da:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004de:	0005079b          	sext.w	a5,a0
    800004e2:	02b5553b          	divuw	a0,a0,a1
    800004e6:	0685                	addi	a3,a3,1
    800004e8:	feb7f0e3          	bgeu	a5,a1,800004c8 <printint+0x26>

  if(sign)
    800004ec:	00088c63          	beqz	a7,80000504 <printint+0x62>
    buf[i++] = '-';
    800004f0:	fe070793          	addi	a5,a4,-32
    800004f4:	00878733          	add	a4,a5,s0
    800004f8:	02d00793          	li	a5,45
    800004fc:	fef70823          	sb	a5,-16(a4)
    80000500:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    80000504:	02e05763          	blez	a4,80000532 <printint+0x90>
    80000508:	fd040793          	addi	a5,s0,-48
    8000050c:	00e784b3          	add	s1,a5,a4
    80000510:	fff78913          	addi	s2,a5,-1
    80000514:	993a                	add	s2,s2,a4
    80000516:	377d                	addiw	a4,a4,-1
    80000518:	1702                	slli	a4,a4,0x20
    8000051a:	9301                	srli	a4,a4,0x20
    8000051c:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000520:	fff4c503          	lbu	a0,-1(s1)
    80000524:	00000097          	auipc	ra,0x0
    80000528:	d5e080e7          	jalr	-674(ra) # 80000282 <consputc>
  while(--i >= 0)
    8000052c:	14fd                	addi	s1,s1,-1
    8000052e:	ff2499e3          	bne	s1,s2,80000520 <printint+0x7e>
}
    80000532:	70a2                	ld	ra,40(sp)
    80000534:	7402                	ld	s0,32(sp)
    80000536:	64e2                	ld	s1,24(sp)
    80000538:	6942                	ld	s2,16(sp)
    8000053a:	6145                	addi	sp,sp,48
    8000053c:	8082                	ret
    x = -xx;
    8000053e:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000542:	4885                	li	a7,1
    x = -xx;
    80000544:	bf95                	j	800004b8 <printint+0x16>

0000000080000546 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000546:	1101                	addi	sp,sp,-32
    80000548:	ec06                	sd	ra,24(sp)
    8000054a:	e822                	sd	s0,16(sp)
    8000054c:	e426                	sd	s1,8(sp)
    8000054e:	1000                	addi	s0,sp,32
    80000550:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000552:	00011797          	auipc	a5,0x11
    80000556:	3807af23          	sw	zero,926(a5) # 800118f0 <pr+0x18>
  printf("panic: ");
    8000055a:	00008517          	auipc	a0,0x8
    8000055e:	abe50513          	addi	a0,a0,-1346 # 80008018 <etext+0x18>
    80000562:	00000097          	auipc	ra,0x0
    80000566:	02e080e7          	jalr	46(ra) # 80000590 <printf>
  printf(s);
    8000056a:	8526                	mv	a0,s1
    8000056c:	00000097          	auipc	ra,0x0
    80000570:	024080e7          	jalr	36(ra) # 80000590 <printf>
  printf("\n");
    80000574:	00008517          	auipc	a0,0x8
    80000578:	b5c50513          	addi	a0,a0,-1188 # 800080d0 <digits+0x88>
    8000057c:	00000097          	auipc	ra,0x0
    80000580:	014080e7          	jalr	20(ra) # 80000590 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000584:	4785                	li	a5,1
    80000586:	00009717          	auipc	a4,0x9
    8000058a:	a6f72d23          	sw	a5,-1414(a4) # 80009000 <panicked>
  for(;;)
    8000058e:	a001                	j	8000058e <panic+0x48>

0000000080000590 <printf>:
{
    80000590:	7131                	addi	sp,sp,-192
    80000592:	fc86                	sd	ra,120(sp)
    80000594:	f8a2                	sd	s0,112(sp)
    80000596:	f4a6                	sd	s1,104(sp)
    80000598:	f0ca                	sd	s2,96(sp)
    8000059a:	ecce                	sd	s3,88(sp)
    8000059c:	e8d2                	sd	s4,80(sp)
    8000059e:	e4d6                	sd	s5,72(sp)
    800005a0:	e0da                	sd	s6,64(sp)
    800005a2:	fc5e                	sd	s7,56(sp)
    800005a4:	f862                	sd	s8,48(sp)
    800005a6:	f466                	sd	s9,40(sp)
    800005a8:	f06a                	sd	s10,32(sp)
    800005aa:	ec6e                	sd	s11,24(sp)
    800005ac:	0100                	addi	s0,sp,128
    800005ae:	8a2a                	mv	s4,a0
    800005b0:	e40c                	sd	a1,8(s0)
    800005b2:	e810                	sd	a2,16(s0)
    800005b4:	ec14                	sd	a3,24(s0)
    800005b6:	f018                	sd	a4,32(s0)
    800005b8:	f41c                	sd	a5,40(s0)
    800005ba:	03043823          	sd	a6,48(s0)
    800005be:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005c2:	00011d97          	auipc	s11,0x11
    800005c6:	32edad83          	lw	s11,814(s11) # 800118f0 <pr+0x18>
  if(locking)
    800005ca:	020d9b63          	bnez	s11,80000600 <printf+0x70>
  if (fmt == 0)
    800005ce:	040a0263          	beqz	s4,80000612 <printf+0x82>
  va_start(ap, fmt);
    800005d2:	00840793          	addi	a5,s0,8
    800005d6:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005da:	000a4503          	lbu	a0,0(s4)
    800005de:	14050f63          	beqz	a0,8000073c <printf+0x1ac>
    800005e2:	4981                	li	s3,0
    if(c != '%'){
    800005e4:	02500a93          	li	s5,37
    switch(c){
    800005e8:	07000b93          	li	s7,112
  consputc('x');
    800005ec:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005ee:	00008b17          	auipc	s6,0x8
    800005f2:	a5ab0b13          	addi	s6,s6,-1446 # 80008048 <digits>
    switch(c){
    800005f6:	07300c93          	li	s9,115
    800005fa:	06400c13          	li	s8,100
    800005fe:	a82d                	j	80000638 <printf+0xa8>
    acquire(&pr.lock);
    80000600:	00011517          	auipc	a0,0x11
    80000604:	2d850513          	addi	a0,a0,728 # 800118d8 <pr>
    80000608:	00000097          	auipc	ra,0x0
    8000060c:	654080e7          	jalr	1620(ra) # 80000c5c <acquire>
    80000610:	bf7d                	j	800005ce <printf+0x3e>
    panic("null fmt");
    80000612:	00008517          	auipc	a0,0x8
    80000616:	a1650513          	addi	a0,a0,-1514 # 80008028 <etext+0x28>
    8000061a:	00000097          	auipc	ra,0x0
    8000061e:	f2c080e7          	jalr	-212(ra) # 80000546 <panic>
      consputc(c);
    80000622:	00000097          	auipc	ra,0x0
    80000626:	c60080e7          	jalr	-928(ra) # 80000282 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    8000062a:	2985                	addiw	s3,s3,1
    8000062c:	013a07b3          	add	a5,s4,s3
    80000630:	0007c503          	lbu	a0,0(a5)
    80000634:	10050463          	beqz	a0,8000073c <printf+0x1ac>
    if(c != '%'){
    80000638:	ff5515e3          	bne	a0,s5,80000622 <printf+0x92>
    c = fmt[++i] & 0xff;
    8000063c:	2985                	addiw	s3,s3,1
    8000063e:	013a07b3          	add	a5,s4,s3
    80000642:	0007c783          	lbu	a5,0(a5)
    80000646:	0007849b          	sext.w	s1,a5
    if(c == 0)
    8000064a:	cbed                	beqz	a5,8000073c <printf+0x1ac>
    switch(c){
    8000064c:	05778a63          	beq	a5,s7,800006a0 <printf+0x110>
    80000650:	02fbf663          	bgeu	s7,a5,8000067c <printf+0xec>
    80000654:	09978863          	beq	a5,s9,800006e4 <printf+0x154>
    80000658:	07800713          	li	a4,120
    8000065c:	0ce79563          	bne	a5,a4,80000726 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4605                	li	a2,1
    8000066e:	85ea                	mv	a1,s10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	00000097          	auipc	ra,0x0
    80000676:	e30080e7          	jalr	-464(ra) # 800004a2 <printint>
      break;
    8000067a:	bf45                	j	8000062a <printf+0x9a>
    switch(c){
    8000067c:	09578f63          	beq	a5,s5,8000071a <printf+0x18a>
    80000680:	0b879363          	bne	a5,s8,80000726 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    80000684:	f8843783          	ld	a5,-120(s0)
    80000688:	00878713          	addi	a4,a5,8
    8000068c:	f8e43423          	sd	a4,-120(s0)
    80000690:	4605                	li	a2,1
    80000692:	45a9                	li	a1,10
    80000694:	4388                	lw	a0,0(a5)
    80000696:	00000097          	auipc	ra,0x0
    8000069a:	e0c080e7          	jalr	-500(ra) # 800004a2 <printint>
      break;
    8000069e:	b771                	j	8000062a <printf+0x9a>
      printptr(va_arg(ap, uint64));
    800006a0:	f8843783          	ld	a5,-120(s0)
    800006a4:	00878713          	addi	a4,a5,8
    800006a8:	f8e43423          	sd	a4,-120(s0)
    800006ac:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006b0:	03000513          	li	a0,48
    800006b4:	00000097          	auipc	ra,0x0
    800006b8:	bce080e7          	jalr	-1074(ra) # 80000282 <consputc>
  consputc('x');
    800006bc:	07800513          	li	a0,120
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bc2080e7          	jalr	-1086(ra) # 80000282 <consputc>
    800006c8:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ca:	03c95793          	srli	a5,s2,0x3c
    800006ce:	97da                	add	a5,a5,s6
    800006d0:	0007c503          	lbu	a0,0(a5)
    800006d4:	00000097          	auipc	ra,0x0
    800006d8:	bae080e7          	jalr	-1106(ra) # 80000282 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006dc:	0912                	slli	s2,s2,0x4
    800006de:	34fd                	addiw	s1,s1,-1
    800006e0:	f4ed                	bnez	s1,800006ca <printf+0x13a>
    800006e2:	b7a1                	j	8000062a <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	6384                	ld	s1,0(a5)
    800006f2:	cc89                	beqz	s1,8000070c <printf+0x17c>
      for(; *s; s++)
    800006f4:	0004c503          	lbu	a0,0(s1)
    800006f8:	d90d                	beqz	a0,8000062a <printf+0x9a>
        consputc(*s);
    800006fa:	00000097          	auipc	ra,0x0
    800006fe:	b88080e7          	jalr	-1144(ra) # 80000282 <consputc>
      for(; *s; s++)
    80000702:	0485                	addi	s1,s1,1
    80000704:	0004c503          	lbu	a0,0(s1)
    80000708:	f96d                	bnez	a0,800006fa <printf+0x16a>
    8000070a:	b705                	j	8000062a <printf+0x9a>
        s = "(null)";
    8000070c:	00008497          	auipc	s1,0x8
    80000710:	91448493          	addi	s1,s1,-1772 # 80008020 <etext+0x20>
      for(; *s; s++)
    80000714:	02800513          	li	a0,40
    80000718:	b7cd                	j	800006fa <printf+0x16a>
      consputc('%');
    8000071a:	8556                	mv	a0,s5
    8000071c:	00000097          	auipc	ra,0x0
    80000720:	b66080e7          	jalr	-1178(ra) # 80000282 <consputc>
      break;
    80000724:	b719                	j	8000062a <printf+0x9a>
      consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b5a080e7          	jalr	-1190(ra) # 80000282 <consputc>
      consputc(c);
    80000730:	8526                	mv	a0,s1
    80000732:	00000097          	auipc	ra,0x0
    80000736:	b50080e7          	jalr	-1200(ra) # 80000282 <consputc>
      break;
    8000073a:	bdc5                	j	8000062a <printf+0x9a>
  if(locking)
    8000073c:	020d9163          	bnez	s11,8000075e <printf+0x1ce>
}
    80000740:	70e6                	ld	ra,120(sp)
    80000742:	7446                	ld	s0,112(sp)
    80000744:	74a6                	ld	s1,104(sp)
    80000746:	7906                	ld	s2,96(sp)
    80000748:	69e6                	ld	s3,88(sp)
    8000074a:	6a46                	ld	s4,80(sp)
    8000074c:	6aa6                	ld	s5,72(sp)
    8000074e:	6b06                	ld	s6,64(sp)
    80000750:	7be2                	ld	s7,56(sp)
    80000752:	7c42                	ld	s8,48(sp)
    80000754:	7ca2                	ld	s9,40(sp)
    80000756:	7d02                	ld	s10,32(sp)
    80000758:	6de2                	ld	s11,24(sp)
    8000075a:	6129                	addi	sp,sp,192
    8000075c:	8082                	ret
    release(&pr.lock);
    8000075e:	00011517          	auipc	a0,0x11
    80000762:	17a50513          	addi	a0,a0,378 # 800118d8 <pr>
    80000766:	00000097          	auipc	ra,0x0
    8000076a:	5aa080e7          	jalr	1450(ra) # 80000d10 <release>
}
    8000076e:	bfc9                	j	80000740 <printf+0x1b0>

0000000080000770 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000770:	1101                	addi	sp,sp,-32
    80000772:	ec06                	sd	ra,24(sp)
    80000774:	e822                	sd	s0,16(sp)
    80000776:	e426                	sd	s1,8(sp)
    80000778:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    8000077a:	00011497          	auipc	s1,0x11
    8000077e:	15e48493          	addi	s1,s1,350 # 800118d8 <pr>
    80000782:	00008597          	auipc	a1,0x8
    80000786:	8b658593          	addi	a1,a1,-1866 # 80008038 <etext+0x38>
    8000078a:	8526                	mv	a0,s1
    8000078c:	00000097          	auipc	ra,0x0
    80000790:	440080e7          	jalr	1088(ra) # 80000bcc <initlock>
  pr.locking = 1;
    80000794:	4785                	li	a5,1
    80000796:	cc9c                	sw	a5,24(s1)
}
    80000798:	60e2                	ld	ra,24(sp)
    8000079a:	6442                	ld	s0,16(sp)
    8000079c:	64a2                	ld	s1,8(sp)
    8000079e:	6105                	addi	sp,sp,32
    800007a0:	8082                	ret

00000000800007a2 <backtrace>:
//add
void backtrace(){
    800007a2:	7179                	addi	sp,sp,-48
    800007a4:	f406                	sd	ra,40(sp)
    800007a6:	f022                	sd	s0,32(sp)
    800007a8:	ec26                	sd	s1,24(sp)
    800007aa:	e84a                	sd	s2,16(sp)
    800007ac:	e44e                	sd	s3,8(sp)
    800007ae:	e052                	sd	s4,0(sp)
    800007b0:	1800                	addi	s0,sp,48
  asm volatile("mv %0,s0" : "=r"(x));
    800007b2:	84a2                	mv	s1,s0
  uint64 fp=r_fp();
  while (fp!=PGROUNDUP(fp))
    800007b4:	6785                	lui	a5,0x1
    800007b6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800007b8:	97a6                	add	a5,a5,s1
    800007ba:	777d                	lui	a4,0xfffff
    800007bc:	8ff9                	and	a5,a5,a4
    800007be:	02f48863          	beq	s1,a5,800007ee <backtrace+0x4c>
  {
    uint64 stackframe=*(uint64*)(fp-8);
    printf("%p\n",stackframe);
    800007c2:	00008a17          	auipc	s4,0x8
    800007c6:	87ea0a13          	addi	s4,s4,-1922 # 80008040 <etext+0x40>
  while (fp!=PGROUNDUP(fp))
    800007ca:	6905                	lui	s2,0x1
    800007cc:	197d                	addi	s2,s2,-1 # fff <_entry-0x7ffff001>
    800007ce:	79fd                	lui	s3,0xfffff
    printf("%p\n",stackframe);
    800007d0:	ff84b583          	ld	a1,-8(s1)
    800007d4:	8552                	mv	a0,s4
    800007d6:	00000097          	auipc	ra,0x0
    800007da:	dba080e7          	jalr	-582(ra) # 80000590 <printf>
    fp=*(uint64*)(fp-16);
    800007de:	ff04b483          	ld	s1,-16(s1)
  while (fp!=PGROUNDUP(fp))
    800007e2:	012487b3          	add	a5,s1,s2
    800007e6:	0137f7b3          	and	a5,a5,s3
    800007ea:	fe9793e3          	bne	a5,s1,800007d0 <backtrace+0x2e>
  }
  
    800007ee:	70a2                	ld	ra,40(sp)
    800007f0:	7402                	ld	s0,32(sp)
    800007f2:	64e2                	ld	s1,24(sp)
    800007f4:	6942                	ld	s2,16(sp)
    800007f6:	69a2                	ld	s3,8(sp)
    800007f8:	6a02                	ld	s4,0(sp)
    800007fa:	6145                	addi	sp,sp,48
    800007fc:	8082                	ret

00000000800007fe <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fe:	1141                	addi	sp,sp,-16
    80000800:	e406                	sd	ra,8(sp)
    80000802:	e022                	sd	s0,0(sp)
    80000804:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000806:	100007b7          	lui	a5,0x10000
    8000080a:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080e:	f8000713          	li	a4,-128
    80000812:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000816:	470d                	li	a4,3
    80000818:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    8000081c:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000820:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80000824:	469d                	li	a3,7
    80000826:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    8000082a:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000082e:	00008597          	auipc	a1,0x8
    80000832:	83258593          	addi	a1,a1,-1998 # 80008060 <digits+0x18>
    80000836:	00011517          	auipc	a0,0x11
    8000083a:	0c250513          	addi	a0,a0,194 # 800118f8 <uart_tx_lock>
    8000083e:	00000097          	auipc	ra,0x0
    80000842:	38e080e7          	jalr	910(ra) # 80000bcc <initlock>
}
    80000846:	60a2                	ld	ra,8(sp)
    80000848:	6402                	ld	s0,0(sp)
    8000084a:	0141                	addi	sp,sp,16
    8000084c:	8082                	ret

000000008000084e <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000084e:	1101                	addi	sp,sp,-32
    80000850:	ec06                	sd	ra,24(sp)
    80000852:	e822                	sd	s0,16(sp)
    80000854:	e426                	sd	s1,8(sp)
    80000856:	1000                	addi	s0,sp,32
    80000858:	84aa                	mv	s1,a0
  push_off();
    8000085a:	00000097          	auipc	ra,0x0
    8000085e:	3b6080e7          	jalr	950(ra) # 80000c10 <push_off>

  if(panicked){
    80000862:	00008797          	auipc	a5,0x8
    80000866:	79e7a783          	lw	a5,1950(a5) # 80009000 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000086e:	c391                	beqz	a5,80000872 <uartputc_sync+0x24>
    for(;;)
    80000870:	a001                	j	80000870 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000872:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000876:	0207f793          	andi	a5,a5,32
    8000087a:	dfe5                	beqz	a5,80000872 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000087c:	0ff4f513          	zext.b	a0,s1
    80000880:	100007b7          	lui	a5,0x10000
    80000884:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000888:	00000097          	auipc	ra,0x0
    8000088c:	428080e7          	jalr	1064(ra) # 80000cb0 <pop_off>
}
    80000890:	60e2                	ld	ra,24(sp)
    80000892:	6442                	ld	s0,16(sp)
    80000894:	64a2                	ld	s1,8(sp)
    80000896:	6105                	addi	sp,sp,32
    80000898:	8082                	ret

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	00008797          	auipc	a5,0x8
    8000089e:	76a7a783          	lw	a5,1898(a5) # 80009004 <uart_tx_r>
    800008a2:	00008717          	auipc	a4,0x8
    800008a6:	76672703          	lw	a4,1894(a4) # 80009008 <uart_tx_w>
    800008aa:	08f70063          	beq	a4,a5,8000092a <uartstart+0x90>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c0:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r];
    800008c4:	00011a97          	auipc	s5,0x11
    800008c8:	034a8a93          	addi	s5,s5,52 # 800118f8 <uart_tx_lock>
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008cc:	00008497          	auipc	s1,0x8
    800008d0:	73848493          	addi	s1,s1,1848 # 80009004 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    800008d4:	00008a17          	auipc	s4,0x8
    800008d8:	734a0a13          	addi	s4,s4,1844 # 80009008 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008dc:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    800008e0:	02077713          	andi	a4,a4,32
    800008e4:	cb15                	beqz	a4,80000918 <uartstart+0x7e>
    int c = uart_tx_buf[uart_tx_r];
    800008e6:	00fa8733          	add	a4,s5,a5
    800008ea:	01874983          	lbu	s3,24(a4)
    uart_tx_r = (uart_tx_r + 1) % UART_TX_BUF_SIZE;
    800008ee:	2785                	addiw	a5,a5,1
    800008f0:	41f7d71b          	sraiw	a4,a5,0x1f
    800008f4:	01b7571b          	srliw	a4,a4,0x1b
    800008f8:	9fb9                	addw	a5,a5,a4
    800008fa:	8bfd                	andi	a5,a5,31
    800008fc:	9f99                	subw	a5,a5,a4
    800008fe:	c09c                	sw	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000900:	8526                	mv	a0,s1
    80000902:	00002097          	auipc	ra,0x2
    80000906:	b0a080e7          	jalr	-1270(ra) # 8000240c <wakeup>
    
    WriteReg(THR, c);
    8000090a:	01390023          	sb	s3,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000090e:	409c                	lw	a5,0(s1)
    80000910:	000a2703          	lw	a4,0(s4)
    80000914:	fcf714e3          	bne	a4,a5,800008dc <uartstart+0x42>
  }
}
    80000918:	70e2                	ld	ra,56(sp)
    8000091a:	7442                	ld	s0,48(sp)
    8000091c:	74a2                	ld	s1,40(sp)
    8000091e:	7902                	ld	s2,32(sp)
    80000920:	69e2                	ld	s3,24(sp)
    80000922:	6a42                	ld	s4,16(sp)
    80000924:	6aa2                	ld	s5,8(sp)
    80000926:	6121                	addi	sp,sp,64
    80000928:	8082                	ret
    8000092a:	8082                	ret

000000008000092c <uartputc>:
{
    8000092c:	7179                	addi	sp,sp,-48
    8000092e:	f406                	sd	ra,40(sp)
    80000930:	f022                	sd	s0,32(sp)
    80000932:	ec26                	sd	s1,24(sp)
    80000934:	e84a                	sd	s2,16(sp)
    80000936:	e44e                	sd	s3,8(sp)
    80000938:	e052                	sd	s4,0(sp)
    8000093a:	1800                	addi	s0,sp,48
    8000093c:	84aa                	mv	s1,a0
  acquire(&uart_tx_lock);
    8000093e:	00011517          	auipc	a0,0x11
    80000942:	fba50513          	addi	a0,a0,-70 # 800118f8 <uart_tx_lock>
    80000946:	00000097          	auipc	ra,0x0
    8000094a:	316080e7          	jalr	790(ra) # 80000c5c <acquire>
  if(panicked){
    8000094e:	00008797          	auipc	a5,0x8
    80000952:	6b27a783          	lw	a5,1714(a5) # 80009000 <panicked>
    80000956:	c391                	beqz	a5,8000095a <uartputc+0x2e>
    for(;;)
    80000958:	a001                	j	80000958 <uartputc+0x2c>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    8000095a:	00008697          	auipc	a3,0x8
    8000095e:	6ae6a683          	lw	a3,1710(a3) # 80009008 <uart_tx_w>
    80000962:	0016879b          	addiw	a5,a3,1
    80000966:	41f7d71b          	sraiw	a4,a5,0x1f
    8000096a:	01b7571b          	srliw	a4,a4,0x1b
    8000096e:	9fb9                	addw	a5,a5,a4
    80000970:	8bfd                	andi	a5,a5,31
    80000972:	9f99                	subw	a5,a5,a4
    80000974:	00008717          	auipc	a4,0x8
    80000978:	69072703          	lw	a4,1680(a4) # 80009004 <uart_tx_r>
    8000097c:	04f71363          	bne	a4,a5,800009c2 <uartputc+0x96>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000980:	00011a17          	auipc	s4,0x11
    80000984:	f78a0a13          	addi	s4,s4,-136 # 800118f8 <uart_tx_lock>
    80000988:	00008917          	auipc	s2,0x8
    8000098c:	67c90913          	addi	s2,s2,1660 # 80009004 <uart_tx_r>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    80000990:	00008997          	auipc	s3,0x8
    80000994:	67898993          	addi	s3,s3,1656 # 80009008 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80000998:	85d2                	mv	a1,s4
    8000099a:	854a                	mv	a0,s2
    8000099c:	00002097          	auipc	ra,0x2
    800009a0:	8f0080e7          	jalr	-1808(ra) # 8000228c <sleep>
    if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
    800009a4:	0009a683          	lw	a3,0(s3)
    800009a8:	0016879b          	addiw	a5,a3,1
    800009ac:	41f7d71b          	sraiw	a4,a5,0x1f
    800009b0:	01b7571b          	srliw	a4,a4,0x1b
    800009b4:	9fb9                	addw	a5,a5,a4
    800009b6:	8bfd                	andi	a5,a5,31
    800009b8:	9f99                	subw	a5,a5,a4
    800009ba:	00092703          	lw	a4,0(s2)
    800009be:	fcf70de3          	beq	a4,a5,80000998 <uartputc+0x6c>
      uart_tx_buf[uart_tx_w] = c;
    800009c2:	00011917          	auipc	s2,0x11
    800009c6:	f3690913          	addi	s2,s2,-202 # 800118f8 <uart_tx_lock>
    800009ca:	96ca                	add	a3,a3,s2
    800009cc:	00968c23          	sb	s1,24(a3)
      uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
    800009d0:	00008717          	auipc	a4,0x8
    800009d4:	62f72c23          	sw	a5,1592(a4) # 80009008 <uart_tx_w>
      uartstart();
    800009d8:	00000097          	auipc	ra,0x0
    800009dc:	ec2080e7          	jalr	-318(ra) # 8000089a <uartstart>
      release(&uart_tx_lock);
    800009e0:	854a                	mv	a0,s2
    800009e2:	00000097          	auipc	ra,0x0
    800009e6:	32e080e7          	jalr	814(ra) # 80000d10 <release>
}
    800009ea:	70a2                	ld	ra,40(sp)
    800009ec:	7402                	ld	s0,32(sp)
    800009ee:	64e2                	ld	s1,24(sp)
    800009f0:	6942                	ld	s2,16(sp)
    800009f2:	69a2                	ld	s3,8(sp)
    800009f4:	6a02                	ld	s4,0(sp)
    800009f6:	6145                	addi	sp,sp,48
    800009f8:	8082                	ret

00000000800009fa <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009fa:	1141                	addi	sp,sp,-16
    800009fc:	e422                	sd	s0,8(sp)
    800009fe:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000a00:	100007b7          	lui	a5,0x10000
    80000a04:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a08:	8b85                	andi	a5,a5,1
    80000a0a:	cb81                	beqz	a5,80000a1a <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000a0c:	100007b7          	lui	a5,0x10000
    80000a10:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a14:	6422                	ld	s0,8(sp)
    80000a16:	0141                	addi	sp,sp,16
    80000a18:	8082                	ret
    return -1;
    80000a1a:	557d                	li	a0,-1
    80000a1c:	bfe5                	j	80000a14 <uartgetc+0x1a>

0000000080000a1e <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80000a1e:	1101                	addi	sp,sp,-32
    80000a20:	ec06                	sd	ra,24(sp)
    80000a22:	e822                	sd	s0,16(sp)
    80000a24:	e426                	sd	s1,8(sp)
    80000a26:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a28:	54fd                	li	s1,-1
    80000a2a:	a029                	j	80000a34 <uartintr+0x16>
      break;
    consoleintr(c);
    80000a2c:	00000097          	auipc	ra,0x0
    80000a30:	898080e7          	jalr	-1896(ra) # 800002c4 <consoleintr>
    int c = uartgetc();
    80000a34:	00000097          	auipc	ra,0x0
    80000a38:	fc6080e7          	jalr	-58(ra) # 800009fa <uartgetc>
    if(c == -1)
    80000a3c:	fe9518e3          	bne	a0,s1,80000a2c <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a40:	00011497          	auipc	s1,0x11
    80000a44:	eb848493          	addi	s1,s1,-328 # 800118f8 <uart_tx_lock>
    80000a48:	8526                	mv	a0,s1
    80000a4a:	00000097          	auipc	ra,0x0
    80000a4e:	212080e7          	jalr	530(ra) # 80000c5c <acquire>
  uartstart();
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	e48080e7          	jalr	-440(ra) # 8000089a <uartstart>
  release(&uart_tx_lock);
    80000a5a:	8526                	mv	a0,s1
    80000a5c:	00000097          	auipc	ra,0x0
    80000a60:	2b4080e7          	jalr	692(ra) # 80000d10 <release>
}
    80000a64:	60e2                	ld	ra,24(sp)
    80000a66:	6442                	ld	s0,16(sp)
    80000a68:	64a2                	ld	s1,8(sp)
    80000a6a:	6105                	addi	sp,sp,32
    80000a6c:	8082                	ret

0000000080000a6e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a6e:	1101                	addi	sp,sp,-32
    80000a70:	ec06                	sd	ra,24(sp)
    80000a72:	e822                	sd	s0,16(sp)
    80000a74:	e426                	sd	s1,8(sp)
    80000a76:	e04a                	sd	s2,0(sp)
    80000a78:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a7a:	03451793          	slli	a5,a0,0x34
    80000a7e:	ebb9                	bnez	a5,80000ad4 <kfree+0x66>
    80000a80:	84aa                	mv	s1,a0
    80000a82:	00026797          	auipc	a5,0x26
    80000a86:	57e78793          	addi	a5,a5,1406 # 80027000 <end>
    80000a8a:	04f56563          	bltu	a0,a5,80000ad4 <kfree+0x66>
    80000a8e:	47c5                	li	a5,17
    80000a90:	07ee                	slli	a5,a5,0x1b
    80000a92:	04f57163          	bgeu	a0,a5,80000ad4 <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a96:	6605                	lui	a2,0x1
    80000a98:	4585                	li	a1,1
    80000a9a:	00000097          	auipc	ra,0x0
    80000a9e:	2be080e7          	jalr	702(ra) # 80000d58 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000aa2:	00011917          	auipc	s2,0x11
    80000aa6:	e8e90913          	addi	s2,s2,-370 # 80011930 <kmem>
    80000aaa:	854a                	mv	a0,s2
    80000aac:	00000097          	auipc	ra,0x0
    80000ab0:	1b0080e7          	jalr	432(ra) # 80000c5c <acquire>
  r->next = kmem.freelist;
    80000ab4:	01893783          	ld	a5,24(s2)
    80000ab8:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000aba:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000abe:	854a                	mv	a0,s2
    80000ac0:	00000097          	auipc	ra,0x0
    80000ac4:	250080e7          	jalr	592(ra) # 80000d10 <release>
}
    80000ac8:	60e2                	ld	ra,24(sp)
    80000aca:	6442                	ld	s0,16(sp)
    80000acc:	64a2                	ld	s1,8(sp)
    80000ace:	6902                	ld	s2,0(sp)
    80000ad0:	6105                	addi	sp,sp,32
    80000ad2:	8082                	ret
    panic("kfree");
    80000ad4:	00007517          	auipc	a0,0x7
    80000ad8:	59450513          	addi	a0,a0,1428 # 80008068 <digits+0x20>
    80000adc:	00000097          	auipc	ra,0x0
    80000ae0:	a6a080e7          	jalr	-1430(ra) # 80000546 <panic>

0000000080000ae4 <freerange>:
{
    80000ae4:	7179                	addi	sp,sp,-48
    80000ae6:	f406                	sd	ra,40(sp)
    80000ae8:	f022                	sd	s0,32(sp)
    80000aea:	ec26                	sd	s1,24(sp)
    80000aec:	e84a                	sd	s2,16(sp)
    80000aee:	e44e                	sd	s3,8(sp)
    80000af0:	e052                	sd	s4,0(sp)
    80000af2:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000af4:	6785                	lui	a5,0x1
    80000af6:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000afa:	00e504b3          	add	s1,a0,a4
    80000afe:	777d                	lui	a4,0xfffff
    80000b00:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b02:	94be                	add	s1,s1,a5
    80000b04:	0095ee63          	bltu	a1,s1,80000b20 <freerange+0x3c>
    80000b08:	892e                	mv	s2,a1
    kfree(p);
    80000b0a:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b0c:	6985                	lui	s3,0x1
    kfree(p);
    80000b0e:	01448533          	add	a0,s1,s4
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	f5c080e7          	jalr	-164(ra) # 80000a6e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b1a:	94ce                	add	s1,s1,s3
    80000b1c:	fe9979e3          	bgeu	s2,s1,80000b0e <freerange+0x2a>
}
    80000b20:	70a2                	ld	ra,40(sp)
    80000b22:	7402                	ld	s0,32(sp)
    80000b24:	64e2                	ld	s1,24(sp)
    80000b26:	6942                	ld	s2,16(sp)
    80000b28:	69a2                	ld	s3,8(sp)
    80000b2a:	6a02                	ld	s4,0(sp)
    80000b2c:	6145                	addi	sp,sp,48
    80000b2e:	8082                	ret

0000000080000b30 <kinit>:
{
    80000b30:	1141                	addi	sp,sp,-16
    80000b32:	e406                	sd	ra,8(sp)
    80000b34:	e022                	sd	s0,0(sp)
    80000b36:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b38:	00007597          	auipc	a1,0x7
    80000b3c:	53858593          	addi	a1,a1,1336 # 80008070 <digits+0x28>
    80000b40:	00011517          	auipc	a0,0x11
    80000b44:	df050513          	addi	a0,a0,-528 # 80011930 <kmem>
    80000b48:	00000097          	auipc	ra,0x0
    80000b4c:	084080e7          	jalr	132(ra) # 80000bcc <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b50:	45c5                	li	a1,17
    80000b52:	05ee                	slli	a1,a1,0x1b
    80000b54:	00026517          	auipc	a0,0x26
    80000b58:	4ac50513          	addi	a0,a0,1196 # 80027000 <end>
    80000b5c:	00000097          	auipc	ra,0x0
    80000b60:	f88080e7          	jalr	-120(ra) # 80000ae4 <freerange>
}
    80000b64:	60a2                	ld	ra,8(sp)
    80000b66:	6402                	ld	s0,0(sp)
    80000b68:	0141                	addi	sp,sp,16
    80000b6a:	8082                	ret

0000000080000b6c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b6c:	1101                	addi	sp,sp,-32
    80000b6e:	ec06                	sd	ra,24(sp)
    80000b70:	e822                	sd	s0,16(sp)
    80000b72:	e426                	sd	s1,8(sp)
    80000b74:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b76:	00011497          	auipc	s1,0x11
    80000b7a:	dba48493          	addi	s1,s1,-582 # 80011930 <kmem>
    80000b7e:	8526                	mv	a0,s1
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	0dc080e7          	jalr	220(ra) # 80000c5c <acquire>
  r = kmem.freelist;
    80000b88:	6c84                	ld	s1,24(s1)
  if(r)
    80000b8a:	c885                	beqz	s1,80000bba <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b8c:	609c                	ld	a5,0(s1)
    80000b8e:	00011517          	auipc	a0,0x11
    80000b92:	da250513          	addi	a0,a0,-606 # 80011930 <kmem>
    80000b96:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	178080e7          	jalr	376(ra) # 80000d10 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000ba0:	6605                	lui	a2,0x1
    80000ba2:	4595                	li	a1,5
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	1b2080e7          	jalr	434(ra) # 80000d58 <memset>
  return (void*)r;
}
    80000bae:	8526                	mv	a0,s1
    80000bb0:	60e2                	ld	ra,24(sp)
    80000bb2:	6442                	ld	s0,16(sp)
    80000bb4:	64a2                	ld	s1,8(sp)
    80000bb6:	6105                	addi	sp,sp,32
    80000bb8:	8082                	ret
  release(&kmem.lock);
    80000bba:	00011517          	auipc	a0,0x11
    80000bbe:	d7650513          	addi	a0,a0,-650 # 80011930 <kmem>
    80000bc2:	00000097          	auipc	ra,0x0
    80000bc6:	14e080e7          	jalr	334(ra) # 80000d10 <release>
  if(r)
    80000bca:	b7d5                	j	80000bae <kalloc+0x42>

0000000080000bcc <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bcc:	1141                	addi	sp,sp,-16
    80000bce:	e422                	sd	s0,8(sp)
    80000bd0:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bd2:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bd4:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bd8:	00053823          	sd	zero,16(a0)
}
    80000bdc:	6422                	ld	s0,8(sp)
    80000bde:	0141                	addi	sp,sp,16
    80000be0:	8082                	ret

0000000080000be2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000be2:	411c                	lw	a5,0(a0)
    80000be4:	e399                	bnez	a5,80000bea <holding+0x8>
    80000be6:	4501                	li	a0,0
  return r;
}
    80000be8:	8082                	ret
{
    80000bea:	1101                	addi	sp,sp,-32
    80000bec:	ec06                	sd	ra,24(sp)
    80000bee:	e822                	sd	s0,16(sp)
    80000bf0:	e426                	sd	s1,8(sp)
    80000bf2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bf4:	6904                	ld	s1,16(a0)
    80000bf6:	00001097          	auipc	ra,0x1
    80000bfa:	e16080e7          	jalr	-490(ra) # 80001a0c <mycpu>
    80000bfe:	40a48533          	sub	a0,s1,a0
    80000c02:	00153513          	seqz	a0,a0
}
    80000c06:	60e2                	ld	ra,24(sp)
    80000c08:	6442                	ld	s0,16(sp)
    80000c0a:	64a2                	ld	s1,8(sp)
    80000c0c:	6105                	addi	sp,sp,32
    80000c0e:	8082                	ret

0000000080000c10 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c10:	1101                	addi	sp,sp,-32
    80000c12:	ec06                	sd	ra,24(sp)
    80000c14:	e822                	sd	s0,16(sp)
    80000c16:	e426                	sd	s1,8(sp)
    80000c18:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c1a:	100024f3          	csrr	s1,sstatus
    80000c1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c22:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c24:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c28:	00001097          	auipc	ra,0x1
    80000c2c:	de4080e7          	jalr	-540(ra) # 80001a0c <mycpu>
    80000c30:	5d3c                	lw	a5,120(a0)
    80000c32:	cf89                	beqz	a5,80000c4c <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c34:	00001097          	auipc	ra,0x1
    80000c38:	dd8080e7          	jalr	-552(ra) # 80001a0c <mycpu>
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	2785                	addiw	a5,a5,1
    80000c40:	dd3c                	sw	a5,120(a0)
}
    80000c42:	60e2                	ld	ra,24(sp)
    80000c44:	6442                	ld	s0,16(sp)
    80000c46:	64a2                	ld	s1,8(sp)
    80000c48:	6105                	addi	sp,sp,32
    80000c4a:	8082                	ret
    mycpu()->intena = old;
    80000c4c:	00001097          	auipc	ra,0x1
    80000c50:	dc0080e7          	jalr	-576(ra) # 80001a0c <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c54:	8085                	srli	s1,s1,0x1
    80000c56:	8885                	andi	s1,s1,1
    80000c58:	dd64                	sw	s1,124(a0)
    80000c5a:	bfe9                	j	80000c34 <push_off+0x24>

0000000080000c5c <acquire>:
{
    80000c5c:	1101                	addi	sp,sp,-32
    80000c5e:	ec06                	sd	ra,24(sp)
    80000c60:	e822                	sd	s0,16(sp)
    80000c62:	e426                	sd	s1,8(sp)
    80000c64:	1000                	addi	s0,sp,32
    80000c66:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c68:	00000097          	auipc	ra,0x0
    80000c6c:	fa8080e7          	jalr	-88(ra) # 80000c10 <push_off>
  if(holding(lk))
    80000c70:	8526                	mv	a0,s1
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	f70080e7          	jalr	-144(ra) # 80000be2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7a:	4705                	li	a4,1
  if(holding(lk))
    80000c7c:	e115                	bnez	a0,80000ca0 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c7e:	87ba                	mv	a5,a4
    80000c80:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c84:	2781                	sext.w	a5,a5
    80000c86:	ffe5                	bnez	a5,80000c7e <acquire+0x22>
  __sync_synchronize();
    80000c88:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c8c:	00001097          	auipc	ra,0x1
    80000c90:	d80080e7          	jalr	-640(ra) # 80001a0c <mycpu>
    80000c94:	e888                	sd	a0,16(s1)
}
    80000c96:	60e2                	ld	ra,24(sp)
    80000c98:	6442                	ld	s0,16(sp)
    80000c9a:	64a2                	ld	s1,8(sp)
    80000c9c:	6105                	addi	sp,sp,32
    80000c9e:	8082                	ret
    panic("acquire");
    80000ca0:	00007517          	auipc	a0,0x7
    80000ca4:	3d850513          	addi	a0,a0,984 # 80008078 <digits+0x30>
    80000ca8:	00000097          	auipc	ra,0x0
    80000cac:	89e080e7          	jalr	-1890(ra) # 80000546 <panic>

0000000080000cb0 <pop_off>:

void
pop_off(void)
{
    80000cb0:	1141                	addi	sp,sp,-16
    80000cb2:	e406                	sd	ra,8(sp)
    80000cb4:	e022                	sd	s0,0(sp)
    80000cb6:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cb8:	00001097          	auipc	ra,0x1
    80000cbc:	d54080e7          	jalr	-684(ra) # 80001a0c <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cc4:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cc6:	e78d                	bnez	a5,80000cf0 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cc8:	5d3c                	lw	a5,120(a0)
    80000cca:	02f05b63          	blez	a5,80000d00 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000cce:	37fd                	addiw	a5,a5,-1
    80000cd0:	0007871b          	sext.w	a4,a5
    80000cd4:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cd6:	eb09                	bnez	a4,80000ce8 <pop_off+0x38>
    80000cd8:	5d7c                	lw	a5,124(a0)
    80000cda:	c799                	beqz	a5,80000ce8 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cdc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000ce0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce4:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000ce8:	60a2                	ld	ra,8(sp)
    80000cea:	6402                	ld	s0,0(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret
    panic("pop_off - interruptible");
    80000cf0:	00007517          	auipc	a0,0x7
    80000cf4:	39050513          	addi	a0,a0,912 # 80008080 <digits+0x38>
    80000cf8:	00000097          	auipc	ra,0x0
    80000cfc:	84e080e7          	jalr	-1970(ra) # 80000546 <panic>
    panic("pop_off");
    80000d00:	00007517          	auipc	a0,0x7
    80000d04:	39850513          	addi	a0,a0,920 # 80008098 <digits+0x50>
    80000d08:	00000097          	auipc	ra,0x0
    80000d0c:	83e080e7          	jalr	-1986(ra) # 80000546 <panic>

0000000080000d10 <release>:
{
    80000d10:	1101                	addi	sp,sp,-32
    80000d12:	ec06                	sd	ra,24(sp)
    80000d14:	e822                	sd	s0,16(sp)
    80000d16:	e426                	sd	s1,8(sp)
    80000d18:	1000                	addi	s0,sp,32
    80000d1a:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d1c:	00000097          	auipc	ra,0x0
    80000d20:	ec6080e7          	jalr	-314(ra) # 80000be2 <holding>
    80000d24:	c115                	beqz	a0,80000d48 <release+0x38>
  lk->cpu = 0;
    80000d26:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d2a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d2e:	0f50000f          	fence	iorw,ow
    80000d32:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d36:	00000097          	auipc	ra,0x0
    80000d3a:	f7a080e7          	jalr	-134(ra) # 80000cb0 <pop_off>
}
    80000d3e:	60e2                	ld	ra,24(sp)
    80000d40:	6442                	ld	s0,16(sp)
    80000d42:	64a2                	ld	s1,8(sp)
    80000d44:	6105                	addi	sp,sp,32
    80000d46:	8082                	ret
    panic("release");
    80000d48:	00007517          	auipc	a0,0x7
    80000d4c:	35850513          	addi	a0,a0,856 # 800080a0 <digits+0x58>
    80000d50:	fffff097          	auipc	ra,0xfffff
    80000d54:	7f6080e7          	jalr	2038(ra) # 80000546 <panic>

0000000080000d58 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d58:	1141                	addi	sp,sp,-16
    80000d5a:	e422                	sd	s0,8(sp)
    80000d5c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d5e:	ca19                	beqz	a2,80000d74 <memset+0x1c>
    80000d60:	87aa                	mv	a5,a0
    80000d62:	1602                	slli	a2,a2,0x20
    80000d64:	9201                	srli	a2,a2,0x20
    80000d66:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d6a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d6e:	0785                	addi	a5,a5,1
    80000d70:	fee79de3          	bne	a5,a4,80000d6a <memset+0x12>
  }
  return dst;
}
    80000d74:	6422                	ld	s0,8(sp)
    80000d76:	0141                	addi	sp,sp,16
    80000d78:	8082                	ret

0000000080000d7a <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d7a:	1141                	addi	sp,sp,-16
    80000d7c:	e422                	sd	s0,8(sp)
    80000d7e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d80:	ca05                	beqz	a2,80000db0 <memcmp+0x36>
    80000d82:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d86:	1682                	slli	a3,a3,0x20
    80000d88:	9281                	srli	a3,a3,0x20
    80000d8a:	0685                	addi	a3,a3,1
    80000d8c:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d8e:	00054783          	lbu	a5,0(a0)
    80000d92:	0005c703          	lbu	a4,0(a1)
    80000d96:	00e79863          	bne	a5,a4,80000da6 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d9a:	0505                	addi	a0,a0,1
    80000d9c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d9e:	fed518e3          	bne	a0,a3,80000d8e <memcmp+0x14>
  }

  return 0;
    80000da2:	4501                	li	a0,0
    80000da4:	a019                	j	80000daa <memcmp+0x30>
      return *s1 - *s2;
    80000da6:	40e7853b          	subw	a0,a5,a4
}
    80000daa:	6422                	ld	s0,8(sp)
    80000dac:	0141                	addi	sp,sp,16
    80000dae:	8082                	ret
  return 0;
    80000db0:	4501                	li	a0,0
    80000db2:	bfe5                	j	80000daa <memcmp+0x30>

0000000080000db4 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000db4:	1141                	addi	sp,sp,-16
    80000db6:	e422                	sd	s0,8(sp)
    80000db8:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dba:	02a5e563          	bltu	a1,a0,80000de4 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000dbe:	fff6069b          	addiw	a3,a2,-1
    80000dc2:	ce11                	beqz	a2,80000dde <memmove+0x2a>
    80000dc4:	1682                	slli	a3,a3,0x20
    80000dc6:	9281                	srli	a3,a3,0x20
    80000dc8:	0685                	addi	a3,a3,1
    80000dca:	96ae                	add	a3,a3,a1
    80000dcc:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000dce:	0585                	addi	a1,a1,1
    80000dd0:	0785                	addi	a5,a5,1
    80000dd2:	fff5c703          	lbu	a4,-1(a1)
    80000dd6:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    80000dda:	fed59ae3          	bne	a1,a3,80000dce <memmove+0x1a>

  return dst;
}
    80000dde:	6422                	ld	s0,8(sp)
    80000de0:	0141                	addi	sp,sp,16
    80000de2:	8082                	ret
  if(s < d && s + n > d){
    80000de4:	02061713          	slli	a4,a2,0x20
    80000de8:	9301                	srli	a4,a4,0x20
    80000dea:	00e587b3          	add	a5,a1,a4
    80000dee:	fcf578e3          	bgeu	a0,a5,80000dbe <memmove+0xa>
    d += n;
    80000df2:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000df4:	fff6069b          	addiw	a3,a2,-1
    80000df8:	d27d                	beqz	a2,80000dde <memmove+0x2a>
    80000dfa:	02069613          	slli	a2,a3,0x20
    80000dfe:	9201                	srli	a2,a2,0x20
    80000e00:	fff64613          	not	a2,a2
    80000e04:	963e                	add	a2,a2,a5
      *--d = *--s;
    80000e06:	17fd                	addi	a5,a5,-1
    80000e08:	177d                	addi	a4,a4,-1 # ffffffffffffefff <end+0xffffffff7ffd7fff>
    80000e0a:	0007c683          	lbu	a3,0(a5)
    80000e0e:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000e12:	fef61ae3          	bne	a2,a5,80000e06 <memmove+0x52>
    80000e16:	b7e1                	j	80000dde <memmove+0x2a>

0000000080000e18 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e18:	1141                	addi	sp,sp,-16
    80000e1a:	e406                	sd	ra,8(sp)
    80000e1c:	e022                	sd	s0,0(sp)
    80000e1e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e20:	00000097          	auipc	ra,0x0
    80000e24:	f94080e7          	jalr	-108(ra) # 80000db4 <memmove>
}
    80000e28:	60a2                	ld	ra,8(sp)
    80000e2a:	6402                	ld	s0,0(sp)
    80000e2c:	0141                	addi	sp,sp,16
    80000e2e:	8082                	ret

0000000080000e30 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e30:	1141                	addi	sp,sp,-16
    80000e32:	e422                	sd	s0,8(sp)
    80000e34:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e36:	ce11                	beqz	a2,80000e52 <strncmp+0x22>
    80000e38:	00054783          	lbu	a5,0(a0)
    80000e3c:	cf89                	beqz	a5,80000e56 <strncmp+0x26>
    80000e3e:	0005c703          	lbu	a4,0(a1)
    80000e42:	00f71a63          	bne	a4,a5,80000e56 <strncmp+0x26>
    n--, p++, q++;
    80000e46:	367d                	addiw	a2,a2,-1
    80000e48:	0505                	addi	a0,a0,1
    80000e4a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e4c:	f675                	bnez	a2,80000e38 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e4e:	4501                	li	a0,0
    80000e50:	a809                	j	80000e62 <strncmp+0x32>
    80000e52:	4501                	li	a0,0
    80000e54:	a039                	j	80000e62 <strncmp+0x32>
  if(n == 0)
    80000e56:	ca09                	beqz	a2,80000e68 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e58:	00054503          	lbu	a0,0(a0)
    80000e5c:	0005c783          	lbu	a5,0(a1)
    80000e60:	9d1d                	subw	a0,a0,a5
}
    80000e62:	6422                	ld	s0,8(sp)
    80000e64:	0141                	addi	sp,sp,16
    80000e66:	8082                	ret
    return 0;
    80000e68:	4501                	li	a0,0
    80000e6a:	bfe5                	j	80000e62 <strncmp+0x32>

0000000080000e6c <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e6c:	1141                	addi	sp,sp,-16
    80000e6e:	e422                	sd	s0,8(sp)
    80000e70:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e72:	872a                	mv	a4,a0
    80000e74:	8832                	mv	a6,a2
    80000e76:	367d                	addiw	a2,a2,-1
    80000e78:	01005963          	blez	a6,80000e8a <strncpy+0x1e>
    80000e7c:	0705                	addi	a4,a4,1
    80000e7e:	0005c783          	lbu	a5,0(a1)
    80000e82:	fef70fa3          	sb	a5,-1(a4)
    80000e86:	0585                	addi	a1,a1,1
    80000e88:	f7f5                	bnez	a5,80000e74 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000e8a:	86ba                	mv	a3,a4
    80000e8c:	00c05c63          	blez	a2,80000ea4 <strncpy+0x38>
    *s++ = 0;
    80000e90:	0685                	addi	a3,a3,1
    80000e92:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e96:	40d707bb          	subw	a5,a4,a3
    80000e9a:	37fd                	addiw	a5,a5,-1
    80000e9c:	010787bb          	addw	a5,a5,a6
    80000ea0:	fef048e3          	bgtz	a5,80000e90 <strncpy+0x24>
  return os;
}
    80000ea4:	6422                	ld	s0,8(sp)
    80000ea6:	0141                	addi	sp,sp,16
    80000ea8:	8082                	ret

0000000080000eaa <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000eaa:	1141                	addi	sp,sp,-16
    80000eac:	e422                	sd	s0,8(sp)
    80000eae:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eb0:	02c05363          	blez	a2,80000ed6 <safestrcpy+0x2c>
    80000eb4:	fff6069b          	addiw	a3,a2,-1
    80000eb8:	1682                	slli	a3,a3,0x20
    80000eba:	9281                	srli	a3,a3,0x20
    80000ebc:	96ae                	add	a3,a3,a1
    80000ebe:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ec0:	00d58963          	beq	a1,a3,80000ed2 <safestrcpy+0x28>
    80000ec4:	0585                	addi	a1,a1,1
    80000ec6:	0785                	addi	a5,a5,1
    80000ec8:	fff5c703          	lbu	a4,-1(a1)
    80000ecc:	fee78fa3          	sb	a4,-1(a5)
    80000ed0:	fb65                	bnez	a4,80000ec0 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ed2:	00078023          	sb	zero,0(a5)
  return os;
}
    80000ed6:	6422                	ld	s0,8(sp)
    80000ed8:	0141                	addi	sp,sp,16
    80000eda:	8082                	ret

0000000080000edc <strlen>:

int
strlen(const char *s)
{
    80000edc:	1141                	addi	sp,sp,-16
    80000ede:	e422                	sd	s0,8(sp)
    80000ee0:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ee2:	00054783          	lbu	a5,0(a0)
    80000ee6:	cf91                	beqz	a5,80000f02 <strlen+0x26>
    80000ee8:	0505                	addi	a0,a0,1
    80000eea:	87aa                	mv	a5,a0
    80000eec:	4685                	li	a3,1
    80000eee:	9e89                	subw	a3,a3,a0
    80000ef0:	00f6853b          	addw	a0,a3,a5
    80000ef4:	0785                	addi	a5,a5,1
    80000ef6:	fff7c703          	lbu	a4,-1(a5)
    80000efa:	fb7d                	bnez	a4,80000ef0 <strlen+0x14>
    ;
  return n;
}
    80000efc:	6422                	ld	s0,8(sp)
    80000efe:	0141                	addi	sp,sp,16
    80000f00:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f02:	4501                	li	a0,0
    80000f04:	bfe5                	j	80000efc <strlen+0x20>

0000000080000f06 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f06:	1141                	addi	sp,sp,-16
    80000f08:	e406                	sd	ra,8(sp)
    80000f0a:	e022                	sd	s0,0(sp)
    80000f0c:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f0e:	00001097          	auipc	ra,0x1
    80000f12:	aee080e7          	jalr	-1298(ra) # 800019fc <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f16:	00008717          	auipc	a4,0x8
    80000f1a:	0f670713          	addi	a4,a4,246 # 8000900c <started>
  if(cpuid() == 0){
    80000f1e:	c139                	beqz	a0,80000f64 <main+0x5e>
    while(started == 0)
    80000f20:	431c                	lw	a5,0(a4)
    80000f22:	2781                	sext.w	a5,a5
    80000f24:	dff5                	beqz	a5,80000f20 <main+0x1a>
      ;
    __sync_synchronize();
    80000f26:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f2a:	00001097          	auipc	ra,0x1
    80000f2e:	ad2080e7          	jalr	-1326(ra) # 800019fc <cpuid>
    80000f32:	85aa                	mv	a1,a0
    80000f34:	00007517          	auipc	a0,0x7
    80000f38:	18c50513          	addi	a0,a0,396 # 800080c0 <digits+0x78>
    80000f3c:	fffff097          	auipc	ra,0xfffff
    80000f40:	654080e7          	jalr	1620(ra) # 80000590 <printf>
    kvminithart();    // turn on paging
    80000f44:	00000097          	auipc	ra,0x0
    80000f48:	0d8080e7          	jalr	216(ra) # 8000101c <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f4c:	00001097          	auipc	ra,0x1
    80000f50:	788080e7          	jalr	1928(ra) # 800026d4 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f54:	00005097          	auipc	ra,0x5
    80000f58:	e6c080e7          	jalr	-404(ra) # 80005dc0 <plicinithart>
  }

  scheduler();        
    80000f5c:	00001097          	auipc	ra,0x1
    80000f60:	054080e7          	jalr	84(ra) # 80001fb0 <scheduler>
    consoleinit();
    80000f64:	fffff097          	auipc	ra,0xfffff
    80000f68:	4f2080e7          	jalr	1266(ra) # 80000456 <consoleinit>
    printfinit();
    80000f6c:	00000097          	auipc	ra,0x0
    80000f70:	804080e7          	jalr	-2044(ra) # 80000770 <printfinit>
    printf("\n");
    80000f74:	00007517          	auipc	a0,0x7
    80000f78:	15c50513          	addi	a0,a0,348 # 800080d0 <digits+0x88>
    80000f7c:	fffff097          	auipc	ra,0xfffff
    80000f80:	614080e7          	jalr	1556(ra) # 80000590 <printf>
    printf("xv6 kernel is booting\n");
    80000f84:	00007517          	auipc	a0,0x7
    80000f88:	12450513          	addi	a0,a0,292 # 800080a8 <digits+0x60>
    80000f8c:	fffff097          	auipc	ra,0xfffff
    80000f90:	604080e7          	jalr	1540(ra) # 80000590 <printf>
    printf("\n");
    80000f94:	00007517          	auipc	a0,0x7
    80000f98:	13c50513          	addi	a0,a0,316 # 800080d0 <digits+0x88>
    80000f9c:	fffff097          	auipc	ra,0xfffff
    80000fa0:	5f4080e7          	jalr	1524(ra) # 80000590 <printf>
    kinit();         // physical page allocator
    80000fa4:	00000097          	auipc	ra,0x0
    80000fa8:	b8c080e7          	jalr	-1140(ra) # 80000b30 <kinit>
    kvminit();       // create kernel page table
    80000fac:	00000097          	auipc	ra,0x0
    80000fb0:	2a0080e7          	jalr	672(ra) # 8000124c <kvminit>
    kvminithart();   // turn on paging
    80000fb4:	00000097          	auipc	ra,0x0
    80000fb8:	068080e7          	jalr	104(ra) # 8000101c <kvminithart>
    procinit();      // process table
    80000fbc:	00001097          	auipc	ra,0x1
    80000fc0:	970080e7          	jalr	-1680(ra) # 8000192c <procinit>
    trapinit();      // trap vectors
    80000fc4:	00001097          	auipc	ra,0x1
    80000fc8:	6e8080e7          	jalr	1768(ra) # 800026ac <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	00001097          	auipc	ra,0x1
    80000fd0:	708080e7          	jalr	1800(ra) # 800026d4 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd4:	00005097          	auipc	ra,0x5
    80000fd8:	dd6080e7          	jalr	-554(ra) # 80005daa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fdc:	00005097          	auipc	ra,0x5
    80000fe0:	de4080e7          	jalr	-540(ra) # 80005dc0 <plicinithart>
    binit();         // buffer cache
    80000fe4:	00002097          	auipc	ra,0x2
    80000fe8:	f7c080e7          	jalr	-132(ra) # 80002f60 <binit>
    iinit();         // inode cache
    80000fec:	00002097          	auipc	ra,0x2
    80000ff0:	60a080e7          	jalr	1546(ra) # 800035f6 <iinit>
    fileinit();      // file table
    80000ff4:	00003097          	auipc	ra,0x3
    80000ff8:	5ac080e7          	jalr	1452(ra) # 800045a0 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000ffc:	00005097          	auipc	ra,0x5
    80001000:	eca080e7          	jalr	-310(ra) # 80005ec6 <virtio_disk_init>
    userinit();      // first user process
    80001004:	00001097          	auipc	ra,0x1
    80001008:	d3e080e7          	jalr	-706(ra) # 80001d42 <userinit>
    __sync_synchronize();
    8000100c:	0ff0000f          	fence
    started = 1;
    80001010:	4785                	li	a5,1
    80001012:	00008717          	auipc	a4,0x8
    80001016:	fef72d23          	sw	a5,-6(a4) # 8000900c <started>
    8000101a:	b789                	j	80000f5c <main+0x56>

000000008000101c <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000101c:	1141                	addi	sp,sp,-16
    8000101e:	e422                	sd	s0,8(sp)
    80001020:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80001022:	00008797          	auipc	a5,0x8
    80001026:	fee7b783          	ld	a5,-18(a5) # 80009010 <kernel_pagetable>
    8000102a:	83b1                	srli	a5,a5,0xc
    8000102c:	577d                	li	a4,-1
    8000102e:	177e                	slli	a4,a4,0x3f
    80001030:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001032:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001036:	12000073          	sfence.vma
  sfence_vma();
}
    8000103a:	6422                	ld	s0,8(sp)
    8000103c:	0141                	addi	sp,sp,16
    8000103e:	8082                	ret

0000000080001040 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001040:	7139                	addi	sp,sp,-64
    80001042:	fc06                	sd	ra,56(sp)
    80001044:	f822                	sd	s0,48(sp)
    80001046:	f426                	sd	s1,40(sp)
    80001048:	f04a                	sd	s2,32(sp)
    8000104a:	ec4e                	sd	s3,24(sp)
    8000104c:	e852                	sd	s4,16(sp)
    8000104e:	e456                	sd	s5,8(sp)
    80001050:	e05a                	sd	s6,0(sp)
    80001052:	0080                	addi	s0,sp,64
    80001054:	84aa                	mv	s1,a0
    80001056:	89ae                	mv	s3,a1
    80001058:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000105a:	57fd                	li	a5,-1
    8000105c:	83e9                	srli	a5,a5,0x1a
    8000105e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001060:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001062:	04b7f263          	bgeu	a5,a1,800010a6 <walk+0x66>
    panic("walk");
    80001066:	00007517          	auipc	a0,0x7
    8000106a:	07250513          	addi	a0,a0,114 # 800080d8 <digits+0x90>
    8000106e:	fffff097          	auipc	ra,0xfffff
    80001072:	4d8080e7          	jalr	1240(ra) # 80000546 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001076:	060a8663          	beqz	s5,800010e2 <walk+0xa2>
    8000107a:	00000097          	auipc	ra,0x0
    8000107e:	af2080e7          	jalr	-1294(ra) # 80000b6c <kalloc>
    80001082:	84aa                	mv	s1,a0
    80001084:	c529                	beqz	a0,800010ce <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80001086:	6605                	lui	a2,0x1
    80001088:	4581                	li	a1,0
    8000108a:	00000097          	auipc	ra,0x0
    8000108e:	cce080e7          	jalr	-818(ra) # 80000d58 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001092:	00c4d793          	srli	a5,s1,0xc
    80001096:	07aa                	slli	a5,a5,0xa
    80001098:	0017e793          	ori	a5,a5,1
    8000109c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    800010a0:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffd7ff7>
    800010a2:	036a0063          	beq	s4,s6,800010c2 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010a6:	0149d933          	srl	s2,s3,s4
    800010aa:	1ff97913          	andi	s2,s2,511
    800010ae:	090e                	slli	s2,s2,0x3
    800010b0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010b2:	00093483          	ld	s1,0(s2)
    800010b6:	0014f793          	andi	a5,s1,1
    800010ba:	dfd5                	beqz	a5,80001076 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010bc:	80a9                	srli	s1,s1,0xa
    800010be:	04b2                	slli	s1,s1,0xc
    800010c0:	b7c5                	j	800010a0 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    800010c2:	00c9d513          	srli	a0,s3,0xc
    800010c6:	1ff57513          	andi	a0,a0,511
    800010ca:	050e                	slli	a0,a0,0x3
    800010cc:	9526                	add	a0,a0,s1
}
    800010ce:	70e2                	ld	ra,56(sp)
    800010d0:	7442                	ld	s0,48(sp)
    800010d2:	74a2                	ld	s1,40(sp)
    800010d4:	7902                	ld	s2,32(sp)
    800010d6:	69e2                	ld	s3,24(sp)
    800010d8:	6a42                	ld	s4,16(sp)
    800010da:	6aa2                	ld	s5,8(sp)
    800010dc:	6b02                	ld	s6,0(sp)
    800010de:	6121                	addi	sp,sp,64
    800010e0:	8082                	ret
        return 0;
    800010e2:	4501                	li	a0,0
    800010e4:	b7ed                	j	800010ce <walk+0x8e>

00000000800010e6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010e6:	57fd                	li	a5,-1
    800010e8:	83e9                	srli	a5,a5,0x1a
    800010ea:	00b7f463          	bgeu	a5,a1,800010f2 <walkaddr+0xc>
    return 0;
    800010ee:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010f0:	8082                	ret
{
    800010f2:	1141                	addi	sp,sp,-16
    800010f4:	e406                	sd	ra,8(sp)
    800010f6:	e022                	sd	s0,0(sp)
    800010f8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010fa:	4601                	li	a2,0
    800010fc:	00000097          	auipc	ra,0x0
    80001100:	f44080e7          	jalr	-188(ra) # 80001040 <walk>
  if(pte == 0)
    80001104:	c105                	beqz	a0,80001124 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001106:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001108:	0117f693          	andi	a3,a5,17
    8000110c:	4745                	li	a4,17
    return 0;
    8000110e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001110:	00e68663          	beq	a3,a4,8000111c <walkaddr+0x36>
}
    80001114:	60a2                	ld	ra,8(sp)
    80001116:	6402                	ld	s0,0(sp)
    80001118:	0141                	addi	sp,sp,16
    8000111a:	8082                	ret
  pa = PTE2PA(*pte);
    8000111c:	83a9                	srli	a5,a5,0xa
    8000111e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001122:	bfcd                	j	80001114 <walkaddr+0x2e>
    return 0;
    80001124:	4501                	li	a0,0
    80001126:	b7fd                	j	80001114 <walkaddr+0x2e>

0000000080001128 <kvmpa>:
// a physical address. only needed for
// addresses on the stack.
// assumes va is page aligned.
uint64
kvmpa(uint64 va)
{
    80001128:	1101                	addi	sp,sp,-32
    8000112a:	ec06                	sd	ra,24(sp)
    8000112c:	e822                	sd	s0,16(sp)
    8000112e:	e426                	sd	s1,8(sp)
    80001130:	1000                	addi	s0,sp,32
    80001132:	85aa                	mv	a1,a0
  uint64 off = va % PGSIZE;
    80001134:	1552                	slli	a0,a0,0x34
    80001136:	03455493          	srli	s1,a0,0x34
  pte_t *pte;
  uint64 pa;
  
  pte = walk(kernel_pagetable, va, 0);
    8000113a:	4601                	li	a2,0
    8000113c:	00008517          	auipc	a0,0x8
    80001140:	ed453503          	ld	a0,-300(a0) # 80009010 <kernel_pagetable>
    80001144:	00000097          	auipc	ra,0x0
    80001148:	efc080e7          	jalr	-260(ra) # 80001040 <walk>
  if(pte == 0)
    8000114c:	cd09                	beqz	a0,80001166 <kvmpa+0x3e>
    panic("kvmpa");
  if((*pte & PTE_V) == 0)
    8000114e:	6108                	ld	a0,0(a0)
    80001150:	00157793          	andi	a5,a0,1
    80001154:	c38d                	beqz	a5,80001176 <kvmpa+0x4e>
    panic("kvmpa");
  pa = PTE2PA(*pte);
    80001156:	8129                	srli	a0,a0,0xa
    80001158:	0532                	slli	a0,a0,0xc
  return pa+off;
}
    8000115a:	9526                	add	a0,a0,s1
    8000115c:	60e2                	ld	ra,24(sp)
    8000115e:	6442                	ld	s0,16(sp)
    80001160:	64a2                	ld	s1,8(sp)
    80001162:	6105                	addi	sp,sp,32
    80001164:	8082                	ret
    panic("kvmpa");
    80001166:	00007517          	auipc	a0,0x7
    8000116a:	f7a50513          	addi	a0,a0,-134 # 800080e0 <digits+0x98>
    8000116e:	fffff097          	auipc	ra,0xfffff
    80001172:	3d8080e7          	jalr	984(ra) # 80000546 <panic>
    panic("kvmpa");
    80001176:	00007517          	auipc	a0,0x7
    8000117a:	f6a50513          	addi	a0,a0,-150 # 800080e0 <digits+0x98>
    8000117e:	fffff097          	auipc	ra,0xfffff
    80001182:	3c8080e7          	jalr	968(ra) # 80000546 <panic>

0000000080001186 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001186:	715d                	addi	sp,sp,-80
    80001188:	e486                	sd	ra,72(sp)
    8000118a:	e0a2                	sd	s0,64(sp)
    8000118c:	fc26                	sd	s1,56(sp)
    8000118e:	f84a                	sd	s2,48(sp)
    80001190:	f44e                	sd	s3,40(sp)
    80001192:	f052                	sd	s4,32(sp)
    80001194:	ec56                	sd	s5,24(sp)
    80001196:	e85a                	sd	s6,16(sp)
    80001198:	e45e                	sd	s7,8(sp)
    8000119a:	0880                	addi	s0,sp,80
    8000119c:	8aaa                	mv	s5,a0
    8000119e:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800011a0:	777d                	lui	a4,0xfffff
    800011a2:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011a6:	fff60993          	addi	s3,a2,-1 # fff <_entry-0x7ffff001>
    800011aa:	99ae                	add	s3,s3,a1
    800011ac:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011b0:	893e                	mv	s2,a5
    800011b2:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800011b6:	6b85                	lui	s7,0x1
    800011b8:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800011bc:	4605                	li	a2,1
    800011be:	85ca                	mv	a1,s2
    800011c0:	8556                	mv	a0,s5
    800011c2:	00000097          	auipc	ra,0x0
    800011c6:	e7e080e7          	jalr	-386(ra) # 80001040 <walk>
    800011ca:	c51d                	beqz	a0,800011f8 <mappages+0x72>
    if(*pte & PTE_V)
    800011cc:	611c                	ld	a5,0(a0)
    800011ce:	8b85                	andi	a5,a5,1
    800011d0:	ef81                	bnez	a5,800011e8 <mappages+0x62>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011d2:	80b1                	srli	s1,s1,0xc
    800011d4:	04aa                	slli	s1,s1,0xa
    800011d6:	0164e4b3          	or	s1,s1,s6
    800011da:	0014e493          	ori	s1,s1,1
    800011de:	e104                	sd	s1,0(a0)
    if(a == last)
    800011e0:	03390863          	beq	s2,s3,80001210 <mappages+0x8a>
    a += PGSIZE;
    800011e4:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800011e6:	bfc9                	j	800011b8 <mappages+0x32>
      panic("remap");
    800011e8:	00007517          	auipc	a0,0x7
    800011ec:	f0050513          	addi	a0,a0,-256 # 800080e8 <digits+0xa0>
    800011f0:	fffff097          	auipc	ra,0xfffff
    800011f4:	356080e7          	jalr	854(ra) # 80000546 <panic>
      return -1;
    800011f8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011fa:	60a6                	ld	ra,72(sp)
    800011fc:	6406                	ld	s0,64(sp)
    800011fe:	74e2                	ld	s1,56(sp)
    80001200:	7942                	ld	s2,48(sp)
    80001202:	79a2                	ld	s3,40(sp)
    80001204:	7a02                	ld	s4,32(sp)
    80001206:	6ae2                	ld	s5,24(sp)
    80001208:	6b42                	ld	s6,16(sp)
    8000120a:	6ba2                	ld	s7,8(sp)
    8000120c:	6161                	addi	sp,sp,80
    8000120e:	8082                	ret
  return 0;
    80001210:	4501                	li	a0,0
    80001212:	b7e5                	j	800011fa <mappages+0x74>

0000000080001214 <kvmmap>:
{
    80001214:	1141                	addi	sp,sp,-16
    80001216:	e406                	sd	ra,8(sp)
    80001218:	e022                	sd	s0,0(sp)
    8000121a:	0800                	addi	s0,sp,16
    8000121c:	8736                	mv	a4,a3
  if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
    8000121e:	86ae                	mv	a3,a1
    80001220:	85aa                	mv	a1,a0
    80001222:	00008517          	auipc	a0,0x8
    80001226:	dee53503          	ld	a0,-530(a0) # 80009010 <kernel_pagetable>
    8000122a:	00000097          	auipc	ra,0x0
    8000122e:	f5c080e7          	jalr	-164(ra) # 80001186 <mappages>
    80001232:	e509                	bnez	a0,8000123c <kvmmap+0x28>
}
    80001234:	60a2                	ld	ra,8(sp)
    80001236:	6402                	ld	s0,0(sp)
    80001238:	0141                	addi	sp,sp,16
    8000123a:	8082                	ret
    panic("kvmmap");
    8000123c:	00007517          	auipc	a0,0x7
    80001240:	eb450513          	addi	a0,a0,-332 # 800080f0 <digits+0xa8>
    80001244:	fffff097          	auipc	ra,0xfffff
    80001248:	302080e7          	jalr	770(ra) # 80000546 <panic>

000000008000124c <kvminit>:
{
    8000124c:	1101                	addi	sp,sp,-32
    8000124e:	ec06                	sd	ra,24(sp)
    80001250:	e822                	sd	s0,16(sp)
    80001252:	e426                	sd	s1,8(sp)
    80001254:	1000                	addi	s0,sp,32
  kernel_pagetable = (pagetable_t) kalloc();
    80001256:	00000097          	auipc	ra,0x0
    8000125a:	916080e7          	jalr	-1770(ra) # 80000b6c <kalloc>
    8000125e:	00008717          	auipc	a4,0x8
    80001262:	daa73923          	sd	a0,-590(a4) # 80009010 <kernel_pagetable>
  memset(kernel_pagetable, 0, PGSIZE);
    80001266:	6605                	lui	a2,0x1
    80001268:	4581                	li	a1,0
    8000126a:	00000097          	auipc	ra,0x0
    8000126e:	aee080e7          	jalr	-1298(ra) # 80000d58 <memset>
  kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001272:	4699                	li	a3,6
    80001274:	6605                	lui	a2,0x1
    80001276:	100005b7          	lui	a1,0x10000
    8000127a:	10000537          	lui	a0,0x10000
    8000127e:	00000097          	auipc	ra,0x0
    80001282:	f96080e7          	jalr	-106(ra) # 80001214 <kvmmap>
  kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001286:	4699                	li	a3,6
    80001288:	6605                	lui	a2,0x1
    8000128a:	100015b7          	lui	a1,0x10001
    8000128e:	10001537          	lui	a0,0x10001
    80001292:	00000097          	auipc	ra,0x0
    80001296:	f82080e7          	jalr	-126(ra) # 80001214 <kvmmap>
  kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
    8000129a:	4699                	li	a3,6
    8000129c:	6641                	lui	a2,0x10
    8000129e:	020005b7          	lui	a1,0x2000
    800012a2:	02000537          	lui	a0,0x2000
    800012a6:	00000097          	auipc	ra,0x0
    800012aa:	f6e080e7          	jalr	-146(ra) # 80001214 <kvmmap>
  kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012ae:	4699                	li	a3,6
    800012b0:	00400637          	lui	a2,0x400
    800012b4:	0c0005b7          	lui	a1,0xc000
    800012b8:	0c000537          	lui	a0,0xc000
    800012bc:	00000097          	auipc	ra,0x0
    800012c0:	f58080e7          	jalr	-168(ra) # 80001214 <kvmmap>
  kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012c4:	00007497          	auipc	s1,0x7
    800012c8:	d3c48493          	addi	s1,s1,-708 # 80008000 <etext>
    800012cc:	46a9                	li	a3,10
    800012ce:	80007617          	auipc	a2,0x80007
    800012d2:	d3260613          	addi	a2,a2,-718 # 8000 <_entry-0x7fff8000>
    800012d6:	4585                	li	a1,1
    800012d8:	05fe                	slli	a1,a1,0x1f
    800012da:	852e                	mv	a0,a1
    800012dc:	00000097          	auipc	ra,0x0
    800012e0:	f38080e7          	jalr	-200(ra) # 80001214 <kvmmap>
  kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012e4:	4699                	li	a3,6
    800012e6:	4645                	li	a2,17
    800012e8:	066e                	slli	a2,a2,0x1b
    800012ea:	8e05                	sub	a2,a2,s1
    800012ec:	85a6                	mv	a1,s1
    800012ee:	8526                	mv	a0,s1
    800012f0:	00000097          	auipc	ra,0x0
    800012f4:	f24080e7          	jalr	-220(ra) # 80001214 <kvmmap>
  kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012f8:	46a9                	li	a3,10
    800012fa:	6605                	lui	a2,0x1
    800012fc:	00006597          	auipc	a1,0x6
    80001300:	d0458593          	addi	a1,a1,-764 # 80007000 <_trampoline>
    80001304:	04000537          	lui	a0,0x4000
    80001308:	157d                	addi	a0,a0,-1 # 3ffffff <_entry-0x7c000001>
    8000130a:	0532                	slli	a0,a0,0xc
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f08080e7          	jalr	-248(ra) # 80001214 <kvmmap>
}
    80001314:	60e2                	ld	ra,24(sp)
    80001316:	6442                	ld	s0,16(sp)
    80001318:	64a2                	ld	s1,8(sp)
    8000131a:	6105                	addi	sp,sp,32
    8000131c:	8082                	ret

000000008000131e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000131e:	715d                	addi	sp,sp,-80
    80001320:	e486                	sd	ra,72(sp)
    80001322:	e0a2                	sd	s0,64(sp)
    80001324:	fc26                	sd	s1,56(sp)
    80001326:	f84a                	sd	s2,48(sp)
    80001328:	f44e                	sd	s3,40(sp)
    8000132a:	f052                	sd	s4,32(sp)
    8000132c:	ec56                	sd	s5,24(sp)
    8000132e:	e85a                	sd	s6,16(sp)
    80001330:	e45e                	sd	s7,8(sp)
    80001332:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001334:	03459793          	slli	a5,a1,0x34
    80001338:	e795                	bnez	a5,80001364 <uvmunmap+0x46>
    8000133a:	8a2a                	mv	s4,a0
    8000133c:	892e                	mv	s2,a1
    8000133e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001340:	0632                	slli	a2,a2,0xc
    80001342:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001346:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001348:	6b05                	lui	s6,0x1
    8000134a:	0735e263          	bltu	a1,s3,800013ae <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000134e:	60a6                	ld	ra,72(sp)
    80001350:	6406                	ld	s0,64(sp)
    80001352:	74e2                	ld	s1,56(sp)
    80001354:	7942                	ld	s2,48(sp)
    80001356:	79a2                	ld	s3,40(sp)
    80001358:	7a02                	ld	s4,32(sp)
    8000135a:	6ae2                	ld	s5,24(sp)
    8000135c:	6b42                	ld	s6,16(sp)
    8000135e:	6ba2                	ld	s7,8(sp)
    80001360:	6161                	addi	sp,sp,80
    80001362:	8082                	ret
    panic("uvmunmap: not aligned");
    80001364:	00007517          	auipc	a0,0x7
    80001368:	d9450513          	addi	a0,a0,-620 # 800080f8 <digits+0xb0>
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	1da080e7          	jalr	474(ra) # 80000546 <panic>
      panic("uvmunmap: walk");
    80001374:	00007517          	auipc	a0,0x7
    80001378:	d9c50513          	addi	a0,a0,-612 # 80008110 <digits+0xc8>
    8000137c:	fffff097          	auipc	ra,0xfffff
    80001380:	1ca080e7          	jalr	458(ra) # 80000546 <panic>
      panic("uvmunmap: not mapped");
    80001384:	00007517          	auipc	a0,0x7
    80001388:	d9c50513          	addi	a0,a0,-612 # 80008120 <digits+0xd8>
    8000138c:	fffff097          	auipc	ra,0xfffff
    80001390:	1ba080e7          	jalr	442(ra) # 80000546 <panic>
      panic("uvmunmap: not a leaf");
    80001394:	00007517          	auipc	a0,0x7
    80001398:	da450513          	addi	a0,a0,-604 # 80008138 <digits+0xf0>
    8000139c:	fffff097          	auipc	ra,0xfffff
    800013a0:	1aa080e7          	jalr	426(ra) # 80000546 <panic>
    *pte = 0;
    800013a4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a8:	995a                	add	s2,s2,s6
    800013aa:	fb3972e3          	bgeu	s2,s3,8000134e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013ae:	4601                	li	a2,0
    800013b0:	85ca                	mv	a1,s2
    800013b2:	8552                	mv	a0,s4
    800013b4:	00000097          	auipc	ra,0x0
    800013b8:	c8c080e7          	jalr	-884(ra) # 80001040 <walk>
    800013bc:	84aa                	mv	s1,a0
    800013be:	d95d                	beqz	a0,80001374 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800013c0:	6108                	ld	a0,0(a0)
    800013c2:	00157793          	andi	a5,a0,1
    800013c6:	dfdd                	beqz	a5,80001384 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    800013c8:	3ff57793          	andi	a5,a0,1023
    800013cc:	fd7784e3          	beq	a5,s7,80001394 <uvmunmap+0x76>
    if(do_free){
    800013d0:	fc0a8ae3          	beqz	s5,800013a4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    800013d4:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    800013d6:	0532                	slli	a0,a0,0xc
    800013d8:	fffff097          	auipc	ra,0xfffff
    800013dc:	696080e7          	jalr	1686(ra) # 80000a6e <kfree>
    800013e0:	b7d1                	j	800013a4 <uvmunmap+0x86>

00000000800013e2 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013e2:	1101                	addi	sp,sp,-32
    800013e4:	ec06                	sd	ra,24(sp)
    800013e6:	e822                	sd	s0,16(sp)
    800013e8:	e426                	sd	s1,8(sp)
    800013ea:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013ec:	fffff097          	auipc	ra,0xfffff
    800013f0:	780080e7          	jalr	1920(ra) # 80000b6c <kalloc>
    800013f4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013f6:	c519                	beqz	a0,80001404 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013f8:	6605                	lui	a2,0x1
    800013fa:	4581                	li	a1,0
    800013fc:	00000097          	auipc	ra,0x0
    80001400:	95c080e7          	jalr	-1700(ra) # 80000d58 <memset>
  return pagetable;
}
    80001404:	8526                	mv	a0,s1
    80001406:	60e2                	ld	ra,24(sp)
    80001408:	6442                	ld	s0,16(sp)
    8000140a:	64a2                	ld	s1,8(sp)
    8000140c:	6105                	addi	sp,sp,32
    8000140e:	8082                	ret

0000000080001410 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80001410:	7179                	addi	sp,sp,-48
    80001412:	f406                	sd	ra,40(sp)
    80001414:	f022                	sd	s0,32(sp)
    80001416:	ec26                	sd	s1,24(sp)
    80001418:	e84a                	sd	s2,16(sp)
    8000141a:	e44e                	sd	s3,8(sp)
    8000141c:	e052                	sd	s4,0(sp)
    8000141e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001420:	6785                	lui	a5,0x1
    80001422:	04f67863          	bgeu	a2,a5,80001472 <uvminit+0x62>
    80001426:	8a2a                	mv	s4,a0
    80001428:	89ae                	mv	s3,a1
    8000142a:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    8000142c:	fffff097          	auipc	ra,0xfffff
    80001430:	740080e7          	jalr	1856(ra) # 80000b6c <kalloc>
    80001434:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001436:	6605                	lui	a2,0x1
    80001438:	4581                	li	a1,0
    8000143a:	00000097          	auipc	ra,0x0
    8000143e:	91e080e7          	jalr	-1762(ra) # 80000d58 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001442:	4779                	li	a4,30
    80001444:	86ca                	mv	a3,s2
    80001446:	6605                	lui	a2,0x1
    80001448:	4581                	li	a1,0
    8000144a:	8552                	mv	a0,s4
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	d3a080e7          	jalr	-710(ra) # 80001186 <mappages>
  memmove(mem, src, sz);
    80001454:	8626                	mv	a2,s1
    80001456:	85ce                	mv	a1,s3
    80001458:	854a                	mv	a0,s2
    8000145a:	00000097          	auipc	ra,0x0
    8000145e:	95a080e7          	jalr	-1702(ra) # 80000db4 <memmove>
}
    80001462:	70a2                	ld	ra,40(sp)
    80001464:	7402                	ld	s0,32(sp)
    80001466:	64e2                	ld	s1,24(sp)
    80001468:	6942                	ld	s2,16(sp)
    8000146a:	69a2                	ld	s3,8(sp)
    8000146c:	6a02                	ld	s4,0(sp)
    8000146e:	6145                	addi	sp,sp,48
    80001470:	8082                	ret
    panic("inituvm: more than a page");
    80001472:	00007517          	auipc	a0,0x7
    80001476:	cde50513          	addi	a0,a0,-802 # 80008150 <digits+0x108>
    8000147a:	fffff097          	auipc	ra,0xfffff
    8000147e:	0cc080e7          	jalr	204(ra) # 80000546 <panic>

0000000080001482 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001482:	1101                	addi	sp,sp,-32
    80001484:	ec06                	sd	ra,24(sp)
    80001486:	e822                	sd	s0,16(sp)
    80001488:	e426                	sd	s1,8(sp)
    8000148a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000148c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000148e:	00b67d63          	bgeu	a2,a1,800014a8 <uvmdealloc+0x26>
    80001492:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001494:	6785                	lui	a5,0x1
    80001496:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001498:	00f60733          	add	a4,a2,a5
    8000149c:	76fd                	lui	a3,0xfffff
    8000149e:	8f75                	and	a4,a4,a3
    800014a0:	97ae                	add	a5,a5,a1
    800014a2:	8ff5                	and	a5,a5,a3
    800014a4:	00f76863          	bltu	a4,a5,800014b4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014a8:	8526                	mv	a0,s1
    800014aa:	60e2                	ld	ra,24(sp)
    800014ac:	6442                	ld	s0,16(sp)
    800014ae:	64a2                	ld	s1,8(sp)
    800014b0:	6105                	addi	sp,sp,32
    800014b2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014b4:	8f99                	sub	a5,a5,a4
    800014b6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014b8:	4685                	li	a3,1
    800014ba:	0007861b          	sext.w	a2,a5
    800014be:	85ba                	mv	a1,a4
    800014c0:	00000097          	auipc	ra,0x0
    800014c4:	e5e080e7          	jalr	-418(ra) # 8000131e <uvmunmap>
    800014c8:	b7c5                	j	800014a8 <uvmdealloc+0x26>

00000000800014ca <uvmalloc>:
  if(newsz < oldsz)
    800014ca:	0ab66163          	bltu	a2,a1,8000156c <uvmalloc+0xa2>
{
    800014ce:	7139                	addi	sp,sp,-64
    800014d0:	fc06                	sd	ra,56(sp)
    800014d2:	f822                	sd	s0,48(sp)
    800014d4:	f426                	sd	s1,40(sp)
    800014d6:	f04a                	sd	s2,32(sp)
    800014d8:	ec4e                	sd	s3,24(sp)
    800014da:	e852                	sd	s4,16(sp)
    800014dc:	e456                	sd	s5,8(sp)
    800014de:	0080                	addi	s0,sp,64
    800014e0:	8aaa                	mv	s5,a0
    800014e2:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    800014e4:	6785                	lui	a5,0x1
    800014e6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014e8:	95be                	add	a1,a1,a5
    800014ea:	77fd                	lui	a5,0xfffff
    800014ec:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014f0:	08c9f063          	bgeu	s3,a2,80001570 <uvmalloc+0xa6>
    800014f4:	894e                	mv	s2,s3
    mem = kalloc();
    800014f6:	fffff097          	auipc	ra,0xfffff
    800014fa:	676080e7          	jalr	1654(ra) # 80000b6c <kalloc>
    800014fe:	84aa                	mv	s1,a0
    if(mem == 0){
    80001500:	c51d                	beqz	a0,8000152e <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001502:	6605                	lui	a2,0x1
    80001504:	4581                	li	a1,0
    80001506:	00000097          	auipc	ra,0x0
    8000150a:	852080e7          	jalr	-1966(ra) # 80000d58 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    8000150e:	4779                	li	a4,30
    80001510:	86a6                	mv	a3,s1
    80001512:	6605                	lui	a2,0x1
    80001514:	85ca                	mv	a1,s2
    80001516:	8556                	mv	a0,s5
    80001518:	00000097          	auipc	ra,0x0
    8000151c:	c6e080e7          	jalr	-914(ra) # 80001186 <mappages>
    80001520:	e905                	bnez	a0,80001550 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001522:	6785                	lui	a5,0x1
    80001524:	993e                	add	s2,s2,a5
    80001526:	fd4968e3          	bltu	s2,s4,800014f6 <uvmalloc+0x2c>
  return newsz;
    8000152a:	8552                	mv	a0,s4
    8000152c:	a809                	j	8000153e <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    8000152e:	864e                	mv	a2,s3
    80001530:	85ca                	mv	a1,s2
    80001532:	8556                	mv	a0,s5
    80001534:	00000097          	auipc	ra,0x0
    80001538:	f4e080e7          	jalr	-178(ra) # 80001482 <uvmdealloc>
      return 0;
    8000153c:	4501                	li	a0,0
}
    8000153e:	70e2                	ld	ra,56(sp)
    80001540:	7442                	ld	s0,48(sp)
    80001542:	74a2                	ld	s1,40(sp)
    80001544:	7902                	ld	s2,32(sp)
    80001546:	69e2                	ld	s3,24(sp)
    80001548:	6a42                	ld	s4,16(sp)
    8000154a:	6aa2                	ld	s5,8(sp)
    8000154c:	6121                	addi	sp,sp,64
    8000154e:	8082                	ret
      kfree(mem);
    80001550:	8526                	mv	a0,s1
    80001552:	fffff097          	auipc	ra,0xfffff
    80001556:	51c080e7          	jalr	1308(ra) # 80000a6e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000155a:	864e                	mv	a2,s3
    8000155c:	85ca                	mv	a1,s2
    8000155e:	8556                	mv	a0,s5
    80001560:	00000097          	auipc	ra,0x0
    80001564:	f22080e7          	jalr	-222(ra) # 80001482 <uvmdealloc>
      return 0;
    80001568:	4501                	li	a0,0
    8000156a:	bfd1                	j	8000153e <uvmalloc+0x74>
    return oldsz;
    8000156c:	852e                	mv	a0,a1
}
    8000156e:	8082                	ret
  return newsz;
    80001570:	8532                	mv	a0,a2
    80001572:	b7f1                	j	8000153e <uvmalloc+0x74>

0000000080001574 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001574:	7179                	addi	sp,sp,-48
    80001576:	f406                	sd	ra,40(sp)
    80001578:	f022                	sd	s0,32(sp)
    8000157a:	ec26                	sd	s1,24(sp)
    8000157c:	e84a                	sd	s2,16(sp)
    8000157e:	e44e                	sd	s3,8(sp)
    80001580:	e052                	sd	s4,0(sp)
    80001582:	1800                	addi	s0,sp,48
    80001584:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001586:	84aa                	mv	s1,a0
    80001588:	6905                	lui	s2,0x1
    8000158a:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000158c:	4985                	li	s3,1
    8000158e:	a829                	j	800015a8 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001590:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001592:	00c79513          	slli	a0,a5,0xc
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	fde080e7          	jalr	-34(ra) # 80001574 <freewalk>
      pagetable[i] = 0;
    8000159e:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015a2:	04a1                	addi	s1,s1,8
    800015a4:	03248163          	beq	s1,s2,800015c6 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015a8:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015aa:	00f7f713          	andi	a4,a5,15
    800015ae:	ff3701e3          	beq	a4,s3,80001590 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015b2:	8b85                	andi	a5,a5,1
    800015b4:	d7fd                	beqz	a5,800015a2 <freewalk+0x2e>
      panic("freewalk: leaf");
    800015b6:	00007517          	auipc	a0,0x7
    800015ba:	bba50513          	addi	a0,a0,-1094 # 80008170 <digits+0x128>
    800015be:	fffff097          	auipc	ra,0xfffff
    800015c2:	f88080e7          	jalr	-120(ra) # 80000546 <panic>
    }
  }
  kfree((void*)pagetable);
    800015c6:	8552                	mv	a0,s4
    800015c8:	fffff097          	auipc	ra,0xfffff
    800015cc:	4a6080e7          	jalr	1190(ra) # 80000a6e <kfree>
}
    800015d0:	70a2                	ld	ra,40(sp)
    800015d2:	7402                	ld	s0,32(sp)
    800015d4:	64e2                	ld	s1,24(sp)
    800015d6:	6942                	ld	s2,16(sp)
    800015d8:	69a2                	ld	s3,8(sp)
    800015da:	6a02                	ld	s4,0(sp)
    800015dc:	6145                	addi	sp,sp,48
    800015de:	8082                	ret

00000000800015e0 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800015e0:	1101                	addi	sp,sp,-32
    800015e2:	ec06                	sd	ra,24(sp)
    800015e4:	e822                	sd	s0,16(sp)
    800015e6:	e426                	sd	s1,8(sp)
    800015e8:	1000                	addi	s0,sp,32
    800015ea:	84aa                	mv	s1,a0
  if(sz > 0)
    800015ec:	e999                	bnez	a1,80001602 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800015ee:	8526                	mv	a0,s1
    800015f0:	00000097          	auipc	ra,0x0
    800015f4:	f84080e7          	jalr	-124(ra) # 80001574 <freewalk>
}
    800015f8:	60e2                	ld	ra,24(sp)
    800015fa:	6442                	ld	s0,16(sp)
    800015fc:	64a2                	ld	s1,8(sp)
    800015fe:	6105                	addi	sp,sp,32
    80001600:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001602:	6785                	lui	a5,0x1
    80001604:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001606:	95be                	add	a1,a1,a5
    80001608:	4685                	li	a3,1
    8000160a:	00c5d613          	srli	a2,a1,0xc
    8000160e:	4581                	li	a1,0
    80001610:	00000097          	auipc	ra,0x0
    80001614:	d0e080e7          	jalr	-754(ra) # 8000131e <uvmunmap>
    80001618:	bfd9                	j	800015ee <uvmfree+0xe>

000000008000161a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000161a:	c679                	beqz	a2,800016e8 <uvmcopy+0xce>
{
    8000161c:	715d                	addi	sp,sp,-80
    8000161e:	e486                	sd	ra,72(sp)
    80001620:	e0a2                	sd	s0,64(sp)
    80001622:	fc26                	sd	s1,56(sp)
    80001624:	f84a                	sd	s2,48(sp)
    80001626:	f44e                	sd	s3,40(sp)
    80001628:	f052                	sd	s4,32(sp)
    8000162a:	ec56                	sd	s5,24(sp)
    8000162c:	e85a                	sd	s6,16(sp)
    8000162e:	e45e                	sd	s7,8(sp)
    80001630:	0880                	addi	s0,sp,80
    80001632:	8b2a                	mv	s6,a0
    80001634:	8aae                	mv	s5,a1
    80001636:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001638:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000163a:	4601                	li	a2,0
    8000163c:	85ce                	mv	a1,s3
    8000163e:	855a                	mv	a0,s6
    80001640:	00000097          	auipc	ra,0x0
    80001644:	a00080e7          	jalr	-1536(ra) # 80001040 <walk>
    80001648:	c531                	beqz	a0,80001694 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000164a:	6118                	ld	a4,0(a0)
    8000164c:	00177793          	andi	a5,a4,1
    80001650:	cbb1                	beqz	a5,800016a4 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001652:	00a75593          	srli	a1,a4,0xa
    80001656:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000165a:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	50e080e7          	jalr	1294(ra) # 80000b6c <kalloc>
    80001666:	892a                	mv	s2,a0
    80001668:	c939                	beqz	a0,800016be <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000166a:	6605                	lui	a2,0x1
    8000166c:	85de                	mv	a1,s7
    8000166e:	fffff097          	auipc	ra,0xfffff
    80001672:	746080e7          	jalr	1862(ra) # 80000db4 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001676:	8726                	mv	a4,s1
    80001678:	86ca                	mv	a3,s2
    8000167a:	6605                	lui	a2,0x1
    8000167c:	85ce                	mv	a1,s3
    8000167e:	8556                	mv	a0,s5
    80001680:	00000097          	auipc	ra,0x0
    80001684:	b06080e7          	jalr	-1274(ra) # 80001186 <mappages>
    80001688:	e515                	bnez	a0,800016b4 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    8000168a:	6785                	lui	a5,0x1
    8000168c:	99be                	add	s3,s3,a5
    8000168e:	fb49e6e3          	bltu	s3,s4,8000163a <uvmcopy+0x20>
    80001692:	a081                	j	800016d2 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80001694:	00007517          	auipc	a0,0x7
    80001698:	aec50513          	addi	a0,a0,-1300 # 80008180 <digits+0x138>
    8000169c:	fffff097          	auipc	ra,0xfffff
    800016a0:	eaa080e7          	jalr	-342(ra) # 80000546 <panic>
      panic("uvmcopy: page not present");
    800016a4:	00007517          	auipc	a0,0x7
    800016a8:	afc50513          	addi	a0,a0,-1284 # 800081a0 <digits+0x158>
    800016ac:	fffff097          	auipc	ra,0xfffff
    800016b0:	e9a080e7          	jalr	-358(ra) # 80000546 <panic>
      kfree(mem);
    800016b4:	854a                	mv	a0,s2
    800016b6:	fffff097          	auipc	ra,0xfffff
    800016ba:	3b8080e7          	jalr	952(ra) # 80000a6e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016be:	4685                	li	a3,1
    800016c0:	00c9d613          	srli	a2,s3,0xc
    800016c4:	4581                	li	a1,0
    800016c6:	8556                	mv	a0,s5
    800016c8:	00000097          	auipc	ra,0x0
    800016cc:	c56080e7          	jalr	-938(ra) # 8000131e <uvmunmap>
  return -1;
    800016d0:	557d                	li	a0,-1
}
    800016d2:	60a6                	ld	ra,72(sp)
    800016d4:	6406                	ld	s0,64(sp)
    800016d6:	74e2                	ld	s1,56(sp)
    800016d8:	7942                	ld	s2,48(sp)
    800016da:	79a2                	ld	s3,40(sp)
    800016dc:	7a02                	ld	s4,32(sp)
    800016de:	6ae2                	ld	s5,24(sp)
    800016e0:	6b42                	ld	s6,16(sp)
    800016e2:	6ba2                	ld	s7,8(sp)
    800016e4:	6161                	addi	sp,sp,80
    800016e6:	8082                	ret
  return 0;
    800016e8:	4501                	li	a0,0
}
    800016ea:	8082                	ret

00000000800016ec <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016ec:	1141                	addi	sp,sp,-16
    800016ee:	e406                	sd	ra,8(sp)
    800016f0:	e022                	sd	s0,0(sp)
    800016f2:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016f4:	4601                	li	a2,0
    800016f6:	00000097          	auipc	ra,0x0
    800016fa:	94a080e7          	jalr	-1718(ra) # 80001040 <walk>
  if(pte == 0)
    800016fe:	c901                	beqz	a0,8000170e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001700:	611c                	ld	a5,0(a0)
    80001702:	9bbd                	andi	a5,a5,-17
    80001704:	e11c                	sd	a5,0(a0)
}
    80001706:	60a2                	ld	ra,8(sp)
    80001708:	6402                	ld	s0,0(sp)
    8000170a:	0141                	addi	sp,sp,16
    8000170c:	8082                	ret
    panic("uvmclear");
    8000170e:	00007517          	auipc	a0,0x7
    80001712:	ab250513          	addi	a0,a0,-1358 # 800081c0 <digits+0x178>
    80001716:	fffff097          	auipc	ra,0xfffff
    8000171a:	e30080e7          	jalr	-464(ra) # 80000546 <panic>

000000008000171e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000171e:	c6bd                	beqz	a3,8000178c <copyout+0x6e>
{
    80001720:	715d                	addi	sp,sp,-80
    80001722:	e486                	sd	ra,72(sp)
    80001724:	e0a2                	sd	s0,64(sp)
    80001726:	fc26                	sd	s1,56(sp)
    80001728:	f84a                	sd	s2,48(sp)
    8000172a:	f44e                	sd	s3,40(sp)
    8000172c:	f052                	sd	s4,32(sp)
    8000172e:	ec56                	sd	s5,24(sp)
    80001730:	e85a                	sd	s6,16(sp)
    80001732:	e45e                	sd	s7,8(sp)
    80001734:	e062                	sd	s8,0(sp)
    80001736:	0880                	addi	s0,sp,80
    80001738:	8b2a                	mv	s6,a0
    8000173a:	8c2e                	mv	s8,a1
    8000173c:	8a32                	mv	s4,a2
    8000173e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001740:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001742:	6a85                	lui	s5,0x1
    80001744:	a015                	j	80001768 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001746:	9562                	add	a0,a0,s8
    80001748:	0004861b          	sext.w	a2,s1
    8000174c:	85d2                	mv	a1,s4
    8000174e:	41250533          	sub	a0,a0,s2
    80001752:	fffff097          	auipc	ra,0xfffff
    80001756:	662080e7          	jalr	1634(ra) # 80000db4 <memmove>

    len -= n;
    8000175a:	409989b3          	sub	s3,s3,s1
    src += n;
    8000175e:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001760:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001764:	02098263          	beqz	s3,80001788 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80001768:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000176c:	85ca                	mv	a1,s2
    8000176e:	855a                	mv	a0,s6
    80001770:	00000097          	auipc	ra,0x0
    80001774:	976080e7          	jalr	-1674(ra) # 800010e6 <walkaddr>
    if(pa0 == 0)
    80001778:	cd01                	beqz	a0,80001790 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000177a:	418904b3          	sub	s1,s2,s8
    8000177e:	94d6                	add	s1,s1,s5
    80001780:	fc99f3e3          	bgeu	s3,s1,80001746 <copyout+0x28>
    80001784:	84ce                	mv	s1,s3
    80001786:	b7c1                	j	80001746 <copyout+0x28>
  }
  return 0;
    80001788:	4501                	li	a0,0
    8000178a:	a021                	j	80001792 <copyout+0x74>
    8000178c:	4501                	li	a0,0
}
    8000178e:	8082                	ret
      return -1;
    80001790:	557d                	li	a0,-1
}
    80001792:	60a6                	ld	ra,72(sp)
    80001794:	6406                	ld	s0,64(sp)
    80001796:	74e2                	ld	s1,56(sp)
    80001798:	7942                	ld	s2,48(sp)
    8000179a:	79a2                	ld	s3,40(sp)
    8000179c:	7a02                	ld	s4,32(sp)
    8000179e:	6ae2                	ld	s5,24(sp)
    800017a0:	6b42                	ld	s6,16(sp)
    800017a2:	6ba2                	ld	s7,8(sp)
    800017a4:	6c02                	ld	s8,0(sp)
    800017a6:	6161                	addi	sp,sp,80
    800017a8:	8082                	ret

00000000800017aa <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800017aa:	caa5                	beqz	a3,8000181a <copyin+0x70>
{
    800017ac:	715d                	addi	sp,sp,-80
    800017ae:	e486                	sd	ra,72(sp)
    800017b0:	e0a2                	sd	s0,64(sp)
    800017b2:	fc26                	sd	s1,56(sp)
    800017b4:	f84a                	sd	s2,48(sp)
    800017b6:	f44e                	sd	s3,40(sp)
    800017b8:	f052                	sd	s4,32(sp)
    800017ba:	ec56                	sd	s5,24(sp)
    800017bc:	e85a                	sd	s6,16(sp)
    800017be:	e45e                	sd	s7,8(sp)
    800017c0:	e062                	sd	s8,0(sp)
    800017c2:	0880                	addi	s0,sp,80
    800017c4:	8b2a                	mv	s6,a0
    800017c6:	8a2e                	mv	s4,a1
    800017c8:	8c32                	mv	s8,a2
    800017ca:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017cc:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ce:	6a85                	lui	s5,0x1
    800017d0:	a01d                	j	800017f6 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800017d2:	018505b3          	add	a1,a0,s8
    800017d6:	0004861b          	sext.w	a2,s1
    800017da:	412585b3          	sub	a1,a1,s2
    800017de:	8552                	mv	a0,s4
    800017e0:	fffff097          	auipc	ra,0xfffff
    800017e4:	5d4080e7          	jalr	1492(ra) # 80000db4 <memmove>

    len -= n;
    800017e8:	409989b3          	sub	s3,s3,s1
    dst += n;
    800017ec:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800017ee:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800017f2:	02098263          	beqz	s3,80001816 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800017f6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800017fa:	85ca                	mv	a1,s2
    800017fc:	855a                	mv	a0,s6
    800017fe:	00000097          	auipc	ra,0x0
    80001802:	8e8080e7          	jalr	-1816(ra) # 800010e6 <walkaddr>
    if(pa0 == 0)
    80001806:	cd01                	beqz	a0,8000181e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001808:	418904b3          	sub	s1,s2,s8
    8000180c:	94d6                	add	s1,s1,s5
    8000180e:	fc99f2e3          	bgeu	s3,s1,800017d2 <copyin+0x28>
    80001812:	84ce                	mv	s1,s3
    80001814:	bf7d                	j	800017d2 <copyin+0x28>
  }
  return 0;
    80001816:	4501                	li	a0,0
    80001818:	a021                	j	80001820 <copyin+0x76>
    8000181a:	4501                	li	a0,0
}
    8000181c:	8082                	ret
      return -1;
    8000181e:	557d                	li	a0,-1
}
    80001820:	60a6                	ld	ra,72(sp)
    80001822:	6406                	ld	s0,64(sp)
    80001824:	74e2                	ld	s1,56(sp)
    80001826:	7942                	ld	s2,48(sp)
    80001828:	79a2                	ld	s3,40(sp)
    8000182a:	7a02                	ld	s4,32(sp)
    8000182c:	6ae2                	ld	s5,24(sp)
    8000182e:	6b42                	ld	s6,16(sp)
    80001830:	6ba2                	ld	s7,8(sp)
    80001832:	6c02                	ld	s8,0(sp)
    80001834:	6161                	addi	sp,sp,80
    80001836:	8082                	ret

0000000080001838 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001838:	c2dd                	beqz	a3,800018de <copyinstr+0xa6>
{
    8000183a:	715d                	addi	sp,sp,-80
    8000183c:	e486                	sd	ra,72(sp)
    8000183e:	e0a2                	sd	s0,64(sp)
    80001840:	fc26                	sd	s1,56(sp)
    80001842:	f84a                	sd	s2,48(sp)
    80001844:	f44e                	sd	s3,40(sp)
    80001846:	f052                	sd	s4,32(sp)
    80001848:	ec56                	sd	s5,24(sp)
    8000184a:	e85a                	sd	s6,16(sp)
    8000184c:	e45e                	sd	s7,8(sp)
    8000184e:	0880                	addi	s0,sp,80
    80001850:	8a2a                	mv	s4,a0
    80001852:	8b2e                	mv	s6,a1
    80001854:	8bb2                	mv	s7,a2
    80001856:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    80001858:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000185a:	6985                	lui	s3,0x1
    8000185c:	a02d                	j	80001886 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000185e:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001862:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001864:	37fd                	addiw	a5,a5,-1
    80001866:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000186a:	60a6                	ld	ra,72(sp)
    8000186c:	6406                	ld	s0,64(sp)
    8000186e:	74e2                	ld	s1,56(sp)
    80001870:	7942                	ld	s2,48(sp)
    80001872:	79a2                	ld	s3,40(sp)
    80001874:	7a02                	ld	s4,32(sp)
    80001876:	6ae2                	ld	s5,24(sp)
    80001878:	6b42                	ld	s6,16(sp)
    8000187a:	6ba2                	ld	s7,8(sp)
    8000187c:	6161                	addi	sp,sp,80
    8000187e:	8082                	ret
    srcva = va0 + PGSIZE;
    80001880:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    80001884:	c8a9                	beqz	s1,800018d6 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    80001886:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000188a:	85ca                	mv	a1,s2
    8000188c:	8552                	mv	a0,s4
    8000188e:	00000097          	auipc	ra,0x0
    80001892:	858080e7          	jalr	-1960(ra) # 800010e6 <walkaddr>
    if(pa0 == 0)
    80001896:	c131                	beqz	a0,800018da <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001898:	417906b3          	sub	a3,s2,s7
    8000189c:	96ce                	add	a3,a3,s3
    8000189e:	00d4f363          	bgeu	s1,a3,800018a4 <copyinstr+0x6c>
    800018a2:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800018a4:	955e                	add	a0,a0,s7
    800018a6:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800018aa:	daf9                	beqz	a3,80001880 <copyinstr+0x48>
    800018ac:	87da                	mv	a5,s6
      if(*p == '\0'){
    800018ae:	41650633          	sub	a2,a0,s6
    800018b2:	fff48593          	addi	a1,s1,-1
    800018b6:	95da                	add	a1,a1,s6
    while(n > 0){
    800018b8:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    800018ba:	00f60733          	add	a4,a2,a5
    800018be:	00074703          	lbu	a4,0(a4)
    800018c2:	df51                	beqz	a4,8000185e <copyinstr+0x26>
        *dst = *p;
    800018c4:	00e78023          	sb	a4,0(a5)
      --max;
    800018c8:	40f584b3          	sub	s1,a1,a5
      dst++;
    800018cc:	0785                	addi	a5,a5,1
    while(n > 0){
    800018ce:	fed796e3          	bne	a5,a3,800018ba <copyinstr+0x82>
      dst++;
    800018d2:	8b3e                	mv	s6,a5
    800018d4:	b775                	j	80001880 <copyinstr+0x48>
    800018d6:	4781                	li	a5,0
    800018d8:	b771                	j	80001864 <copyinstr+0x2c>
      return -1;
    800018da:	557d                	li	a0,-1
    800018dc:	b779                	j	8000186a <copyinstr+0x32>
  int got_null = 0;
    800018de:	4781                	li	a5,0
  if(got_null){
    800018e0:	37fd                	addiw	a5,a5,-1
    800018e2:	0007851b          	sext.w	a0,a5
}
    800018e6:	8082                	ret

00000000800018e8 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    800018e8:	1101                	addi	sp,sp,-32
    800018ea:	ec06                	sd	ra,24(sp)
    800018ec:	e822                	sd	s0,16(sp)
    800018ee:	e426                	sd	s1,8(sp)
    800018f0:	1000                	addi	s0,sp,32
    800018f2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800018f4:	fffff097          	auipc	ra,0xfffff
    800018f8:	2ee080e7          	jalr	750(ra) # 80000be2 <holding>
    800018fc:	c909                	beqz	a0,8000190e <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    800018fe:	749c                	ld	a5,40(s1)
    80001900:	00978f63          	beq	a5,s1,8000191e <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80001904:	60e2                	ld	ra,24(sp)
    80001906:	6442                	ld	s0,16(sp)
    80001908:	64a2                	ld	s1,8(sp)
    8000190a:	6105                	addi	sp,sp,32
    8000190c:	8082                	ret
    panic("wakeup1");
    8000190e:	00007517          	auipc	a0,0x7
    80001912:	8c250513          	addi	a0,a0,-1854 # 800081d0 <digits+0x188>
    80001916:	fffff097          	auipc	ra,0xfffff
    8000191a:	c30080e7          	jalr	-976(ra) # 80000546 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    8000191e:	4c98                	lw	a4,24(s1)
    80001920:	4785                	li	a5,1
    80001922:	fef711e3          	bne	a4,a5,80001904 <wakeup1+0x1c>
    p->state = RUNNABLE;
    80001926:	4789                	li	a5,2
    80001928:	cc9c                	sw	a5,24(s1)
}
    8000192a:	bfe9                	j	80001904 <wakeup1+0x1c>

000000008000192c <procinit>:
{
    8000192c:	715d                	addi	sp,sp,-80
    8000192e:	e486                	sd	ra,72(sp)
    80001930:	e0a2                	sd	s0,64(sp)
    80001932:	fc26                	sd	s1,56(sp)
    80001934:	f84a                	sd	s2,48(sp)
    80001936:	f44e                	sd	s3,40(sp)
    80001938:	f052                	sd	s4,32(sp)
    8000193a:	ec56                	sd	s5,24(sp)
    8000193c:	e85a                	sd	s6,16(sp)
    8000193e:	e45e                	sd	s7,8(sp)
    80001940:	0880                	addi	s0,sp,80
  initlock(&pid_lock, "nextpid");
    80001942:	00007597          	auipc	a1,0x7
    80001946:	89658593          	addi	a1,a1,-1898 # 800081d8 <digits+0x190>
    8000194a:	00010517          	auipc	a0,0x10
    8000194e:	00650513          	addi	a0,a0,6 # 80011950 <pid_lock>
    80001952:	fffff097          	auipc	ra,0xfffff
    80001956:	27a080e7          	jalr	634(ra) # 80000bcc <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195a:	00010917          	auipc	s2,0x10
    8000195e:	40e90913          	addi	s2,s2,1038 # 80011d68 <proc>
      initlock(&p->lock, "proc");
    80001962:	00007b97          	auipc	s7,0x7
    80001966:	87eb8b93          	addi	s7,s7,-1922 # 800081e0 <digits+0x198>
      uint64 va = KSTACK((int) (p - proc));
    8000196a:	8b4a                	mv	s6,s2
    8000196c:	00006a97          	auipc	s5,0x6
    80001970:	694a8a93          	addi	s5,s5,1684 # 80008000 <etext>
    80001974:	040009b7          	lui	s3,0x4000
    80001978:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000197a:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000197c:	00016a17          	auipc	s4,0x16
    80001980:	7eca0a13          	addi	s4,s4,2028 # 80018168 <tickslock>
      initlock(&p->lock, "proc");
    80001984:	85de                	mv	a1,s7
    80001986:	854a                	mv	a0,s2
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	244080e7          	jalr	580(ra) # 80000bcc <initlock>
      char *pa = kalloc();
    80001990:	fffff097          	auipc	ra,0xfffff
    80001994:	1dc080e7          	jalr	476(ra) # 80000b6c <kalloc>
    80001998:	85aa                	mv	a1,a0
      if(pa == 0)
    8000199a:	c929                	beqz	a0,800019ec <procinit+0xc0>
      uint64 va = KSTACK((int) (p - proc));
    8000199c:	416904b3          	sub	s1,s2,s6
    800019a0:	8491                	srai	s1,s1,0x4
    800019a2:	000ab783          	ld	a5,0(s5)
    800019a6:	02f484b3          	mul	s1,s1,a5
    800019aa:	2485                	addiw	s1,s1,1
    800019ac:	00d4949b          	slliw	s1,s1,0xd
    800019b0:	409984b3          	sub	s1,s3,s1
      kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800019b4:	4699                	li	a3,6
    800019b6:	6605                	lui	a2,0x1
    800019b8:	8526                	mv	a0,s1
    800019ba:	00000097          	auipc	ra,0x0
    800019be:	85a080e7          	jalr	-1958(ra) # 80001214 <kvmmap>
      p->kstack = va;
    800019c2:	04993023          	sd	s1,64(s2)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019c6:	19090913          	addi	s2,s2,400
    800019ca:	fb491de3          	bne	s2,s4,80001984 <procinit+0x58>
  kvminithart();
    800019ce:	fffff097          	auipc	ra,0xfffff
    800019d2:	64e080e7          	jalr	1614(ra) # 8000101c <kvminithart>
}
    800019d6:	60a6                	ld	ra,72(sp)
    800019d8:	6406                	ld	s0,64(sp)
    800019da:	74e2                	ld	s1,56(sp)
    800019dc:	7942                	ld	s2,48(sp)
    800019de:	79a2                	ld	s3,40(sp)
    800019e0:	7a02                	ld	s4,32(sp)
    800019e2:	6ae2                	ld	s5,24(sp)
    800019e4:	6b42                	ld	s6,16(sp)
    800019e6:	6ba2                	ld	s7,8(sp)
    800019e8:	6161                	addi	sp,sp,80
    800019ea:	8082                	ret
        panic("kalloc");
    800019ec:	00006517          	auipc	a0,0x6
    800019f0:	7fc50513          	addi	a0,a0,2044 # 800081e8 <digits+0x1a0>
    800019f4:	fffff097          	auipc	ra,0xfffff
    800019f8:	b52080e7          	jalr	-1198(ra) # 80000546 <panic>

00000000800019fc <cpuid>:
{
    800019fc:	1141                	addi	sp,sp,-16
    800019fe:	e422                	sd	s0,8(sp)
    80001a00:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001a02:	8512                	mv	a0,tp
}
    80001a04:	2501                	sext.w	a0,a0
    80001a06:	6422                	ld	s0,8(sp)
    80001a08:	0141                	addi	sp,sp,16
    80001a0a:	8082                	ret

0000000080001a0c <mycpu>:
mycpu(void) {
    80001a0c:	1141                	addi	sp,sp,-16
    80001a0e:	e422                	sd	s0,8(sp)
    80001a10:	0800                	addi	s0,sp,16
    80001a12:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80001a14:	2781                	sext.w	a5,a5
    80001a16:	079e                	slli	a5,a5,0x7
}
    80001a18:	00010517          	auipc	a0,0x10
    80001a1c:	f5050513          	addi	a0,a0,-176 # 80011968 <cpus>
    80001a20:	953e                	add	a0,a0,a5
    80001a22:	6422                	ld	s0,8(sp)
    80001a24:	0141                	addi	sp,sp,16
    80001a26:	8082                	ret

0000000080001a28 <myproc>:
myproc(void) {
    80001a28:	1101                	addi	sp,sp,-32
    80001a2a:	ec06                	sd	ra,24(sp)
    80001a2c:	e822                	sd	s0,16(sp)
    80001a2e:	e426                	sd	s1,8(sp)
    80001a30:	1000                	addi	s0,sp,32
  push_off();
    80001a32:	fffff097          	auipc	ra,0xfffff
    80001a36:	1de080e7          	jalr	478(ra) # 80000c10 <push_off>
    80001a3a:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80001a3c:	2781                	sext.w	a5,a5
    80001a3e:	079e                	slli	a5,a5,0x7
    80001a40:	00010717          	auipc	a4,0x10
    80001a44:	f1070713          	addi	a4,a4,-240 # 80011950 <pid_lock>
    80001a48:	97ba                	add	a5,a5,a4
    80001a4a:	6f84                	ld	s1,24(a5)
  pop_off();
    80001a4c:	fffff097          	auipc	ra,0xfffff
    80001a50:	264080e7          	jalr	612(ra) # 80000cb0 <pop_off>
}
    80001a54:	8526                	mv	a0,s1
    80001a56:	60e2                	ld	ra,24(sp)
    80001a58:	6442                	ld	s0,16(sp)
    80001a5a:	64a2                	ld	s1,8(sp)
    80001a5c:	6105                	addi	sp,sp,32
    80001a5e:	8082                	ret

0000000080001a60 <forkret>:
{
    80001a60:	1141                	addi	sp,sp,-16
    80001a62:	e406                	sd	ra,8(sp)
    80001a64:	e022                	sd	s0,0(sp)
    80001a66:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80001a68:	00000097          	auipc	ra,0x0
    80001a6c:	fc0080e7          	jalr	-64(ra) # 80001a28 <myproc>
    80001a70:	fffff097          	auipc	ra,0xfffff
    80001a74:	2a0080e7          	jalr	672(ra) # 80000d10 <release>
  if (first) {
    80001a78:	00007797          	auipc	a5,0x7
    80001a7c:	db87a783          	lw	a5,-584(a5) # 80008830 <first.1>
    80001a80:	eb89                	bnez	a5,80001a92 <forkret+0x32>
  usertrapret();
    80001a82:	00001097          	auipc	ra,0x1
    80001a86:	c6a080e7          	jalr	-918(ra) # 800026ec <usertrapret>
}
    80001a8a:	60a2                	ld	ra,8(sp)
    80001a8c:	6402                	ld	s0,0(sp)
    80001a8e:	0141                	addi	sp,sp,16
    80001a90:	8082                	ret
    first = 0;
    80001a92:	00007797          	auipc	a5,0x7
    80001a96:	d807af23          	sw	zero,-610(a5) # 80008830 <first.1>
    fsinit(ROOTDEV);
    80001a9a:	4505                	li	a0,1
    80001a9c:	00002097          	auipc	ra,0x2
    80001aa0:	ada080e7          	jalr	-1318(ra) # 80003576 <fsinit>
    80001aa4:	bff9                	j	80001a82 <forkret+0x22>

0000000080001aa6 <allocpid>:
allocpid() {
    80001aa6:	1101                	addi	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	e04a                	sd	s2,0(sp)
    80001ab0:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ab2:	00010917          	auipc	s2,0x10
    80001ab6:	e9e90913          	addi	s2,s2,-354 # 80011950 <pid_lock>
    80001aba:	854a                	mv	a0,s2
    80001abc:	fffff097          	auipc	ra,0xfffff
    80001ac0:	1a0080e7          	jalr	416(ra) # 80000c5c <acquire>
  pid = nextpid;
    80001ac4:	00007797          	auipc	a5,0x7
    80001ac8:	d7078793          	addi	a5,a5,-656 # 80008834 <nextpid>
    80001acc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ace:	0014871b          	addiw	a4,s1,1
    80001ad2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ad4:	854a                	mv	a0,s2
    80001ad6:	fffff097          	auipc	ra,0xfffff
    80001ada:	23a080e7          	jalr	570(ra) # 80000d10 <release>
}
    80001ade:	8526                	mv	a0,s1
    80001ae0:	60e2                	ld	ra,24(sp)
    80001ae2:	6442                	ld	s0,16(sp)
    80001ae4:	64a2                	ld	s1,8(sp)
    80001ae6:	6902                	ld	s2,0(sp)
    80001ae8:	6105                	addi	sp,sp,32
    80001aea:	8082                	ret

0000000080001aec <proc_pagetable>:
{
    80001aec:	1101                	addi	sp,sp,-32
    80001aee:	ec06                	sd	ra,24(sp)
    80001af0:	e822                	sd	s0,16(sp)
    80001af2:	e426                	sd	s1,8(sp)
    80001af4:	e04a                	sd	s2,0(sp)
    80001af6:	1000                	addi	s0,sp,32
    80001af8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	8e8080e7          	jalr	-1816(ra) # 800013e2 <uvmcreate>
    80001b02:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001b04:	c121                	beqz	a0,80001b44 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001b06:	4729                	li	a4,10
    80001b08:	00005697          	auipc	a3,0x5
    80001b0c:	4f868693          	addi	a3,a3,1272 # 80007000 <_trampoline>
    80001b10:	6605                	lui	a2,0x1
    80001b12:	040005b7          	lui	a1,0x4000
    80001b16:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b18:	05b2                	slli	a1,a1,0xc
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	66c080e7          	jalr	1644(ra) # 80001186 <mappages>
    80001b22:	02054863          	bltz	a0,80001b52 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001b26:	4719                	li	a4,6
    80001b28:	05893683          	ld	a3,88(s2)
    80001b2c:	6605                	lui	a2,0x1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	64e080e7          	jalr	1614(ra) # 80001186 <mappages>
    80001b40:	02054163          	bltz	a0,80001b62 <proc_pagetable+0x76>
}
    80001b44:	8526                	mv	a0,s1
    80001b46:	60e2                	ld	ra,24(sp)
    80001b48:	6442                	ld	s0,16(sp)
    80001b4a:	64a2                	ld	s1,8(sp)
    80001b4c:	6902                	ld	s2,0(sp)
    80001b4e:	6105                	addi	sp,sp,32
    80001b50:	8082                	ret
    uvmfree(pagetable, 0);
    80001b52:	4581                	li	a1,0
    80001b54:	8526                	mv	a0,s1
    80001b56:	00000097          	auipc	ra,0x0
    80001b5a:	a8a080e7          	jalr	-1398(ra) # 800015e0 <uvmfree>
    return 0;
    80001b5e:	4481                	li	s1,0
    80001b60:	b7d5                	j	80001b44 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b62:	4681                	li	a3,0
    80001b64:	4605                	li	a2,1
    80001b66:	040005b7          	lui	a1,0x4000
    80001b6a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b6c:	05b2                	slli	a1,a1,0xc
    80001b6e:	8526                	mv	a0,s1
    80001b70:	fffff097          	auipc	ra,0xfffff
    80001b74:	7ae080e7          	jalr	1966(ra) # 8000131e <uvmunmap>
    uvmfree(pagetable, 0);
    80001b78:	4581                	li	a1,0
    80001b7a:	8526                	mv	a0,s1
    80001b7c:	00000097          	auipc	ra,0x0
    80001b80:	a64080e7          	jalr	-1436(ra) # 800015e0 <uvmfree>
    return 0;
    80001b84:	4481                	li	s1,0
    80001b86:	bf7d                	j	80001b44 <proc_pagetable+0x58>

0000000080001b88 <proc_freepagetable>:
{
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
    80001b94:	84aa                	mv	s1,a0
    80001b96:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b98:	4681                	li	a3,0
    80001b9a:	4605                	li	a2,1
    80001b9c:	040005b7          	lui	a1,0x4000
    80001ba0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ba2:	05b2                	slli	a1,a1,0xc
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	77a080e7          	jalr	1914(ra) # 8000131e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001bac:	4681                	li	a3,0
    80001bae:	4605                	li	a2,1
    80001bb0:	020005b7          	lui	a1,0x2000
    80001bb4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001bb6:	05b6                	slli	a1,a1,0xd
    80001bb8:	8526                	mv	a0,s1
    80001bba:	fffff097          	auipc	ra,0xfffff
    80001bbe:	764080e7          	jalr	1892(ra) # 8000131e <uvmunmap>
  uvmfree(pagetable, sz);
    80001bc2:	85ca                	mv	a1,s2
    80001bc4:	8526                	mv	a0,s1
    80001bc6:	00000097          	auipc	ra,0x0
    80001bca:	a1a080e7          	jalr	-1510(ra) # 800015e0 <uvmfree>
}
    80001bce:	60e2                	ld	ra,24(sp)
    80001bd0:	6442                	ld	s0,16(sp)
    80001bd2:	64a2                	ld	s1,8(sp)
    80001bd4:	6902                	ld	s2,0(sp)
    80001bd6:	6105                	addi	sp,sp,32
    80001bd8:	8082                	ret

0000000080001bda <freeproc>:
{
    80001bda:	1101                	addi	sp,sp,-32
    80001bdc:	ec06                	sd	ra,24(sp)
    80001bde:	e822                	sd	s0,16(sp)
    80001be0:	e426                	sd	s1,8(sp)
    80001be2:	1000                	addi	s0,sp,32
    80001be4:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001be6:	6d28                	ld	a0,88(a0)
    80001be8:	c509                	beqz	a0,80001bf2 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bea:	fffff097          	auipc	ra,0xfffff
    80001bee:	e84080e7          	jalr	-380(ra) # 80000a6e <kfree>
  p->trapframe = 0;
    80001bf2:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bf6:	68a8                	ld	a0,80(s1)
    80001bf8:	c511                	beqz	a0,80001c04 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bfa:	64ac                	ld	a1,72(s1)
    80001bfc:	00000097          	auipc	ra,0x0
    80001c00:	f8c080e7          	jalr	-116(ra) # 80001b88 <proc_freepagetable>
  if(p->alarm_trapframe)
    80001c04:	1804b503          	ld	a0,384(s1)
    80001c08:	c509                	beqz	a0,80001c12 <freeproc+0x38>
    kfree((void*)p->alarm_trapframe);
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	e64080e7          	jalr	-412(ra) # 80000a6e <kfree>
  p->alarm_trapframe=0;
    80001c12:	1804b023          	sd	zero,384(s1)
  p->alarm_rank=0;
    80001c16:	1604a423          	sw	zero,360(s1)
  p->alarm_check=0;
    80001c1a:	1804a423          	sw	zero,392(s1)
  p->alarm_handler=0;
    80001c1e:	1604b823          	sd	zero,368(s1)
  p->alarm_ticks=0;
    80001c22:	1604ac23          	sw	zero,376(s1)
  p->pagetable = 0;
    80001c26:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001c2a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001c2e:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    80001c32:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    80001c36:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001c3a:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    80001c3e:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    80001c42:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    80001c46:	0004ac23          	sw	zero,24(s1)
}
    80001c4a:	60e2                	ld	ra,24(sp)
    80001c4c:	6442                	ld	s0,16(sp)
    80001c4e:	64a2                	ld	s1,8(sp)
    80001c50:	6105                	addi	sp,sp,32
    80001c52:	8082                	ret

0000000080001c54 <allocproc>:
{
    80001c54:	1101                	addi	sp,sp,-32
    80001c56:	ec06                	sd	ra,24(sp)
    80001c58:	e822                	sd	s0,16(sp)
    80001c5a:	e426                	sd	s1,8(sp)
    80001c5c:	e04a                	sd	s2,0(sp)
    80001c5e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c60:	00010497          	auipc	s1,0x10
    80001c64:	10848493          	addi	s1,s1,264 # 80011d68 <proc>
    80001c68:	00016917          	auipc	s2,0x16
    80001c6c:	50090913          	addi	s2,s2,1280 # 80018168 <tickslock>
    acquire(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	fea080e7          	jalr	-22(ra) # 80000c5c <acquire>
    if(p->state == UNUSED) {
    80001c7a:	4c9c                	lw	a5,24(s1)
    80001c7c:	cf81                	beqz	a5,80001c94 <allocproc+0x40>
      release(&p->lock);
    80001c7e:	8526                	mv	a0,s1
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	090080e7          	jalr	144(ra) # 80000d10 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c88:	19048493          	addi	s1,s1,400
    80001c8c:	ff2492e3          	bne	s1,s2,80001c70 <allocproc+0x1c>
  return 0;
    80001c90:	4481                	li	s1,0
    80001c92:	a0bd                	j	80001d00 <allocproc+0xac>
  p->pid = allocpid();
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	e12080e7          	jalr	-494(ra) # 80001aa6 <allocpid>
    80001c9c:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	ece080e7          	jalr	-306(ra) # 80000b6c <kalloc>
    80001ca6:	892a                	mv	s2,a0
    80001ca8:	eca8                	sd	a0,88(s1)
    80001caa:	c135                	beqz	a0,80001d0e <allocproc+0xba>
  if((p->alarm_trapframe=(struct trapframe*)kalloc())==0){
    80001cac:	fffff097          	auipc	ra,0xfffff
    80001cb0:	ec0080e7          	jalr	-320(ra) # 80000b6c <kalloc>
    80001cb4:	892a                	mv	s2,a0
    80001cb6:	18a4b023          	sd	a0,384(s1)
    80001cba:	c12d                	beqz	a0,80001d1c <allocproc+0xc8>
  p->alarm_rank=0;
    80001cbc:	1604a423          	sw	zero,360(s1)
  p->alarm_check=0;
    80001cc0:	1804a423          	sw	zero,392(s1)
  p->alarm_handler=0;
    80001cc4:	1604b823          	sd	zero,368(s1)
  p->alarm_ticks=0;
    80001cc8:	1604ac23          	sw	zero,376(s1)
  p->pagetable = proc_pagetable(p);
    80001ccc:	8526                	mv	a0,s1
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	e1e080e7          	jalr	-482(ra) # 80001aec <proc_pagetable>
    80001cd6:	892a                	mv	s2,a0
    80001cd8:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001cda:	c921                	beqz	a0,80001d2a <allocproc+0xd6>
  memset(&p->context, 0, sizeof(p->context));
    80001cdc:	07000613          	li	a2,112
    80001ce0:	4581                	li	a1,0
    80001ce2:	06048513          	addi	a0,s1,96
    80001ce6:	fffff097          	auipc	ra,0xfffff
    80001cea:	072080e7          	jalr	114(ra) # 80000d58 <memset>
  p->context.ra = (uint64)forkret;
    80001cee:	00000797          	auipc	a5,0x0
    80001cf2:	d7278793          	addi	a5,a5,-654 # 80001a60 <forkret>
    80001cf6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001cf8:	60bc                	ld	a5,64(s1)
    80001cfa:	6705                	lui	a4,0x1
    80001cfc:	97ba                	add	a5,a5,a4
    80001cfe:	f4bc                	sd	a5,104(s1)
}
    80001d00:	8526                	mv	a0,s1
    80001d02:	60e2                	ld	ra,24(sp)
    80001d04:	6442                	ld	s0,16(sp)
    80001d06:	64a2                	ld	s1,8(sp)
    80001d08:	6902                	ld	s2,0(sp)
    80001d0a:	6105                	addi	sp,sp,32
    80001d0c:	8082                	ret
    release(&p->lock);
    80001d0e:	8526                	mv	a0,s1
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	000080e7          	jalr	ra # 80000d10 <release>
    return 0;
    80001d18:	84ca                	mv	s1,s2
    80001d1a:	b7dd                	j	80001d00 <allocproc+0xac>
    release(&p->lock);
    80001d1c:	8526                	mv	a0,s1
    80001d1e:	fffff097          	auipc	ra,0xfffff
    80001d22:	ff2080e7          	jalr	-14(ra) # 80000d10 <release>
    return 0;
    80001d26:	84ca                	mv	s1,s2
    80001d28:	bfe1                	j	80001d00 <allocproc+0xac>
    freeproc(p);
    80001d2a:	8526                	mv	a0,s1
    80001d2c:	00000097          	auipc	ra,0x0
    80001d30:	eae080e7          	jalr	-338(ra) # 80001bda <freeproc>
    release(&p->lock);
    80001d34:	8526                	mv	a0,s1
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	fda080e7          	jalr	-38(ra) # 80000d10 <release>
    return 0;
    80001d3e:	84ca                	mv	s1,s2
    80001d40:	b7c1                	j	80001d00 <allocproc+0xac>

0000000080001d42 <userinit>:
{
    80001d42:	1101                	addi	sp,sp,-32
    80001d44:	ec06                	sd	ra,24(sp)
    80001d46:	e822                	sd	s0,16(sp)
    80001d48:	e426                	sd	s1,8(sp)
    80001d4a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001d4c:	00000097          	auipc	ra,0x0
    80001d50:	f08080e7          	jalr	-248(ra) # 80001c54 <allocproc>
    80001d54:	84aa                	mv	s1,a0
  initproc = p;
    80001d56:	00007797          	auipc	a5,0x7
    80001d5a:	2ca7b123          	sd	a0,706(a5) # 80009018 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    80001d5e:	03400613          	li	a2,52
    80001d62:	00007597          	auipc	a1,0x7
    80001d66:	ade58593          	addi	a1,a1,-1314 # 80008840 <initcode>
    80001d6a:	6928                	ld	a0,80(a0)
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	6a4080e7          	jalr	1700(ra) # 80001410 <uvminit>
  p->sz = PGSIZE;
    80001d74:	6785                	lui	a5,0x1
    80001d76:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d78:	6cb8                	ld	a4,88(s1)
    80001d7a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d7e:	6cb8                	ld	a4,88(s1)
    80001d80:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d82:	4641                	li	a2,16
    80001d84:	00006597          	auipc	a1,0x6
    80001d88:	46c58593          	addi	a1,a1,1132 # 800081f0 <digits+0x1a8>
    80001d8c:	15848513          	addi	a0,s1,344
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	11a080e7          	jalr	282(ra) # 80000eaa <safestrcpy>
  p->cwd = namei("/");
    80001d98:	00006517          	auipc	a0,0x6
    80001d9c:	46850513          	addi	a0,a0,1128 # 80008200 <digits+0x1b8>
    80001da0:	00002097          	auipc	ra,0x2
    80001da4:	206080e7          	jalr	518(ra) # 80003fa6 <namei>
    80001da8:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001dac:	4789                	li	a5,2
    80001dae:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001db0:	8526                	mv	a0,s1
    80001db2:	fffff097          	auipc	ra,0xfffff
    80001db6:	f5e080e7          	jalr	-162(ra) # 80000d10 <release>
}
    80001dba:	60e2                	ld	ra,24(sp)
    80001dbc:	6442                	ld	s0,16(sp)
    80001dbe:	64a2                	ld	s1,8(sp)
    80001dc0:	6105                	addi	sp,sp,32
    80001dc2:	8082                	ret

0000000080001dc4 <growproc>:
{
    80001dc4:	1101                	addi	sp,sp,-32
    80001dc6:	ec06                	sd	ra,24(sp)
    80001dc8:	e822                	sd	s0,16(sp)
    80001dca:	e426                	sd	s1,8(sp)
    80001dcc:	e04a                	sd	s2,0(sp)
    80001dce:	1000                	addi	s0,sp,32
    80001dd0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001dd2:	00000097          	auipc	ra,0x0
    80001dd6:	c56080e7          	jalr	-938(ra) # 80001a28 <myproc>
    80001dda:	892a                	mv	s2,a0
  sz = p->sz;
    80001ddc:	652c                	ld	a1,72(a0)
    80001dde:	0005879b          	sext.w	a5,a1
  if(n > 0){
    80001de2:	00904f63          	bgtz	s1,80001e00 <growproc+0x3c>
  } else if(n < 0){
    80001de6:	0204cd63          	bltz	s1,80001e20 <growproc+0x5c>
  p->sz = sz;
    80001dea:	1782                	slli	a5,a5,0x20
    80001dec:	9381                	srli	a5,a5,0x20
    80001dee:	04f93423          	sd	a5,72(s2)
  return 0;
    80001df2:	4501                	li	a0,0
}
    80001df4:	60e2                	ld	ra,24(sp)
    80001df6:	6442                	ld	s0,16(sp)
    80001df8:	64a2                	ld	s1,8(sp)
    80001dfa:	6902                	ld	s2,0(sp)
    80001dfc:	6105                	addi	sp,sp,32
    80001dfe:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    80001e00:	00f4863b          	addw	a2,s1,a5
    80001e04:	1602                	slli	a2,a2,0x20
    80001e06:	9201                	srli	a2,a2,0x20
    80001e08:	1582                	slli	a1,a1,0x20
    80001e0a:	9181                	srli	a1,a1,0x20
    80001e0c:	6928                	ld	a0,80(a0)
    80001e0e:	fffff097          	auipc	ra,0xfffff
    80001e12:	6bc080e7          	jalr	1724(ra) # 800014ca <uvmalloc>
    80001e16:	0005079b          	sext.w	a5,a0
    80001e1a:	fbe1                	bnez	a5,80001dea <growproc+0x26>
      return -1;
    80001e1c:	557d                	li	a0,-1
    80001e1e:	bfd9                	j	80001df4 <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e20:	00f4863b          	addw	a2,s1,a5
    80001e24:	1602                	slli	a2,a2,0x20
    80001e26:	9201                	srli	a2,a2,0x20
    80001e28:	1582                	slli	a1,a1,0x20
    80001e2a:	9181                	srli	a1,a1,0x20
    80001e2c:	6928                	ld	a0,80(a0)
    80001e2e:	fffff097          	auipc	ra,0xfffff
    80001e32:	654080e7          	jalr	1620(ra) # 80001482 <uvmdealloc>
    80001e36:	0005079b          	sext.w	a5,a0
    80001e3a:	bf45                	j	80001dea <growproc+0x26>

0000000080001e3c <fork>:
{
    80001e3c:	7139                	addi	sp,sp,-64
    80001e3e:	fc06                	sd	ra,56(sp)
    80001e40:	f822                	sd	s0,48(sp)
    80001e42:	f426                	sd	s1,40(sp)
    80001e44:	f04a                	sd	s2,32(sp)
    80001e46:	ec4e                	sd	s3,24(sp)
    80001e48:	e852                	sd	s4,16(sp)
    80001e4a:	e456                	sd	s5,8(sp)
    80001e4c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001e4e:	00000097          	auipc	ra,0x0
    80001e52:	bda080e7          	jalr	-1062(ra) # 80001a28 <myproc>
    80001e56:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e58:	00000097          	auipc	ra,0x0
    80001e5c:	dfc080e7          	jalr	-516(ra) # 80001c54 <allocproc>
    80001e60:	c17d                	beqz	a0,80001f46 <fork+0x10a>
    80001e62:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e64:	048ab603          	ld	a2,72(s5)
    80001e68:	692c                	ld	a1,80(a0)
    80001e6a:	050ab503          	ld	a0,80(s5)
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	7ac080e7          	jalr	1964(ra) # 8000161a <uvmcopy>
    80001e76:	04054a63          	bltz	a0,80001eca <fork+0x8e>
  np->sz = p->sz;
    80001e7a:	048ab783          	ld	a5,72(s5)
    80001e7e:	04fa3423          	sd	a5,72(s4)
  np->parent = p;
    80001e82:	035a3023          	sd	s5,32(s4)
  *(np->trapframe) = *(p->trapframe);
    80001e86:	058ab683          	ld	a3,88(s5)
    80001e8a:	87b6                	mv	a5,a3
    80001e8c:	058a3703          	ld	a4,88(s4)
    80001e90:	12068693          	addi	a3,a3,288
    80001e94:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001e98:	6788                	ld	a0,8(a5)
    80001e9a:	6b8c                	ld	a1,16(a5)
    80001e9c:	6f90                	ld	a2,24(a5)
    80001e9e:	01073023          	sd	a6,0(a4)
    80001ea2:	e708                	sd	a0,8(a4)
    80001ea4:	eb0c                	sd	a1,16(a4)
    80001ea6:	ef10                	sd	a2,24(a4)
    80001ea8:	02078793          	addi	a5,a5,32
    80001eac:	02070713          	addi	a4,a4,32
    80001eb0:	fed792e3          	bne	a5,a3,80001e94 <fork+0x58>
  np->trapframe->a0 = 0;
    80001eb4:	058a3783          	ld	a5,88(s4)
    80001eb8:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ebc:	0d0a8493          	addi	s1,s5,208
    80001ec0:	0d0a0913          	addi	s2,s4,208
    80001ec4:	150a8993          	addi	s3,s5,336
    80001ec8:	a00d                	j	80001eea <fork+0xae>
    freeproc(np);
    80001eca:	8552                	mv	a0,s4
    80001ecc:	00000097          	auipc	ra,0x0
    80001ed0:	d0e080e7          	jalr	-754(ra) # 80001bda <freeproc>
    release(&np->lock);
    80001ed4:	8552                	mv	a0,s4
    80001ed6:	fffff097          	auipc	ra,0xfffff
    80001eda:	e3a080e7          	jalr	-454(ra) # 80000d10 <release>
    return -1;
    80001ede:	54fd                	li	s1,-1
    80001ee0:	a889                	j	80001f32 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
    80001ee2:	04a1                	addi	s1,s1,8
    80001ee4:	0921                	addi	s2,s2,8
    80001ee6:	01348b63          	beq	s1,s3,80001efc <fork+0xc0>
    if(p->ofile[i])
    80001eea:	6088                	ld	a0,0(s1)
    80001eec:	d97d                	beqz	a0,80001ee2 <fork+0xa6>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eee:	00002097          	auipc	ra,0x2
    80001ef2:	744080e7          	jalr	1860(ra) # 80004632 <filedup>
    80001ef6:	00a93023          	sd	a0,0(s2)
    80001efa:	b7e5                	j	80001ee2 <fork+0xa6>
  np->cwd = idup(p->cwd);
    80001efc:	150ab503          	ld	a0,336(s5)
    80001f00:	00002097          	auipc	ra,0x2
    80001f04:	8b2080e7          	jalr	-1870(ra) # 800037b2 <idup>
    80001f08:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f0c:	4641                	li	a2,16
    80001f0e:	158a8593          	addi	a1,s5,344
    80001f12:	158a0513          	addi	a0,s4,344
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	f94080e7          	jalr	-108(ra) # 80000eaa <safestrcpy>
  pid = np->pid;
    80001f1e:	038a2483          	lw	s1,56(s4)
  np->state = RUNNABLE;
    80001f22:	4789                	li	a5,2
    80001f24:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001f28:	8552                	mv	a0,s4
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	de6080e7          	jalr	-538(ra) # 80000d10 <release>
}
    80001f32:	8526                	mv	a0,s1
    80001f34:	70e2                	ld	ra,56(sp)
    80001f36:	7442                	ld	s0,48(sp)
    80001f38:	74a2                	ld	s1,40(sp)
    80001f3a:	7902                	ld	s2,32(sp)
    80001f3c:	69e2                	ld	s3,24(sp)
    80001f3e:	6a42                	ld	s4,16(sp)
    80001f40:	6aa2                	ld	s5,8(sp)
    80001f42:	6121                	addi	sp,sp,64
    80001f44:	8082                	ret
    return -1;
    80001f46:	54fd                	li	s1,-1
    80001f48:	b7ed                	j	80001f32 <fork+0xf6>

0000000080001f4a <reparent>:
{
    80001f4a:	7179                	addi	sp,sp,-48
    80001f4c:	f406                	sd	ra,40(sp)
    80001f4e:	f022                	sd	s0,32(sp)
    80001f50:	ec26                	sd	s1,24(sp)
    80001f52:	e84a                	sd	s2,16(sp)
    80001f54:	e44e                	sd	s3,8(sp)
    80001f56:	e052                	sd	s4,0(sp)
    80001f58:	1800                	addi	s0,sp,48
    80001f5a:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f5c:	00010497          	auipc	s1,0x10
    80001f60:	e0c48493          	addi	s1,s1,-500 # 80011d68 <proc>
      pp->parent = initproc;
    80001f64:	00007a17          	auipc	s4,0x7
    80001f68:	0b4a0a13          	addi	s4,s4,180 # 80009018 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001f6c:	00016997          	auipc	s3,0x16
    80001f70:	1fc98993          	addi	s3,s3,508 # 80018168 <tickslock>
    80001f74:	a029                	j	80001f7e <reparent+0x34>
    80001f76:	19048493          	addi	s1,s1,400
    80001f7a:	03348363          	beq	s1,s3,80001fa0 <reparent+0x56>
    if(pp->parent == p){
    80001f7e:	709c                	ld	a5,32(s1)
    80001f80:	ff279be3          	bne	a5,s2,80001f76 <reparent+0x2c>
      acquire(&pp->lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	cd6080e7          	jalr	-810(ra) # 80000c5c <acquire>
      pp->parent = initproc;
    80001f8e:	000a3783          	ld	a5,0(s4)
    80001f92:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    80001f94:	8526                	mv	a0,s1
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	d7a080e7          	jalr	-646(ra) # 80000d10 <release>
    80001f9e:	bfe1                	j	80001f76 <reparent+0x2c>
}
    80001fa0:	70a2                	ld	ra,40(sp)
    80001fa2:	7402                	ld	s0,32(sp)
    80001fa4:	64e2                	ld	s1,24(sp)
    80001fa6:	6942                	ld	s2,16(sp)
    80001fa8:	69a2                	ld	s3,8(sp)
    80001faa:	6a02                	ld	s4,0(sp)
    80001fac:	6145                	addi	sp,sp,48
    80001fae:	8082                	ret

0000000080001fb0 <scheduler>:
{
    80001fb0:	715d                	addi	sp,sp,-80
    80001fb2:	e486                	sd	ra,72(sp)
    80001fb4:	e0a2                	sd	s0,64(sp)
    80001fb6:	fc26                	sd	s1,56(sp)
    80001fb8:	f84a                	sd	s2,48(sp)
    80001fba:	f44e                	sd	s3,40(sp)
    80001fbc:	f052                	sd	s4,32(sp)
    80001fbe:	ec56                	sd	s5,24(sp)
    80001fc0:	e85a                	sd	s6,16(sp)
    80001fc2:	e45e                	sd	s7,8(sp)
    80001fc4:	e062                	sd	s8,0(sp)
    80001fc6:	0880                	addi	s0,sp,80
    80001fc8:	8792                	mv	a5,tp
  int id = r_tp();
    80001fca:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fcc:	00779b13          	slli	s6,a5,0x7
    80001fd0:	00010717          	auipc	a4,0x10
    80001fd4:	98070713          	addi	a4,a4,-1664 # 80011950 <pid_lock>
    80001fd8:	975a                	add	a4,a4,s6
    80001fda:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001fde:	00010717          	auipc	a4,0x10
    80001fe2:	99270713          	addi	a4,a4,-1646 # 80011970 <cpus+0x8>
    80001fe6:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001fe8:	4c0d                	li	s8,3
        c->proc = p;
    80001fea:	079e                	slli	a5,a5,0x7
    80001fec:	00010a17          	auipc	s4,0x10
    80001ff0:	964a0a13          	addi	s4,s4,-1692 # 80011950 <pid_lock>
    80001ff4:	9a3e                	add	s4,s4,a5
        found = 1;
    80001ff6:	4b85                	li	s7,1
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ff8:	00016997          	auipc	s3,0x16
    80001ffc:	17098993          	addi	s3,s3,368 # 80018168 <tickslock>
    80002000:	a899                	j	80002056 <scheduler+0xa6>
      release(&p->lock);
    80002002:	8526                	mv	a0,s1
    80002004:	fffff097          	auipc	ra,0xfffff
    80002008:	d0c080e7          	jalr	-756(ra) # 80000d10 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000200c:	19048493          	addi	s1,s1,400
    80002010:	03348963          	beq	s1,s3,80002042 <scheduler+0x92>
      acquire(&p->lock);
    80002014:	8526                	mv	a0,s1
    80002016:	fffff097          	auipc	ra,0xfffff
    8000201a:	c46080e7          	jalr	-954(ra) # 80000c5c <acquire>
      if(p->state == RUNNABLE) {
    8000201e:	4c9c                	lw	a5,24(s1)
    80002020:	ff2791e3          	bne	a5,s2,80002002 <scheduler+0x52>
        p->state = RUNNING;
    80002024:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80002028:	009a3c23          	sd	s1,24(s4)
        swtch(&c->context, &p->context);
    8000202c:	06048593          	addi	a1,s1,96
    80002030:	855a                	mv	a0,s6
    80002032:	00000097          	auipc	ra,0x0
    80002036:	610080e7          	jalr	1552(ra) # 80002642 <swtch>
        c->proc = 0;
    8000203a:	000a3c23          	sd	zero,24(s4)
        found = 1;
    8000203e:	8ade                	mv	s5,s7
    80002040:	b7c9                	j	80002002 <scheduler+0x52>
    if(found == 0) {
    80002042:	000a9a63          	bnez	s5,80002056 <scheduler+0xa6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002046:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000204a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000204e:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80002052:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002056:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000205a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000205e:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002062:	4a81                	li	s5,0
    for(p = proc; p < &proc[NPROC]; p++) {
    80002064:	00010497          	auipc	s1,0x10
    80002068:	d0448493          	addi	s1,s1,-764 # 80011d68 <proc>
      if(p->state == RUNNABLE) {
    8000206c:	4909                	li	s2,2
    8000206e:	b75d                	j	80002014 <scheduler+0x64>

0000000080002070 <sched>:
{
    80002070:	7179                	addi	sp,sp,-48
    80002072:	f406                	sd	ra,40(sp)
    80002074:	f022                	sd	s0,32(sp)
    80002076:	ec26                	sd	s1,24(sp)
    80002078:	e84a                	sd	s2,16(sp)
    8000207a:	e44e                	sd	s3,8(sp)
    8000207c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000207e:	00000097          	auipc	ra,0x0
    80002082:	9aa080e7          	jalr	-1622(ra) # 80001a28 <myproc>
    80002086:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002088:	fffff097          	auipc	ra,0xfffff
    8000208c:	b5a080e7          	jalr	-1190(ra) # 80000be2 <holding>
    80002090:	c93d                	beqz	a0,80002106 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002092:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002094:	2781                	sext.w	a5,a5
    80002096:	079e                	slli	a5,a5,0x7
    80002098:	00010717          	auipc	a4,0x10
    8000209c:	8b870713          	addi	a4,a4,-1864 # 80011950 <pid_lock>
    800020a0:	97ba                	add	a5,a5,a4
    800020a2:	0907a703          	lw	a4,144(a5)
    800020a6:	4785                	li	a5,1
    800020a8:	06f71763          	bne	a4,a5,80002116 <sched+0xa6>
  if(p->state == RUNNING)
    800020ac:	4c98                	lw	a4,24(s1)
    800020ae:	478d                	li	a5,3
    800020b0:	06f70b63          	beq	a4,a5,80002126 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020b4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020b8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020ba:	efb5                	bnez	a5,80002136 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020bc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020be:	00010917          	auipc	s2,0x10
    800020c2:	89290913          	addi	s2,s2,-1902 # 80011950 <pid_lock>
    800020c6:	2781                	sext.w	a5,a5
    800020c8:	079e                	slli	a5,a5,0x7
    800020ca:	97ca                	add	a5,a5,s2
    800020cc:	0947a983          	lw	s3,148(a5)
    800020d0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020d2:	2781                	sext.w	a5,a5
    800020d4:	079e                	slli	a5,a5,0x7
    800020d6:	00010597          	auipc	a1,0x10
    800020da:	89a58593          	addi	a1,a1,-1894 # 80011970 <cpus+0x8>
    800020de:	95be                	add	a1,a1,a5
    800020e0:	06048513          	addi	a0,s1,96
    800020e4:	00000097          	auipc	ra,0x0
    800020e8:	55e080e7          	jalr	1374(ra) # 80002642 <swtch>
    800020ec:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020ee:	2781                	sext.w	a5,a5
    800020f0:	079e                	slli	a5,a5,0x7
    800020f2:	993e                	add	s2,s2,a5
    800020f4:	09392a23          	sw	s3,148(s2)
}
    800020f8:	70a2                	ld	ra,40(sp)
    800020fa:	7402                	ld	s0,32(sp)
    800020fc:	64e2                	ld	s1,24(sp)
    800020fe:	6942                	ld	s2,16(sp)
    80002100:	69a2                	ld	s3,8(sp)
    80002102:	6145                	addi	sp,sp,48
    80002104:	8082                	ret
    panic("sched p->lock");
    80002106:	00006517          	auipc	a0,0x6
    8000210a:	10250513          	addi	a0,a0,258 # 80008208 <digits+0x1c0>
    8000210e:	ffffe097          	auipc	ra,0xffffe
    80002112:	438080e7          	jalr	1080(ra) # 80000546 <panic>
    panic("sched locks");
    80002116:	00006517          	auipc	a0,0x6
    8000211a:	10250513          	addi	a0,a0,258 # 80008218 <digits+0x1d0>
    8000211e:	ffffe097          	auipc	ra,0xffffe
    80002122:	428080e7          	jalr	1064(ra) # 80000546 <panic>
    panic("sched running");
    80002126:	00006517          	auipc	a0,0x6
    8000212a:	10250513          	addi	a0,a0,258 # 80008228 <digits+0x1e0>
    8000212e:	ffffe097          	auipc	ra,0xffffe
    80002132:	418080e7          	jalr	1048(ra) # 80000546 <panic>
    panic("sched interruptible");
    80002136:	00006517          	auipc	a0,0x6
    8000213a:	10250513          	addi	a0,a0,258 # 80008238 <digits+0x1f0>
    8000213e:	ffffe097          	auipc	ra,0xffffe
    80002142:	408080e7          	jalr	1032(ra) # 80000546 <panic>

0000000080002146 <exit>:
{
    80002146:	7179                	addi	sp,sp,-48
    80002148:	f406                	sd	ra,40(sp)
    8000214a:	f022                	sd	s0,32(sp)
    8000214c:	ec26                	sd	s1,24(sp)
    8000214e:	e84a                	sd	s2,16(sp)
    80002150:	e44e                	sd	s3,8(sp)
    80002152:	e052                	sd	s4,0(sp)
    80002154:	1800                	addi	s0,sp,48
    80002156:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002158:	00000097          	auipc	ra,0x0
    8000215c:	8d0080e7          	jalr	-1840(ra) # 80001a28 <myproc>
    80002160:	89aa                	mv	s3,a0
  if(p == initproc)
    80002162:	00007797          	auipc	a5,0x7
    80002166:	eb67b783          	ld	a5,-330(a5) # 80009018 <initproc>
    8000216a:	0d050493          	addi	s1,a0,208
    8000216e:	15050913          	addi	s2,a0,336
    80002172:	02a79363          	bne	a5,a0,80002198 <exit+0x52>
    panic("init exiting");
    80002176:	00006517          	auipc	a0,0x6
    8000217a:	0da50513          	addi	a0,a0,218 # 80008250 <digits+0x208>
    8000217e:	ffffe097          	auipc	ra,0xffffe
    80002182:	3c8080e7          	jalr	968(ra) # 80000546 <panic>
      fileclose(f);
    80002186:	00002097          	auipc	ra,0x2
    8000218a:	4fe080e7          	jalr	1278(ra) # 80004684 <fileclose>
      p->ofile[fd] = 0;
    8000218e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002192:	04a1                	addi	s1,s1,8
    80002194:	01248563          	beq	s1,s2,8000219e <exit+0x58>
    if(p->ofile[fd]){
    80002198:	6088                	ld	a0,0(s1)
    8000219a:	f575                	bnez	a0,80002186 <exit+0x40>
    8000219c:	bfdd                	j	80002192 <exit+0x4c>
  begin_op();
    8000219e:	00002097          	auipc	ra,0x2
    800021a2:	018080e7          	jalr	24(ra) # 800041b6 <begin_op>
  iput(p->cwd);
    800021a6:	1509b503          	ld	a0,336(s3)
    800021aa:	00002097          	auipc	ra,0x2
    800021ae:	800080e7          	jalr	-2048(ra) # 800039aa <iput>
  end_op();
    800021b2:	00002097          	auipc	ra,0x2
    800021b6:	082080e7          	jalr	130(ra) # 80004234 <end_op>
  p->cwd = 0;
    800021ba:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    800021be:	00007497          	auipc	s1,0x7
    800021c2:	e5a48493          	addi	s1,s1,-422 # 80009018 <initproc>
    800021c6:	6088                	ld	a0,0(s1)
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	a94080e7          	jalr	-1388(ra) # 80000c5c <acquire>
  wakeup1(initproc);
    800021d0:	6088                	ld	a0,0(s1)
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	716080e7          	jalr	1814(ra) # 800018e8 <wakeup1>
  release(&initproc->lock);
    800021da:	6088                	ld	a0,0(s1)
    800021dc:	fffff097          	auipc	ra,0xfffff
    800021e0:	b34080e7          	jalr	-1228(ra) # 80000d10 <release>
  acquire(&p->lock);
    800021e4:	854e                	mv	a0,s3
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	a76080e7          	jalr	-1418(ra) # 80000c5c <acquire>
  struct proc *original_parent = p->parent;
    800021ee:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    800021f2:	854e                	mv	a0,s3
    800021f4:	fffff097          	auipc	ra,0xfffff
    800021f8:	b1c080e7          	jalr	-1252(ra) # 80000d10 <release>
  acquire(&original_parent->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	fffff097          	auipc	ra,0xfffff
    80002202:	a5e080e7          	jalr	-1442(ra) # 80000c5c <acquire>
  acquire(&p->lock);
    80002206:	854e                	mv	a0,s3
    80002208:	fffff097          	auipc	ra,0xfffff
    8000220c:	a54080e7          	jalr	-1452(ra) # 80000c5c <acquire>
  reparent(p);
    80002210:	854e                	mv	a0,s3
    80002212:	00000097          	auipc	ra,0x0
    80002216:	d38080e7          	jalr	-712(ra) # 80001f4a <reparent>
  wakeup1(original_parent);
    8000221a:	8526                	mv	a0,s1
    8000221c:	fffff097          	auipc	ra,0xfffff
    80002220:	6cc080e7          	jalr	1740(ra) # 800018e8 <wakeup1>
  p->xstate = status;
    80002224:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    80002228:	4791                	li	a5,4
    8000222a:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    8000222e:	8526                	mv	a0,s1
    80002230:	fffff097          	auipc	ra,0xfffff
    80002234:	ae0080e7          	jalr	-1312(ra) # 80000d10 <release>
  sched();
    80002238:	00000097          	auipc	ra,0x0
    8000223c:	e38080e7          	jalr	-456(ra) # 80002070 <sched>
  panic("zombie exit");
    80002240:	00006517          	auipc	a0,0x6
    80002244:	02050513          	addi	a0,a0,32 # 80008260 <digits+0x218>
    80002248:	ffffe097          	auipc	ra,0xffffe
    8000224c:	2fe080e7          	jalr	766(ra) # 80000546 <panic>

0000000080002250 <yield>:
{
    80002250:	1101                	addi	sp,sp,-32
    80002252:	ec06                	sd	ra,24(sp)
    80002254:	e822                	sd	s0,16(sp)
    80002256:	e426                	sd	s1,8(sp)
    80002258:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	7ce080e7          	jalr	1998(ra) # 80001a28 <myproc>
    80002262:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002264:	fffff097          	auipc	ra,0xfffff
    80002268:	9f8080e7          	jalr	-1544(ra) # 80000c5c <acquire>
  p->state = RUNNABLE;
    8000226c:	4789                	li	a5,2
    8000226e:	cc9c                	sw	a5,24(s1)
  sched();
    80002270:	00000097          	auipc	ra,0x0
    80002274:	e00080e7          	jalr	-512(ra) # 80002070 <sched>
  release(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	a96080e7          	jalr	-1386(ra) # 80000d10 <release>
}
    80002282:	60e2                	ld	ra,24(sp)
    80002284:	6442                	ld	s0,16(sp)
    80002286:	64a2                	ld	s1,8(sp)
    80002288:	6105                	addi	sp,sp,32
    8000228a:	8082                	ret

000000008000228c <sleep>:
{
    8000228c:	7179                	addi	sp,sp,-48
    8000228e:	f406                	sd	ra,40(sp)
    80002290:	f022                	sd	s0,32(sp)
    80002292:	ec26                	sd	s1,24(sp)
    80002294:	e84a                	sd	s2,16(sp)
    80002296:	e44e                	sd	s3,8(sp)
    80002298:	1800                	addi	s0,sp,48
    8000229a:	89aa                	mv	s3,a0
    8000229c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000229e:	fffff097          	auipc	ra,0xfffff
    800022a2:	78a080e7          	jalr	1930(ra) # 80001a28 <myproc>
    800022a6:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    800022a8:	05250663          	beq	a0,s2,800022f4 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9b0080e7          	jalr	-1616(ra) # 80000c5c <acquire>
    release(lk);
    800022b4:	854a                	mv	a0,s2
    800022b6:	fffff097          	auipc	ra,0xfffff
    800022ba:	a5a080e7          	jalr	-1446(ra) # 80000d10 <release>
  p->chan = chan;
    800022be:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    800022c2:	4785                	li	a5,1
    800022c4:	cc9c                	sw	a5,24(s1)
  sched();
    800022c6:	00000097          	auipc	ra,0x0
    800022ca:	daa080e7          	jalr	-598(ra) # 80002070 <sched>
  p->chan = 0;
    800022ce:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    800022d2:	8526                	mv	a0,s1
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	a3c080e7          	jalr	-1476(ra) # 80000d10 <release>
    acquire(lk);
    800022dc:	854a                	mv	a0,s2
    800022de:	fffff097          	auipc	ra,0xfffff
    800022e2:	97e080e7          	jalr	-1666(ra) # 80000c5c <acquire>
}
    800022e6:	70a2                	ld	ra,40(sp)
    800022e8:	7402                	ld	s0,32(sp)
    800022ea:	64e2                	ld	s1,24(sp)
    800022ec:	6942                	ld	s2,16(sp)
    800022ee:	69a2                	ld	s3,8(sp)
    800022f0:	6145                	addi	sp,sp,48
    800022f2:	8082                	ret
  p->chan = chan;
    800022f4:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    800022f8:	4785                	li	a5,1
    800022fa:	cd1c                	sw	a5,24(a0)
  sched();
    800022fc:	00000097          	auipc	ra,0x0
    80002300:	d74080e7          	jalr	-652(ra) # 80002070 <sched>
  p->chan = 0;
    80002304:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80002308:	bff9                	j	800022e6 <sleep+0x5a>

000000008000230a <wait>:
{
    8000230a:	715d                	addi	sp,sp,-80
    8000230c:	e486                	sd	ra,72(sp)
    8000230e:	e0a2                	sd	s0,64(sp)
    80002310:	fc26                	sd	s1,56(sp)
    80002312:	f84a                	sd	s2,48(sp)
    80002314:	f44e                	sd	s3,40(sp)
    80002316:	f052                	sd	s4,32(sp)
    80002318:	ec56                	sd	s5,24(sp)
    8000231a:	e85a                	sd	s6,16(sp)
    8000231c:	e45e                	sd	s7,8(sp)
    8000231e:	0880                	addi	s0,sp,80
    80002320:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002322:	fffff097          	auipc	ra,0xfffff
    80002326:	706080e7          	jalr	1798(ra) # 80001a28 <myproc>
    8000232a:	892a                	mv	s2,a0
  acquire(&p->lock);
    8000232c:	fffff097          	auipc	ra,0xfffff
    80002330:	930080e7          	jalr	-1744(ra) # 80000c5c <acquire>
    havekids = 0;
    80002334:	4b81                	li	s7,0
        if(np->state == ZOMBIE){
    80002336:	4a11                	li	s4,4
        havekids = 1;
    80002338:	4a85                	li	s5,1
    for(np = proc; np < &proc[NPROC]; np++){
    8000233a:	00016997          	auipc	s3,0x16
    8000233e:	e2e98993          	addi	s3,s3,-466 # 80018168 <tickslock>
    havekids = 0;
    80002342:	875e                	mv	a4,s7
    for(np = proc; np < &proc[NPROC]; np++){
    80002344:	00010497          	auipc	s1,0x10
    80002348:	a2448493          	addi	s1,s1,-1500 # 80011d68 <proc>
    8000234c:	a08d                	j	800023ae <wait+0xa4>
          pid = np->pid;
    8000234e:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    80002352:	000b0e63          	beqz	s6,8000236e <wait+0x64>
    80002356:	4691                	li	a3,4
    80002358:	03448613          	addi	a2,s1,52
    8000235c:	85da                	mv	a1,s6
    8000235e:	05093503          	ld	a0,80(s2)
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	3bc080e7          	jalr	956(ra) # 8000171e <copyout>
    8000236a:	02054263          	bltz	a0,8000238e <wait+0x84>
          freeproc(np);
    8000236e:	8526                	mv	a0,s1
    80002370:	00000097          	auipc	ra,0x0
    80002374:	86a080e7          	jalr	-1942(ra) # 80001bda <freeproc>
          release(&np->lock);
    80002378:	8526                	mv	a0,s1
    8000237a:	fffff097          	auipc	ra,0xfffff
    8000237e:	996080e7          	jalr	-1642(ra) # 80000d10 <release>
          release(&p->lock);
    80002382:	854a                	mv	a0,s2
    80002384:	fffff097          	auipc	ra,0xfffff
    80002388:	98c080e7          	jalr	-1652(ra) # 80000d10 <release>
          return pid;
    8000238c:	a8a9                	j	800023e6 <wait+0xdc>
            release(&np->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	fffff097          	auipc	ra,0xfffff
    80002394:	980080e7          	jalr	-1664(ra) # 80000d10 <release>
            release(&p->lock);
    80002398:	854a                	mv	a0,s2
    8000239a:	fffff097          	auipc	ra,0xfffff
    8000239e:	976080e7          	jalr	-1674(ra) # 80000d10 <release>
            return -1;
    800023a2:	59fd                	li	s3,-1
    800023a4:	a089                	j	800023e6 <wait+0xdc>
    for(np = proc; np < &proc[NPROC]; np++){
    800023a6:	19048493          	addi	s1,s1,400
    800023aa:	03348463          	beq	s1,s3,800023d2 <wait+0xc8>
      if(np->parent == p){
    800023ae:	709c                	ld	a5,32(s1)
    800023b0:	ff279be3          	bne	a5,s2,800023a6 <wait+0x9c>
        acquire(&np->lock);
    800023b4:	8526                	mv	a0,s1
    800023b6:	fffff097          	auipc	ra,0xfffff
    800023ba:	8a6080e7          	jalr	-1882(ra) # 80000c5c <acquire>
        if(np->state == ZOMBIE){
    800023be:	4c9c                	lw	a5,24(s1)
    800023c0:	f94787e3          	beq	a5,s4,8000234e <wait+0x44>
        release(&np->lock);
    800023c4:	8526                	mv	a0,s1
    800023c6:	fffff097          	auipc	ra,0xfffff
    800023ca:	94a080e7          	jalr	-1718(ra) # 80000d10 <release>
        havekids = 1;
    800023ce:	8756                	mv	a4,s5
    800023d0:	bfd9                	j	800023a6 <wait+0x9c>
    if(!havekids || p->killed){
    800023d2:	c701                	beqz	a4,800023da <wait+0xd0>
    800023d4:	03092783          	lw	a5,48(s2)
    800023d8:	c39d                	beqz	a5,800023fe <wait+0xf4>
      release(&p->lock);
    800023da:	854a                	mv	a0,s2
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	934080e7          	jalr	-1740(ra) # 80000d10 <release>
      return -1;
    800023e4:	59fd                	li	s3,-1
}
    800023e6:	854e                	mv	a0,s3
    800023e8:	60a6                	ld	ra,72(sp)
    800023ea:	6406                	ld	s0,64(sp)
    800023ec:	74e2                	ld	s1,56(sp)
    800023ee:	7942                	ld	s2,48(sp)
    800023f0:	79a2                	ld	s3,40(sp)
    800023f2:	7a02                	ld	s4,32(sp)
    800023f4:	6ae2                	ld	s5,24(sp)
    800023f6:	6b42                	ld	s6,16(sp)
    800023f8:	6ba2                	ld	s7,8(sp)
    800023fa:	6161                	addi	sp,sp,80
    800023fc:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    800023fe:	85ca                	mv	a1,s2
    80002400:	854a                	mv	a0,s2
    80002402:	00000097          	auipc	ra,0x0
    80002406:	e8a080e7          	jalr	-374(ra) # 8000228c <sleep>
    havekids = 0;
    8000240a:	bf25                	j	80002342 <wait+0x38>

000000008000240c <wakeup>:
{
    8000240c:	7139                	addi	sp,sp,-64
    8000240e:	fc06                	sd	ra,56(sp)
    80002410:	f822                	sd	s0,48(sp)
    80002412:	f426                	sd	s1,40(sp)
    80002414:	f04a                	sd	s2,32(sp)
    80002416:	ec4e                	sd	s3,24(sp)
    80002418:	e852                	sd	s4,16(sp)
    8000241a:	e456                	sd	s5,8(sp)
    8000241c:	0080                	addi	s0,sp,64
    8000241e:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80002420:	00010497          	auipc	s1,0x10
    80002424:	94848493          	addi	s1,s1,-1720 # 80011d68 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    80002428:	4985                	li	s3,1
      p->state = RUNNABLE;
    8000242a:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    8000242c:	00016917          	auipc	s2,0x16
    80002430:	d3c90913          	addi	s2,s2,-708 # 80018168 <tickslock>
    80002434:	a811                	j	80002448 <wakeup+0x3c>
    release(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	8d8080e7          	jalr	-1832(ra) # 80000d10 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002440:	19048493          	addi	s1,s1,400
    80002444:	03248063          	beq	s1,s2,80002464 <wakeup+0x58>
    acquire(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	812080e7          	jalr	-2030(ra) # 80000c5c <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    80002452:	4c9c                	lw	a5,24(s1)
    80002454:	ff3791e3          	bne	a5,s3,80002436 <wakeup+0x2a>
    80002458:	749c                	ld	a5,40(s1)
    8000245a:	fd479ee3          	bne	a5,s4,80002436 <wakeup+0x2a>
      p->state = RUNNABLE;
    8000245e:	0154ac23          	sw	s5,24(s1)
    80002462:	bfd1                	j	80002436 <wakeup+0x2a>
}
    80002464:	70e2                	ld	ra,56(sp)
    80002466:	7442                	ld	s0,48(sp)
    80002468:	74a2                	ld	s1,40(sp)
    8000246a:	7902                	ld	s2,32(sp)
    8000246c:	69e2                	ld	s3,24(sp)
    8000246e:	6a42                	ld	s4,16(sp)
    80002470:	6aa2                	ld	s5,8(sp)
    80002472:	6121                	addi	sp,sp,64
    80002474:	8082                	ret

0000000080002476 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	1800                	addi	s0,sp,48
    80002484:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002486:	00010497          	auipc	s1,0x10
    8000248a:	8e248493          	addi	s1,s1,-1822 # 80011d68 <proc>
    8000248e:	00016997          	auipc	s3,0x16
    80002492:	cda98993          	addi	s3,s3,-806 # 80018168 <tickslock>
    acquire(&p->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7c4080e7          	jalr	1988(ra) # 80000c5c <acquire>
    if(p->pid == pid){
    800024a0:	5c9c                	lw	a5,56(s1)
    800024a2:	01278d63          	beq	a5,s2,800024bc <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800024a6:	8526                	mv	a0,s1
    800024a8:	fffff097          	auipc	ra,0xfffff
    800024ac:	868080e7          	jalr	-1944(ra) # 80000d10 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800024b0:	19048493          	addi	s1,s1,400
    800024b4:	ff3491e3          	bne	s1,s3,80002496 <kill+0x20>
  }
  return -1;
    800024b8:	557d                	li	a0,-1
    800024ba:	a821                	j	800024d2 <kill+0x5c>
      p->killed = 1;
    800024bc:	4785                	li	a5,1
    800024be:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    800024c0:	4c98                	lw	a4,24(s1)
    800024c2:	00f70f63          	beq	a4,a5,800024e0 <kill+0x6a>
      release(&p->lock);
    800024c6:	8526                	mv	a0,s1
    800024c8:	fffff097          	auipc	ra,0xfffff
    800024cc:	848080e7          	jalr	-1976(ra) # 80000d10 <release>
      return 0;
    800024d0:	4501                	li	a0,0
}
    800024d2:	70a2                	ld	ra,40(sp)
    800024d4:	7402                	ld	s0,32(sp)
    800024d6:	64e2                	ld	s1,24(sp)
    800024d8:	6942                	ld	s2,16(sp)
    800024da:	69a2                	ld	s3,8(sp)
    800024dc:	6145                	addi	sp,sp,48
    800024de:	8082                	ret
        p->state = RUNNABLE;
    800024e0:	4789                	li	a5,2
    800024e2:	cc9c                	sw	a5,24(s1)
    800024e4:	b7cd                	j	800024c6 <kill+0x50>

00000000800024e6 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800024e6:	7179                	addi	sp,sp,-48
    800024e8:	f406                	sd	ra,40(sp)
    800024ea:	f022                	sd	s0,32(sp)
    800024ec:	ec26                	sd	s1,24(sp)
    800024ee:	e84a                	sd	s2,16(sp)
    800024f0:	e44e                	sd	s3,8(sp)
    800024f2:	e052                	sd	s4,0(sp)
    800024f4:	1800                	addi	s0,sp,48
    800024f6:	84aa                	mv	s1,a0
    800024f8:	892e                	mv	s2,a1
    800024fa:	89b2                	mv	s3,a2
    800024fc:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024fe:	fffff097          	auipc	ra,0xfffff
    80002502:	52a080e7          	jalr	1322(ra) # 80001a28 <myproc>
  if(user_dst){
    80002506:	c08d                	beqz	s1,80002528 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002508:	86d2                	mv	a3,s4
    8000250a:	864e                	mv	a2,s3
    8000250c:	85ca                	mv	a1,s2
    8000250e:	6928                	ld	a0,80(a0)
    80002510:	fffff097          	auipc	ra,0xfffff
    80002514:	20e080e7          	jalr	526(ra) # 8000171e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002518:	70a2                	ld	ra,40(sp)
    8000251a:	7402                	ld	s0,32(sp)
    8000251c:	64e2                	ld	s1,24(sp)
    8000251e:	6942                	ld	s2,16(sp)
    80002520:	69a2                	ld	s3,8(sp)
    80002522:	6a02                	ld	s4,0(sp)
    80002524:	6145                	addi	sp,sp,48
    80002526:	8082                	ret
    memmove((char *)dst, src, len);
    80002528:	000a061b          	sext.w	a2,s4
    8000252c:	85ce                	mv	a1,s3
    8000252e:	854a                	mv	a0,s2
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	884080e7          	jalr	-1916(ra) # 80000db4 <memmove>
    return 0;
    80002538:	8526                	mv	a0,s1
    8000253a:	bff9                	j	80002518 <either_copyout+0x32>

000000008000253c <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000253c:	7179                	addi	sp,sp,-48
    8000253e:	f406                	sd	ra,40(sp)
    80002540:	f022                	sd	s0,32(sp)
    80002542:	ec26                	sd	s1,24(sp)
    80002544:	e84a                	sd	s2,16(sp)
    80002546:	e44e                	sd	s3,8(sp)
    80002548:	e052                	sd	s4,0(sp)
    8000254a:	1800                	addi	s0,sp,48
    8000254c:	892a                	mv	s2,a0
    8000254e:	84ae                	mv	s1,a1
    80002550:	89b2                	mv	s3,a2
    80002552:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002554:	fffff097          	auipc	ra,0xfffff
    80002558:	4d4080e7          	jalr	1236(ra) # 80001a28 <myproc>
  if(user_src){
    8000255c:	c08d                	beqz	s1,8000257e <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000255e:	86d2                	mv	a3,s4
    80002560:	864e                	mv	a2,s3
    80002562:	85ca                	mv	a1,s2
    80002564:	6928                	ld	a0,80(a0)
    80002566:	fffff097          	auipc	ra,0xfffff
    8000256a:	244080e7          	jalr	580(ra) # 800017aa <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000256e:	70a2                	ld	ra,40(sp)
    80002570:	7402                	ld	s0,32(sp)
    80002572:	64e2                	ld	s1,24(sp)
    80002574:	6942                	ld	s2,16(sp)
    80002576:	69a2                	ld	s3,8(sp)
    80002578:	6a02                	ld	s4,0(sp)
    8000257a:	6145                	addi	sp,sp,48
    8000257c:	8082                	ret
    memmove(dst, (char*)src, len);
    8000257e:	000a061b          	sext.w	a2,s4
    80002582:	85ce                	mv	a1,s3
    80002584:	854a                	mv	a0,s2
    80002586:	fffff097          	auipc	ra,0xfffff
    8000258a:	82e080e7          	jalr	-2002(ra) # 80000db4 <memmove>
    return 0;
    8000258e:	8526                	mv	a0,s1
    80002590:	bff9                	j	8000256e <either_copyin+0x32>

0000000080002592 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002592:	715d                	addi	sp,sp,-80
    80002594:	e486                	sd	ra,72(sp)
    80002596:	e0a2                	sd	s0,64(sp)
    80002598:	fc26                	sd	s1,56(sp)
    8000259a:	f84a                	sd	s2,48(sp)
    8000259c:	f44e                	sd	s3,40(sp)
    8000259e:	f052                	sd	s4,32(sp)
    800025a0:	ec56                	sd	s5,24(sp)
    800025a2:	e85a                	sd	s6,16(sp)
    800025a4:	e45e                	sd	s7,8(sp)
    800025a6:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025a8:	00006517          	auipc	a0,0x6
    800025ac:	b2850513          	addi	a0,a0,-1240 # 800080d0 <digits+0x88>
    800025b0:	ffffe097          	auipc	ra,0xffffe
    800025b4:	fe0080e7          	jalr	-32(ra) # 80000590 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025b8:	00010497          	auipc	s1,0x10
    800025bc:	90848493          	addi	s1,s1,-1784 # 80011ec0 <proc+0x158>
    800025c0:	00016917          	auipc	s2,0x16
    800025c4:	d0090913          	addi	s2,s2,-768 # 800182c0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025c8:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    800025ca:	00006997          	auipc	s3,0x6
    800025ce:	ca698993          	addi	s3,s3,-858 # 80008270 <digits+0x228>
    printf("%d %s %s", p->pid, state, p->name);
    800025d2:	00006a97          	auipc	s5,0x6
    800025d6:	ca6a8a93          	addi	s5,s5,-858 # 80008278 <digits+0x230>
    printf("\n");
    800025da:	00006a17          	auipc	s4,0x6
    800025de:	af6a0a13          	addi	s4,s4,-1290 # 800080d0 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025e2:	00006b97          	auipc	s7,0x6
    800025e6:	cceb8b93          	addi	s7,s7,-818 # 800082b0 <states.0>
    800025ea:	a00d                	j	8000260c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800025ec:	ee06a583          	lw	a1,-288(a3)
    800025f0:	8556                	mv	a0,s5
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	f9e080e7          	jalr	-98(ra) # 80000590 <printf>
    printf("\n");
    800025fa:	8552                	mv	a0,s4
    800025fc:	ffffe097          	auipc	ra,0xffffe
    80002600:	f94080e7          	jalr	-108(ra) # 80000590 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002604:	19048493          	addi	s1,s1,400
    80002608:	03248263          	beq	s1,s2,8000262c <procdump+0x9a>
    if(p->state == UNUSED)
    8000260c:	86a6                	mv	a3,s1
    8000260e:	ec04a783          	lw	a5,-320(s1)
    80002612:	dbed                	beqz	a5,80002604 <procdump+0x72>
      state = "???";
    80002614:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002616:	fcfb6be3          	bltu	s6,a5,800025ec <procdump+0x5a>
    8000261a:	02079713          	slli	a4,a5,0x20
    8000261e:	01d75793          	srli	a5,a4,0x1d
    80002622:	97de                	add	a5,a5,s7
    80002624:	6390                	ld	a2,0(a5)
    80002626:	f279                	bnez	a2,800025ec <procdump+0x5a>
      state = "???";
    80002628:	864e                	mv	a2,s3
    8000262a:	b7c9                	j	800025ec <procdump+0x5a>
  }
}
    8000262c:	60a6                	ld	ra,72(sp)
    8000262e:	6406                	ld	s0,64(sp)
    80002630:	74e2                	ld	s1,56(sp)
    80002632:	7942                	ld	s2,48(sp)
    80002634:	79a2                	ld	s3,40(sp)
    80002636:	7a02                	ld	s4,32(sp)
    80002638:	6ae2                	ld	s5,24(sp)
    8000263a:	6b42                	ld	s6,16(sp)
    8000263c:	6ba2                	ld	s7,8(sp)
    8000263e:	6161                	addi	sp,sp,80
    80002640:	8082                	ret

0000000080002642 <swtch>:
    80002642:	00153023          	sd	ra,0(a0)
    80002646:	00253423          	sd	sp,8(a0)
    8000264a:	e900                	sd	s0,16(a0)
    8000264c:	ed04                	sd	s1,24(a0)
    8000264e:	03253023          	sd	s2,32(a0)
    80002652:	03353423          	sd	s3,40(a0)
    80002656:	03453823          	sd	s4,48(a0)
    8000265a:	03553c23          	sd	s5,56(a0)
    8000265e:	05653023          	sd	s6,64(a0)
    80002662:	05753423          	sd	s7,72(a0)
    80002666:	05853823          	sd	s8,80(a0)
    8000266a:	05953c23          	sd	s9,88(a0)
    8000266e:	07a53023          	sd	s10,96(a0)
    80002672:	07b53423          	sd	s11,104(a0)
    80002676:	0005b083          	ld	ra,0(a1)
    8000267a:	0085b103          	ld	sp,8(a1)
    8000267e:	6980                	ld	s0,16(a1)
    80002680:	6d84                	ld	s1,24(a1)
    80002682:	0205b903          	ld	s2,32(a1)
    80002686:	0285b983          	ld	s3,40(a1)
    8000268a:	0305ba03          	ld	s4,48(a1)
    8000268e:	0385ba83          	ld	s5,56(a1)
    80002692:	0405bb03          	ld	s6,64(a1)
    80002696:	0485bb83          	ld	s7,72(a1)
    8000269a:	0505bc03          	ld	s8,80(a1)
    8000269e:	0585bc83          	ld	s9,88(a1)
    800026a2:	0605bd03          	ld	s10,96(a1)
    800026a6:	0685bd83          	ld	s11,104(a1)
    800026aa:	8082                	ret

00000000800026ac <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ac:	1141                	addi	sp,sp,-16
    800026ae:	e406                	sd	ra,8(sp)
    800026b0:	e022                	sd	s0,0(sp)
    800026b2:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800026b4:	00006597          	auipc	a1,0x6
    800026b8:	c2458593          	addi	a1,a1,-988 # 800082d8 <states.0+0x28>
    800026bc:	00016517          	auipc	a0,0x16
    800026c0:	aac50513          	addi	a0,a0,-1364 # 80018168 <tickslock>
    800026c4:	ffffe097          	auipc	ra,0xffffe
    800026c8:	508080e7          	jalr	1288(ra) # 80000bcc <initlock>
}
    800026cc:	60a2                	ld	ra,8(sp)
    800026ce:	6402                	ld	s0,0(sp)
    800026d0:	0141                	addi	sp,sp,16
    800026d2:	8082                	ret

00000000800026d4 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800026d4:	1141                	addi	sp,sp,-16
    800026d6:	e422                	sd	s0,8(sp)
    800026d8:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026da:	00003797          	auipc	a5,0x3
    800026de:	61678793          	addi	a5,a5,1558 # 80005cf0 <kernelvec>
    800026e2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800026e6:	6422                	ld	s0,8(sp)
    800026e8:	0141                	addi	sp,sp,16
    800026ea:	8082                	ret

00000000800026ec <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800026ec:	1141                	addi	sp,sp,-16
    800026ee:	e406                	sd	ra,8(sp)
    800026f0:	e022                	sd	s0,0(sp)
    800026f2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800026f4:	fffff097          	auipc	ra,0xfffff
    800026f8:	334080e7          	jalr	820(ra) # 80001a28 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026fc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002700:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002702:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80002706:	00005697          	auipc	a3,0x5
    8000270a:	8fa68693          	addi	a3,a3,-1798 # 80007000 <_trampoline>
    8000270e:	00005717          	auipc	a4,0x5
    80002712:	8f270713          	addi	a4,a4,-1806 # 80007000 <_trampoline>
    80002716:	8f15                	sub	a4,a4,a3
    80002718:	040007b7          	lui	a5,0x4000
    8000271c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000271e:	07b2                	slli	a5,a5,0xc
    80002720:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002722:	10571073          	csrw	stvec,a4

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002726:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002728:	18002673          	csrr	a2,satp
    8000272c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000272e:	6d30                	ld	a2,88(a0)
    80002730:	6138                	ld	a4,64(a0)
    80002732:	6585                	lui	a1,0x1
    80002734:	972e                	add	a4,a4,a1
    80002736:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002738:	6d38                	ld	a4,88(a0)
    8000273a:	00000617          	auipc	a2,0x0
    8000273e:	13860613          	addi	a2,a2,312 # 80002872 <usertrap>
    80002742:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002744:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002746:	8612                	mv	a2,tp
    80002748:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000274a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000274e:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002752:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002756:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000275a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000275c:	6f18                	ld	a4,24(a4)
    8000275e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002762:	692c                	ld	a1,80(a0)
    80002764:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80002766:	00005717          	auipc	a4,0x5
    8000276a:	92a70713          	addi	a4,a4,-1750 # 80007090 <userret>
    8000276e:	8f15                	sub	a4,a4,a3
    80002770:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80002772:	577d                	li	a4,-1
    80002774:	177e                	slli	a4,a4,0x3f
    80002776:	8dd9                	or	a1,a1,a4
    80002778:	02000537          	lui	a0,0x2000
    8000277c:	157d                	addi	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000277e:	0536                	slli	a0,a0,0xd
    80002780:	9782                	jalr	a5
}
    80002782:	60a2                	ld	ra,8(sp)
    80002784:	6402                	ld	s0,0(sp)
    80002786:	0141                	addi	sp,sp,16
    80002788:	8082                	ret

000000008000278a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000278a:	1101                	addi	sp,sp,-32
    8000278c:	ec06                	sd	ra,24(sp)
    8000278e:	e822                	sd	s0,16(sp)
    80002790:	e426                	sd	s1,8(sp)
    80002792:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002794:	00016497          	auipc	s1,0x16
    80002798:	9d448493          	addi	s1,s1,-1580 # 80018168 <tickslock>
    8000279c:	8526                	mv	a0,s1
    8000279e:	ffffe097          	auipc	ra,0xffffe
    800027a2:	4be080e7          	jalr	1214(ra) # 80000c5c <acquire>
  ticks++;
    800027a6:	00007517          	auipc	a0,0x7
    800027aa:	87a50513          	addi	a0,a0,-1926 # 80009020 <ticks>
    800027ae:	411c                	lw	a5,0(a0)
    800027b0:	2785                	addiw	a5,a5,1
    800027b2:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027b4:	00000097          	auipc	ra,0x0
    800027b8:	c58080e7          	jalr	-936(ra) # 8000240c <wakeup>
  release(&tickslock);
    800027bc:	8526                	mv	a0,s1
    800027be:	ffffe097          	auipc	ra,0xffffe
    800027c2:	552080e7          	jalr	1362(ra) # 80000d10 <release>
}
    800027c6:	60e2                	ld	ra,24(sp)
    800027c8:	6442                	ld	s0,16(sp)
    800027ca:	64a2                	ld	s1,8(sp)
    800027cc:	6105                	addi	sp,sp,32
    800027ce:	8082                	ret

00000000800027d0 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800027d0:	1101                	addi	sp,sp,-32
    800027d2:	ec06                	sd	ra,24(sp)
    800027d4:	e822                	sd	s0,16(sp)
    800027d6:	e426                	sd	s1,8(sp)
    800027d8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027da:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    800027de:	00074d63          	bltz	a4,800027f8 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    800027e2:	57fd                	li	a5,-1
    800027e4:	17fe                	slli	a5,a5,0x3f
    800027e6:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027e8:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800027ea:	06f70363          	beq	a4,a5,80002850 <devintr+0x80>
  }
}
    800027ee:	60e2                	ld	ra,24(sp)
    800027f0:	6442                	ld	s0,16(sp)
    800027f2:	64a2                	ld	s1,8(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret
     (scause & 0xff) == 9){
    800027f8:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800027fc:	46a5                	li	a3,9
    800027fe:	fed792e3          	bne	a5,a3,800027e2 <devintr+0x12>
    int irq = plic_claim();
    80002802:	00003097          	auipc	ra,0x3
    80002806:	5f6080e7          	jalr	1526(ra) # 80005df8 <plic_claim>
    8000280a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000280c:	47a9                	li	a5,10
    8000280e:	02f50763          	beq	a0,a5,8000283c <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    80002812:	4785                	li	a5,1
    80002814:	02f50963          	beq	a0,a5,80002846 <devintr+0x76>
    return 1;
    80002818:	4505                	li	a0,1
    } else if(irq){
    8000281a:	d8f1                	beqz	s1,800027ee <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    8000281c:	85a6                	mv	a1,s1
    8000281e:	00006517          	auipc	a0,0x6
    80002822:	ac250513          	addi	a0,a0,-1342 # 800082e0 <states.0+0x30>
    80002826:	ffffe097          	auipc	ra,0xffffe
    8000282a:	d6a080e7          	jalr	-662(ra) # 80000590 <printf>
      plic_complete(irq);
    8000282e:	8526                	mv	a0,s1
    80002830:	00003097          	auipc	ra,0x3
    80002834:	5ec080e7          	jalr	1516(ra) # 80005e1c <plic_complete>
    return 1;
    80002838:	4505                	li	a0,1
    8000283a:	bf55                	j	800027ee <devintr+0x1e>
      uartintr();
    8000283c:	ffffe097          	auipc	ra,0xffffe
    80002840:	1e2080e7          	jalr	482(ra) # 80000a1e <uartintr>
    80002844:	b7ed                	j	8000282e <devintr+0x5e>
      virtio_disk_intr();
    80002846:	00004097          	auipc	ra,0x4
    8000284a:	a4a080e7          	jalr	-1462(ra) # 80006290 <virtio_disk_intr>
    8000284e:	b7c5                	j	8000282e <devintr+0x5e>
    if(cpuid() == 0){
    80002850:	fffff097          	auipc	ra,0xfffff
    80002854:	1ac080e7          	jalr	428(ra) # 800019fc <cpuid>
    80002858:	c901                	beqz	a0,80002868 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000285a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000285e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002860:	14479073          	csrw	sip,a5
    return 2;
    80002864:	4509                	li	a0,2
    80002866:	b761                	j	800027ee <devintr+0x1e>
      clockintr();
    80002868:	00000097          	auipc	ra,0x0
    8000286c:	f22080e7          	jalr	-222(ra) # 8000278a <clockintr>
    80002870:	b7ed                	j	8000285a <devintr+0x8a>

0000000080002872 <usertrap>:
{
    80002872:	1101                	addi	sp,sp,-32
    80002874:	ec06                	sd	ra,24(sp)
    80002876:	e822                	sd	s0,16(sp)
    80002878:	e426                	sd	s1,8(sp)
    8000287a:	e04a                	sd	s2,0(sp)
    8000287c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000287e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002882:	1007f793          	andi	a5,a5,256
    80002886:	e3ad                	bnez	a5,800028e8 <usertrap+0x76>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002888:	00003797          	auipc	a5,0x3
    8000288c:	46878793          	addi	a5,a5,1128 # 80005cf0 <kernelvec>
    80002890:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002894:	fffff097          	auipc	ra,0xfffff
    80002898:	194080e7          	jalr	404(ra) # 80001a28 <myproc>
    8000289c:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000289e:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028a0:	14102773          	csrr	a4,sepc
    800028a4:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028a6:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028aa:	47a1                	li	a5,8
    800028ac:	04f71c63          	bne	a4,a5,80002904 <usertrap+0x92>
    if(p->killed)
    800028b0:	591c                	lw	a5,48(a0)
    800028b2:	e3b9                	bnez	a5,800028f8 <usertrap+0x86>
    p->trapframe->epc += 4;
    800028b4:	6cb8                	ld	a4,88(s1)
    800028b6:	6f1c                	ld	a5,24(a4)
    800028b8:	0791                	addi	a5,a5,4
    800028ba:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028bc:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800028c0:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800028c4:	10079073          	csrw	sstatus,a5
    syscall();
    800028c8:	00000097          	auipc	ra,0x0
    800028cc:	3be080e7          	jalr	958(ra) # 80002c86 <syscall>
  if(p->killed)
    800028d0:	589c                	lw	a5,48(s1)
    800028d2:	e7c5                	bnez	a5,8000297a <usertrap+0x108>
  usertrapret();
    800028d4:	00000097          	auipc	ra,0x0
    800028d8:	e18080e7          	jalr	-488(ra) # 800026ec <usertrapret>
}
    800028dc:	60e2                	ld	ra,24(sp)
    800028de:	6442                	ld	s0,16(sp)
    800028e0:	64a2                	ld	s1,8(sp)
    800028e2:	6902                	ld	s2,0(sp)
    800028e4:	6105                	addi	sp,sp,32
    800028e6:	8082                	ret
    panic("usertrap: not from user mode");
    800028e8:	00006517          	auipc	a0,0x6
    800028ec:	a1850513          	addi	a0,a0,-1512 # 80008300 <states.0+0x50>
    800028f0:	ffffe097          	auipc	ra,0xffffe
    800028f4:	c56080e7          	jalr	-938(ra) # 80000546 <panic>
      exit(-1);
    800028f8:	557d                	li	a0,-1
    800028fa:	00000097          	auipc	ra,0x0
    800028fe:	84c080e7          	jalr	-1972(ra) # 80002146 <exit>
    80002902:	bf4d                	j	800028b4 <usertrap+0x42>
  } else if((which_dev = devintr()) != 0){
    80002904:	00000097          	auipc	ra,0x0
    80002908:	ecc080e7          	jalr	-308(ra) # 800027d0 <devintr>
    8000290c:	892a                	mv	s2,a0
    8000290e:	c501                	beqz	a0,80002916 <usertrap+0xa4>
  if(p->killed)
    80002910:	589c                	lw	a5,48(s1)
    80002912:	c3a1                	beqz	a5,80002952 <usertrap+0xe0>
    80002914:	a815                	j	80002948 <usertrap+0xd6>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002916:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    8000291a:	5c90                	lw	a2,56(s1)
    8000291c:	00006517          	auipc	a0,0x6
    80002920:	a0450513          	addi	a0,a0,-1532 # 80008320 <states.0+0x70>
    80002924:	ffffe097          	auipc	ra,0xffffe
    80002928:	c6c080e7          	jalr	-916(ra) # 80000590 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000292c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002930:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002934:	00006517          	auipc	a0,0x6
    80002938:	a1c50513          	addi	a0,a0,-1508 # 80008350 <states.0+0xa0>
    8000293c:	ffffe097          	auipc	ra,0xffffe
    80002940:	c54080e7          	jalr	-940(ra) # 80000590 <printf>
    p->killed = 1;
    80002944:	4785                	li	a5,1
    80002946:	d89c                	sw	a5,48(s1)
    exit(-1);
    80002948:	557d                	li	a0,-1
    8000294a:	fffff097          	auipc	ra,0xfffff
    8000294e:	7fc080e7          	jalr	2044(ra) # 80002146 <exit>
  if(which_dev == 2){
    80002952:	4789                	li	a5,2
    80002954:	f8f910e3          	bne	s2,a5,800028d4 <usertrap+0x62>
    if(p->alarm_rank!=0){
    80002958:	1684a703          	lw	a4,360(s1)
    8000295c:	cb11                	beqz	a4,80002970 <usertrap+0xfe>
      p->alarm_ticks--;
    8000295e:	1784a783          	lw	a5,376(s1)
    80002962:	37fd                	addiw	a5,a5,-1
    80002964:	0007869b          	sext.w	a3,a5
    80002968:	16f4ac23          	sw	a5,376(s1)
      if(p->alarm_ticks<=0){
    8000296c:	00d05963          	blez	a3,8000297e <usertrap+0x10c>
    yield();
    80002970:	00000097          	auipc	ra,0x0
    80002974:	8e0080e7          	jalr	-1824(ra) # 80002250 <yield>
    80002978:	bfb1                	j	800028d4 <usertrap+0x62>
  int which_dev = 0;
    8000297a:	4901                	li	s2,0
    8000297c:	b7f1                	j	80002948 <usertrap+0xd6>
        if(!p->alarm_check){
    8000297e:	1884a783          	lw	a5,392(s1)
    80002982:	f7fd                	bnez	a5,80002970 <usertrap+0xfe>
          p->alarm_ticks=p->alarm_rank;
    80002984:	16e4ac23          	sw	a4,376(s1)
          *p->alarm_trapframe=*p->trapframe;
    80002988:	6cb4                	ld	a3,88(s1)
    8000298a:	87b6                	mv	a5,a3
    8000298c:	1804b703          	ld	a4,384(s1)
    80002990:	12068693          	addi	a3,a3,288
    80002994:	0007b803          	ld	a6,0(a5)
    80002998:	6788                	ld	a0,8(a5)
    8000299a:	6b8c                	ld	a1,16(a5)
    8000299c:	6f90                	ld	a2,24(a5)
    8000299e:	01073023          	sd	a6,0(a4)
    800029a2:	e708                	sd	a0,8(a4)
    800029a4:	eb0c                	sd	a1,16(a4)
    800029a6:	ef10                	sd	a2,24(a4)
    800029a8:	02078793          	addi	a5,a5,32
    800029ac:	02070713          	addi	a4,a4,32
    800029b0:	fed792e3          	bne	a5,a3,80002994 <usertrap+0x122>
          p->trapframe->epc=(uint64)p->alarm_handler;
    800029b4:	6cbc                	ld	a5,88(s1)
    800029b6:	1704b703          	ld	a4,368(s1)
    800029ba:	ef98                	sd	a4,24(a5)
          p->alarm_check=1;
    800029bc:	4785                	li	a5,1
    800029be:	18f4a423          	sw	a5,392(s1)
    800029c2:	b77d                	j	80002970 <usertrap+0xfe>

00000000800029c4 <kerneltrap>:
{
    800029c4:	7179                	addi	sp,sp,-48
    800029c6:	f406                	sd	ra,40(sp)
    800029c8:	f022                	sd	s0,32(sp)
    800029ca:	ec26                	sd	s1,24(sp)
    800029cc:	e84a                	sd	s2,16(sp)
    800029ce:	e44e                	sd	s3,8(sp)
    800029d0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029d2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029da:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029de:	1004f793          	andi	a5,s1,256
    800029e2:	cb85                	beqz	a5,80002a12 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029e8:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800029ea:	ef85                	bnez	a5,80002a22 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029ec:	00000097          	auipc	ra,0x0
    800029f0:	de4080e7          	jalr	-540(ra) # 800027d0 <devintr>
    800029f4:	cd1d                	beqz	a0,80002a32 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    800029f6:	4789                	li	a5,2
    800029f8:	06f50a63          	beq	a0,a5,80002a6c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029fc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a00:	10049073          	csrw	sstatus,s1
}
    80002a04:	70a2                	ld	ra,40(sp)
    80002a06:	7402                	ld	s0,32(sp)
    80002a08:	64e2                	ld	s1,24(sp)
    80002a0a:	6942                	ld	s2,16(sp)
    80002a0c:	69a2                	ld	s3,8(sp)
    80002a0e:	6145                	addi	sp,sp,48
    80002a10:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	95e50513          	addi	a0,a0,-1698 # 80008370 <states.0+0xc0>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b2c080e7          	jalr	-1236(ra) # 80000546 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	97650513          	addi	a0,a0,-1674 # 80008398 <states.0+0xe8>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b1c080e7          	jalr	-1252(ra) # 80000546 <panic>
    printf("scause %p\n", scause);
    80002a32:	85ce                	mv	a1,s3
    80002a34:	00006517          	auipc	a0,0x6
    80002a38:	98450513          	addi	a0,a0,-1660 # 800083b8 <states.0+0x108>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b54080e7          	jalr	-1196(ra) # 80000590 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a44:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a48:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a4c:	00006517          	auipc	a0,0x6
    80002a50:	97c50513          	addi	a0,a0,-1668 # 800083c8 <states.0+0x118>
    80002a54:	ffffe097          	auipc	ra,0xffffe
    80002a58:	b3c080e7          	jalr	-1220(ra) # 80000590 <printf>
    panic("kerneltrap");
    80002a5c:	00006517          	auipc	a0,0x6
    80002a60:	98450513          	addi	a0,a0,-1660 # 800083e0 <states.0+0x130>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	ae2080e7          	jalr	-1310(ra) # 80000546 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a6c:	fffff097          	auipc	ra,0xfffff
    80002a70:	fbc080e7          	jalr	-68(ra) # 80001a28 <myproc>
    80002a74:	d541                	beqz	a0,800029fc <kerneltrap+0x38>
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	fb2080e7          	jalr	-78(ra) # 80001a28 <myproc>
    80002a7e:	4d18                	lw	a4,24(a0)
    80002a80:	478d                	li	a5,3
    80002a82:	f6f71de3          	bne	a4,a5,800029fc <kerneltrap+0x38>
    yield();
    80002a86:	fffff097          	auipc	ra,0xfffff
    80002a8a:	7ca080e7          	jalr	1994(ra) # 80002250 <yield>
    80002a8e:	b7bd                	j	800029fc <kerneltrap+0x38>

0000000080002a90 <sigalarm>:

//add
int sigalarm(int ticks,void(*handler)()){
    80002a90:	1101                	addi	sp,sp,-32
    80002a92:	ec06                	sd	ra,24(sp)
    80002a94:	e822                	sd	s0,16(sp)
    80002a96:	e426                	sd	s1,8(sp)
    80002a98:	e04a                	sd	s2,0(sp)
    80002a9a:	1000                	addi	s0,sp,32
    80002a9c:	84aa                	mv	s1,a0
    80002a9e:	892e                	mv	s2,a1
  struct proc *p=myproc();
    80002aa0:	fffff097          	auipc	ra,0xfffff
    80002aa4:	f88080e7          	jalr	-120(ra) # 80001a28 <myproc>
  p->alarm_rank=ticks;
    80002aa8:	16952423          	sw	s1,360(a0)
  p->alarm_handler=handler;
    80002aac:	17253823          	sd	s2,368(a0)
  p->alarm_ticks=ticks;
    80002ab0:	16952c23          	sw	s1,376(a0)
  return 0;
}
    80002ab4:	4501                	li	a0,0
    80002ab6:	60e2                	ld	ra,24(sp)
    80002ab8:	6442                	ld	s0,16(sp)
    80002aba:	64a2                	ld	s1,8(sp)
    80002abc:	6902                	ld	s2,0(sp)
    80002abe:	6105                	addi	sp,sp,32
    80002ac0:	8082                	ret

0000000080002ac2 <sigreturn>:
int sigreturn(){
    80002ac2:	1141                	addi	sp,sp,-16
    80002ac4:	e406                	sd	ra,8(sp)
    80002ac6:	e022                	sd	s0,0(sp)
    80002ac8:	0800                	addi	s0,sp,16
  struct proc *p=myproc();
    80002aca:	fffff097          	auipc	ra,0xfffff
    80002ace:	f5e080e7          	jalr	-162(ra) # 80001a28 <myproc>
  *p->trapframe=*p->alarm_trapframe;
    80002ad2:	18053683          	ld	a3,384(a0)
    80002ad6:	87b6                	mv	a5,a3
    80002ad8:	6d38                	ld	a4,88(a0)
    80002ada:	12068693          	addi	a3,a3,288
    80002ade:	0007b883          	ld	a7,0(a5)
    80002ae2:	0087b803          	ld	a6,8(a5)
    80002ae6:	6b8c                	ld	a1,16(a5)
    80002ae8:	6f90                	ld	a2,24(a5)
    80002aea:	01173023          	sd	a7,0(a4)
    80002aee:	01073423          	sd	a6,8(a4)
    80002af2:	eb0c                	sd	a1,16(a4)
    80002af4:	ef10                	sd	a2,24(a4)
    80002af6:	02078793          	addi	a5,a5,32
    80002afa:	02070713          	addi	a4,a4,32
    80002afe:	fed790e3          	bne	a5,a3,80002ade <sigreturn+0x1c>
  p->alarm_check=0;
    80002b02:	18052423          	sw	zero,392(a0)
  return 0;
}
    80002b06:	4501                	li	a0,0
    80002b08:	60a2                	ld	ra,8(sp)
    80002b0a:	6402                	ld	s0,0(sp)
    80002b0c:	0141                	addi	sp,sp,16
    80002b0e:	8082                	ret

0000000080002b10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b10:	1101                	addi	sp,sp,-32
    80002b12:	ec06                	sd	ra,24(sp)
    80002b14:	e822                	sd	s0,16(sp)
    80002b16:	e426                	sd	s1,8(sp)
    80002b18:	1000                	addi	s0,sp,32
    80002b1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b1c:	fffff097          	auipc	ra,0xfffff
    80002b20:	f0c080e7          	jalr	-244(ra) # 80001a28 <myproc>
  switch (n) {
    80002b24:	4795                	li	a5,5
    80002b26:	0497e163          	bltu	a5,s1,80002b68 <argraw+0x58>
    80002b2a:	048a                	slli	s1,s1,0x2
    80002b2c:	00006717          	auipc	a4,0x6
    80002b30:	8ec70713          	addi	a4,a4,-1812 # 80008418 <states.0+0x168>
    80002b34:	94ba                	add	s1,s1,a4
    80002b36:	409c                	lw	a5,0(s1)
    80002b38:	97ba                	add	a5,a5,a4
    80002b3a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b3c:	6d3c                	ld	a5,88(a0)
    80002b3e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b40:	60e2                	ld	ra,24(sp)
    80002b42:	6442                	ld	s0,16(sp)
    80002b44:	64a2                	ld	s1,8(sp)
    80002b46:	6105                	addi	sp,sp,32
    80002b48:	8082                	ret
    return p->trapframe->a1;
    80002b4a:	6d3c                	ld	a5,88(a0)
    80002b4c:	7fa8                	ld	a0,120(a5)
    80002b4e:	bfcd                	j	80002b40 <argraw+0x30>
    return p->trapframe->a2;
    80002b50:	6d3c                	ld	a5,88(a0)
    80002b52:	63c8                	ld	a0,128(a5)
    80002b54:	b7f5                	j	80002b40 <argraw+0x30>
    return p->trapframe->a3;
    80002b56:	6d3c                	ld	a5,88(a0)
    80002b58:	67c8                	ld	a0,136(a5)
    80002b5a:	b7dd                	j	80002b40 <argraw+0x30>
    return p->trapframe->a4;
    80002b5c:	6d3c                	ld	a5,88(a0)
    80002b5e:	6bc8                	ld	a0,144(a5)
    80002b60:	b7c5                	j	80002b40 <argraw+0x30>
    return p->trapframe->a5;
    80002b62:	6d3c                	ld	a5,88(a0)
    80002b64:	6fc8                	ld	a0,152(a5)
    80002b66:	bfe9                	j	80002b40 <argraw+0x30>
  panic("argraw");
    80002b68:	00006517          	auipc	a0,0x6
    80002b6c:	88850513          	addi	a0,a0,-1912 # 800083f0 <states.0+0x140>
    80002b70:	ffffe097          	auipc	ra,0xffffe
    80002b74:	9d6080e7          	jalr	-1578(ra) # 80000546 <panic>

0000000080002b78 <fetchaddr>:
{
    80002b78:	1101                	addi	sp,sp,-32
    80002b7a:	ec06                	sd	ra,24(sp)
    80002b7c:	e822                	sd	s0,16(sp)
    80002b7e:	e426                	sd	s1,8(sp)
    80002b80:	e04a                	sd	s2,0(sp)
    80002b82:	1000                	addi	s0,sp,32
    80002b84:	84aa                	mv	s1,a0
    80002b86:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b88:	fffff097          	auipc	ra,0xfffff
    80002b8c:	ea0080e7          	jalr	-352(ra) # 80001a28 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80002b90:	653c                	ld	a5,72(a0)
    80002b92:	02f4f863          	bgeu	s1,a5,80002bc2 <fetchaddr+0x4a>
    80002b96:	00848713          	addi	a4,s1,8
    80002b9a:	02e7e663          	bltu	a5,a4,80002bc6 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b9e:	46a1                	li	a3,8
    80002ba0:	8626                	mv	a2,s1
    80002ba2:	85ca                	mv	a1,s2
    80002ba4:	6928                	ld	a0,80(a0)
    80002ba6:	fffff097          	auipc	ra,0xfffff
    80002baa:	c04080e7          	jalr	-1020(ra) # 800017aa <copyin>
    80002bae:	00a03533          	snez	a0,a0
    80002bb2:	40a00533          	neg	a0,a0
}
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	6902                	ld	s2,0(sp)
    80002bbe:	6105                	addi	sp,sp,32
    80002bc0:	8082                	ret
    return -1;
    80002bc2:	557d                	li	a0,-1
    80002bc4:	bfcd                	j	80002bb6 <fetchaddr+0x3e>
    80002bc6:	557d                	li	a0,-1
    80002bc8:	b7fd                	j	80002bb6 <fetchaddr+0x3e>

0000000080002bca <fetchstr>:
{
    80002bca:	7179                	addi	sp,sp,-48
    80002bcc:	f406                	sd	ra,40(sp)
    80002bce:	f022                	sd	s0,32(sp)
    80002bd0:	ec26                	sd	s1,24(sp)
    80002bd2:	e84a                	sd	s2,16(sp)
    80002bd4:	e44e                	sd	s3,8(sp)
    80002bd6:	1800                	addi	s0,sp,48
    80002bd8:	892a                	mv	s2,a0
    80002bda:	84ae                	mv	s1,a1
    80002bdc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bde:	fffff097          	auipc	ra,0xfffff
    80002be2:	e4a080e7          	jalr	-438(ra) # 80001a28 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80002be6:	86ce                	mv	a3,s3
    80002be8:	864a                	mv	a2,s2
    80002bea:	85a6                	mv	a1,s1
    80002bec:	6928                	ld	a0,80(a0)
    80002bee:	fffff097          	auipc	ra,0xfffff
    80002bf2:	c4a080e7          	jalr	-950(ra) # 80001838 <copyinstr>
  if(err < 0)
    80002bf6:	00054763          	bltz	a0,80002c04 <fetchstr+0x3a>
  return strlen(buf);
    80002bfa:	8526                	mv	a0,s1
    80002bfc:	ffffe097          	auipc	ra,0xffffe
    80002c00:	2e0080e7          	jalr	736(ra) # 80000edc <strlen>
}
    80002c04:	70a2                	ld	ra,40(sp)
    80002c06:	7402                	ld	s0,32(sp)
    80002c08:	64e2                	ld	s1,24(sp)
    80002c0a:	6942                	ld	s2,16(sp)
    80002c0c:	69a2                	ld	s3,8(sp)
    80002c0e:	6145                	addi	sp,sp,48
    80002c10:	8082                	ret

0000000080002c12 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002c12:	1101                	addi	sp,sp,-32
    80002c14:	ec06                	sd	ra,24(sp)
    80002c16:	e822                	sd	s0,16(sp)
    80002c18:	e426                	sd	s1,8(sp)
    80002c1a:	1000                	addi	s0,sp,32
    80002c1c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c1e:	00000097          	auipc	ra,0x0
    80002c22:	ef2080e7          	jalr	-270(ra) # 80002b10 <argraw>
    80002c26:	c088                	sw	a0,0(s1)
  return 0;
}
    80002c28:	4501                	li	a0,0
    80002c2a:	60e2                	ld	ra,24(sp)
    80002c2c:	6442                	ld	s0,16(sp)
    80002c2e:	64a2                	ld	s1,8(sp)
    80002c30:	6105                	addi	sp,sp,32
    80002c32:	8082                	ret

0000000080002c34 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002c34:	1101                	addi	sp,sp,-32
    80002c36:	ec06                	sd	ra,24(sp)
    80002c38:	e822                	sd	s0,16(sp)
    80002c3a:	e426                	sd	s1,8(sp)
    80002c3c:	1000                	addi	s0,sp,32
    80002c3e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c40:	00000097          	auipc	ra,0x0
    80002c44:	ed0080e7          	jalr	-304(ra) # 80002b10 <argraw>
    80002c48:	e088                	sd	a0,0(s1)
  return 0;
}
    80002c4a:	4501                	li	a0,0
    80002c4c:	60e2                	ld	ra,24(sp)
    80002c4e:	6442                	ld	s0,16(sp)
    80002c50:	64a2                	ld	s1,8(sp)
    80002c52:	6105                	addi	sp,sp,32
    80002c54:	8082                	ret

0000000080002c56 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c56:	1101                	addi	sp,sp,-32
    80002c58:	ec06                	sd	ra,24(sp)
    80002c5a:	e822                	sd	s0,16(sp)
    80002c5c:	e426                	sd	s1,8(sp)
    80002c5e:	e04a                	sd	s2,0(sp)
    80002c60:	1000                	addi	s0,sp,32
    80002c62:	84ae                	mv	s1,a1
    80002c64:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002c66:	00000097          	auipc	ra,0x0
    80002c6a:	eaa080e7          	jalr	-342(ra) # 80002b10 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    80002c6e:	864a                	mv	a2,s2
    80002c70:	85a6                	mv	a1,s1
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	f58080e7          	jalr	-168(ra) # 80002bca <fetchstr>
}
    80002c7a:	60e2                	ld	ra,24(sp)
    80002c7c:	6442                	ld	s0,16(sp)
    80002c7e:	64a2                	ld	s1,8(sp)
    80002c80:	6902                	ld	s2,0(sp)
    80002c82:	6105                	addi	sp,sp,32
    80002c84:	8082                	ret

0000000080002c86 <syscall>:
[SYS_sigreturn] sys_sigreturn,
};

void
syscall(void)
{
    80002c86:	1101                	addi	sp,sp,-32
    80002c88:	ec06                	sd	ra,24(sp)
    80002c8a:	e822                	sd	s0,16(sp)
    80002c8c:	e426                	sd	s1,8(sp)
    80002c8e:	e04a                	sd	s2,0(sp)
    80002c90:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c92:	fffff097          	auipc	ra,0xfffff
    80002c96:	d96080e7          	jalr	-618(ra) # 80001a28 <myproc>
    80002c9a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c9c:	05853903          	ld	s2,88(a0)
    80002ca0:	0a893783          	ld	a5,168(s2)
    80002ca4:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ca8:	37fd                	addiw	a5,a5,-1
    80002caa:	4759                	li	a4,22
    80002cac:	00f76f63          	bltu	a4,a5,80002cca <syscall+0x44>
    80002cb0:	00369713          	slli	a4,a3,0x3
    80002cb4:	00005797          	auipc	a5,0x5
    80002cb8:	77c78793          	addi	a5,a5,1916 # 80008430 <syscalls>
    80002cbc:	97ba                	add	a5,a5,a4
    80002cbe:	639c                	ld	a5,0(a5)
    80002cc0:	c789                	beqz	a5,80002cca <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    80002cc2:	9782                	jalr	a5
    80002cc4:	06a93823          	sd	a0,112(s2)
    80002cc8:	a839                	j	80002ce6 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002cca:	15848613          	addi	a2,s1,344
    80002cce:	5c8c                	lw	a1,56(s1)
    80002cd0:	00005517          	auipc	a0,0x5
    80002cd4:	72850513          	addi	a0,a0,1832 # 800083f8 <states.0+0x148>
    80002cd8:	ffffe097          	auipc	ra,0xffffe
    80002cdc:	8b8080e7          	jalr	-1864(ra) # 80000590 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ce0:	6cbc                	ld	a5,88(s1)
    80002ce2:	577d                	li	a4,-1
    80002ce4:	fbb8                	sd	a4,112(a5)
  }
}
    80002ce6:	60e2                	ld	ra,24(sp)
    80002ce8:	6442                	ld	s0,16(sp)
    80002cea:	64a2                	ld	s1,8(sp)
    80002cec:	6902                	ld	s2,0(sp)
    80002cee:	6105                	addi	sp,sp,32
    80002cf0:	8082                	ret

0000000080002cf2 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cf2:	1101                	addi	sp,sp,-32
    80002cf4:	ec06                	sd	ra,24(sp)
    80002cf6:	e822                	sd	s0,16(sp)
    80002cf8:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    80002cfa:	fec40593          	addi	a1,s0,-20
    80002cfe:	4501                	li	a0,0
    80002d00:	00000097          	auipc	ra,0x0
    80002d04:	f12080e7          	jalr	-238(ra) # 80002c12 <argint>
    return -1;
    80002d08:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002d0a:	00054963          	bltz	a0,80002d1c <sys_exit+0x2a>
  exit(n);
    80002d0e:	fec42503          	lw	a0,-20(s0)
    80002d12:	fffff097          	auipc	ra,0xfffff
    80002d16:	434080e7          	jalr	1076(ra) # 80002146 <exit>
  return 0;  // not reached
    80002d1a:	4781                	li	a5,0
}
    80002d1c:	853e                	mv	a0,a5
    80002d1e:	60e2                	ld	ra,24(sp)
    80002d20:	6442                	ld	s0,16(sp)
    80002d22:	6105                	addi	sp,sp,32
    80002d24:	8082                	ret

0000000080002d26 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d26:	1141                	addi	sp,sp,-16
    80002d28:	e406                	sd	ra,8(sp)
    80002d2a:	e022                	sd	s0,0(sp)
    80002d2c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d2e:	fffff097          	auipc	ra,0xfffff
    80002d32:	cfa080e7          	jalr	-774(ra) # 80001a28 <myproc>
}
    80002d36:	5d08                	lw	a0,56(a0)
    80002d38:	60a2                	ld	ra,8(sp)
    80002d3a:	6402                	ld	s0,0(sp)
    80002d3c:	0141                	addi	sp,sp,16
    80002d3e:	8082                	ret

0000000080002d40 <sys_fork>:

uint64
sys_fork(void)
{
    80002d40:	1141                	addi	sp,sp,-16
    80002d42:	e406                	sd	ra,8(sp)
    80002d44:	e022                	sd	s0,0(sp)
    80002d46:	0800                	addi	s0,sp,16
  return fork();
    80002d48:	fffff097          	auipc	ra,0xfffff
    80002d4c:	0f4080e7          	jalr	244(ra) # 80001e3c <fork>
}
    80002d50:	60a2                	ld	ra,8(sp)
    80002d52:	6402                	ld	s0,0(sp)
    80002d54:	0141                	addi	sp,sp,16
    80002d56:	8082                	ret

0000000080002d58 <sys_wait>:

uint64
sys_wait(void)
{
    80002d58:	1101                	addi	sp,sp,-32
    80002d5a:	ec06                	sd	ra,24(sp)
    80002d5c:	e822                	sd	s0,16(sp)
    80002d5e:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    80002d60:	fe840593          	addi	a1,s0,-24
    80002d64:	4501                	li	a0,0
    80002d66:	00000097          	auipc	ra,0x0
    80002d6a:	ece080e7          	jalr	-306(ra) # 80002c34 <argaddr>
    80002d6e:	87aa                	mv	a5,a0
    return -1;
    80002d70:	557d                	li	a0,-1
  if(argaddr(0, &p) < 0)
    80002d72:	0007c863          	bltz	a5,80002d82 <sys_wait+0x2a>
  return wait(p);
    80002d76:	fe843503          	ld	a0,-24(s0)
    80002d7a:	fffff097          	auipc	ra,0xfffff
    80002d7e:	590080e7          	jalr	1424(ra) # 8000230a <wait>
}
    80002d82:	60e2                	ld	ra,24(sp)
    80002d84:	6442                	ld	s0,16(sp)
    80002d86:	6105                	addi	sp,sp,32
    80002d88:	8082                	ret

0000000080002d8a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d8a:	7179                	addi	sp,sp,-48
    80002d8c:	f406                	sd	ra,40(sp)
    80002d8e:	f022                	sd	s0,32(sp)
    80002d90:	ec26                	sd	s1,24(sp)
    80002d92:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002d94:	fdc40593          	addi	a1,s0,-36
    80002d98:	4501                	li	a0,0
    80002d9a:	00000097          	auipc	ra,0x0
    80002d9e:	e78080e7          	jalr	-392(ra) # 80002c12 <argint>
    80002da2:	87aa                	mv	a5,a0
    return -1;
    80002da4:	557d                	li	a0,-1
  if(argint(0, &n) < 0)
    80002da6:	0207c063          	bltz	a5,80002dc6 <sys_sbrk+0x3c>
  addr = myproc()->sz;
    80002daa:	fffff097          	auipc	ra,0xfffff
    80002dae:	c7e080e7          	jalr	-898(ra) # 80001a28 <myproc>
    80002db2:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    80002db4:	fdc42503          	lw	a0,-36(s0)
    80002db8:	fffff097          	auipc	ra,0xfffff
    80002dbc:	00c080e7          	jalr	12(ra) # 80001dc4 <growproc>
    80002dc0:	00054863          	bltz	a0,80002dd0 <sys_sbrk+0x46>
    return -1;
  return addr;
    80002dc4:	8526                	mv	a0,s1
}
    80002dc6:	70a2                	ld	ra,40(sp)
    80002dc8:	7402                	ld	s0,32(sp)
    80002dca:	64e2                	ld	s1,24(sp)
    80002dcc:	6145                	addi	sp,sp,48
    80002dce:	8082                	ret
    return -1;
    80002dd0:	557d                	li	a0,-1
    80002dd2:	bfd5                	j	80002dc6 <sys_sbrk+0x3c>

0000000080002dd4 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dd4:	7139                	addi	sp,sp,-64
    80002dd6:	fc06                	sd	ra,56(sp)
    80002dd8:	f822                	sd	s0,48(sp)
    80002dda:	f426                	sd	s1,40(sp)
    80002ddc:	f04a                	sd	s2,32(sp)
    80002dde:	ec4e                	sd	s3,24(sp)
    80002de0:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;
  //add
  backtrace();
    80002de2:	ffffe097          	auipc	ra,0xffffe
    80002de6:	9c0080e7          	jalr	-1600(ra) # 800007a2 <backtrace>

  if(argint(0, &n) < 0)
    80002dea:	fcc40593          	addi	a1,s0,-52
    80002dee:	4501                	li	a0,0
    80002df0:	00000097          	auipc	ra,0x0
    80002df4:	e22080e7          	jalr	-478(ra) # 80002c12 <argint>
    return -1;
    80002df8:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    80002dfa:	06054563          	bltz	a0,80002e64 <sys_sleep+0x90>
  acquire(&tickslock);
    80002dfe:	00015517          	auipc	a0,0x15
    80002e02:	36a50513          	addi	a0,a0,874 # 80018168 <tickslock>
    80002e06:	ffffe097          	auipc	ra,0xffffe
    80002e0a:	e56080e7          	jalr	-426(ra) # 80000c5c <acquire>
  ticks0 = ticks;
    80002e0e:	00006917          	auipc	s2,0x6
    80002e12:	21292903          	lw	s2,530(s2) # 80009020 <ticks>
  while(ticks - ticks0 < n){
    80002e16:	fcc42783          	lw	a5,-52(s0)
    80002e1a:	cf85                	beqz	a5,80002e52 <sys_sleep+0x7e>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e1c:	00015997          	auipc	s3,0x15
    80002e20:	34c98993          	addi	s3,s3,844 # 80018168 <tickslock>
    80002e24:	00006497          	auipc	s1,0x6
    80002e28:	1fc48493          	addi	s1,s1,508 # 80009020 <ticks>
    if(myproc()->killed){
    80002e2c:	fffff097          	auipc	ra,0xfffff
    80002e30:	bfc080e7          	jalr	-1028(ra) # 80001a28 <myproc>
    80002e34:	591c                	lw	a5,48(a0)
    80002e36:	ef9d                	bnez	a5,80002e74 <sys_sleep+0xa0>
    sleep(&ticks, &tickslock);
    80002e38:	85ce                	mv	a1,s3
    80002e3a:	8526                	mv	a0,s1
    80002e3c:	fffff097          	auipc	ra,0xfffff
    80002e40:	450080e7          	jalr	1104(ra) # 8000228c <sleep>
  while(ticks - ticks0 < n){
    80002e44:	409c                	lw	a5,0(s1)
    80002e46:	412787bb          	subw	a5,a5,s2
    80002e4a:	fcc42703          	lw	a4,-52(s0)
    80002e4e:	fce7efe3          	bltu	a5,a4,80002e2c <sys_sleep+0x58>
  }
  release(&tickslock);
    80002e52:	00015517          	auipc	a0,0x15
    80002e56:	31650513          	addi	a0,a0,790 # 80018168 <tickslock>
    80002e5a:	ffffe097          	auipc	ra,0xffffe
    80002e5e:	eb6080e7          	jalr	-330(ra) # 80000d10 <release>
  return 0;
    80002e62:	4781                	li	a5,0
}
    80002e64:	853e                	mv	a0,a5
    80002e66:	70e2                	ld	ra,56(sp)
    80002e68:	7442                	ld	s0,48(sp)
    80002e6a:	74a2                	ld	s1,40(sp)
    80002e6c:	7902                	ld	s2,32(sp)
    80002e6e:	69e2                	ld	s3,24(sp)
    80002e70:	6121                	addi	sp,sp,64
    80002e72:	8082                	ret
      release(&tickslock);
    80002e74:	00015517          	auipc	a0,0x15
    80002e78:	2f450513          	addi	a0,a0,756 # 80018168 <tickslock>
    80002e7c:	ffffe097          	auipc	ra,0xffffe
    80002e80:	e94080e7          	jalr	-364(ra) # 80000d10 <release>
      return -1;
    80002e84:	57fd                	li	a5,-1
    80002e86:	bff9                	j	80002e64 <sys_sleep+0x90>

0000000080002e88 <sys_kill>:

uint64
sys_kill(void)
{
    80002e88:	1101                	addi	sp,sp,-32
    80002e8a:	ec06                	sd	ra,24(sp)
    80002e8c:	e822                	sd	s0,16(sp)
    80002e8e:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    80002e90:	fec40593          	addi	a1,s0,-20
    80002e94:	4501                	li	a0,0
    80002e96:	00000097          	auipc	ra,0x0
    80002e9a:	d7c080e7          	jalr	-644(ra) # 80002c12 <argint>
    80002e9e:	87aa                	mv	a5,a0
    return -1;
    80002ea0:	557d                	li	a0,-1
  if(argint(0, &pid) < 0)
    80002ea2:	0007c863          	bltz	a5,80002eb2 <sys_kill+0x2a>
  return kill(pid);
    80002ea6:	fec42503          	lw	a0,-20(s0)
    80002eaa:	fffff097          	auipc	ra,0xfffff
    80002eae:	5cc080e7          	jalr	1484(ra) # 80002476 <kill>
}
    80002eb2:	60e2                	ld	ra,24(sp)
    80002eb4:	6442                	ld	s0,16(sp)
    80002eb6:	6105                	addi	sp,sp,32
    80002eb8:	8082                	ret

0000000080002eba <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002eba:	1101                	addi	sp,sp,-32
    80002ebc:	ec06                	sd	ra,24(sp)
    80002ebe:	e822                	sd	s0,16(sp)
    80002ec0:	e426                	sd	s1,8(sp)
    80002ec2:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ec4:	00015517          	auipc	a0,0x15
    80002ec8:	2a450513          	addi	a0,a0,676 # 80018168 <tickslock>
    80002ecc:	ffffe097          	auipc	ra,0xffffe
    80002ed0:	d90080e7          	jalr	-624(ra) # 80000c5c <acquire>
  xticks = ticks;
    80002ed4:	00006497          	auipc	s1,0x6
    80002ed8:	14c4a483          	lw	s1,332(s1) # 80009020 <ticks>
  release(&tickslock);
    80002edc:	00015517          	auipc	a0,0x15
    80002ee0:	28c50513          	addi	a0,a0,652 # 80018168 <tickslock>
    80002ee4:	ffffe097          	auipc	ra,0xffffe
    80002ee8:	e2c080e7          	jalr	-468(ra) # 80000d10 <release>
  return xticks;
}
    80002eec:	02049513          	slli	a0,s1,0x20
    80002ef0:	9101                	srli	a0,a0,0x20
    80002ef2:	60e2                	ld	ra,24(sp)
    80002ef4:	6442                	ld	s0,16(sp)
    80002ef6:	64a2                	ld	s1,8(sp)
    80002ef8:	6105                	addi	sp,sp,32
    80002efa:	8082                	ret

0000000080002efc <sys_sigalarm>:
//add
uint64
sys_sigalarm(void){
    80002efc:	1101                	addi	sp,sp,-32
    80002efe:	ec06                	sd	ra,24(sp)
    80002f00:	e822                	sd	s0,16(sp)
    80002f02:	1000                	addi	s0,sp,32
  int n;
  uint64 fn;
  if(argint(0,&n)<0)
    80002f04:	fec40593          	addi	a1,s0,-20
    80002f08:	4501                	li	a0,0
    80002f0a:	00000097          	auipc	ra,0x0
    80002f0e:	d08080e7          	jalr	-760(ra) # 80002c12 <argint>
    return -1;
    80002f12:	57fd                	li	a5,-1
  if(argint(0,&n)<0)
    80002f14:	02054563          	bltz	a0,80002f3e <sys_sigalarm+0x42>
  if(argaddr(1,&fn)<0)
    80002f18:	fe040593          	addi	a1,s0,-32
    80002f1c:	4505                	li	a0,1
    80002f1e:	00000097          	auipc	ra,0x0
    80002f22:	d16080e7          	jalr	-746(ra) # 80002c34 <argaddr>
    return -1;
    80002f26:	57fd                	li	a5,-1
  if(argaddr(1,&fn)<0)
    80002f28:	00054b63          	bltz	a0,80002f3e <sys_sigalarm+0x42>
  return sigalarm(n,(void(*)())(fn));
    80002f2c:	fe043583          	ld	a1,-32(s0)
    80002f30:	fec42503          	lw	a0,-20(s0)
    80002f34:	00000097          	auipc	ra,0x0
    80002f38:	b5c080e7          	jalr	-1188(ra) # 80002a90 <sigalarm>
    80002f3c:	87aa                	mv	a5,a0
}
    80002f3e:	853e                	mv	a0,a5
    80002f40:	60e2                	ld	ra,24(sp)
    80002f42:	6442                	ld	s0,16(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret

0000000080002f48 <sys_sigreturn>:
uint64 sys_sigreturn(void){
    80002f48:	1141                	addi	sp,sp,-16
    80002f4a:	e406                	sd	ra,8(sp)
    80002f4c:	e022                	sd	s0,0(sp)
    80002f4e:	0800                	addi	s0,sp,16
  return sigreturn();
    80002f50:	00000097          	auipc	ra,0x0
    80002f54:	b72080e7          	jalr	-1166(ra) # 80002ac2 <sigreturn>
}
    80002f58:	60a2                	ld	ra,8(sp)
    80002f5a:	6402                	ld	s0,0(sp)
    80002f5c:	0141                	addi	sp,sp,16
    80002f5e:	8082                	ret

0000000080002f60 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f60:	7179                	addi	sp,sp,-48
    80002f62:	f406                	sd	ra,40(sp)
    80002f64:	f022                	sd	s0,32(sp)
    80002f66:	ec26                	sd	s1,24(sp)
    80002f68:	e84a                	sd	s2,16(sp)
    80002f6a:	e44e                	sd	s3,8(sp)
    80002f6c:	e052                	sd	s4,0(sp)
    80002f6e:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f70:	00005597          	auipc	a1,0x5
    80002f74:	58058593          	addi	a1,a1,1408 # 800084f0 <syscalls+0xc0>
    80002f78:	00015517          	auipc	a0,0x15
    80002f7c:	20850513          	addi	a0,a0,520 # 80018180 <bcache>
    80002f80:	ffffe097          	auipc	ra,0xffffe
    80002f84:	c4c080e7          	jalr	-948(ra) # 80000bcc <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f88:	0001d797          	auipc	a5,0x1d
    80002f8c:	1f878793          	addi	a5,a5,504 # 80020180 <bcache+0x8000>
    80002f90:	0001d717          	auipc	a4,0x1d
    80002f94:	45870713          	addi	a4,a4,1112 # 800203e8 <bcache+0x8268>
    80002f98:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f9c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fa0:	00015497          	auipc	s1,0x15
    80002fa4:	1f848493          	addi	s1,s1,504 # 80018198 <bcache+0x18>
    b->next = bcache.head.next;
    80002fa8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002faa:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002fac:	00005a17          	auipc	s4,0x5
    80002fb0:	54ca0a13          	addi	s4,s4,1356 # 800084f8 <syscalls+0xc8>
    b->next = bcache.head.next;
    80002fb4:	2b893783          	ld	a5,696(s2)
    80002fb8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002fba:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002fbe:	85d2                	mv	a1,s4
    80002fc0:	01048513          	addi	a0,s1,16
    80002fc4:	00001097          	auipc	ra,0x1
    80002fc8:	4b2080e7          	jalr	1202(ra) # 80004476 <initsleeplock>
    bcache.head.next->prev = b;
    80002fcc:	2b893783          	ld	a5,696(s2)
    80002fd0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002fd2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fd6:	45848493          	addi	s1,s1,1112
    80002fda:	fd349de3          	bne	s1,s3,80002fb4 <binit+0x54>
  }
}
    80002fde:	70a2                	ld	ra,40(sp)
    80002fe0:	7402                	ld	s0,32(sp)
    80002fe2:	64e2                	ld	s1,24(sp)
    80002fe4:	6942                	ld	s2,16(sp)
    80002fe6:	69a2                	ld	s3,8(sp)
    80002fe8:	6a02                	ld	s4,0(sp)
    80002fea:	6145                	addi	sp,sp,48
    80002fec:	8082                	ret

0000000080002fee <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fee:	7179                	addi	sp,sp,-48
    80002ff0:	f406                	sd	ra,40(sp)
    80002ff2:	f022                	sd	s0,32(sp)
    80002ff4:	ec26                	sd	s1,24(sp)
    80002ff6:	e84a                	sd	s2,16(sp)
    80002ff8:	e44e                	sd	s3,8(sp)
    80002ffa:	1800                	addi	s0,sp,48
    80002ffc:	892a                	mv	s2,a0
    80002ffe:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003000:	00015517          	auipc	a0,0x15
    80003004:	18050513          	addi	a0,a0,384 # 80018180 <bcache>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	c54080e7          	jalr	-940(ra) # 80000c5c <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003010:	0001d497          	auipc	s1,0x1d
    80003014:	4284b483          	ld	s1,1064(s1) # 80020438 <bcache+0x82b8>
    80003018:	0001d797          	auipc	a5,0x1d
    8000301c:	3d078793          	addi	a5,a5,976 # 800203e8 <bcache+0x8268>
    80003020:	02f48f63          	beq	s1,a5,8000305e <bread+0x70>
    80003024:	873e                	mv	a4,a5
    80003026:	a021                	j	8000302e <bread+0x40>
    80003028:	68a4                	ld	s1,80(s1)
    8000302a:	02e48a63          	beq	s1,a4,8000305e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000302e:	449c                	lw	a5,8(s1)
    80003030:	ff279ce3          	bne	a5,s2,80003028 <bread+0x3a>
    80003034:	44dc                	lw	a5,12(s1)
    80003036:	ff3799e3          	bne	a5,s3,80003028 <bread+0x3a>
      b->refcnt++;
    8000303a:	40bc                	lw	a5,64(s1)
    8000303c:	2785                	addiw	a5,a5,1
    8000303e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003040:	00015517          	auipc	a0,0x15
    80003044:	14050513          	addi	a0,a0,320 # 80018180 <bcache>
    80003048:	ffffe097          	auipc	ra,0xffffe
    8000304c:	cc8080e7          	jalr	-824(ra) # 80000d10 <release>
      acquiresleep(&b->lock);
    80003050:	01048513          	addi	a0,s1,16
    80003054:	00001097          	auipc	ra,0x1
    80003058:	45c080e7          	jalr	1116(ra) # 800044b0 <acquiresleep>
      return b;
    8000305c:	a8b9                	j	800030ba <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000305e:	0001d497          	auipc	s1,0x1d
    80003062:	3d24b483          	ld	s1,978(s1) # 80020430 <bcache+0x82b0>
    80003066:	0001d797          	auipc	a5,0x1d
    8000306a:	38278793          	addi	a5,a5,898 # 800203e8 <bcache+0x8268>
    8000306e:	00f48863          	beq	s1,a5,8000307e <bread+0x90>
    80003072:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003074:	40bc                	lw	a5,64(s1)
    80003076:	cf81                	beqz	a5,8000308e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003078:	64a4                	ld	s1,72(s1)
    8000307a:	fee49de3          	bne	s1,a4,80003074 <bread+0x86>
  panic("bget: no buffers");
    8000307e:	00005517          	auipc	a0,0x5
    80003082:	48250513          	addi	a0,a0,1154 # 80008500 <syscalls+0xd0>
    80003086:	ffffd097          	auipc	ra,0xffffd
    8000308a:	4c0080e7          	jalr	1216(ra) # 80000546 <panic>
      b->dev = dev;
    8000308e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003092:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003096:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000309a:	4785                	li	a5,1
    8000309c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000309e:	00015517          	auipc	a0,0x15
    800030a2:	0e250513          	addi	a0,a0,226 # 80018180 <bcache>
    800030a6:	ffffe097          	auipc	ra,0xffffe
    800030aa:	c6a080e7          	jalr	-918(ra) # 80000d10 <release>
      acquiresleep(&b->lock);
    800030ae:	01048513          	addi	a0,s1,16
    800030b2:	00001097          	auipc	ra,0x1
    800030b6:	3fe080e7          	jalr	1022(ra) # 800044b0 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800030ba:	409c                	lw	a5,0(s1)
    800030bc:	cb89                	beqz	a5,800030ce <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800030be:	8526                	mv	a0,s1
    800030c0:	70a2                	ld	ra,40(sp)
    800030c2:	7402                	ld	s0,32(sp)
    800030c4:	64e2                	ld	s1,24(sp)
    800030c6:	6942                	ld	s2,16(sp)
    800030c8:	69a2                	ld	s3,8(sp)
    800030ca:	6145                	addi	sp,sp,48
    800030cc:	8082                	ret
    virtio_disk_rw(b, 0);
    800030ce:	4581                	li	a1,0
    800030d0:	8526                	mv	a0,s1
    800030d2:	00003097          	auipc	ra,0x3
    800030d6:	f36080e7          	jalr	-202(ra) # 80006008 <virtio_disk_rw>
    b->valid = 1;
    800030da:	4785                	li	a5,1
    800030dc:	c09c                	sw	a5,0(s1)
  return b;
    800030de:	b7c5                	j	800030be <bread+0xd0>

00000000800030e0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030e0:	1101                	addi	sp,sp,-32
    800030e2:	ec06                	sd	ra,24(sp)
    800030e4:	e822                	sd	s0,16(sp)
    800030e6:	e426                	sd	s1,8(sp)
    800030e8:	1000                	addi	s0,sp,32
    800030ea:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030ec:	0541                	addi	a0,a0,16
    800030ee:	00001097          	auipc	ra,0x1
    800030f2:	45c080e7          	jalr	1116(ra) # 8000454a <holdingsleep>
    800030f6:	cd01                	beqz	a0,8000310e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800030f8:	4585                	li	a1,1
    800030fa:	8526                	mv	a0,s1
    800030fc:	00003097          	auipc	ra,0x3
    80003100:	f0c080e7          	jalr	-244(ra) # 80006008 <virtio_disk_rw>
}
    80003104:	60e2                	ld	ra,24(sp)
    80003106:	6442                	ld	s0,16(sp)
    80003108:	64a2                	ld	s1,8(sp)
    8000310a:	6105                	addi	sp,sp,32
    8000310c:	8082                	ret
    panic("bwrite");
    8000310e:	00005517          	auipc	a0,0x5
    80003112:	40a50513          	addi	a0,a0,1034 # 80008518 <syscalls+0xe8>
    80003116:	ffffd097          	auipc	ra,0xffffd
    8000311a:	430080e7          	jalr	1072(ra) # 80000546 <panic>

000000008000311e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000311e:	1101                	addi	sp,sp,-32
    80003120:	ec06                	sd	ra,24(sp)
    80003122:	e822                	sd	s0,16(sp)
    80003124:	e426                	sd	s1,8(sp)
    80003126:	e04a                	sd	s2,0(sp)
    80003128:	1000                	addi	s0,sp,32
    8000312a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000312c:	01050913          	addi	s2,a0,16
    80003130:	854a                	mv	a0,s2
    80003132:	00001097          	auipc	ra,0x1
    80003136:	418080e7          	jalr	1048(ra) # 8000454a <holdingsleep>
    8000313a:	c92d                	beqz	a0,800031ac <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    8000313c:	854a                	mv	a0,s2
    8000313e:	00001097          	auipc	ra,0x1
    80003142:	3c8080e7          	jalr	968(ra) # 80004506 <releasesleep>

  acquire(&bcache.lock);
    80003146:	00015517          	auipc	a0,0x15
    8000314a:	03a50513          	addi	a0,a0,58 # 80018180 <bcache>
    8000314e:	ffffe097          	auipc	ra,0xffffe
    80003152:	b0e080e7          	jalr	-1266(ra) # 80000c5c <acquire>
  b->refcnt--;
    80003156:	40bc                	lw	a5,64(s1)
    80003158:	37fd                	addiw	a5,a5,-1
    8000315a:	0007871b          	sext.w	a4,a5
    8000315e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003160:	eb05                	bnez	a4,80003190 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003162:	68bc                	ld	a5,80(s1)
    80003164:	64b8                	ld	a4,72(s1)
    80003166:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003168:	64bc                	ld	a5,72(s1)
    8000316a:	68b8                	ld	a4,80(s1)
    8000316c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000316e:	0001d797          	auipc	a5,0x1d
    80003172:	01278793          	addi	a5,a5,18 # 80020180 <bcache+0x8000>
    80003176:	2b87b703          	ld	a4,696(a5)
    8000317a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000317c:	0001d717          	auipc	a4,0x1d
    80003180:	26c70713          	addi	a4,a4,620 # 800203e8 <bcache+0x8268>
    80003184:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003186:	2b87b703          	ld	a4,696(a5)
    8000318a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000318c:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003190:	00015517          	auipc	a0,0x15
    80003194:	ff050513          	addi	a0,a0,-16 # 80018180 <bcache>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	b78080e7          	jalr	-1160(ra) # 80000d10 <release>
}
    800031a0:	60e2                	ld	ra,24(sp)
    800031a2:	6442                	ld	s0,16(sp)
    800031a4:	64a2                	ld	s1,8(sp)
    800031a6:	6902                	ld	s2,0(sp)
    800031a8:	6105                	addi	sp,sp,32
    800031aa:	8082                	ret
    panic("brelse");
    800031ac:	00005517          	auipc	a0,0x5
    800031b0:	37450513          	addi	a0,a0,884 # 80008520 <syscalls+0xf0>
    800031b4:	ffffd097          	auipc	ra,0xffffd
    800031b8:	392080e7          	jalr	914(ra) # 80000546 <panic>

00000000800031bc <bpin>:

void
bpin(struct buf *b) {
    800031bc:	1101                	addi	sp,sp,-32
    800031be:	ec06                	sd	ra,24(sp)
    800031c0:	e822                	sd	s0,16(sp)
    800031c2:	e426                	sd	s1,8(sp)
    800031c4:	1000                	addi	s0,sp,32
    800031c6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031c8:	00015517          	auipc	a0,0x15
    800031cc:	fb850513          	addi	a0,a0,-72 # 80018180 <bcache>
    800031d0:	ffffe097          	auipc	ra,0xffffe
    800031d4:	a8c080e7          	jalr	-1396(ra) # 80000c5c <acquire>
  b->refcnt++;
    800031d8:	40bc                	lw	a5,64(s1)
    800031da:	2785                	addiw	a5,a5,1
    800031dc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031de:	00015517          	auipc	a0,0x15
    800031e2:	fa250513          	addi	a0,a0,-94 # 80018180 <bcache>
    800031e6:	ffffe097          	auipc	ra,0xffffe
    800031ea:	b2a080e7          	jalr	-1238(ra) # 80000d10 <release>
}
    800031ee:	60e2                	ld	ra,24(sp)
    800031f0:	6442                	ld	s0,16(sp)
    800031f2:	64a2                	ld	s1,8(sp)
    800031f4:	6105                	addi	sp,sp,32
    800031f6:	8082                	ret

00000000800031f8 <bunpin>:

void
bunpin(struct buf *b) {
    800031f8:	1101                	addi	sp,sp,-32
    800031fa:	ec06                	sd	ra,24(sp)
    800031fc:	e822                	sd	s0,16(sp)
    800031fe:	e426                	sd	s1,8(sp)
    80003200:	1000                	addi	s0,sp,32
    80003202:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003204:	00015517          	auipc	a0,0x15
    80003208:	f7c50513          	addi	a0,a0,-132 # 80018180 <bcache>
    8000320c:	ffffe097          	auipc	ra,0xffffe
    80003210:	a50080e7          	jalr	-1456(ra) # 80000c5c <acquire>
  b->refcnt--;
    80003214:	40bc                	lw	a5,64(s1)
    80003216:	37fd                	addiw	a5,a5,-1
    80003218:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000321a:	00015517          	auipc	a0,0x15
    8000321e:	f6650513          	addi	a0,a0,-154 # 80018180 <bcache>
    80003222:	ffffe097          	auipc	ra,0xffffe
    80003226:	aee080e7          	jalr	-1298(ra) # 80000d10 <release>
}
    8000322a:	60e2                	ld	ra,24(sp)
    8000322c:	6442                	ld	s0,16(sp)
    8000322e:	64a2                	ld	s1,8(sp)
    80003230:	6105                	addi	sp,sp,32
    80003232:	8082                	ret

0000000080003234 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003234:	1101                	addi	sp,sp,-32
    80003236:	ec06                	sd	ra,24(sp)
    80003238:	e822                	sd	s0,16(sp)
    8000323a:	e426                	sd	s1,8(sp)
    8000323c:	e04a                	sd	s2,0(sp)
    8000323e:	1000                	addi	s0,sp,32
    80003240:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003242:	00d5d59b          	srliw	a1,a1,0xd
    80003246:	0001d797          	auipc	a5,0x1d
    8000324a:	6167a783          	lw	a5,1558(a5) # 8002085c <sb+0x1c>
    8000324e:	9dbd                	addw	a1,a1,a5
    80003250:	00000097          	auipc	ra,0x0
    80003254:	d9e080e7          	jalr	-610(ra) # 80002fee <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003258:	0074f713          	andi	a4,s1,7
    8000325c:	4785                	li	a5,1
    8000325e:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003262:	14ce                	slli	s1,s1,0x33
    80003264:	90d9                	srli	s1,s1,0x36
    80003266:	00950733          	add	a4,a0,s1
    8000326a:	05874703          	lbu	a4,88(a4)
    8000326e:	00e7f6b3          	and	a3,a5,a4
    80003272:	c69d                	beqz	a3,800032a0 <bfree+0x6c>
    80003274:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003276:	94aa                	add	s1,s1,a0
    80003278:	fff7c793          	not	a5,a5
    8000327c:	8f7d                	and	a4,a4,a5
    8000327e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003282:	00001097          	auipc	ra,0x1
    80003286:	108080e7          	jalr	264(ra) # 8000438a <log_write>
  brelse(bp);
    8000328a:	854a                	mv	a0,s2
    8000328c:	00000097          	auipc	ra,0x0
    80003290:	e92080e7          	jalr	-366(ra) # 8000311e <brelse>
}
    80003294:	60e2                	ld	ra,24(sp)
    80003296:	6442                	ld	s0,16(sp)
    80003298:	64a2                	ld	s1,8(sp)
    8000329a:	6902                	ld	s2,0(sp)
    8000329c:	6105                	addi	sp,sp,32
    8000329e:	8082                	ret
    panic("freeing free block");
    800032a0:	00005517          	auipc	a0,0x5
    800032a4:	28850513          	addi	a0,a0,648 # 80008528 <syscalls+0xf8>
    800032a8:	ffffd097          	auipc	ra,0xffffd
    800032ac:	29e080e7          	jalr	670(ra) # 80000546 <panic>

00000000800032b0 <balloc>:
{
    800032b0:	711d                	addi	sp,sp,-96
    800032b2:	ec86                	sd	ra,88(sp)
    800032b4:	e8a2                	sd	s0,80(sp)
    800032b6:	e4a6                	sd	s1,72(sp)
    800032b8:	e0ca                	sd	s2,64(sp)
    800032ba:	fc4e                	sd	s3,56(sp)
    800032bc:	f852                	sd	s4,48(sp)
    800032be:	f456                	sd	s5,40(sp)
    800032c0:	f05a                	sd	s6,32(sp)
    800032c2:	ec5e                	sd	s7,24(sp)
    800032c4:	e862                	sd	s8,16(sp)
    800032c6:	e466                	sd	s9,8(sp)
    800032c8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800032ca:	0001d797          	auipc	a5,0x1d
    800032ce:	57a7a783          	lw	a5,1402(a5) # 80020844 <sb+0x4>
    800032d2:	cbc1                	beqz	a5,80003362 <balloc+0xb2>
    800032d4:	8baa                	mv	s7,a0
    800032d6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032d8:	0001db17          	auipc	s6,0x1d
    800032dc:	568b0b13          	addi	s6,s6,1384 # 80020840 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e0:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032e2:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032e4:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032e6:	6c89                	lui	s9,0x2
    800032e8:	a831                	j	80003304 <balloc+0x54>
    brelse(bp);
    800032ea:	854a                	mv	a0,s2
    800032ec:	00000097          	auipc	ra,0x0
    800032f0:	e32080e7          	jalr	-462(ra) # 8000311e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800032f4:	015c87bb          	addw	a5,s9,s5
    800032f8:	00078a9b          	sext.w	s5,a5
    800032fc:	004b2703          	lw	a4,4(s6)
    80003300:	06eaf163          	bgeu	s5,a4,80003362 <balloc+0xb2>
    bp = bread(dev, BBLOCK(b, sb));
    80003304:	41fad79b          	sraiw	a5,s5,0x1f
    80003308:	0137d79b          	srliw	a5,a5,0x13
    8000330c:	015787bb          	addw	a5,a5,s5
    80003310:	40d7d79b          	sraiw	a5,a5,0xd
    80003314:	01cb2583          	lw	a1,28(s6)
    80003318:	9dbd                	addw	a1,a1,a5
    8000331a:	855e                	mv	a0,s7
    8000331c:	00000097          	auipc	ra,0x0
    80003320:	cd2080e7          	jalr	-814(ra) # 80002fee <bread>
    80003324:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003326:	004b2503          	lw	a0,4(s6)
    8000332a:	000a849b          	sext.w	s1,s5
    8000332e:	8762                	mv	a4,s8
    80003330:	faa4fde3          	bgeu	s1,a0,800032ea <balloc+0x3a>
      m = 1 << (bi % 8);
    80003334:	00777693          	andi	a3,a4,7
    80003338:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000333c:	41f7579b          	sraiw	a5,a4,0x1f
    80003340:	01d7d79b          	srliw	a5,a5,0x1d
    80003344:	9fb9                	addw	a5,a5,a4
    80003346:	4037d79b          	sraiw	a5,a5,0x3
    8000334a:	00f90633          	add	a2,s2,a5
    8000334e:	05864603          	lbu	a2,88(a2)
    80003352:	00c6f5b3          	and	a1,a3,a2
    80003356:	cd91                	beqz	a1,80003372 <balloc+0xc2>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003358:	2705                	addiw	a4,a4,1
    8000335a:	2485                	addiw	s1,s1,1
    8000335c:	fd471ae3          	bne	a4,s4,80003330 <balloc+0x80>
    80003360:	b769                	j	800032ea <balloc+0x3a>
  panic("balloc: out of blocks");
    80003362:	00005517          	auipc	a0,0x5
    80003366:	1de50513          	addi	a0,a0,478 # 80008540 <syscalls+0x110>
    8000336a:	ffffd097          	auipc	ra,0xffffd
    8000336e:	1dc080e7          	jalr	476(ra) # 80000546 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003372:	97ca                	add	a5,a5,s2
    80003374:	8e55                	or	a2,a2,a3
    80003376:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000337a:	854a                	mv	a0,s2
    8000337c:	00001097          	auipc	ra,0x1
    80003380:	00e080e7          	jalr	14(ra) # 8000438a <log_write>
        brelse(bp);
    80003384:	854a                	mv	a0,s2
    80003386:	00000097          	auipc	ra,0x0
    8000338a:	d98080e7          	jalr	-616(ra) # 8000311e <brelse>
  bp = bread(dev, bno);
    8000338e:	85a6                	mv	a1,s1
    80003390:	855e                	mv	a0,s7
    80003392:	00000097          	auipc	ra,0x0
    80003396:	c5c080e7          	jalr	-932(ra) # 80002fee <bread>
    8000339a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000339c:	40000613          	li	a2,1024
    800033a0:	4581                	li	a1,0
    800033a2:	05850513          	addi	a0,a0,88
    800033a6:	ffffe097          	auipc	ra,0xffffe
    800033aa:	9b2080e7          	jalr	-1614(ra) # 80000d58 <memset>
  log_write(bp);
    800033ae:	854a                	mv	a0,s2
    800033b0:	00001097          	auipc	ra,0x1
    800033b4:	fda080e7          	jalr	-38(ra) # 8000438a <log_write>
  brelse(bp);
    800033b8:	854a                	mv	a0,s2
    800033ba:	00000097          	auipc	ra,0x0
    800033be:	d64080e7          	jalr	-668(ra) # 8000311e <brelse>
}
    800033c2:	8526                	mv	a0,s1
    800033c4:	60e6                	ld	ra,88(sp)
    800033c6:	6446                	ld	s0,80(sp)
    800033c8:	64a6                	ld	s1,72(sp)
    800033ca:	6906                	ld	s2,64(sp)
    800033cc:	79e2                	ld	s3,56(sp)
    800033ce:	7a42                	ld	s4,48(sp)
    800033d0:	7aa2                	ld	s5,40(sp)
    800033d2:	7b02                	ld	s6,32(sp)
    800033d4:	6be2                	ld	s7,24(sp)
    800033d6:	6c42                	ld	s8,16(sp)
    800033d8:	6ca2                	ld	s9,8(sp)
    800033da:	6125                	addi	sp,sp,96
    800033dc:	8082                	ret

00000000800033de <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800033de:	7179                	addi	sp,sp,-48
    800033e0:	f406                	sd	ra,40(sp)
    800033e2:	f022                	sd	s0,32(sp)
    800033e4:	ec26                	sd	s1,24(sp)
    800033e6:	e84a                	sd	s2,16(sp)
    800033e8:	e44e                	sd	s3,8(sp)
    800033ea:	e052                	sd	s4,0(sp)
    800033ec:	1800                	addi	s0,sp,48
    800033ee:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033f0:	47ad                	li	a5,11
    800033f2:	04b7fe63          	bgeu	a5,a1,8000344e <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800033f6:	ff45849b          	addiw	s1,a1,-12
    800033fa:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033fe:	0ff00793          	li	a5,255
    80003402:	0ae7e463          	bltu	a5,a4,800034aa <bmap+0xcc>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    80003406:	08052583          	lw	a1,128(a0)
    8000340a:	c5b5                	beqz	a1,80003476 <bmap+0x98>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    8000340c:	00092503          	lw	a0,0(s2)
    80003410:	00000097          	auipc	ra,0x0
    80003414:	bde080e7          	jalr	-1058(ra) # 80002fee <bread>
    80003418:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000341a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000341e:	02049713          	slli	a4,s1,0x20
    80003422:	01e75593          	srli	a1,a4,0x1e
    80003426:	00b784b3          	add	s1,a5,a1
    8000342a:	0004a983          	lw	s3,0(s1)
    8000342e:	04098e63          	beqz	s3,8000348a <bmap+0xac>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80003432:	8552                	mv	a0,s4
    80003434:	00000097          	auipc	ra,0x0
    80003438:	cea080e7          	jalr	-790(ra) # 8000311e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000343c:	854e                	mv	a0,s3
    8000343e:	70a2                	ld	ra,40(sp)
    80003440:	7402                	ld	s0,32(sp)
    80003442:	64e2                	ld	s1,24(sp)
    80003444:	6942                	ld	s2,16(sp)
    80003446:	69a2                	ld	s3,8(sp)
    80003448:	6a02                	ld	s4,0(sp)
    8000344a:	6145                	addi	sp,sp,48
    8000344c:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    8000344e:	02059793          	slli	a5,a1,0x20
    80003452:	01e7d593          	srli	a1,a5,0x1e
    80003456:	00b504b3          	add	s1,a0,a1
    8000345a:	0504a983          	lw	s3,80(s1)
    8000345e:	fc099fe3          	bnez	s3,8000343c <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80003462:	4108                	lw	a0,0(a0)
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e4c080e7          	jalr	-436(ra) # 800032b0 <balloc>
    8000346c:	0005099b          	sext.w	s3,a0
    80003470:	0534a823          	sw	s3,80(s1)
    80003474:	b7e1                	j	8000343c <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80003476:	4108                	lw	a0,0(a0)
    80003478:	00000097          	auipc	ra,0x0
    8000347c:	e38080e7          	jalr	-456(ra) # 800032b0 <balloc>
    80003480:	0005059b          	sext.w	a1,a0
    80003484:	08b92023          	sw	a1,128(s2)
    80003488:	b751                	j	8000340c <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000348a:	00092503          	lw	a0,0(s2)
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	e22080e7          	jalr	-478(ra) # 800032b0 <balloc>
    80003496:	0005099b          	sext.w	s3,a0
    8000349a:	0134a023          	sw	s3,0(s1)
      log_write(bp);
    8000349e:	8552                	mv	a0,s4
    800034a0:	00001097          	auipc	ra,0x1
    800034a4:	eea080e7          	jalr	-278(ra) # 8000438a <log_write>
    800034a8:	b769                	j	80003432 <bmap+0x54>
  panic("bmap: out of range");
    800034aa:	00005517          	auipc	a0,0x5
    800034ae:	0ae50513          	addi	a0,a0,174 # 80008558 <syscalls+0x128>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	094080e7          	jalr	148(ra) # 80000546 <panic>

00000000800034ba <iget>:
{
    800034ba:	7179                	addi	sp,sp,-48
    800034bc:	f406                	sd	ra,40(sp)
    800034be:	f022                	sd	s0,32(sp)
    800034c0:	ec26                	sd	s1,24(sp)
    800034c2:	e84a                	sd	s2,16(sp)
    800034c4:	e44e                	sd	s3,8(sp)
    800034c6:	e052                	sd	s4,0(sp)
    800034c8:	1800                	addi	s0,sp,48
    800034ca:	89aa                	mv	s3,a0
    800034cc:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    800034ce:	0001d517          	auipc	a0,0x1d
    800034d2:	39250513          	addi	a0,a0,914 # 80020860 <icache>
    800034d6:	ffffd097          	auipc	ra,0xffffd
    800034da:	786080e7          	jalr	1926(ra) # 80000c5c <acquire>
  empty = 0;
    800034de:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034e0:	0001d497          	auipc	s1,0x1d
    800034e4:	39848493          	addi	s1,s1,920 # 80020878 <icache+0x18>
    800034e8:	0001f697          	auipc	a3,0x1f
    800034ec:	e2068693          	addi	a3,a3,-480 # 80022308 <log>
    800034f0:	a039                	j	800034fe <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034f2:	02090b63          	beqz	s2,80003528 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800034f6:	08848493          	addi	s1,s1,136
    800034fa:	02d48a63          	beq	s1,a3,8000352e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034fe:	449c                	lw	a5,8(s1)
    80003500:	fef059e3          	blez	a5,800034f2 <iget+0x38>
    80003504:	4098                	lw	a4,0(s1)
    80003506:	ff3716e3          	bne	a4,s3,800034f2 <iget+0x38>
    8000350a:	40d8                	lw	a4,4(s1)
    8000350c:	ff4713e3          	bne	a4,s4,800034f2 <iget+0x38>
      ip->ref++;
    80003510:	2785                	addiw	a5,a5,1
    80003512:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    80003514:	0001d517          	auipc	a0,0x1d
    80003518:	34c50513          	addi	a0,a0,844 # 80020860 <icache>
    8000351c:	ffffd097          	auipc	ra,0xffffd
    80003520:	7f4080e7          	jalr	2036(ra) # 80000d10 <release>
      return ip;
    80003524:	8926                	mv	s2,s1
    80003526:	a03d                	j	80003554 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003528:	f7f9                	bnez	a5,800034f6 <iget+0x3c>
    8000352a:	8926                	mv	s2,s1
    8000352c:	b7e9                	j	800034f6 <iget+0x3c>
  if(empty == 0)
    8000352e:	02090c63          	beqz	s2,80003566 <iget+0xac>
  ip->dev = dev;
    80003532:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003536:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000353a:	4785                	li	a5,1
    8000353c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003540:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80003544:	0001d517          	auipc	a0,0x1d
    80003548:	31c50513          	addi	a0,a0,796 # 80020860 <icache>
    8000354c:	ffffd097          	auipc	ra,0xffffd
    80003550:	7c4080e7          	jalr	1988(ra) # 80000d10 <release>
}
    80003554:	854a                	mv	a0,s2
    80003556:	70a2                	ld	ra,40(sp)
    80003558:	7402                	ld	s0,32(sp)
    8000355a:	64e2                	ld	s1,24(sp)
    8000355c:	6942                	ld	s2,16(sp)
    8000355e:	69a2                	ld	s3,8(sp)
    80003560:	6a02                	ld	s4,0(sp)
    80003562:	6145                	addi	sp,sp,48
    80003564:	8082                	ret
    panic("iget: no inodes");
    80003566:	00005517          	auipc	a0,0x5
    8000356a:	00a50513          	addi	a0,a0,10 # 80008570 <syscalls+0x140>
    8000356e:	ffffd097          	auipc	ra,0xffffd
    80003572:	fd8080e7          	jalr	-40(ra) # 80000546 <panic>

0000000080003576 <fsinit>:
fsinit(int dev) {
    80003576:	7179                	addi	sp,sp,-48
    80003578:	f406                	sd	ra,40(sp)
    8000357a:	f022                	sd	s0,32(sp)
    8000357c:	ec26                	sd	s1,24(sp)
    8000357e:	e84a                	sd	s2,16(sp)
    80003580:	e44e                	sd	s3,8(sp)
    80003582:	1800                	addi	s0,sp,48
    80003584:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003586:	4585                	li	a1,1
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	a66080e7          	jalr	-1434(ra) # 80002fee <bread>
    80003590:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003592:	0001d997          	auipc	s3,0x1d
    80003596:	2ae98993          	addi	s3,s3,686 # 80020840 <sb>
    8000359a:	02000613          	li	a2,32
    8000359e:	05850593          	addi	a1,a0,88
    800035a2:	854e                	mv	a0,s3
    800035a4:	ffffe097          	auipc	ra,0xffffe
    800035a8:	810080e7          	jalr	-2032(ra) # 80000db4 <memmove>
  brelse(bp);
    800035ac:	8526                	mv	a0,s1
    800035ae:	00000097          	auipc	ra,0x0
    800035b2:	b70080e7          	jalr	-1168(ra) # 8000311e <brelse>
  if(sb.magic != FSMAGIC)
    800035b6:	0009a703          	lw	a4,0(s3)
    800035ba:	102037b7          	lui	a5,0x10203
    800035be:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035c2:	02f71263          	bne	a4,a5,800035e6 <fsinit+0x70>
  initlog(dev, &sb);
    800035c6:	0001d597          	auipc	a1,0x1d
    800035ca:	27a58593          	addi	a1,a1,634 # 80020840 <sb>
    800035ce:	854a                	mv	a0,s2
    800035d0:	00001097          	auipc	ra,0x1
    800035d4:	b42080e7          	jalr	-1214(ra) # 80004112 <initlog>
}
    800035d8:	70a2                	ld	ra,40(sp)
    800035da:	7402                	ld	s0,32(sp)
    800035dc:	64e2                	ld	s1,24(sp)
    800035de:	6942                	ld	s2,16(sp)
    800035e0:	69a2                	ld	s3,8(sp)
    800035e2:	6145                	addi	sp,sp,48
    800035e4:	8082                	ret
    panic("invalid file system");
    800035e6:	00005517          	auipc	a0,0x5
    800035ea:	f9a50513          	addi	a0,a0,-102 # 80008580 <syscalls+0x150>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	f58080e7          	jalr	-168(ra) # 80000546 <panic>

00000000800035f6 <iinit>:
{
    800035f6:	7179                	addi	sp,sp,-48
    800035f8:	f406                	sd	ra,40(sp)
    800035fa:	f022                	sd	s0,32(sp)
    800035fc:	ec26                	sd	s1,24(sp)
    800035fe:	e84a                	sd	s2,16(sp)
    80003600:	e44e                	sd	s3,8(sp)
    80003602:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    80003604:	00005597          	auipc	a1,0x5
    80003608:	f9458593          	addi	a1,a1,-108 # 80008598 <syscalls+0x168>
    8000360c:	0001d517          	auipc	a0,0x1d
    80003610:	25450513          	addi	a0,a0,596 # 80020860 <icache>
    80003614:	ffffd097          	auipc	ra,0xffffd
    80003618:	5b8080e7          	jalr	1464(ra) # 80000bcc <initlock>
  for(i = 0; i < NINODE; i++) {
    8000361c:	0001d497          	auipc	s1,0x1d
    80003620:	26c48493          	addi	s1,s1,620 # 80020888 <icache+0x28>
    80003624:	0001f997          	auipc	s3,0x1f
    80003628:	cf498993          	addi	s3,s3,-780 # 80022318 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    8000362c:	00005917          	auipc	s2,0x5
    80003630:	f7490913          	addi	s2,s2,-140 # 800085a0 <syscalls+0x170>
    80003634:	85ca                	mv	a1,s2
    80003636:	8526                	mv	a0,s1
    80003638:	00001097          	auipc	ra,0x1
    8000363c:	e3e080e7          	jalr	-450(ra) # 80004476 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003640:	08848493          	addi	s1,s1,136
    80003644:	ff3498e3          	bne	s1,s3,80003634 <iinit+0x3e>
}
    80003648:	70a2                	ld	ra,40(sp)
    8000364a:	7402                	ld	s0,32(sp)
    8000364c:	64e2                	ld	s1,24(sp)
    8000364e:	6942                	ld	s2,16(sp)
    80003650:	69a2                	ld	s3,8(sp)
    80003652:	6145                	addi	sp,sp,48
    80003654:	8082                	ret

0000000080003656 <ialloc>:
{
    80003656:	715d                	addi	sp,sp,-80
    80003658:	e486                	sd	ra,72(sp)
    8000365a:	e0a2                	sd	s0,64(sp)
    8000365c:	fc26                	sd	s1,56(sp)
    8000365e:	f84a                	sd	s2,48(sp)
    80003660:	f44e                	sd	s3,40(sp)
    80003662:	f052                	sd	s4,32(sp)
    80003664:	ec56                	sd	s5,24(sp)
    80003666:	e85a                	sd	s6,16(sp)
    80003668:	e45e                	sd	s7,8(sp)
    8000366a:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    8000366c:	0001d717          	auipc	a4,0x1d
    80003670:	1e072703          	lw	a4,480(a4) # 8002084c <sb+0xc>
    80003674:	4785                	li	a5,1
    80003676:	04e7fa63          	bgeu	a5,a4,800036ca <ialloc+0x74>
    8000367a:	8aaa                	mv	s5,a0
    8000367c:	8bae                	mv	s7,a1
    8000367e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003680:	0001da17          	auipc	s4,0x1d
    80003684:	1c0a0a13          	addi	s4,s4,448 # 80020840 <sb>
    80003688:	00048b1b          	sext.w	s6,s1
    8000368c:	0044d593          	srli	a1,s1,0x4
    80003690:	018a2783          	lw	a5,24(s4)
    80003694:	9dbd                	addw	a1,a1,a5
    80003696:	8556                	mv	a0,s5
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	956080e7          	jalr	-1706(ra) # 80002fee <bread>
    800036a0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036a2:	05850993          	addi	s3,a0,88
    800036a6:	00f4f793          	andi	a5,s1,15
    800036aa:	079a                	slli	a5,a5,0x6
    800036ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036ae:	00099783          	lh	a5,0(s3)
    800036b2:	c785                	beqz	a5,800036da <ialloc+0x84>
    brelse(bp);
    800036b4:	00000097          	auipc	ra,0x0
    800036b8:	a6a080e7          	jalr	-1430(ra) # 8000311e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036bc:	0485                	addi	s1,s1,1
    800036be:	00ca2703          	lw	a4,12(s4)
    800036c2:	0004879b          	sext.w	a5,s1
    800036c6:	fce7e1e3          	bltu	a5,a4,80003688 <ialloc+0x32>
  panic("ialloc: no inodes");
    800036ca:	00005517          	auipc	a0,0x5
    800036ce:	ede50513          	addi	a0,a0,-290 # 800085a8 <syscalls+0x178>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	e74080e7          	jalr	-396(ra) # 80000546 <panic>
      memset(dip, 0, sizeof(*dip));
    800036da:	04000613          	li	a2,64
    800036de:	4581                	li	a1,0
    800036e0:	854e                	mv	a0,s3
    800036e2:	ffffd097          	auipc	ra,0xffffd
    800036e6:	676080e7          	jalr	1654(ra) # 80000d58 <memset>
      dip->type = type;
    800036ea:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036ee:	854a                	mv	a0,s2
    800036f0:	00001097          	auipc	ra,0x1
    800036f4:	c9a080e7          	jalr	-870(ra) # 8000438a <log_write>
      brelse(bp);
    800036f8:	854a                	mv	a0,s2
    800036fa:	00000097          	auipc	ra,0x0
    800036fe:	a24080e7          	jalr	-1500(ra) # 8000311e <brelse>
      return iget(dev, inum);
    80003702:	85da                	mv	a1,s6
    80003704:	8556                	mv	a0,s5
    80003706:	00000097          	auipc	ra,0x0
    8000370a:	db4080e7          	jalr	-588(ra) # 800034ba <iget>
}
    8000370e:	60a6                	ld	ra,72(sp)
    80003710:	6406                	ld	s0,64(sp)
    80003712:	74e2                	ld	s1,56(sp)
    80003714:	7942                	ld	s2,48(sp)
    80003716:	79a2                	ld	s3,40(sp)
    80003718:	7a02                	ld	s4,32(sp)
    8000371a:	6ae2                	ld	s5,24(sp)
    8000371c:	6b42                	ld	s6,16(sp)
    8000371e:	6ba2                	ld	s7,8(sp)
    80003720:	6161                	addi	sp,sp,80
    80003722:	8082                	ret

0000000080003724 <iupdate>:
{
    80003724:	1101                	addi	sp,sp,-32
    80003726:	ec06                	sd	ra,24(sp)
    80003728:	e822                	sd	s0,16(sp)
    8000372a:	e426                	sd	s1,8(sp)
    8000372c:	e04a                	sd	s2,0(sp)
    8000372e:	1000                	addi	s0,sp,32
    80003730:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003732:	415c                	lw	a5,4(a0)
    80003734:	0047d79b          	srliw	a5,a5,0x4
    80003738:	0001d597          	auipc	a1,0x1d
    8000373c:	1205a583          	lw	a1,288(a1) # 80020858 <sb+0x18>
    80003740:	9dbd                	addw	a1,a1,a5
    80003742:	4108                	lw	a0,0(a0)
    80003744:	00000097          	auipc	ra,0x0
    80003748:	8aa080e7          	jalr	-1878(ra) # 80002fee <bread>
    8000374c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000374e:	05850793          	addi	a5,a0,88
    80003752:	40d8                	lw	a4,4(s1)
    80003754:	8b3d                	andi	a4,a4,15
    80003756:	071a                	slli	a4,a4,0x6
    80003758:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000375a:	04449703          	lh	a4,68(s1)
    8000375e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003762:	04649703          	lh	a4,70(s1)
    80003766:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000376a:	04849703          	lh	a4,72(s1)
    8000376e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003772:	04a49703          	lh	a4,74(s1)
    80003776:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000377a:	44f8                	lw	a4,76(s1)
    8000377c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000377e:	03400613          	li	a2,52
    80003782:	05048593          	addi	a1,s1,80
    80003786:	00c78513          	addi	a0,a5,12
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	62a080e7          	jalr	1578(ra) # 80000db4 <memmove>
  log_write(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	00001097          	auipc	ra,0x1
    80003798:	bf6080e7          	jalr	-1034(ra) # 8000438a <log_write>
  brelse(bp);
    8000379c:	854a                	mv	a0,s2
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	980080e7          	jalr	-1664(ra) # 8000311e <brelse>
}
    800037a6:	60e2                	ld	ra,24(sp)
    800037a8:	6442                	ld	s0,16(sp)
    800037aa:	64a2                	ld	s1,8(sp)
    800037ac:	6902                	ld	s2,0(sp)
    800037ae:	6105                	addi	sp,sp,32
    800037b0:	8082                	ret

00000000800037b2 <idup>:
{
    800037b2:	1101                	addi	sp,sp,-32
    800037b4:	ec06                	sd	ra,24(sp)
    800037b6:	e822                	sd	s0,16(sp)
    800037b8:	e426                	sd	s1,8(sp)
    800037ba:	1000                	addi	s0,sp,32
    800037bc:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800037be:	0001d517          	auipc	a0,0x1d
    800037c2:	0a250513          	addi	a0,a0,162 # 80020860 <icache>
    800037c6:	ffffd097          	auipc	ra,0xffffd
    800037ca:	496080e7          	jalr	1174(ra) # 80000c5c <acquire>
  ip->ref++;
    800037ce:	449c                	lw	a5,8(s1)
    800037d0:	2785                	addiw	a5,a5,1
    800037d2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800037d4:	0001d517          	auipc	a0,0x1d
    800037d8:	08c50513          	addi	a0,a0,140 # 80020860 <icache>
    800037dc:	ffffd097          	auipc	ra,0xffffd
    800037e0:	534080e7          	jalr	1332(ra) # 80000d10 <release>
}
    800037e4:	8526                	mv	a0,s1
    800037e6:	60e2                	ld	ra,24(sp)
    800037e8:	6442                	ld	s0,16(sp)
    800037ea:	64a2                	ld	s1,8(sp)
    800037ec:	6105                	addi	sp,sp,32
    800037ee:	8082                	ret

00000000800037f0 <ilock>:
{
    800037f0:	1101                	addi	sp,sp,-32
    800037f2:	ec06                	sd	ra,24(sp)
    800037f4:	e822                	sd	s0,16(sp)
    800037f6:	e426                	sd	s1,8(sp)
    800037f8:	e04a                	sd	s2,0(sp)
    800037fa:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037fc:	c115                	beqz	a0,80003820 <ilock+0x30>
    800037fe:	84aa                	mv	s1,a0
    80003800:	451c                	lw	a5,8(a0)
    80003802:	00f05f63          	blez	a5,80003820 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003806:	0541                	addi	a0,a0,16
    80003808:	00001097          	auipc	ra,0x1
    8000380c:	ca8080e7          	jalr	-856(ra) # 800044b0 <acquiresleep>
  if(ip->valid == 0){
    80003810:	40bc                	lw	a5,64(s1)
    80003812:	cf99                	beqz	a5,80003830 <ilock+0x40>
}
    80003814:	60e2                	ld	ra,24(sp)
    80003816:	6442                	ld	s0,16(sp)
    80003818:	64a2                	ld	s1,8(sp)
    8000381a:	6902                	ld	s2,0(sp)
    8000381c:	6105                	addi	sp,sp,32
    8000381e:	8082                	ret
    panic("ilock");
    80003820:	00005517          	auipc	a0,0x5
    80003824:	da050513          	addi	a0,a0,-608 # 800085c0 <syscalls+0x190>
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	d1e080e7          	jalr	-738(ra) # 80000546 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003830:	40dc                	lw	a5,4(s1)
    80003832:	0047d79b          	srliw	a5,a5,0x4
    80003836:	0001d597          	auipc	a1,0x1d
    8000383a:	0225a583          	lw	a1,34(a1) # 80020858 <sb+0x18>
    8000383e:	9dbd                	addw	a1,a1,a5
    80003840:	4088                	lw	a0,0(s1)
    80003842:	fffff097          	auipc	ra,0xfffff
    80003846:	7ac080e7          	jalr	1964(ra) # 80002fee <bread>
    8000384a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384c:	05850593          	addi	a1,a0,88
    80003850:	40dc                	lw	a5,4(s1)
    80003852:	8bbd                	andi	a5,a5,15
    80003854:	079a                	slli	a5,a5,0x6
    80003856:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003858:	00059783          	lh	a5,0(a1)
    8000385c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003860:	00259783          	lh	a5,2(a1)
    80003864:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003868:	00459783          	lh	a5,4(a1)
    8000386c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003870:	00659783          	lh	a5,6(a1)
    80003874:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003878:	459c                	lw	a5,8(a1)
    8000387a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000387c:	03400613          	li	a2,52
    80003880:	05b1                	addi	a1,a1,12
    80003882:	05048513          	addi	a0,s1,80
    80003886:	ffffd097          	auipc	ra,0xffffd
    8000388a:	52e080e7          	jalr	1326(ra) # 80000db4 <memmove>
    brelse(bp);
    8000388e:	854a                	mv	a0,s2
    80003890:	00000097          	auipc	ra,0x0
    80003894:	88e080e7          	jalr	-1906(ra) # 8000311e <brelse>
    ip->valid = 1;
    80003898:	4785                	li	a5,1
    8000389a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000389c:	04449783          	lh	a5,68(s1)
    800038a0:	fbb5                	bnez	a5,80003814 <ilock+0x24>
      panic("ilock: no type");
    800038a2:	00005517          	auipc	a0,0x5
    800038a6:	d2650513          	addi	a0,a0,-730 # 800085c8 <syscalls+0x198>
    800038aa:	ffffd097          	auipc	ra,0xffffd
    800038ae:	c9c080e7          	jalr	-868(ra) # 80000546 <panic>

00000000800038b2 <iunlock>:
{
    800038b2:	1101                	addi	sp,sp,-32
    800038b4:	ec06                	sd	ra,24(sp)
    800038b6:	e822                	sd	s0,16(sp)
    800038b8:	e426                	sd	s1,8(sp)
    800038ba:	e04a                	sd	s2,0(sp)
    800038bc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038be:	c905                	beqz	a0,800038ee <iunlock+0x3c>
    800038c0:	84aa                	mv	s1,a0
    800038c2:	01050913          	addi	s2,a0,16
    800038c6:	854a                	mv	a0,s2
    800038c8:	00001097          	auipc	ra,0x1
    800038cc:	c82080e7          	jalr	-894(ra) # 8000454a <holdingsleep>
    800038d0:	cd19                	beqz	a0,800038ee <iunlock+0x3c>
    800038d2:	449c                	lw	a5,8(s1)
    800038d4:	00f05d63          	blez	a5,800038ee <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038d8:	854a                	mv	a0,s2
    800038da:	00001097          	auipc	ra,0x1
    800038de:	c2c080e7          	jalr	-980(ra) # 80004506 <releasesleep>
}
    800038e2:	60e2                	ld	ra,24(sp)
    800038e4:	6442                	ld	s0,16(sp)
    800038e6:	64a2                	ld	s1,8(sp)
    800038e8:	6902                	ld	s2,0(sp)
    800038ea:	6105                	addi	sp,sp,32
    800038ec:	8082                	ret
    panic("iunlock");
    800038ee:	00005517          	auipc	a0,0x5
    800038f2:	cea50513          	addi	a0,a0,-790 # 800085d8 <syscalls+0x1a8>
    800038f6:	ffffd097          	auipc	ra,0xffffd
    800038fa:	c50080e7          	jalr	-944(ra) # 80000546 <panic>

00000000800038fe <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038fe:	7179                	addi	sp,sp,-48
    80003900:	f406                	sd	ra,40(sp)
    80003902:	f022                	sd	s0,32(sp)
    80003904:	ec26                	sd	s1,24(sp)
    80003906:	e84a                	sd	s2,16(sp)
    80003908:	e44e                	sd	s3,8(sp)
    8000390a:	e052                	sd	s4,0(sp)
    8000390c:	1800                	addi	s0,sp,48
    8000390e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003910:	05050493          	addi	s1,a0,80
    80003914:	08050913          	addi	s2,a0,128
    80003918:	a021                	j	80003920 <itrunc+0x22>
    8000391a:	0491                	addi	s1,s1,4
    8000391c:	01248d63          	beq	s1,s2,80003936 <itrunc+0x38>
    if(ip->addrs[i]){
    80003920:	408c                	lw	a1,0(s1)
    80003922:	dde5                	beqz	a1,8000391a <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003924:	0009a503          	lw	a0,0(s3)
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	90c080e7          	jalr	-1780(ra) # 80003234 <bfree>
      ip->addrs[i] = 0;
    80003930:	0004a023          	sw	zero,0(s1)
    80003934:	b7dd                	j	8000391a <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003936:	0809a583          	lw	a1,128(s3)
    8000393a:	e185                	bnez	a1,8000395a <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000393c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003940:	854e                	mv	a0,s3
    80003942:	00000097          	auipc	ra,0x0
    80003946:	de2080e7          	jalr	-542(ra) # 80003724 <iupdate>
}
    8000394a:	70a2                	ld	ra,40(sp)
    8000394c:	7402                	ld	s0,32(sp)
    8000394e:	64e2                	ld	s1,24(sp)
    80003950:	6942                	ld	s2,16(sp)
    80003952:	69a2                	ld	s3,8(sp)
    80003954:	6a02                	ld	s4,0(sp)
    80003956:	6145                	addi	sp,sp,48
    80003958:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000395a:	0009a503          	lw	a0,0(s3)
    8000395e:	fffff097          	auipc	ra,0xfffff
    80003962:	690080e7          	jalr	1680(ra) # 80002fee <bread>
    80003966:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003968:	05850493          	addi	s1,a0,88
    8000396c:	45850913          	addi	s2,a0,1112
    80003970:	a021                	j	80003978 <itrunc+0x7a>
    80003972:	0491                	addi	s1,s1,4
    80003974:	01248b63          	beq	s1,s2,8000398a <itrunc+0x8c>
      if(a[j])
    80003978:	408c                	lw	a1,0(s1)
    8000397a:	dde5                	beqz	a1,80003972 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    8000397c:	0009a503          	lw	a0,0(s3)
    80003980:	00000097          	auipc	ra,0x0
    80003984:	8b4080e7          	jalr	-1868(ra) # 80003234 <bfree>
    80003988:	b7ed                	j	80003972 <itrunc+0x74>
    brelse(bp);
    8000398a:	8552                	mv	a0,s4
    8000398c:	fffff097          	auipc	ra,0xfffff
    80003990:	792080e7          	jalr	1938(ra) # 8000311e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003994:	0809a583          	lw	a1,128(s3)
    80003998:	0009a503          	lw	a0,0(s3)
    8000399c:	00000097          	auipc	ra,0x0
    800039a0:	898080e7          	jalr	-1896(ra) # 80003234 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039a4:	0809a023          	sw	zero,128(s3)
    800039a8:	bf51                	j	8000393c <itrunc+0x3e>

00000000800039aa <iput>:
{
    800039aa:	1101                	addi	sp,sp,-32
    800039ac:	ec06                	sd	ra,24(sp)
    800039ae:	e822                	sd	s0,16(sp)
    800039b0:	e426                	sd	s1,8(sp)
    800039b2:	e04a                	sd	s2,0(sp)
    800039b4:	1000                	addi	s0,sp,32
    800039b6:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    800039b8:	0001d517          	auipc	a0,0x1d
    800039bc:	ea850513          	addi	a0,a0,-344 # 80020860 <icache>
    800039c0:	ffffd097          	auipc	ra,0xffffd
    800039c4:	29c080e7          	jalr	668(ra) # 80000c5c <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039c8:	4498                	lw	a4,8(s1)
    800039ca:	4785                	li	a5,1
    800039cc:	02f70363          	beq	a4,a5,800039f2 <iput+0x48>
  ip->ref--;
    800039d0:	449c                	lw	a5,8(s1)
    800039d2:	37fd                	addiw	a5,a5,-1
    800039d4:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    800039d6:	0001d517          	auipc	a0,0x1d
    800039da:	e8a50513          	addi	a0,a0,-374 # 80020860 <icache>
    800039de:	ffffd097          	auipc	ra,0xffffd
    800039e2:	332080e7          	jalr	818(ra) # 80000d10 <release>
}
    800039e6:	60e2                	ld	ra,24(sp)
    800039e8:	6442                	ld	s0,16(sp)
    800039ea:	64a2                	ld	s1,8(sp)
    800039ec:	6902                	ld	s2,0(sp)
    800039ee:	6105                	addi	sp,sp,32
    800039f0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039f2:	40bc                	lw	a5,64(s1)
    800039f4:	dff1                	beqz	a5,800039d0 <iput+0x26>
    800039f6:	04a49783          	lh	a5,74(s1)
    800039fa:	fbf9                	bnez	a5,800039d0 <iput+0x26>
    acquiresleep(&ip->lock);
    800039fc:	01048913          	addi	s2,s1,16
    80003a00:	854a                	mv	a0,s2
    80003a02:	00001097          	auipc	ra,0x1
    80003a06:	aae080e7          	jalr	-1362(ra) # 800044b0 <acquiresleep>
    release(&icache.lock);
    80003a0a:	0001d517          	auipc	a0,0x1d
    80003a0e:	e5650513          	addi	a0,a0,-426 # 80020860 <icache>
    80003a12:	ffffd097          	auipc	ra,0xffffd
    80003a16:	2fe080e7          	jalr	766(ra) # 80000d10 <release>
    itrunc(ip);
    80003a1a:	8526                	mv	a0,s1
    80003a1c:	00000097          	auipc	ra,0x0
    80003a20:	ee2080e7          	jalr	-286(ra) # 800038fe <itrunc>
    ip->type = 0;
    80003a24:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a28:	8526                	mv	a0,s1
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	cfa080e7          	jalr	-774(ra) # 80003724 <iupdate>
    ip->valid = 0;
    80003a32:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a36:	854a                	mv	a0,s2
    80003a38:	00001097          	auipc	ra,0x1
    80003a3c:	ace080e7          	jalr	-1330(ra) # 80004506 <releasesleep>
    acquire(&icache.lock);
    80003a40:	0001d517          	auipc	a0,0x1d
    80003a44:	e2050513          	addi	a0,a0,-480 # 80020860 <icache>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	214080e7          	jalr	532(ra) # 80000c5c <acquire>
    80003a50:	b741                	j	800039d0 <iput+0x26>

0000000080003a52 <iunlockput>:
{
    80003a52:	1101                	addi	sp,sp,-32
    80003a54:	ec06                	sd	ra,24(sp)
    80003a56:	e822                	sd	s0,16(sp)
    80003a58:	e426                	sd	s1,8(sp)
    80003a5a:	1000                	addi	s0,sp,32
    80003a5c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a5e:	00000097          	auipc	ra,0x0
    80003a62:	e54080e7          	jalr	-428(ra) # 800038b2 <iunlock>
  iput(ip);
    80003a66:	8526                	mv	a0,s1
    80003a68:	00000097          	auipc	ra,0x0
    80003a6c:	f42080e7          	jalr	-190(ra) # 800039aa <iput>
}
    80003a70:	60e2                	ld	ra,24(sp)
    80003a72:	6442                	ld	s0,16(sp)
    80003a74:	64a2                	ld	s1,8(sp)
    80003a76:	6105                	addi	sp,sp,32
    80003a78:	8082                	ret

0000000080003a7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a7a:	1141                	addi	sp,sp,-16
    80003a7c:	e422                	sd	s0,8(sp)
    80003a7e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003a80:	411c                	lw	a5,0(a0)
    80003a82:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a84:	415c                	lw	a5,4(a0)
    80003a86:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a88:	04451783          	lh	a5,68(a0)
    80003a8c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a90:	04a51783          	lh	a5,74(a0)
    80003a94:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a98:	04c56783          	lwu	a5,76(a0)
    80003a9c:	e99c                	sd	a5,16(a1)
}
    80003a9e:	6422                	ld	s0,8(sp)
    80003aa0:	0141                	addi	sp,sp,16
    80003aa2:	8082                	ret

0000000080003aa4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa4:	457c                	lw	a5,76(a0)
    80003aa6:	0ed7e863          	bltu	a5,a3,80003b96 <readi+0xf2>
{
    80003aaa:	7159                	addi	sp,sp,-112
    80003aac:	f486                	sd	ra,104(sp)
    80003aae:	f0a2                	sd	s0,96(sp)
    80003ab0:	eca6                	sd	s1,88(sp)
    80003ab2:	e8ca                	sd	s2,80(sp)
    80003ab4:	e4ce                	sd	s3,72(sp)
    80003ab6:	e0d2                	sd	s4,64(sp)
    80003ab8:	fc56                	sd	s5,56(sp)
    80003aba:	f85a                	sd	s6,48(sp)
    80003abc:	f45e                	sd	s7,40(sp)
    80003abe:	f062                	sd	s8,32(sp)
    80003ac0:	ec66                	sd	s9,24(sp)
    80003ac2:	e86a                	sd	s10,16(sp)
    80003ac4:	e46e                	sd	s11,8(sp)
    80003ac6:	1880                	addi	s0,sp,112
    80003ac8:	8baa                	mv	s7,a0
    80003aca:	8c2e                	mv	s8,a1
    80003acc:	8ab2                	mv	s5,a2
    80003ace:	84b6                	mv	s1,a3
    80003ad0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ad2:	9f35                	addw	a4,a4,a3
    return 0;
    80003ad4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003ad6:	08d76f63          	bltu	a4,a3,80003b74 <readi+0xd0>
  if(off + n > ip->size)
    80003ada:	00e7f463          	bgeu	a5,a4,80003ae2 <readi+0x3e>
    n = ip->size - off;
    80003ade:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae2:	0a0b0863          	beqz	s6,80003b92 <readi+0xee>
    80003ae6:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae8:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003aec:	5cfd                	li	s9,-1
    80003aee:	a82d                	j	80003b28 <readi+0x84>
    80003af0:	020a1d93          	slli	s11,s4,0x20
    80003af4:	020ddd93          	srli	s11,s11,0x20
    80003af8:	05890613          	addi	a2,s2,88
    80003afc:	86ee                	mv	a3,s11
    80003afe:	963a                	add	a2,a2,a4
    80003b00:	85d6                	mv	a1,s5
    80003b02:	8562                	mv	a0,s8
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	9e2080e7          	jalr	-1566(ra) # 800024e6 <either_copyout>
    80003b0c:	05950d63          	beq	a0,s9,80003b66 <readi+0xc2>
      brelse(bp);
      break;
    }
    brelse(bp);
    80003b10:	854a                	mv	a0,s2
    80003b12:	fffff097          	auipc	ra,0xfffff
    80003b16:	60c080e7          	jalr	1548(ra) # 8000311e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b1a:	013a09bb          	addw	s3,s4,s3
    80003b1e:	009a04bb          	addw	s1,s4,s1
    80003b22:	9aee                	add	s5,s5,s11
    80003b24:	0569f663          	bgeu	s3,s6,80003b70 <readi+0xcc>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003b28:	000ba903          	lw	s2,0(s7)
    80003b2c:	00a4d59b          	srliw	a1,s1,0xa
    80003b30:	855e                	mv	a0,s7
    80003b32:	00000097          	auipc	ra,0x0
    80003b36:	8ac080e7          	jalr	-1876(ra) # 800033de <bmap>
    80003b3a:	0005059b          	sext.w	a1,a0
    80003b3e:	854a                	mv	a0,s2
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	4ae080e7          	jalr	1198(ra) # 80002fee <bread>
    80003b48:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b4a:	3ff4f713          	andi	a4,s1,1023
    80003b4e:	40ed07bb          	subw	a5,s10,a4
    80003b52:	413b06bb          	subw	a3,s6,s3
    80003b56:	8a3e                	mv	s4,a5
    80003b58:	2781                	sext.w	a5,a5
    80003b5a:	0006861b          	sext.w	a2,a3
    80003b5e:	f8f679e3          	bgeu	a2,a5,80003af0 <readi+0x4c>
    80003b62:	8a36                	mv	s4,a3
    80003b64:	b771                	j	80003af0 <readi+0x4c>
      brelse(bp);
    80003b66:	854a                	mv	a0,s2
    80003b68:	fffff097          	auipc	ra,0xfffff
    80003b6c:	5b6080e7          	jalr	1462(ra) # 8000311e <brelse>
  }
  return tot;
    80003b70:	0009851b          	sext.w	a0,s3
}
    80003b74:	70a6                	ld	ra,104(sp)
    80003b76:	7406                	ld	s0,96(sp)
    80003b78:	64e6                	ld	s1,88(sp)
    80003b7a:	6946                	ld	s2,80(sp)
    80003b7c:	69a6                	ld	s3,72(sp)
    80003b7e:	6a06                	ld	s4,64(sp)
    80003b80:	7ae2                	ld	s5,56(sp)
    80003b82:	7b42                	ld	s6,48(sp)
    80003b84:	7ba2                	ld	s7,40(sp)
    80003b86:	7c02                	ld	s8,32(sp)
    80003b88:	6ce2                	ld	s9,24(sp)
    80003b8a:	6d42                	ld	s10,16(sp)
    80003b8c:	6da2                	ld	s11,8(sp)
    80003b8e:	6165                	addi	sp,sp,112
    80003b90:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b92:	89da                	mv	s3,s6
    80003b94:	bff1                	j	80003b70 <readi+0xcc>
    return 0;
    80003b96:	4501                	li	a0,0
}
    80003b98:	8082                	ret

0000000080003b9a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b9a:	457c                	lw	a5,76(a0)
    80003b9c:	10d7e663          	bltu	a5,a3,80003ca8 <writei+0x10e>
{
    80003ba0:	7159                	addi	sp,sp,-112
    80003ba2:	f486                	sd	ra,104(sp)
    80003ba4:	f0a2                	sd	s0,96(sp)
    80003ba6:	eca6                	sd	s1,88(sp)
    80003ba8:	e8ca                	sd	s2,80(sp)
    80003baa:	e4ce                	sd	s3,72(sp)
    80003bac:	e0d2                	sd	s4,64(sp)
    80003bae:	fc56                	sd	s5,56(sp)
    80003bb0:	f85a                	sd	s6,48(sp)
    80003bb2:	f45e                	sd	s7,40(sp)
    80003bb4:	f062                	sd	s8,32(sp)
    80003bb6:	ec66                	sd	s9,24(sp)
    80003bb8:	e86a                	sd	s10,16(sp)
    80003bba:	e46e                	sd	s11,8(sp)
    80003bbc:	1880                	addi	s0,sp,112
    80003bbe:	8baa                	mv	s7,a0
    80003bc0:	8c2e                	mv	s8,a1
    80003bc2:	8ab2                	mv	s5,a2
    80003bc4:	8936                	mv	s2,a3
    80003bc6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003bc8:	00e687bb          	addw	a5,a3,a4
    80003bcc:	0ed7e063          	bltu	a5,a3,80003cac <writei+0x112>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003bd0:	00043737          	lui	a4,0x43
    80003bd4:	0cf76e63          	bltu	a4,a5,80003cb0 <writei+0x116>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bd8:	0a0b0763          	beqz	s6,80003c86 <writei+0xec>
    80003bdc:	4a01                	li	s4,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bde:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003be2:	5cfd                	li	s9,-1
    80003be4:	a091                	j	80003c28 <writei+0x8e>
    80003be6:	02099d93          	slli	s11,s3,0x20
    80003bea:	020ddd93          	srli	s11,s11,0x20
    80003bee:	05848513          	addi	a0,s1,88
    80003bf2:	86ee                	mv	a3,s11
    80003bf4:	8656                	mv	a2,s5
    80003bf6:	85e2                	mv	a1,s8
    80003bf8:	953a                	add	a0,a0,a4
    80003bfa:	fffff097          	auipc	ra,0xfffff
    80003bfe:	942080e7          	jalr	-1726(ra) # 8000253c <either_copyin>
    80003c02:	07950263          	beq	a0,s9,80003c66 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003c06:	8526                	mv	a0,s1
    80003c08:	00000097          	auipc	ra,0x0
    80003c0c:	782080e7          	jalr	1922(ra) # 8000438a <log_write>
    brelse(bp);
    80003c10:	8526                	mv	a0,s1
    80003c12:	fffff097          	auipc	ra,0xfffff
    80003c16:	50c080e7          	jalr	1292(ra) # 8000311e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c1a:	01498a3b          	addw	s4,s3,s4
    80003c1e:	0129893b          	addw	s2,s3,s2
    80003c22:	9aee                	add	s5,s5,s11
    80003c24:	056a7663          	bgeu	s4,s6,80003c70 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80003c28:	000ba483          	lw	s1,0(s7)
    80003c2c:	00a9559b          	srliw	a1,s2,0xa
    80003c30:	855e                	mv	a0,s7
    80003c32:	fffff097          	auipc	ra,0xfffff
    80003c36:	7ac080e7          	jalr	1964(ra) # 800033de <bmap>
    80003c3a:	0005059b          	sext.w	a1,a0
    80003c3e:	8526                	mv	a0,s1
    80003c40:	fffff097          	auipc	ra,0xfffff
    80003c44:	3ae080e7          	jalr	942(ra) # 80002fee <bread>
    80003c48:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c4a:	3ff97713          	andi	a4,s2,1023
    80003c4e:	40ed07bb          	subw	a5,s10,a4
    80003c52:	414b06bb          	subw	a3,s6,s4
    80003c56:	89be                	mv	s3,a5
    80003c58:	2781                	sext.w	a5,a5
    80003c5a:	0006861b          	sext.w	a2,a3
    80003c5e:	f8f674e3          	bgeu	a2,a5,80003be6 <writei+0x4c>
    80003c62:	89b6                	mv	s3,a3
    80003c64:	b749                	j	80003be6 <writei+0x4c>
      brelse(bp);
    80003c66:	8526                	mv	a0,s1
    80003c68:	fffff097          	auipc	ra,0xfffff
    80003c6c:	4b6080e7          	jalr	1206(ra) # 8000311e <brelse>
  }

  if(n > 0){
    if(off > ip->size)
    80003c70:	04cba783          	lw	a5,76(s7)
    80003c74:	0127f463          	bgeu	a5,s2,80003c7c <writei+0xe2>
      ip->size = off;
    80003c78:	052ba623          	sw	s2,76(s7)
    // write the i-node back to disk even if the size didn't change
    // because the loop above might have called bmap() and added a new
    // block to ip->addrs[].
    iupdate(ip);
    80003c7c:	855e                	mv	a0,s7
    80003c7e:	00000097          	auipc	ra,0x0
    80003c82:	aa6080e7          	jalr	-1370(ra) # 80003724 <iupdate>
  }

  return n;
    80003c86:	000b051b          	sext.w	a0,s6
}
    80003c8a:	70a6                	ld	ra,104(sp)
    80003c8c:	7406                	ld	s0,96(sp)
    80003c8e:	64e6                	ld	s1,88(sp)
    80003c90:	6946                	ld	s2,80(sp)
    80003c92:	69a6                	ld	s3,72(sp)
    80003c94:	6a06                	ld	s4,64(sp)
    80003c96:	7ae2                	ld	s5,56(sp)
    80003c98:	7b42                	ld	s6,48(sp)
    80003c9a:	7ba2                	ld	s7,40(sp)
    80003c9c:	7c02                	ld	s8,32(sp)
    80003c9e:	6ce2                	ld	s9,24(sp)
    80003ca0:	6d42                	ld	s10,16(sp)
    80003ca2:	6da2                	ld	s11,8(sp)
    80003ca4:	6165                	addi	sp,sp,112
    80003ca6:	8082                	ret
    return -1;
    80003ca8:	557d                	li	a0,-1
}
    80003caa:	8082                	ret
    return -1;
    80003cac:	557d                	li	a0,-1
    80003cae:	bff1                	j	80003c8a <writei+0xf0>
    return -1;
    80003cb0:	557d                	li	a0,-1
    80003cb2:	bfe1                	j	80003c8a <writei+0xf0>

0000000080003cb4 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003cb4:	1141                	addi	sp,sp,-16
    80003cb6:	e406                	sd	ra,8(sp)
    80003cb8:	e022                	sd	s0,0(sp)
    80003cba:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003cbc:	4639                	li	a2,14
    80003cbe:	ffffd097          	auipc	ra,0xffffd
    80003cc2:	172080e7          	jalr	370(ra) # 80000e30 <strncmp>
}
    80003cc6:	60a2                	ld	ra,8(sp)
    80003cc8:	6402                	ld	s0,0(sp)
    80003cca:	0141                	addi	sp,sp,16
    80003ccc:	8082                	ret

0000000080003cce <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cce:	7139                	addi	sp,sp,-64
    80003cd0:	fc06                	sd	ra,56(sp)
    80003cd2:	f822                	sd	s0,48(sp)
    80003cd4:	f426                	sd	s1,40(sp)
    80003cd6:	f04a                	sd	s2,32(sp)
    80003cd8:	ec4e                	sd	s3,24(sp)
    80003cda:	e852                	sd	s4,16(sp)
    80003cdc:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cde:	04451703          	lh	a4,68(a0)
    80003ce2:	4785                	li	a5,1
    80003ce4:	00f71a63          	bne	a4,a5,80003cf8 <dirlookup+0x2a>
    80003ce8:	892a                	mv	s2,a0
    80003cea:	89ae                	mv	s3,a1
    80003cec:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cee:	457c                	lw	a5,76(a0)
    80003cf0:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cf2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf4:	e79d                	bnez	a5,80003d22 <dirlookup+0x54>
    80003cf6:	a8a5                	j	80003d6e <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cf8:	00005517          	auipc	a0,0x5
    80003cfc:	8e850513          	addi	a0,a0,-1816 # 800085e0 <syscalls+0x1b0>
    80003d00:	ffffd097          	auipc	ra,0xffffd
    80003d04:	846080e7          	jalr	-1978(ra) # 80000546 <panic>
      panic("dirlookup read");
    80003d08:	00005517          	auipc	a0,0x5
    80003d0c:	8f050513          	addi	a0,a0,-1808 # 800085f8 <syscalls+0x1c8>
    80003d10:	ffffd097          	auipc	ra,0xffffd
    80003d14:	836080e7          	jalr	-1994(ra) # 80000546 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d18:	24c1                	addiw	s1,s1,16
    80003d1a:	04c92783          	lw	a5,76(s2)
    80003d1e:	04f4f763          	bgeu	s1,a5,80003d6c <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d22:	4741                	li	a4,16
    80003d24:	86a6                	mv	a3,s1
    80003d26:	fc040613          	addi	a2,s0,-64
    80003d2a:	4581                	li	a1,0
    80003d2c:	854a                	mv	a0,s2
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	d76080e7          	jalr	-650(ra) # 80003aa4 <readi>
    80003d36:	47c1                	li	a5,16
    80003d38:	fcf518e3          	bne	a0,a5,80003d08 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d3c:	fc045783          	lhu	a5,-64(s0)
    80003d40:	dfe1                	beqz	a5,80003d18 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d42:	fc240593          	addi	a1,s0,-62
    80003d46:	854e                	mv	a0,s3
    80003d48:	00000097          	auipc	ra,0x0
    80003d4c:	f6c080e7          	jalr	-148(ra) # 80003cb4 <namecmp>
    80003d50:	f561                	bnez	a0,80003d18 <dirlookup+0x4a>
      if(poff)
    80003d52:	000a0463          	beqz	s4,80003d5a <dirlookup+0x8c>
        *poff = off;
    80003d56:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d5a:	fc045583          	lhu	a1,-64(s0)
    80003d5e:	00092503          	lw	a0,0(s2)
    80003d62:	fffff097          	auipc	ra,0xfffff
    80003d66:	758080e7          	jalr	1880(ra) # 800034ba <iget>
    80003d6a:	a011                	j	80003d6e <dirlookup+0xa0>
  return 0;
    80003d6c:	4501                	li	a0,0
}
    80003d6e:	70e2                	ld	ra,56(sp)
    80003d70:	7442                	ld	s0,48(sp)
    80003d72:	74a2                	ld	s1,40(sp)
    80003d74:	7902                	ld	s2,32(sp)
    80003d76:	69e2                	ld	s3,24(sp)
    80003d78:	6a42                	ld	s4,16(sp)
    80003d7a:	6121                	addi	sp,sp,64
    80003d7c:	8082                	ret

0000000080003d7e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d7e:	711d                	addi	sp,sp,-96
    80003d80:	ec86                	sd	ra,88(sp)
    80003d82:	e8a2                	sd	s0,80(sp)
    80003d84:	e4a6                	sd	s1,72(sp)
    80003d86:	e0ca                	sd	s2,64(sp)
    80003d88:	fc4e                	sd	s3,56(sp)
    80003d8a:	f852                	sd	s4,48(sp)
    80003d8c:	f456                	sd	s5,40(sp)
    80003d8e:	f05a                	sd	s6,32(sp)
    80003d90:	ec5e                	sd	s7,24(sp)
    80003d92:	e862                	sd	s8,16(sp)
    80003d94:	e466                	sd	s9,8(sp)
    80003d96:	e06a                	sd	s10,0(sp)
    80003d98:	1080                	addi	s0,sp,96
    80003d9a:	84aa                	mv	s1,a0
    80003d9c:	8b2e                	mv	s6,a1
    80003d9e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003da0:	00054703          	lbu	a4,0(a0)
    80003da4:	02f00793          	li	a5,47
    80003da8:	02f70363          	beq	a4,a5,80003dce <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003dac:	ffffe097          	auipc	ra,0xffffe
    80003db0:	c7c080e7          	jalr	-900(ra) # 80001a28 <myproc>
    80003db4:	15053503          	ld	a0,336(a0)
    80003db8:	00000097          	auipc	ra,0x0
    80003dbc:	9fa080e7          	jalr	-1542(ra) # 800037b2 <idup>
    80003dc0:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003dc2:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003dc6:	4cb5                	li	s9,13
  len = path - s;
    80003dc8:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003dca:	4c05                	li	s8,1
    80003dcc:	a87d                	j	80003e8a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003dce:	4585                	li	a1,1
    80003dd0:	4505                	li	a0,1
    80003dd2:	fffff097          	auipc	ra,0xfffff
    80003dd6:	6e8080e7          	jalr	1768(ra) # 800034ba <iget>
    80003dda:	8a2a                	mv	s4,a0
    80003ddc:	b7dd                	j	80003dc2 <namex+0x44>
      iunlockput(ip);
    80003dde:	8552                	mv	a0,s4
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	c72080e7          	jalr	-910(ra) # 80003a52 <iunlockput>
      return 0;
    80003de8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003dea:	8552                	mv	a0,s4
    80003dec:	60e6                	ld	ra,88(sp)
    80003dee:	6446                	ld	s0,80(sp)
    80003df0:	64a6                	ld	s1,72(sp)
    80003df2:	6906                	ld	s2,64(sp)
    80003df4:	79e2                	ld	s3,56(sp)
    80003df6:	7a42                	ld	s4,48(sp)
    80003df8:	7aa2                	ld	s5,40(sp)
    80003dfa:	7b02                	ld	s6,32(sp)
    80003dfc:	6be2                	ld	s7,24(sp)
    80003dfe:	6c42                	ld	s8,16(sp)
    80003e00:	6ca2                	ld	s9,8(sp)
    80003e02:	6d02                	ld	s10,0(sp)
    80003e04:	6125                	addi	sp,sp,96
    80003e06:	8082                	ret
      iunlock(ip);
    80003e08:	8552                	mv	a0,s4
    80003e0a:	00000097          	auipc	ra,0x0
    80003e0e:	aa8080e7          	jalr	-1368(ra) # 800038b2 <iunlock>
      return ip;
    80003e12:	bfe1                	j	80003dea <namex+0x6c>
      iunlockput(ip);
    80003e14:	8552                	mv	a0,s4
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	c3c080e7          	jalr	-964(ra) # 80003a52 <iunlockput>
      return 0;
    80003e1e:	8a4e                	mv	s4,s3
    80003e20:	b7e9                	j	80003dea <namex+0x6c>
  len = path - s;
    80003e22:	40998633          	sub	a2,s3,s1
    80003e26:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003e2a:	09acd863          	bge	s9,s10,80003eba <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003e2e:	4639                	li	a2,14
    80003e30:	85a6                	mv	a1,s1
    80003e32:	8556                	mv	a0,s5
    80003e34:	ffffd097          	auipc	ra,0xffffd
    80003e38:	f80080e7          	jalr	-128(ra) # 80000db4 <memmove>
    80003e3c:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e3e:	0004c783          	lbu	a5,0(s1)
    80003e42:	01279763          	bne	a5,s2,80003e50 <namex+0xd2>
    path++;
    80003e46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e48:	0004c783          	lbu	a5,0(s1)
    80003e4c:	ff278de3          	beq	a5,s2,80003e46 <namex+0xc8>
    ilock(ip);
    80003e50:	8552                	mv	a0,s4
    80003e52:	00000097          	auipc	ra,0x0
    80003e56:	99e080e7          	jalr	-1634(ra) # 800037f0 <ilock>
    if(ip->type != T_DIR){
    80003e5a:	044a1783          	lh	a5,68(s4)
    80003e5e:	f98790e3          	bne	a5,s8,80003dde <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003e62:	000b0563          	beqz	s6,80003e6c <namex+0xee>
    80003e66:	0004c783          	lbu	a5,0(s1)
    80003e6a:	dfd9                	beqz	a5,80003e08 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e6c:	865e                	mv	a2,s7
    80003e6e:	85d6                	mv	a1,s5
    80003e70:	8552                	mv	a0,s4
    80003e72:	00000097          	auipc	ra,0x0
    80003e76:	e5c080e7          	jalr	-420(ra) # 80003cce <dirlookup>
    80003e7a:	89aa                	mv	s3,a0
    80003e7c:	dd41                	beqz	a0,80003e14 <namex+0x96>
    iunlockput(ip);
    80003e7e:	8552                	mv	a0,s4
    80003e80:	00000097          	auipc	ra,0x0
    80003e84:	bd2080e7          	jalr	-1070(ra) # 80003a52 <iunlockput>
    ip = next;
    80003e88:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e8a:	0004c783          	lbu	a5,0(s1)
    80003e8e:	01279763          	bne	a5,s2,80003e9c <namex+0x11e>
    path++;
    80003e92:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003e94:	0004c783          	lbu	a5,0(s1)
    80003e98:	ff278de3          	beq	a5,s2,80003e92 <namex+0x114>
  if(*path == 0)
    80003e9c:	cb9d                	beqz	a5,80003ed2 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003e9e:	0004c783          	lbu	a5,0(s1)
    80003ea2:	89a6                	mv	s3,s1
  len = path - s;
    80003ea4:	8d5e                	mv	s10,s7
    80003ea6:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003ea8:	01278963          	beq	a5,s2,80003eba <namex+0x13c>
    80003eac:	dbbd                	beqz	a5,80003e22 <namex+0xa4>
    path++;
    80003eae:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003eb0:	0009c783          	lbu	a5,0(s3)
    80003eb4:	ff279ce3          	bne	a5,s2,80003eac <namex+0x12e>
    80003eb8:	b7ad                	j	80003e22 <namex+0xa4>
    memmove(name, s, len);
    80003eba:	2601                	sext.w	a2,a2
    80003ebc:	85a6                	mv	a1,s1
    80003ebe:	8556                	mv	a0,s5
    80003ec0:	ffffd097          	auipc	ra,0xffffd
    80003ec4:	ef4080e7          	jalr	-268(ra) # 80000db4 <memmove>
    name[len] = 0;
    80003ec8:	9d56                	add	s10,s10,s5
    80003eca:	000d0023          	sb	zero,0(s10)
    80003ece:	84ce                	mv	s1,s3
    80003ed0:	b7bd                	j	80003e3e <namex+0xc0>
  if(nameiparent){
    80003ed2:	f00b0ce3          	beqz	s6,80003dea <namex+0x6c>
    iput(ip);
    80003ed6:	8552                	mv	a0,s4
    80003ed8:	00000097          	auipc	ra,0x0
    80003edc:	ad2080e7          	jalr	-1326(ra) # 800039aa <iput>
    return 0;
    80003ee0:	4a01                	li	s4,0
    80003ee2:	b721                	j	80003dea <namex+0x6c>

0000000080003ee4 <dirlink>:
{
    80003ee4:	7139                	addi	sp,sp,-64
    80003ee6:	fc06                	sd	ra,56(sp)
    80003ee8:	f822                	sd	s0,48(sp)
    80003eea:	f426                	sd	s1,40(sp)
    80003eec:	f04a                	sd	s2,32(sp)
    80003eee:	ec4e                	sd	s3,24(sp)
    80003ef0:	e852                	sd	s4,16(sp)
    80003ef2:	0080                	addi	s0,sp,64
    80003ef4:	892a                	mv	s2,a0
    80003ef6:	8a2e                	mv	s4,a1
    80003ef8:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003efa:	4601                	li	a2,0
    80003efc:	00000097          	auipc	ra,0x0
    80003f00:	dd2080e7          	jalr	-558(ra) # 80003cce <dirlookup>
    80003f04:	e93d                	bnez	a0,80003f7a <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f06:	04c92483          	lw	s1,76(s2)
    80003f0a:	c49d                	beqz	s1,80003f38 <dirlink+0x54>
    80003f0c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f0e:	4741                	li	a4,16
    80003f10:	86a6                	mv	a3,s1
    80003f12:	fc040613          	addi	a2,s0,-64
    80003f16:	4581                	li	a1,0
    80003f18:	854a                	mv	a0,s2
    80003f1a:	00000097          	auipc	ra,0x0
    80003f1e:	b8a080e7          	jalr	-1142(ra) # 80003aa4 <readi>
    80003f22:	47c1                	li	a5,16
    80003f24:	06f51163          	bne	a0,a5,80003f86 <dirlink+0xa2>
    if(de.inum == 0)
    80003f28:	fc045783          	lhu	a5,-64(s0)
    80003f2c:	c791                	beqz	a5,80003f38 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f2e:	24c1                	addiw	s1,s1,16
    80003f30:	04c92783          	lw	a5,76(s2)
    80003f34:	fcf4ede3          	bltu	s1,a5,80003f0e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f38:	4639                	li	a2,14
    80003f3a:	85d2                	mv	a1,s4
    80003f3c:	fc240513          	addi	a0,s0,-62
    80003f40:	ffffd097          	auipc	ra,0xffffd
    80003f44:	f2c080e7          	jalr	-212(ra) # 80000e6c <strncpy>
  de.inum = inum;
    80003f48:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f4c:	4741                	li	a4,16
    80003f4e:	86a6                	mv	a3,s1
    80003f50:	fc040613          	addi	a2,s0,-64
    80003f54:	4581                	li	a1,0
    80003f56:	854a                	mv	a0,s2
    80003f58:	00000097          	auipc	ra,0x0
    80003f5c:	c42080e7          	jalr	-958(ra) # 80003b9a <writei>
    80003f60:	872a                	mv	a4,a0
    80003f62:	47c1                	li	a5,16
  return 0;
    80003f64:	4501                	li	a0,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f66:	02f71863          	bne	a4,a5,80003f96 <dirlink+0xb2>
}
    80003f6a:	70e2                	ld	ra,56(sp)
    80003f6c:	7442                	ld	s0,48(sp)
    80003f6e:	74a2                	ld	s1,40(sp)
    80003f70:	7902                	ld	s2,32(sp)
    80003f72:	69e2                	ld	s3,24(sp)
    80003f74:	6a42                	ld	s4,16(sp)
    80003f76:	6121                	addi	sp,sp,64
    80003f78:	8082                	ret
    iput(ip);
    80003f7a:	00000097          	auipc	ra,0x0
    80003f7e:	a30080e7          	jalr	-1488(ra) # 800039aa <iput>
    return -1;
    80003f82:	557d                	li	a0,-1
    80003f84:	b7dd                	j	80003f6a <dirlink+0x86>
      panic("dirlink read");
    80003f86:	00004517          	auipc	a0,0x4
    80003f8a:	68250513          	addi	a0,a0,1666 # 80008608 <syscalls+0x1d8>
    80003f8e:	ffffc097          	auipc	ra,0xffffc
    80003f92:	5b8080e7          	jalr	1464(ra) # 80000546 <panic>
    panic("dirlink");
    80003f96:	00004517          	auipc	a0,0x4
    80003f9a:	79250513          	addi	a0,a0,1938 # 80008728 <syscalls+0x2f8>
    80003f9e:	ffffc097          	auipc	ra,0xffffc
    80003fa2:	5a8080e7          	jalr	1448(ra) # 80000546 <panic>

0000000080003fa6 <namei>:

struct inode*
namei(char *path)
{
    80003fa6:	1101                	addi	sp,sp,-32
    80003fa8:	ec06                	sd	ra,24(sp)
    80003faa:	e822                	sd	s0,16(sp)
    80003fac:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003fae:	fe040613          	addi	a2,s0,-32
    80003fb2:	4581                	li	a1,0
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	dca080e7          	jalr	-566(ra) # 80003d7e <namex>
}
    80003fbc:	60e2                	ld	ra,24(sp)
    80003fbe:	6442                	ld	s0,16(sp)
    80003fc0:	6105                	addi	sp,sp,32
    80003fc2:	8082                	ret

0000000080003fc4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003fc4:	1141                	addi	sp,sp,-16
    80003fc6:	e406                	sd	ra,8(sp)
    80003fc8:	e022                	sd	s0,0(sp)
    80003fca:	0800                	addi	s0,sp,16
    80003fcc:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003fce:	4585                	li	a1,1
    80003fd0:	00000097          	auipc	ra,0x0
    80003fd4:	dae080e7          	jalr	-594(ra) # 80003d7e <namex>
}
    80003fd8:	60a2                	ld	ra,8(sp)
    80003fda:	6402                	ld	s0,0(sp)
    80003fdc:	0141                	addi	sp,sp,16
    80003fde:	8082                	ret

0000000080003fe0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fe0:	1101                	addi	sp,sp,-32
    80003fe2:	ec06                	sd	ra,24(sp)
    80003fe4:	e822                	sd	s0,16(sp)
    80003fe6:	e426                	sd	s1,8(sp)
    80003fe8:	e04a                	sd	s2,0(sp)
    80003fea:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fec:	0001e917          	auipc	s2,0x1e
    80003ff0:	31c90913          	addi	s2,s2,796 # 80022308 <log>
    80003ff4:	01892583          	lw	a1,24(s2)
    80003ff8:	02892503          	lw	a0,40(s2)
    80003ffc:	fffff097          	auipc	ra,0xfffff
    80004000:	ff2080e7          	jalr	-14(ra) # 80002fee <bread>
    80004004:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004006:	02c92683          	lw	a3,44(s2)
    8000400a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000400c:	02d05863          	blez	a3,8000403c <write_head+0x5c>
    80004010:	0001e797          	auipc	a5,0x1e
    80004014:	32878793          	addi	a5,a5,808 # 80022338 <log+0x30>
    80004018:	05c50713          	addi	a4,a0,92
    8000401c:	36fd                	addiw	a3,a3,-1
    8000401e:	02069613          	slli	a2,a3,0x20
    80004022:	01e65693          	srli	a3,a2,0x1e
    80004026:	0001e617          	auipc	a2,0x1e
    8000402a:	31660613          	addi	a2,a2,790 # 8002233c <log+0x34>
    8000402e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004030:	4390                	lw	a2,0(a5)
    80004032:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004034:	0791                	addi	a5,a5,4
    80004036:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004038:	fed79ce3          	bne	a5,a3,80004030 <write_head+0x50>
  }
  bwrite(buf);
    8000403c:	8526                	mv	a0,s1
    8000403e:	fffff097          	auipc	ra,0xfffff
    80004042:	0a2080e7          	jalr	162(ra) # 800030e0 <bwrite>
  brelse(buf);
    80004046:	8526                	mv	a0,s1
    80004048:	fffff097          	auipc	ra,0xfffff
    8000404c:	0d6080e7          	jalr	214(ra) # 8000311e <brelse>
}
    80004050:	60e2                	ld	ra,24(sp)
    80004052:	6442                	ld	s0,16(sp)
    80004054:	64a2                	ld	s1,8(sp)
    80004056:	6902                	ld	s2,0(sp)
    80004058:	6105                	addi	sp,sp,32
    8000405a:	8082                	ret

000000008000405c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405c:	0001e797          	auipc	a5,0x1e
    80004060:	2d87a783          	lw	a5,728(a5) # 80022334 <log+0x2c>
    80004064:	0af05663          	blez	a5,80004110 <install_trans+0xb4>
{
    80004068:	7139                	addi	sp,sp,-64
    8000406a:	fc06                	sd	ra,56(sp)
    8000406c:	f822                	sd	s0,48(sp)
    8000406e:	f426                	sd	s1,40(sp)
    80004070:	f04a                	sd	s2,32(sp)
    80004072:	ec4e                	sd	s3,24(sp)
    80004074:	e852                	sd	s4,16(sp)
    80004076:	e456                	sd	s5,8(sp)
    80004078:	0080                	addi	s0,sp,64
    8000407a:	0001ea97          	auipc	s5,0x1e
    8000407e:	2bea8a93          	addi	s5,s5,702 # 80022338 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004082:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004084:	0001e997          	auipc	s3,0x1e
    80004088:	28498993          	addi	s3,s3,644 # 80022308 <log>
    8000408c:	0189a583          	lw	a1,24(s3)
    80004090:	014585bb          	addw	a1,a1,s4
    80004094:	2585                	addiw	a1,a1,1
    80004096:	0289a503          	lw	a0,40(s3)
    8000409a:	fffff097          	auipc	ra,0xfffff
    8000409e:	f54080e7          	jalr	-172(ra) # 80002fee <bread>
    800040a2:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040a4:	000aa583          	lw	a1,0(s5)
    800040a8:	0289a503          	lw	a0,40(s3)
    800040ac:	fffff097          	auipc	ra,0xfffff
    800040b0:	f42080e7          	jalr	-190(ra) # 80002fee <bread>
    800040b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040b6:	40000613          	li	a2,1024
    800040ba:	05890593          	addi	a1,s2,88
    800040be:	05850513          	addi	a0,a0,88
    800040c2:	ffffd097          	auipc	ra,0xffffd
    800040c6:	cf2080e7          	jalr	-782(ra) # 80000db4 <memmove>
    bwrite(dbuf);  // write dst to disk
    800040ca:	8526                	mv	a0,s1
    800040cc:	fffff097          	auipc	ra,0xfffff
    800040d0:	014080e7          	jalr	20(ra) # 800030e0 <bwrite>
    bunpin(dbuf);
    800040d4:	8526                	mv	a0,s1
    800040d6:	fffff097          	auipc	ra,0xfffff
    800040da:	122080e7          	jalr	290(ra) # 800031f8 <bunpin>
    brelse(lbuf);
    800040de:	854a                	mv	a0,s2
    800040e0:	fffff097          	auipc	ra,0xfffff
    800040e4:	03e080e7          	jalr	62(ra) # 8000311e <brelse>
    brelse(dbuf);
    800040e8:	8526                	mv	a0,s1
    800040ea:	fffff097          	auipc	ra,0xfffff
    800040ee:	034080e7          	jalr	52(ra) # 8000311e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040f2:	2a05                	addiw	s4,s4,1
    800040f4:	0a91                	addi	s5,s5,4
    800040f6:	02c9a783          	lw	a5,44(s3)
    800040fa:	f8fa49e3          	blt	s4,a5,8000408c <install_trans+0x30>
}
    800040fe:	70e2                	ld	ra,56(sp)
    80004100:	7442                	ld	s0,48(sp)
    80004102:	74a2                	ld	s1,40(sp)
    80004104:	7902                	ld	s2,32(sp)
    80004106:	69e2                	ld	s3,24(sp)
    80004108:	6a42                	ld	s4,16(sp)
    8000410a:	6aa2                	ld	s5,8(sp)
    8000410c:	6121                	addi	sp,sp,64
    8000410e:	8082                	ret
    80004110:	8082                	ret

0000000080004112 <initlog>:
{
    80004112:	7179                	addi	sp,sp,-48
    80004114:	f406                	sd	ra,40(sp)
    80004116:	f022                	sd	s0,32(sp)
    80004118:	ec26                	sd	s1,24(sp)
    8000411a:	e84a                	sd	s2,16(sp)
    8000411c:	e44e                	sd	s3,8(sp)
    8000411e:	1800                	addi	s0,sp,48
    80004120:	892a                	mv	s2,a0
    80004122:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004124:	0001e497          	auipc	s1,0x1e
    80004128:	1e448493          	addi	s1,s1,484 # 80022308 <log>
    8000412c:	00004597          	auipc	a1,0x4
    80004130:	4ec58593          	addi	a1,a1,1260 # 80008618 <syscalls+0x1e8>
    80004134:	8526                	mv	a0,s1
    80004136:	ffffd097          	auipc	ra,0xffffd
    8000413a:	a96080e7          	jalr	-1386(ra) # 80000bcc <initlock>
  log.start = sb->logstart;
    8000413e:	0149a583          	lw	a1,20(s3)
    80004142:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004144:	0109a783          	lw	a5,16(s3)
    80004148:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000414a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000414e:	854a                	mv	a0,s2
    80004150:	fffff097          	auipc	ra,0xfffff
    80004154:	e9e080e7          	jalr	-354(ra) # 80002fee <bread>
  log.lh.n = lh->n;
    80004158:	4d34                	lw	a3,88(a0)
    8000415a:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000415c:	02d05663          	blez	a3,80004188 <initlog+0x76>
    80004160:	05c50793          	addi	a5,a0,92
    80004164:	0001e717          	auipc	a4,0x1e
    80004168:	1d470713          	addi	a4,a4,468 # 80022338 <log+0x30>
    8000416c:	36fd                	addiw	a3,a3,-1
    8000416e:	02069613          	slli	a2,a3,0x20
    80004172:	01e65693          	srli	a3,a2,0x1e
    80004176:	06050613          	addi	a2,a0,96
    8000417a:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    8000417c:	4390                	lw	a2,0(a5)
    8000417e:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004180:	0791                	addi	a5,a5,4
    80004182:	0711                	addi	a4,a4,4
    80004184:	fed79ce3          	bne	a5,a3,8000417c <initlog+0x6a>
  brelse(buf);
    80004188:	fffff097          	auipc	ra,0xfffff
    8000418c:	f96080e7          	jalr	-106(ra) # 8000311e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
    80004190:	00000097          	auipc	ra,0x0
    80004194:	ecc080e7          	jalr	-308(ra) # 8000405c <install_trans>
  log.lh.n = 0;
    80004198:	0001e797          	auipc	a5,0x1e
    8000419c:	1807ae23          	sw	zero,412(a5) # 80022334 <log+0x2c>
  write_head(); // clear the log
    800041a0:	00000097          	auipc	ra,0x0
    800041a4:	e40080e7          	jalr	-448(ra) # 80003fe0 <write_head>
}
    800041a8:	70a2                	ld	ra,40(sp)
    800041aa:	7402                	ld	s0,32(sp)
    800041ac:	64e2                	ld	s1,24(sp)
    800041ae:	6942                	ld	s2,16(sp)
    800041b0:	69a2                	ld	s3,8(sp)
    800041b2:	6145                	addi	sp,sp,48
    800041b4:	8082                	ret

00000000800041b6 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041b6:	1101                	addi	sp,sp,-32
    800041b8:	ec06                	sd	ra,24(sp)
    800041ba:	e822                	sd	s0,16(sp)
    800041bc:	e426                	sd	s1,8(sp)
    800041be:	e04a                	sd	s2,0(sp)
    800041c0:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041c2:	0001e517          	auipc	a0,0x1e
    800041c6:	14650513          	addi	a0,a0,326 # 80022308 <log>
    800041ca:	ffffd097          	auipc	ra,0xffffd
    800041ce:	a92080e7          	jalr	-1390(ra) # 80000c5c <acquire>
  while(1){
    if(log.committing){
    800041d2:	0001e497          	auipc	s1,0x1e
    800041d6:	13648493          	addi	s1,s1,310 # 80022308 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041da:	4979                	li	s2,30
    800041dc:	a039                	j	800041ea <begin_op+0x34>
      sleep(&log, &log.lock);
    800041de:	85a6                	mv	a1,s1
    800041e0:	8526                	mv	a0,s1
    800041e2:	ffffe097          	auipc	ra,0xffffe
    800041e6:	0aa080e7          	jalr	170(ra) # 8000228c <sleep>
    if(log.committing){
    800041ea:	50dc                	lw	a5,36(s1)
    800041ec:	fbed                	bnez	a5,800041de <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041ee:	5098                	lw	a4,32(s1)
    800041f0:	2705                	addiw	a4,a4,1
    800041f2:	0007069b          	sext.w	a3,a4
    800041f6:	0027179b          	slliw	a5,a4,0x2
    800041fa:	9fb9                	addw	a5,a5,a4
    800041fc:	0017979b          	slliw	a5,a5,0x1
    80004200:	54d8                	lw	a4,44(s1)
    80004202:	9fb9                	addw	a5,a5,a4
    80004204:	00f95963          	bge	s2,a5,80004216 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004208:	85a6                	mv	a1,s1
    8000420a:	8526                	mv	a0,s1
    8000420c:	ffffe097          	auipc	ra,0xffffe
    80004210:	080080e7          	jalr	128(ra) # 8000228c <sleep>
    80004214:	bfd9                	j	800041ea <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004216:	0001e517          	auipc	a0,0x1e
    8000421a:	0f250513          	addi	a0,a0,242 # 80022308 <log>
    8000421e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004220:	ffffd097          	auipc	ra,0xffffd
    80004224:	af0080e7          	jalr	-1296(ra) # 80000d10 <release>
      break;
    }
  }
}
    80004228:	60e2                	ld	ra,24(sp)
    8000422a:	6442                	ld	s0,16(sp)
    8000422c:	64a2                	ld	s1,8(sp)
    8000422e:	6902                	ld	s2,0(sp)
    80004230:	6105                	addi	sp,sp,32
    80004232:	8082                	ret

0000000080004234 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004234:	7139                	addi	sp,sp,-64
    80004236:	fc06                	sd	ra,56(sp)
    80004238:	f822                	sd	s0,48(sp)
    8000423a:	f426                	sd	s1,40(sp)
    8000423c:	f04a                	sd	s2,32(sp)
    8000423e:	ec4e                	sd	s3,24(sp)
    80004240:	e852                	sd	s4,16(sp)
    80004242:	e456                	sd	s5,8(sp)
    80004244:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004246:	0001e497          	auipc	s1,0x1e
    8000424a:	0c248493          	addi	s1,s1,194 # 80022308 <log>
    8000424e:	8526                	mv	a0,s1
    80004250:	ffffd097          	auipc	ra,0xffffd
    80004254:	a0c080e7          	jalr	-1524(ra) # 80000c5c <acquire>
  log.outstanding -= 1;
    80004258:	509c                	lw	a5,32(s1)
    8000425a:	37fd                	addiw	a5,a5,-1
    8000425c:	0007891b          	sext.w	s2,a5
    80004260:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004262:	50dc                	lw	a5,36(s1)
    80004264:	e7b9                	bnez	a5,800042b2 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004266:	04091e63          	bnez	s2,800042c2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000426a:	0001e497          	auipc	s1,0x1e
    8000426e:	09e48493          	addi	s1,s1,158 # 80022308 <log>
    80004272:	4785                	li	a5,1
    80004274:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004276:	8526                	mv	a0,s1
    80004278:	ffffd097          	auipc	ra,0xffffd
    8000427c:	a98080e7          	jalr	-1384(ra) # 80000d10 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004280:	54dc                	lw	a5,44(s1)
    80004282:	06f04763          	bgtz	a5,800042f0 <end_op+0xbc>
    acquire(&log.lock);
    80004286:	0001e497          	auipc	s1,0x1e
    8000428a:	08248493          	addi	s1,s1,130 # 80022308 <log>
    8000428e:	8526                	mv	a0,s1
    80004290:	ffffd097          	auipc	ra,0xffffd
    80004294:	9cc080e7          	jalr	-1588(ra) # 80000c5c <acquire>
    log.committing = 0;
    80004298:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000429c:	8526                	mv	a0,s1
    8000429e:	ffffe097          	auipc	ra,0xffffe
    800042a2:	16e080e7          	jalr	366(ra) # 8000240c <wakeup>
    release(&log.lock);
    800042a6:	8526                	mv	a0,s1
    800042a8:	ffffd097          	auipc	ra,0xffffd
    800042ac:	a68080e7          	jalr	-1432(ra) # 80000d10 <release>
}
    800042b0:	a03d                	j	800042de <end_op+0xaa>
    panic("log.committing");
    800042b2:	00004517          	auipc	a0,0x4
    800042b6:	36e50513          	addi	a0,a0,878 # 80008620 <syscalls+0x1f0>
    800042ba:	ffffc097          	auipc	ra,0xffffc
    800042be:	28c080e7          	jalr	652(ra) # 80000546 <panic>
    wakeup(&log);
    800042c2:	0001e497          	auipc	s1,0x1e
    800042c6:	04648493          	addi	s1,s1,70 # 80022308 <log>
    800042ca:	8526                	mv	a0,s1
    800042cc:	ffffe097          	auipc	ra,0xffffe
    800042d0:	140080e7          	jalr	320(ra) # 8000240c <wakeup>
  release(&log.lock);
    800042d4:	8526                	mv	a0,s1
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	a3a080e7          	jalr	-1478(ra) # 80000d10 <release>
}
    800042de:	70e2                	ld	ra,56(sp)
    800042e0:	7442                	ld	s0,48(sp)
    800042e2:	74a2                	ld	s1,40(sp)
    800042e4:	7902                	ld	s2,32(sp)
    800042e6:	69e2                	ld	s3,24(sp)
    800042e8:	6a42                	ld	s4,16(sp)
    800042ea:	6aa2                	ld	s5,8(sp)
    800042ec:	6121                	addi	sp,sp,64
    800042ee:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800042f0:	0001ea97          	auipc	s5,0x1e
    800042f4:	048a8a93          	addi	s5,s5,72 # 80022338 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042f8:	0001ea17          	auipc	s4,0x1e
    800042fc:	010a0a13          	addi	s4,s4,16 # 80022308 <log>
    80004300:	018a2583          	lw	a1,24(s4)
    80004304:	012585bb          	addw	a1,a1,s2
    80004308:	2585                	addiw	a1,a1,1
    8000430a:	028a2503          	lw	a0,40(s4)
    8000430e:	fffff097          	auipc	ra,0xfffff
    80004312:	ce0080e7          	jalr	-800(ra) # 80002fee <bread>
    80004316:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004318:	000aa583          	lw	a1,0(s5)
    8000431c:	028a2503          	lw	a0,40(s4)
    80004320:	fffff097          	auipc	ra,0xfffff
    80004324:	cce080e7          	jalr	-818(ra) # 80002fee <bread>
    80004328:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000432a:	40000613          	li	a2,1024
    8000432e:	05850593          	addi	a1,a0,88
    80004332:	05848513          	addi	a0,s1,88
    80004336:	ffffd097          	auipc	ra,0xffffd
    8000433a:	a7e080e7          	jalr	-1410(ra) # 80000db4 <memmove>
    bwrite(to);  // write the log
    8000433e:	8526                	mv	a0,s1
    80004340:	fffff097          	auipc	ra,0xfffff
    80004344:	da0080e7          	jalr	-608(ra) # 800030e0 <bwrite>
    brelse(from);
    80004348:	854e                	mv	a0,s3
    8000434a:	fffff097          	auipc	ra,0xfffff
    8000434e:	dd4080e7          	jalr	-556(ra) # 8000311e <brelse>
    brelse(to);
    80004352:	8526                	mv	a0,s1
    80004354:	fffff097          	auipc	ra,0xfffff
    80004358:	dca080e7          	jalr	-566(ra) # 8000311e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000435c:	2905                	addiw	s2,s2,1
    8000435e:	0a91                	addi	s5,s5,4
    80004360:	02ca2783          	lw	a5,44(s4)
    80004364:	f8f94ee3          	blt	s2,a5,80004300 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004368:	00000097          	auipc	ra,0x0
    8000436c:	c78080e7          	jalr	-904(ra) # 80003fe0 <write_head>
    install_trans(); // Now install writes to home locations
    80004370:	00000097          	auipc	ra,0x0
    80004374:	cec080e7          	jalr	-788(ra) # 8000405c <install_trans>
    log.lh.n = 0;
    80004378:	0001e797          	auipc	a5,0x1e
    8000437c:	fa07ae23          	sw	zero,-68(a5) # 80022334 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004380:	00000097          	auipc	ra,0x0
    80004384:	c60080e7          	jalr	-928(ra) # 80003fe0 <write_head>
    80004388:	bdfd                	j	80004286 <end_op+0x52>

000000008000438a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000438a:	1101                	addi	sp,sp,-32
    8000438c:	ec06                	sd	ra,24(sp)
    8000438e:	e822                	sd	s0,16(sp)
    80004390:	e426                	sd	s1,8(sp)
    80004392:	e04a                	sd	s2,0(sp)
    80004394:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004396:	0001e717          	auipc	a4,0x1e
    8000439a:	f9e72703          	lw	a4,-98(a4) # 80022334 <log+0x2c>
    8000439e:	47f5                	li	a5,29
    800043a0:	08e7c063          	blt	a5,a4,80004420 <log_write+0x96>
    800043a4:	84aa                	mv	s1,a0
    800043a6:	0001e797          	auipc	a5,0x1e
    800043aa:	f7e7a783          	lw	a5,-130(a5) # 80022324 <log+0x1c>
    800043ae:	37fd                	addiw	a5,a5,-1
    800043b0:	06f75863          	bge	a4,a5,80004420 <log_write+0x96>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043b4:	0001e797          	auipc	a5,0x1e
    800043b8:	f747a783          	lw	a5,-140(a5) # 80022328 <log+0x20>
    800043bc:	06f05a63          	blez	a5,80004430 <log_write+0xa6>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800043c0:	0001e917          	auipc	s2,0x1e
    800043c4:	f4890913          	addi	s2,s2,-184 # 80022308 <log>
    800043c8:	854a                	mv	a0,s2
    800043ca:	ffffd097          	auipc	ra,0xffffd
    800043ce:	892080e7          	jalr	-1902(ra) # 80000c5c <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800043d2:	02c92603          	lw	a2,44(s2)
    800043d6:	06c05563          	blez	a2,80004440 <log_write+0xb6>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800043da:	44cc                	lw	a1,12(s1)
    800043dc:	0001e717          	auipc	a4,0x1e
    800043e0:	f5c70713          	addi	a4,a4,-164 # 80022338 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800043e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800043e6:	4314                	lw	a3,0(a4)
    800043e8:	04b68d63          	beq	a3,a1,80004442 <log_write+0xb8>
  for (i = 0; i < log.lh.n; i++) {
    800043ec:	2785                	addiw	a5,a5,1
    800043ee:	0711                	addi	a4,a4,4
    800043f0:	fec79be3          	bne	a5,a2,800043e6 <log_write+0x5c>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043f4:	0621                	addi	a2,a2,8
    800043f6:	060a                	slli	a2,a2,0x2
    800043f8:	0001e797          	auipc	a5,0x1e
    800043fc:	f1078793          	addi	a5,a5,-240 # 80022308 <log>
    80004400:	97b2                	add	a5,a5,a2
    80004402:	44d8                	lw	a4,12(s1)
    80004404:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004406:	8526                	mv	a0,s1
    80004408:	fffff097          	auipc	ra,0xfffff
    8000440c:	db4080e7          	jalr	-588(ra) # 800031bc <bpin>
    log.lh.n++;
    80004410:	0001e717          	auipc	a4,0x1e
    80004414:	ef870713          	addi	a4,a4,-264 # 80022308 <log>
    80004418:	575c                	lw	a5,44(a4)
    8000441a:	2785                	addiw	a5,a5,1
    8000441c:	d75c                	sw	a5,44(a4)
    8000441e:	a835                	j	8000445a <log_write+0xd0>
    panic("too big a transaction");
    80004420:	00004517          	auipc	a0,0x4
    80004424:	21050513          	addi	a0,a0,528 # 80008630 <syscalls+0x200>
    80004428:	ffffc097          	auipc	ra,0xffffc
    8000442c:	11e080e7          	jalr	286(ra) # 80000546 <panic>
    panic("log_write outside of trans");
    80004430:	00004517          	auipc	a0,0x4
    80004434:	21850513          	addi	a0,a0,536 # 80008648 <syscalls+0x218>
    80004438:	ffffc097          	auipc	ra,0xffffc
    8000443c:	10e080e7          	jalr	270(ra) # 80000546 <panic>
  for (i = 0; i < log.lh.n; i++) {
    80004440:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004442:	00878693          	addi	a3,a5,8
    80004446:	068a                	slli	a3,a3,0x2
    80004448:	0001e717          	auipc	a4,0x1e
    8000444c:	ec070713          	addi	a4,a4,-320 # 80022308 <log>
    80004450:	9736                	add	a4,a4,a3
    80004452:	44d4                	lw	a3,12(s1)
    80004454:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004456:	faf608e3          	beq	a2,a5,80004406 <log_write+0x7c>
  }
  release(&log.lock);
    8000445a:	0001e517          	auipc	a0,0x1e
    8000445e:	eae50513          	addi	a0,a0,-338 # 80022308 <log>
    80004462:	ffffd097          	auipc	ra,0xffffd
    80004466:	8ae080e7          	jalr	-1874(ra) # 80000d10 <release>
}
    8000446a:	60e2                	ld	ra,24(sp)
    8000446c:	6442                	ld	s0,16(sp)
    8000446e:	64a2                	ld	s1,8(sp)
    80004470:	6902                	ld	s2,0(sp)
    80004472:	6105                	addi	sp,sp,32
    80004474:	8082                	ret

0000000080004476 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004476:	1101                	addi	sp,sp,-32
    80004478:	ec06                	sd	ra,24(sp)
    8000447a:	e822                	sd	s0,16(sp)
    8000447c:	e426                	sd	s1,8(sp)
    8000447e:	e04a                	sd	s2,0(sp)
    80004480:	1000                	addi	s0,sp,32
    80004482:	84aa                	mv	s1,a0
    80004484:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004486:	00004597          	auipc	a1,0x4
    8000448a:	1e258593          	addi	a1,a1,482 # 80008668 <syscalls+0x238>
    8000448e:	0521                	addi	a0,a0,8
    80004490:	ffffc097          	auipc	ra,0xffffc
    80004494:	73c080e7          	jalr	1852(ra) # 80000bcc <initlock>
  lk->name = name;
    80004498:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000449c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044a0:	0204a423          	sw	zero,40(s1)
}
    800044a4:	60e2                	ld	ra,24(sp)
    800044a6:	6442                	ld	s0,16(sp)
    800044a8:	64a2                	ld	s1,8(sp)
    800044aa:	6902                	ld	s2,0(sp)
    800044ac:	6105                	addi	sp,sp,32
    800044ae:	8082                	ret

00000000800044b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044b0:	1101                	addi	sp,sp,-32
    800044b2:	ec06                	sd	ra,24(sp)
    800044b4:	e822                	sd	s0,16(sp)
    800044b6:	e426                	sd	s1,8(sp)
    800044b8:	e04a                	sd	s2,0(sp)
    800044ba:	1000                	addi	s0,sp,32
    800044bc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044be:	00850913          	addi	s2,a0,8
    800044c2:	854a                	mv	a0,s2
    800044c4:	ffffc097          	auipc	ra,0xffffc
    800044c8:	798080e7          	jalr	1944(ra) # 80000c5c <acquire>
  while (lk->locked) {
    800044cc:	409c                	lw	a5,0(s1)
    800044ce:	cb89                	beqz	a5,800044e0 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800044d0:	85ca                	mv	a1,s2
    800044d2:	8526                	mv	a0,s1
    800044d4:	ffffe097          	auipc	ra,0xffffe
    800044d8:	db8080e7          	jalr	-584(ra) # 8000228c <sleep>
  while (lk->locked) {
    800044dc:	409c                	lw	a5,0(s1)
    800044de:	fbed                	bnez	a5,800044d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800044e0:	4785                	li	a5,1
    800044e2:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044e4:	ffffd097          	auipc	ra,0xffffd
    800044e8:	544080e7          	jalr	1348(ra) # 80001a28 <myproc>
    800044ec:	5d1c                	lw	a5,56(a0)
    800044ee:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044f0:	854a                	mv	a0,s2
    800044f2:	ffffd097          	auipc	ra,0xffffd
    800044f6:	81e080e7          	jalr	-2018(ra) # 80000d10 <release>
}
    800044fa:	60e2                	ld	ra,24(sp)
    800044fc:	6442                	ld	s0,16(sp)
    800044fe:	64a2                	ld	s1,8(sp)
    80004500:	6902                	ld	s2,0(sp)
    80004502:	6105                	addi	sp,sp,32
    80004504:	8082                	ret

0000000080004506 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004506:	1101                	addi	sp,sp,-32
    80004508:	ec06                	sd	ra,24(sp)
    8000450a:	e822                	sd	s0,16(sp)
    8000450c:	e426                	sd	s1,8(sp)
    8000450e:	e04a                	sd	s2,0(sp)
    80004510:	1000                	addi	s0,sp,32
    80004512:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004514:	00850913          	addi	s2,a0,8
    80004518:	854a                	mv	a0,s2
    8000451a:	ffffc097          	auipc	ra,0xffffc
    8000451e:	742080e7          	jalr	1858(ra) # 80000c5c <acquire>
  lk->locked = 0;
    80004522:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004526:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000452a:	8526                	mv	a0,s1
    8000452c:	ffffe097          	auipc	ra,0xffffe
    80004530:	ee0080e7          	jalr	-288(ra) # 8000240c <wakeup>
  release(&lk->lk);
    80004534:	854a                	mv	a0,s2
    80004536:	ffffc097          	auipc	ra,0xffffc
    8000453a:	7da080e7          	jalr	2010(ra) # 80000d10 <release>
}
    8000453e:	60e2                	ld	ra,24(sp)
    80004540:	6442                	ld	s0,16(sp)
    80004542:	64a2                	ld	s1,8(sp)
    80004544:	6902                	ld	s2,0(sp)
    80004546:	6105                	addi	sp,sp,32
    80004548:	8082                	ret

000000008000454a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000454a:	7179                	addi	sp,sp,-48
    8000454c:	f406                	sd	ra,40(sp)
    8000454e:	f022                	sd	s0,32(sp)
    80004550:	ec26                	sd	s1,24(sp)
    80004552:	e84a                	sd	s2,16(sp)
    80004554:	e44e                	sd	s3,8(sp)
    80004556:	1800                	addi	s0,sp,48
    80004558:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000455a:	00850913          	addi	s2,a0,8
    8000455e:	854a                	mv	a0,s2
    80004560:	ffffc097          	auipc	ra,0xffffc
    80004564:	6fc080e7          	jalr	1788(ra) # 80000c5c <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004568:	409c                	lw	a5,0(s1)
    8000456a:	ef99                	bnez	a5,80004588 <holdingsleep+0x3e>
    8000456c:	4481                	li	s1,0
  release(&lk->lk);
    8000456e:	854a                	mv	a0,s2
    80004570:	ffffc097          	auipc	ra,0xffffc
    80004574:	7a0080e7          	jalr	1952(ra) # 80000d10 <release>
  return r;
}
    80004578:	8526                	mv	a0,s1
    8000457a:	70a2                	ld	ra,40(sp)
    8000457c:	7402                	ld	s0,32(sp)
    8000457e:	64e2                	ld	s1,24(sp)
    80004580:	6942                	ld	s2,16(sp)
    80004582:	69a2                	ld	s3,8(sp)
    80004584:	6145                	addi	sp,sp,48
    80004586:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004588:	0284a983          	lw	s3,40(s1)
    8000458c:	ffffd097          	auipc	ra,0xffffd
    80004590:	49c080e7          	jalr	1180(ra) # 80001a28 <myproc>
    80004594:	5d04                	lw	s1,56(a0)
    80004596:	413484b3          	sub	s1,s1,s3
    8000459a:	0014b493          	seqz	s1,s1
    8000459e:	bfc1                	j	8000456e <holdingsleep+0x24>

00000000800045a0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045a0:	1141                	addi	sp,sp,-16
    800045a2:	e406                	sd	ra,8(sp)
    800045a4:	e022                	sd	s0,0(sp)
    800045a6:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045a8:	00004597          	auipc	a1,0x4
    800045ac:	0d058593          	addi	a1,a1,208 # 80008678 <syscalls+0x248>
    800045b0:	0001e517          	auipc	a0,0x1e
    800045b4:	ea050513          	addi	a0,a0,-352 # 80022450 <ftable>
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	614080e7          	jalr	1556(ra) # 80000bcc <initlock>
}
    800045c0:	60a2                	ld	ra,8(sp)
    800045c2:	6402                	ld	s0,0(sp)
    800045c4:	0141                	addi	sp,sp,16
    800045c6:	8082                	ret

00000000800045c8 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045c8:	1101                	addi	sp,sp,-32
    800045ca:	ec06                	sd	ra,24(sp)
    800045cc:	e822                	sd	s0,16(sp)
    800045ce:	e426                	sd	s1,8(sp)
    800045d0:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045d2:	0001e517          	auipc	a0,0x1e
    800045d6:	e7e50513          	addi	a0,a0,-386 # 80022450 <ftable>
    800045da:	ffffc097          	auipc	ra,0xffffc
    800045de:	682080e7          	jalr	1666(ra) # 80000c5c <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045e2:	0001e497          	auipc	s1,0x1e
    800045e6:	e8648493          	addi	s1,s1,-378 # 80022468 <ftable+0x18>
    800045ea:	0001f717          	auipc	a4,0x1f
    800045ee:	e1e70713          	addi	a4,a4,-482 # 80023408 <ftable+0xfb8>
    if(f->ref == 0){
    800045f2:	40dc                	lw	a5,4(s1)
    800045f4:	cf99                	beqz	a5,80004612 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045f6:	02848493          	addi	s1,s1,40
    800045fa:	fee49ce3          	bne	s1,a4,800045f2 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045fe:	0001e517          	auipc	a0,0x1e
    80004602:	e5250513          	addi	a0,a0,-430 # 80022450 <ftable>
    80004606:	ffffc097          	auipc	ra,0xffffc
    8000460a:	70a080e7          	jalr	1802(ra) # 80000d10 <release>
  return 0;
    8000460e:	4481                	li	s1,0
    80004610:	a819                	j	80004626 <filealloc+0x5e>
      f->ref = 1;
    80004612:	4785                	li	a5,1
    80004614:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004616:	0001e517          	auipc	a0,0x1e
    8000461a:	e3a50513          	addi	a0,a0,-454 # 80022450 <ftable>
    8000461e:	ffffc097          	auipc	ra,0xffffc
    80004622:	6f2080e7          	jalr	1778(ra) # 80000d10 <release>
}
    80004626:	8526                	mv	a0,s1
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6105                	addi	sp,sp,32
    80004630:	8082                	ret

0000000080004632 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004632:	1101                	addi	sp,sp,-32
    80004634:	ec06                	sd	ra,24(sp)
    80004636:	e822                	sd	s0,16(sp)
    80004638:	e426                	sd	s1,8(sp)
    8000463a:	1000                	addi	s0,sp,32
    8000463c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000463e:	0001e517          	auipc	a0,0x1e
    80004642:	e1250513          	addi	a0,a0,-494 # 80022450 <ftable>
    80004646:	ffffc097          	auipc	ra,0xffffc
    8000464a:	616080e7          	jalr	1558(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    8000464e:	40dc                	lw	a5,4(s1)
    80004650:	02f05263          	blez	a5,80004674 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004654:	2785                	addiw	a5,a5,1
    80004656:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004658:	0001e517          	auipc	a0,0x1e
    8000465c:	df850513          	addi	a0,a0,-520 # 80022450 <ftable>
    80004660:	ffffc097          	auipc	ra,0xffffc
    80004664:	6b0080e7          	jalr	1712(ra) # 80000d10 <release>
  return f;
}
    80004668:	8526                	mv	a0,s1
    8000466a:	60e2                	ld	ra,24(sp)
    8000466c:	6442                	ld	s0,16(sp)
    8000466e:	64a2                	ld	s1,8(sp)
    80004670:	6105                	addi	sp,sp,32
    80004672:	8082                	ret
    panic("filedup");
    80004674:	00004517          	auipc	a0,0x4
    80004678:	00c50513          	addi	a0,a0,12 # 80008680 <syscalls+0x250>
    8000467c:	ffffc097          	auipc	ra,0xffffc
    80004680:	eca080e7          	jalr	-310(ra) # 80000546 <panic>

0000000080004684 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004684:	7139                	addi	sp,sp,-64
    80004686:	fc06                	sd	ra,56(sp)
    80004688:	f822                	sd	s0,48(sp)
    8000468a:	f426                	sd	s1,40(sp)
    8000468c:	f04a                	sd	s2,32(sp)
    8000468e:	ec4e                	sd	s3,24(sp)
    80004690:	e852                	sd	s4,16(sp)
    80004692:	e456                	sd	s5,8(sp)
    80004694:	0080                	addi	s0,sp,64
    80004696:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004698:	0001e517          	auipc	a0,0x1e
    8000469c:	db850513          	addi	a0,a0,-584 # 80022450 <ftable>
    800046a0:	ffffc097          	auipc	ra,0xffffc
    800046a4:	5bc080e7          	jalr	1468(ra) # 80000c5c <acquire>
  if(f->ref < 1)
    800046a8:	40dc                	lw	a5,4(s1)
    800046aa:	06f05163          	blez	a5,8000470c <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800046ae:	37fd                	addiw	a5,a5,-1
    800046b0:	0007871b          	sext.w	a4,a5
    800046b4:	c0dc                	sw	a5,4(s1)
    800046b6:	06e04363          	bgtz	a4,8000471c <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046ba:	0004a903          	lw	s2,0(s1)
    800046be:	0094ca83          	lbu	s5,9(s1)
    800046c2:	0104ba03          	ld	s4,16(s1)
    800046c6:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800046ca:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046ce:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046d2:	0001e517          	auipc	a0,0x1e
    800046d6:	d7e50513          	addi	a0,a0,-642 # 80022450 <ftable>
    800046da:	ffffc097          	auipc	ra,0xffffc
    800046de:	636080e7          	jalr	1590(ra) # 80000d10 <release>

  if(ff.type == FD_PIPE){
    800046e2:	4785                	li	a5,1
    800046e4:	04f90d63          	beq	s2,a5,8000473e <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046e8:	3979                	addiw	s2,s2,-2
    800046ea:	4785                	li	a5,1
    800046ec:	0527e063          	bltu	a5,s2,8000472c <fileclose+0xa8>
    begin_op();
    800046f0:	00000097          	auipc	ra,0x0
    800046f4:	ac6080e7          	jalr	-1338(ra) # 800041b6 <begin_op>
    iput(ff.ip);
    800046f8:	854e                	mv	a0,s3
    800046fa:	fffff097          	auipc	ra,0xfffff
    800046fe:	2b0080e7          	jalr	688(ra) # 800039aa <iput>
    end_op();
    80004702:	00000097          	auipc	ra,0x0
    80004706:	b32080e7          	jalr	-1230(ra) # 80004234 <end_op>
    8000470a:	a00d                	j	8000472c <fileclose+0xa8>
    panic("fileclose");
    8000470c:	00004517          	auipc	a0,0x4
    80004710:	f7c50513          	addi	a0,a0,-132 # 80008688 <syscalls+0x258>
    80004714:	ffffc097          	auipc	ra,0xffffc
    80004718:	e32080e7          	jalr	-462(ra) # 80000546 <panic>
    release(&ftable.lock);
    8000471c:	0001e517          	auipc	a0,0x1e
    80004720:	d3450513          	addi	a0,a0,-716 # 80022450 <ftable>
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	5ec080e7          	jalr	1516(ra) # 80000d10 <release>
  }
}
    8000472c:	70e2                	ld	ra,56(sp)
    8000472e:	7442                	ld	s0,48(sp)
    80004730:	74a2                	ld	s1,40(sp)
    80004732:	7902                	ld	s2,32(sp)
    80004734:	69e2                	ld	s3,24(sp)
    80004736:	6a42                	ld	s4,16(sp)
    80004738:	6aa2                	ld	s5,8(sp)
    8000473a:	6121                	addi	sp,sp,64
    8000473c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000473e:	85d6                	mv	a1,s5
    80004740:	8552                	mv	a0,s4
    80004742:	00000097          	auipc	ra,0x0
    80004746:	372080e7          	jalr	882(ra) # 80004ab4 <pipeclose>
    8000474a:	b7cd                	j	8000472c <fileclose+0xa8>

000000008000474c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000474c:	715d                	addi	sp,sp,-80
    8000474e:	e486                	sd	ra,72(sp)
    80004750:	e0a2                	sd	s0,64(sp)
    80004752:	fc26                	sd	s1,56(sp)
    80004754:	f84a                	sd	s2,48(sp)
    80004756:	f44e                	sd	s3,40(sp)
    80004758:	0880                	addi	s0,sp,80
    8000475a:	84aa                	mv	s1,a0
    8000475c:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000475e:	ffffd097          	auipc	ra,0xffffd
    80004762:	2ca080e7          	jalr	714(ra) # 80001a28 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004766:	409c                	lw	a5,0(s1)
    80004768:	37f9                	addiw	a5,a5,-2
    8000476a:	4705                	li	a4,1
    8000476c:	04f76763          	bltu	a4,a5,800047ba <filestat+0x6e>
    80004770:	892a                	mv	s2,a0
    ilock(f->ip);
    80004772:	6c88                	ld	a0,24(s1)
    80004774:	fffff097          	auipc	ra,0xfffff
    80004778:	07c080e7          	jalr	124(ra) # 800037f0 <ilock>
    stati(f->ip, &st);
    8000477c:	fb840593          	addi	a1,s0,-72
    80004780:	6c88                	ld	a0,24(s1)
    80004782:	fffff097          	auipc	ra,0xfffff
    80004786:	2f8080e7          	jalr	760(ra) # 80003a7a <stati>
    iunlock(f->ip);
    8000478a:	6c88                	ld	a0,24(s1)
    8000478c:	fffff097          	auipc	ra,0xfffff
    80004790:	126080e7          	jalr	294(ra) # 800038b2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004794:	46e1                	li	a3,24
    80004796:	fb840613          	addi	a2,s0,-72
    8000479a:	85ce                	mv	a1,s3
    8000479c:	05093503          	ld	a0,80(s2)
    800047a0:	ffffd097          	auipc	ra,0xffffd
    800047a4:	f7e080e7          	jalr	-130(ra) # 8000171e <copyout>
    800047a8:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800047ac:	60a6                	ld	ra,72(sp)
    800047ae:	6406                	ld	s0,64(sp)
    800047b0:	74e2                	ld	s1,56(sp)
    800047b2:	7942                	ld	s2,48(sp)
    800047b4:	79a2                	ld	s3,40(sp)
    800047b6:	6161                	addi	sp,sp,80
    800047b8:	8082                	ret
  return -1;
    800047ba:	557d                	li	a0,-1
    800047bc:	bfc5                	j	800047ac <filestat+0x60>

00000000800047be <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047be:	7179                	addi	sp,sp,-48
    800047c0:	f406                	sd	ra,40(sp)
    800047c2:	f022                	sd	s0,32(sp)
    800047c4:	ec26                	sd	s1,24(sp)
    800047c6:	e84a                	sd	s2,16(sp)
    800047c8:	e44e                	sd	s3,8(sp)
    800047ca:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047cc:	00854783          	lbu	a5,8(a0)
    800047d0:	c3d5                	beqz	a5,80004874 <fileread+0xb6>
    800047d2:	84aa                	mv	s1,a0
    800047d4:	89ae                	mv	s3,a1
    800047d6:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800047d8:	411c                	lw	a5,0(a0)
    800047da:	4705                	li	a4,1
    800047dc:	04e78963          	beq	a5,a4,8000482e <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047e0:	470d                	li	a4,3
    800047e2:	04e78d63          	beq	a5,a4,8000483c <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047e6:	4709                	li	a4,2
    800047e8:	06e79e63          	bne	a5,a4,80004864 <fileread+0xa6>
    ilock(f->ip);
    800047ec:	6d08                	ld	a0,24(a0)
    800047ee:	fffff097          	auipc	ra,0xfffff
    800047f2:	002080e7          	jalr	2(ra) # 800037f0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047f6:	874a                	mv	a4,s2
    800047f8:	5094                	lw	a3,32(s1)
    800047fa:	864e                	mv	a2,s3
    800047fc:	4585                	li	a1,1
    800047fe:	6c88                	ld	a0,24(s1)
    80004800:	fffff097          	auipc	ra,0xfffff
    80004804:	2a4080e7          	jalr	676(ra) # 80003aa4 <readi>
    80004808:	892a                	mv	s2,a0
    8000480a:	00a05563          	blez	a0,80004814 <fileread+0x56>
      f->off += r;
    8000480e:	509c                	lw	a5,32(s1)
    80004810:	9fa9                	addw	a5,a5,a0
    80004812:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004814:	6c88                	ld	a0,24(s1)
    80004816:	fffff097          	auipc	ra,0xfffff
    8000481a:	09c080e7          	jalr	156(ra) # 800038b2 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000481e:	854a                	mv	a0,s2
    80004820:	70a2                	ld	ra,40(sp)
    80004822:	7402                	ld	s0,32(sp)
    80004824:	64e2                	ld	s1,24(sp)
    80004826:	6942                	ld	s2,16(sp)
    80004828:	69a2                	ld	s3,8(sp)
    8000482a:	6145                	addi	sp,sp,48
    8000482c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000482e:	6908                	ld	a0,16(a0)
    80004830:	00000097          	auipc	ra,0x0
    80004834:	3f6080e7          	jalr	1014(ra) # 80004c26 <piperead>
    80004838:	892a                	mv	s2,a0
    8000483a:	b7d5                	j	8000481e <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000483c:	02451783          	lh	a5,36(a0)
    80004840:	03079693          	slli	a3,a5,0x30
    80004844:	92c1                	srli	a3,a3,0x30
    80004846:	4725                	li	a4,9
    80004848:	02d76863          	bltu	a4,a3,80004878 <fileread+0xba>
    8000484c:	0792                	slli	a5,a5,0x4
    8000484e:	0001e717          	auipc	a4,0x1e
    80004852:	b6270713          	addi	a4,a4,-1182 # 800223b0 <devsw>
    80004856:	97ba                	add	a5,a5,a4
    80004858:	639c                	ld	a5,0(a5)
    8000485a:	c38d                	beqz	a5,8000487c <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000485c:	4505                	li	a0,1
    8000485e:	9782                	jalr	a5
    80004860:	892a                	mv	s2,a0
    80004862:	bf75                	j	8000481e <fileread+0x60>
    panic("fileread");
    80004864:	00004517          	auipc	a0,0x4
    80004868:	e3450513          	addi	a0,a0,-460 # 80008698 <syscalls+0x268>
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	cda080e7          	jalr	-806(ra) # 80000546 <panic>
    return -1;
    80004874:	597d                	li	s2,-1
    80004876:	b765                	j	8000481e <fileread+0x60>
      return -1;
    80004878:	597d                	li	s2,-1
    8000487a:	b755                	j	8000481e <fileread+0x60>
    8000487c:	597d                	li	s2,-1
    8000487e:	b745                	j	8000481e <fileread+0x60>

0000000080004880 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004880:	00954783          	lbu	a5,9(a0)
    80004884:	14078563          	beqz	a5,800049ce <filewrite+0x14e>
{
    80004888:	715d                	addi	sp,sp,-80
    8000488a:	e486                	sd	ra,72(sp)
    8000488c:	e0a2                	sd	s0,64(sp)
    8000488e:	fc26                	sd	s1,56(sp)
    80004890:	f84a                	sd	s2,48(sp)
    80004892:	f44e                	sd	s3,40(sp)
    80004894:	f052                	sd	s4,32(sp)
    80004896:	ec56                	sd	s5,24(sp)
    80004898:	e85a                	sd	s6,16(sp)
    8000489a:	e45e                	sd	s7,8(sp)
    8000489c:	e062                	sd	s8,0(sp)
    8000489e:	0880                	addi	s0,sp,80
    800048a0:	892a                	mv	s2,a0
    800048a2:	8b2e                	mv	s6,a1
    800048a4:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800048a6:	411c                	lw	a5,0(a0)
    800048a8:	4705                	li	a4,1
    800048aa:	02e78263          	beq	a5,a4,800048ce <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048ae:	470d                	li	a4,3
    800048b0:	02e78563          	beq	a5,a4,800048da <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048b4:	4709                	li	a4,2
    800048b6:	10e79463          	bne	a5,a4,800049be <filewrite+0x13e>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048ba:	0ec05e63          	blez	a2,800049b6 <filewrite+0x136>
    int i = 0;
    800048be:	4981                	li	s3,0
    800048c0:	6b85                	lui	s7,0x1
    800048c2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048c6:	6c05                	lui	s8,0x1
    800048c8:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800048cc:	a851                	j	80004960 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800048ce:	6908                	ld	a0,16(a0)
    800048d0:	00000097          	auipc	ra,0x0
    800048d4:	254080e7          	jalr	596(ra) # 80004b24 <pipewrite>
    800048d8:	a85d                	j	8000498e <filewrite+0x10e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048da:	02451783          	lh	a5,36(a0)
    800048de:	03079693          	slli	a3,a5,0x30
    800048e2:	92c1                	srli	a3,a3,0x30
    800048e4:	4725                	li	a4,9
    800048e6:	0ed76663          	bltu	a4,a3,800049d2 <filewrite+0x152>
    800048ea:	0792                	slli	a5,a5,0x4
    800048ec:	0001e717          	auipc	a4,0x1e
    800048f0:	ac470713          	addi	a4,a4,-1340 # 800223b0 <devsw>
    800048f4:	97ba                	add	a5,a5,a4
    800048f6:	679c                	ld	a5,8(a5)
    800048f8:	cff9                	beqz	a5,800049d6 <filewrite+0x156>
    ret = devsw[f->major].write(1, addr, n);
    800048fa:	4505                	li	a0,1
    800048fc:	9782                	jalr	a5
    800048fe:	a841                	j	8000498e <filewrite+0x10e>
    80004900:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004904:	00000097          	auipc	ra,0x0
    80004908:	8b2080e7          	jalr	-1870(ra) # 800041b6 <begin_op>
      ilock(f->ip);
    8000490c:	01893503          	ld	a0,24(s2)
    80004910:	fffff097          	auipc	ra,0xfffff
    80004914:	ee0080e7          	jalr	-288(ra) # 800037f0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004918:	8756                	mv	a4,s5
    8000491a:	02092683          	lw	a3,32(s2)
    8000491e:	01698633          	add	a2,s3,s6
    80004922:	4585                	li	a1,1
    80004924:	01893503          	ld	a0,24(s2)
    80004928:	fffff097          	auipc	ra,0xfffff
    8000492c:	272080e7          	jalr	626(ra) # 80003b9a <writei>
    80004930:	84aa                	mv	s1,a0
    80004932:	02a05f63          	blez	a0,80004970 <filewrite+0xf0>
        f->off += r;
    80004936:	02092783          	lw	a5,32(s2)
    8000493a:	9fa9                	addw	a5,a5,a0
    8000493c:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004940:	01893503          	ld	a0,24(s2)
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	f6e080e7          	jalr	-146(ra) # 800038b2 <iunlock>
      end_op();
    8000494c:	00000097          	auipc	ra,0x0
    80004950:	8e8080e7          	jalr	-1816(ra) # 80004234 <end_op>

      if(r < 0)
        break;
      if(r != n1)
    80004954:	049a9963          	bne	s5,s1,800049a6 <filewrite+0x126>
        panic("short filewrite");
      i += r;
    80004958:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000495c:	0349d663          	bge	s3,s4,80004988 <filewrite+0x108>
      int n1 = n - i;
    80004960:	413a04bb          	subw	s1,s4,s3
    80004964:	0004879b          	sext.w	a5,s1
    80004968:	f8fbdce3          	bge	s7,a5,80004900 <filewrite+0x80>
    8000496c:	84e2                	mv	s1,s8
    8000496e:	bf49                	j	80004900 <filewrite+0x80>
      iunlock(f->ip);
    80004970:	01893503          	ld	a0,24(s2)
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	f3e080e7          	jalr	-194(ra) # 800038b2 <iunlock>
      end_op();
    8000497c:	00000097          	auipc	ra,0x0
    80004980:	8b8080e7          	jalr	-1864(ra) # 80004234 <end_op>
      if(r < 0)
    80004984:	fc04d8e3          	bgez	s1,80004954 <filewrite+0xd4>
    }
    ret = (i == n ? n : -1);
    80004988:	8552                	mv	a0,s4
    8000498a:	033a1863          	bne	s4,s3,800049ba <filewrite+0x13a>
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000498e:	60a6                	ld	ra,72(sp)
    80004990:	6406                	ld	s0,64(sp)
    80004992:	74e2                	ld	s1,56(sp)
    80004994:	7942                	ld	s2,48(sp)
    80004996:	79a2                	ld	s3,40(sp)
    80004998:	7a02                	ld	s4,32(sp)
    8000499a:	6ae2                	ld	s5,24(sp)
    8000499c:	6b42                	ld	s6,16(sp)
    8000499e:	6ba2                	ld	s7,8(sp)
    800049a0:	6c02                	ld	s8,0(sp)
    800049a2:	6161                	addi	sp,sp,80
    800049a4:	8082                	ret
        panic("short filewrite");
    800049a6:	00004517          	auipc	a0,0x4
    800049aa:	d0250513          	addi	a0,a0,-766 # 800086a8 <syscalls+0x278>
    800049ae:	ffffc097          	auipc	ra,0xffffc
    800049b2:	b98080e7          	jalr	-1128(ra) # 80000546 <panic>
    int i = 0;
    800049b6:	4981                	li	s3,0
    800049b8:	bfc1                	j	80004988 <filewrite+0x108>
    ret = (i == n ? n : -1);
    800049ba:	557d                	li	a0,-1
    800049bc:	bfc9                	j	8000498e <filewrite+0x10e>
    panic("filewrite");
    800049be:	00004517          	auipc	a0,0x4
    800049c2:	cfa50513          	addi	a0,a0,-774 # 800086b8 <syscalls+0x288>
    800049c6:	ffffc097          	auipc	ra,0xffffc
    800049ca:	b80080e7          	jalr	-1152(ra) # 80000546 <panic>
    return -1;
    800049ce:	557d                	li	a0,-1
}
    800049d0:	8082                	ret
      return -1;
    800049d2:	557d                	li	a0,-1
    800049d4:	bf6d                	j	8000498e <filewrite+0x10e>
    800049d6:	557d                	li	a0,-1
    800049d8:	bf5d                	j	8000498e <filewrite+0x10e>

00000000800049da <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049da:	7179                	addi	sp,sp,-48
    800049dc:	f406                	sd	ra,40(sp)
    800049de:	f022                	sd	s0,32(sp)
    800049e0:	ec26                	sd	s1,24(sp)
    800049e2:	e84a                	sd	s2,16(sp)
    800049e4:	e44e                	sd	s3,8(sp)
    800049e6:	e052                	sd	s4,0(sp)
    800049e8:	1800                	addi	s0,sp,48
    800049ea:	84aa                	mv	s1,a0
    800049ec:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049ee:	0005b023          	sd	zero,0(a1)
    800049f2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049f6:	00000097          	auipc	ra,0x0
    800049fa:	bd2080e7          	jalr	-1070(ra) # 800045c8 <filealloc>
    800049fe:	e088                	sd	a0,0(s1)
    80004a00:	c551                	beqz	a0,80004a8c <pipealloc+0xb2>
    80004a02:	00000097          	auipc	ra,0x0
    80004a06:	bc6080e7          	jalr	-1082(ra) # 800045c8 <filealloc>
    80004a0a:	00aa3023          	sd	a0,0(s4)
    80004a0e:	c92d                	beqz	a0,80004a80 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004a10:	ffffc097          	auipc	ra,0xffffc
    80004a14:	15c080e7          	jalr	348(ra) # 80000b6c <kalloc>
    80004a18:	892a                	mv	s2,a0
    80004a1a:	c125                	beqz	a0,80004a7a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004a1c:	4985                	li	s3,1
    80004a1e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004a22:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004a26:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004a2a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004a2e:	00004597          	auipc	a1,0x4
    80004a32:	c9a58593          	addi	a1,a1,-870 # 800086c8 <syscalls+0x298>
    80004a36:	ffffc097          	auipc	ra,0xffffc
    80004a3a:	196080e7          	jalr	406(ra) # 80000bcc <initlock>
  (*f0)->type = FD_PIPE;
    80004a3e:	609c                	ld	a5,0(s1)
    80004a40:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a44:	609c                	ld	a5,0(s1)
    80004a46:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a4a:	609c                	ld	a5,0(s1)
    80004a4c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a50:	609c                	ld	a5,0(s1)
    80004a52:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a56:	000a3783          	ld	a5,0(s4)
    80004a5a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a5e:	000a3783          	ld	a5,0(s4)
    80004a62:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a66:	000a3783          	ld	a5,0(s4)
    80004a6a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a6e:	000a3783          	ld	a5,0(s4)
    80004a72:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a76:	4501                	li	a0,0
    80004a78:	a025                	j	80004aa0 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a7a:	6088                	ld	a0,0(s1)
    80004a7c:	e501                	bnez	a0,80004a84 <pipealloc+0xaa>
    80004a7e:	a039                	j	80004a8c <pipealloc+0xb2>
    80004a80:	6088                	ld	a0,0(s1)
    80004a82:	c51d                	beqz	a0,80004ab0 <pipealloc+0xd6>
    fileclose(*f0);
    80004a84:	00000097          	auipc	ra,0x0
    80004a88:	c00080e7          	jalr	-1024(ra) # 80004684 <fileclose>
  if(*f1)
    80004a8c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a90:	557d                	li	a0,-1
  if(*f1)
    80004a92:	c799                	beqz	a5,80004aa0 <pipealloc+0xc6>
    fileclose(*f1);
    80004a94:	853e                	mv	a0,a5
    80004a96:	00000097          	auipc	ra,0x0
    80004a9a:	bee080e7          	jalr	-1042(ra) # 80004684 <fileclose>
  return -1;
    80004a9e:	557d                	li	a0,-1
}
    80004aa0:	70a2                	ld	ra,40(sp)
    80004aa2:	7402                	ld	s0,32(sp)
    80004aa4:	64e2                	ld	s1,24(sp)
    80004aa6:	6942                	ld	s2,16(sp)
    80004aa8:	69a2                	ld	s3,8(sp)
    80004aaa:	6a02                	ld	s4,0(sp)
    80004aac:	6145                	addi	sp,sp,48
    80004aae:	8082                	ret
  return -1;
    80004ab0:	557d                	li	a0,-1
    80004ab2:	b7fd                	j	80004aa0 <pipealloc+0xc6>

0000000080004ab4 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004ab4:	1101                	addi	sp,sp,-32
    80004ab6:	ec06                	sd	ra,24(sp)
    80004ab8:	e822                	sd	s0,16(sp)
    80004aba:	e426                	sd	s1,8(sp)
    80004abc:	e04a                	sd	s2,0(sp)
    80004abe:	1000                	addi	s0,sp,32
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004ac4:	ffffc097          	auipc	ra,0xffffc
    80004ac8:	198080e7          	jalr	408(ra) # 80000c5c <acquire>
  if(writable){
    80004acc:	02090d63          	beqz	s2,80004b06 <pipeclose+0x52>
    pi->writeopen = 0;
    80004ad0:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004ad4:	21848513          	addi	a0,s1,536
    80004ad8:	ffffe097          	auipc	ra,0xffffe
    80004adc:	934080e7          	jalr	-1740(ra) # 8000240c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004ae0:	2204b783          	ld	a5,544(s1)
    80004ae4:	eb95                	bnez	a5,80004b18 <pipeclose+0x64>
    release(&pi->lock);
    80004ae6:	8526                	mv	a0,s1
    80004ae8:	ffffc097          	auipc	ra,0xffffc
    80004aec:	228080e7          	jalr	552(ra) # 80000d10 <release>
    kfree((char*)pi);
    80004af0:	8526                	mv	a0,s1
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	f7c080e7          	jalr	-132(ra) # 80000a6e <kfree>
  } else
    release(&pi->lock);
}
    80004afa:	60e2                	ld	ra,24(sp)
    80004afc:	6442                	ld	s0,16(sp)
    80004afe:	64a2                	ld	s1,8(sp)
    80004b00:	6902                	ld	s2,0(sp)
    80004b02:	6105                	addi	sp,sp,32
    80004b04:	8082                	ret
    pi->readopen = 0;
    80004b06:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004b0a:	21c48513          	addi	a0,s1,540
    80004b0e:	ffffe097          	auipc	ra,0xffffe
    80004b12:	8fe080e7          	jalr	-1794(ra) # 8000240c <wakeup>
    80004b16:	b7e9                	j	80004ae0 <pipeclose+0x2c>
    release(&pi->lock);
    80004b18:	8526                	mv	a0,s1
    80004b1a:	ffffc097          	auipc	ra,0xffffc
    80004b1e:	1f6080e7          	jalr	502(ra) # 80000d10 <release>
}
    80004b22:	bfe1                	j	80004afa <pipeclose+0x46>

0000000080004b24 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004b24:	711d                	addi	sp,sp,-96
    80004b26:	ec86                	sd	ra,88(sp)
    80004b28:	e8a2                	sd	s0,80(sp)
    80004b2a:	e4a6                	sd	s1,72(sp)
    80004b2c:	e0ca                	sd	s2,64(sp)
    80004b2e:	fc4e                	sd	s3,56(sp)
    80004b30:	f852                	sd	s4,48(sp)
    80004b32:	f456                	sd	s5,40(sp)
    80004b34:	f05a                	sd	s6,32(sp)
    80004b36:	ec5e                	sd	s7,24(sp)
    80004b38:	e862                	sd	s8,16(sp)
    80004b3a:	1080                	addi	s0,sp,96
    80004b3c:	84aa                	mv	s1,a0
    80004b3e:	8b2e                	mv	s6,a1
    80004b40:	8ab2                	mv	s5,a2
  int i;
  char ch;
  struct proc *pr = myproc();
    80004b42:	ffffd097          	auipc	ra,0xffffd
    80004b46:	ee6080e7          	jalr	-282(ra) # 80001a28 <myproc>
    80004b4a:	892a                	mv	s2,a0

  acquire(&pi->lock);
    80004b4c:	8526                	mv	a0,s1
    80004b4e:	ffffc097          	auipc	ra,0xffffc
    80004b52:	10e080e7          	jalr	270(ra) # 80000c5c <acquire>
  for(i = 0; i < n; i++){
    80004b56:	09505863          	blez	s5,80004be6 <pipewrite+0xc2>
    80004b5a:	4b81                	li	s7,0
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
      if(pi->readopen == 0 || pr->killed){
        release(&pi->lock);
        return -1;
      }
      wakeup(&pi->nread);
    80004b5c:	21848a13          	addi	s4,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b60:	21c48993          	addi	s3,s1,540
    }
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b64:	5c7d                	li	s8,-1
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b66:	2184a783          	lw	a5,536(s1)
    80004b6a:	21c4a703          	lw	a4,540(s1)
    80004b6e:	2007879b          	addiw	a5,a5,512
    80004b72:	02f71b63          	bne	a4,a5,80004ba8 <pipewrite+0x84>
      if(pi->readopen == 0 || pr->killed){
    80004b76:	2204a783          	lw	a5,544(s1)
    80004b7a:	c3d9                	beqz	a5,80004c00 <pipewrite+0xdc>
    80004b7c:	03092783          	lw	a5,48(s2)
    80004b80:	e3c1                	bnez	a5,80004c00 <pipewrite+0xdc>
      wakeup(&pi->nread);
    80004b82:	8552                	mv	a0,s4
    80004b84:	ffffe097          	auipc	ra,0xffffe
    80004b88:	888080e7          	jalr	-1912(ra) # 8000240c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b8c:	85a6                	mv	a1,s1
    80004b8e:	854e                	mv	a0,s3
    80004b90:	ffffd097          	auipc	ra,0xffffd
    80004b94:	6fc080e7          	jalr	1788(ra) # 8000228c <sleep>
    while(pi->nwrite == pi->nread + PIPESIZE){  //DOC: pipewrite-full
    80004b98:	2184a783          	lw	a5,536(s1)
    80004b9c:	21c4a703          	lw	a4,540(s1)
    80004ba0:	2007879b          	addiw	a5,a5,512
    80004ba4:	fcf709e3          	beq	a4,a5,80004b76 <pipewrite+0x52>
    if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ba8:	4685                	li	a3,1
    80004baa:	865a                	mv	a2,s6
    80004bac:	faf40593          	addi	a1,s0,-81
    80004bb0:	05093503          	ld	a0,80(s2)
    80004bb4:	ffffd097          	auipc	ra,0xffffd
    80004bb8:	bf6080e7          	jalr	-1034(ra) # 800017aa <copyin>
    80004bbc:	03850663          	beq	a0,s8,80004be8 <pipewrite+0xc4>
      break;
    pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004bc0:	21c4a783          	lw	a5,540(s1)
    80004bc4:	0017871b          	addiw	a4,a5,1
    80004bc8:	20e4ae23          	sw	a4,540(s1)
    80004bcc:	1ff7f793          	andi	a5,a5,511
    80004bd0:	97a6                	add	a5,a5,s1
    80004bd2:	faf44703          	lbu	a4,-81(s0)
    80004bd6:	00e78c23          	sb	a4,24(a5)
  for(i = 0; i < n; i++){
    80004bda:	2b85                	addiw	s7,s7,1
    80004bdc:	0b05                	addi	s6,s6,1
    80004bde:	f97a94e3          	bne	s5,s7,80004b66 <pipewrite+0x42>
    80004be2:	8bd6                	mv	s7,s5
    80004be4:	a011                	j	80004be8 <pipewrite+0xc4>
    80004be6:	4b81                	li	s7,0
  }
  wakeup(&pi->nread);
    80004be8:	21848513          	addi	a0,s1,536
    80004bec:	ffffe097          	auipc	ra,0xffffe
    80004bf0:	820080e7          	jalr	-2016(ra) # 8000240c <wakeup>
  release(&pi->lock);
    80004bf4:	8526                	mv	a0,s1
    80004bf6:	ffffc097          	auipc	ra,0xffffc
    80004bfa:	11a080e7          	jalr	282(ra) # 80000d10 <release>
  return i;
    80004bfe:	a039                	j	80004c0c <pipewrite+0xe8>
        release(&pi->lock);
    80004c00:	8526                	mv	a0,s1
    80004c02:	ffffc097          	auipc	ra,0xffffc
    80004c06:	10e080e7          	jalr	270(ra) # 80000d10 <release>
        return -1;
    80004c0a:	5bfd                	li	s7,-1
}
    80004c0c:	855e                	mv	a0,s7
    80004c0e:	60e6                	ld	ra,88(sp)
    80004c10:	6446                	ld	s0,80(sp)
    80004c12:	64a6                	ld	s1,72(sp)
    80004c14:	6906                	ld	s2,64(sp)
    80004c16:	79e2                	ld	s3,56(sp)
    80004c18:	7a42                	ld	s4,48(sp)
    80004c1a:	7aa2                	ld	s5,40(sp)
    80004c1c:	7b02                	ld	s6,32(sp)
    80004c1e:	6be2                	ld	s7,24(sp)
    80004c20:	6c42                	ld	s8,16(sp)
    80004c22:	6125                	addi	sp,sp,96
    80004c24:	8082                	ret

0000000080004c26 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004c26:	715d                	addi	sp,sp,-80
    80004c28:	e486                	sd	ra,72(sp)
    80004c2a:	e0a2                	sd	s0,64(sp)
    80004c2c:	fc26                	sd	s1,56(sp)
    80004c2e:	f84a                	sd	s2,48(sp)
    80004c30:	f44e                	sd	s3,40(sp)
    80004c32:	f052                	sd	s4,32(sp)
    80004c34:	ec56                	sd	s5,24(sp)
    80004c36:	e85a                	sd	s6,16(sp)
    80004c38:	0880                	addi	s0,sp,80
    80004c3a:	84aa                	mv	s1,a0
    80004c3c:	892e                	mv	s2,a1
    80004c3e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004c40:	ffffd097          	auipc	ra,0xffffd
    80004c44:	de8080e7          	jalr	-536(ra) # 80001a28 <myproc>
    80004c48:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004c4a:	8526                	mv	a0,s1
    80004c4c:	ffffc097          	auipc	ra,0xffffc
    80004c50:	010080e7          	jalr	16(ra) # 80000c5c <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c54:	2184a703          	lw	a4,536(s1)
    80004c58:	21c4a783          	lw	a5,540(s1)
    if(pr->killed){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c5c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c60:	02f71463          	bne	a4,a5,80004c88 <piperead+0x62>
    80004c64:	2244a783          	lw	a5,548(s1)
    80004c68:	c385                	beqz	a5,80004c88 <piperead+0x62>
    if(pr->killed){
    80004c6a:	030a2783          	lw	a5,48(s4)
    80004c6e:	ebc9                	bnez	a5,80004d00 <piperead+0xda>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c70:	85a6                	mv	a1,s1
    80004c72:	854e                	mv	a0,s3
    80004c74:	ffffd097          	auipc	ra,0xffffd
    80004c78:	618080e7          	jalr	1560(ra) # 8000228c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c7c:	2184a703          	lw	a4,536(s1)
    80004c80:	21c4a783          	lw	a5,540(s1)
    80004c84:	fef700e3          	beq	a4,a5,80004c64 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c88:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c8a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c8c:	05505463          	blez	s5,80004cd4 <piperead+0xae>
    if(pi->nread == pi->nwrite)
    80004c90:	2184a783          	lw	a5,536(s1)
    80004c94:	21c4a703          	lw	a4,540(s1)
    80004c98:	02f70e63          	beq	a4,a5,80004cd4 <piperead+0xae>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c9c:	0017871b          	addiw	a4,a5,1
    80004ca0:	20e4ac23          	sw	a4,536(s1)
    80004ca4:	1ff7f793          	andi	a5,a5,511
    80004ca8:	97a6                	add	a5,a5,s1
    80004caa:	0187c783          	lbu	a5,24(a5)
    80004cae:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004cb2:	4685                	li	a3,1
    80004cb4:	fbf40613          	addi	a2,s0,-65
    80004cb8:	85ca                	mv	a1,s2
    80004cba:	050a3503          	ld	a0,80(s4)
    80004cbe:	ffffd097          	auipc	ra,0xffffd
    80004cc2:	a60080e7          	jalr	-1440(ra) # 8000171e <copyout>
    80004cc6:	01650763          	beq	a0,s6,80004cd4 <piperead+0xae>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004cca:	2985                	addiw	s3,s3,1
    80004ccc:	0905                	addi	s2,s2,1
    80004cce:	fd3a91e3          	bne	s5,s3,80004c90 <piperead+0x6a>
    80004cd2:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004cd4:	21c48513          	addi	a0,s1,540
    80004cd8:	ffffd097          	auipc	ra,0xffffd
    80004cdc:	734080e7          	jalr	1844(ra) # 8000240c <wakeup>
  release(&pi->lock);
    80004ce0:	8526                	mv	a0,s1
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	02e080e7          	jalr	46(ra) # 80000d10 <release>
  return i;
}
    80004cea:	854e                	mv	a0,s3
    80004cec:	60a6                	ld	ra,72(sp)
    80004cee:	6406                	ld	s0,64(sp)
    80004cf0:	74e2                	ld	s1,56(sp)
    80004cf2:	7942                	ld	s2,48(sp)
    80004cf4:	79a2                	ld	s3,40(sp)
    80004cf6:	7a02                	ld	s4,32(sp)
    80004cf8:	6ae2                	ld	s5,24(sp)
    80004cfa:	6b42                	ld	s6,16(sp)
    80004cfc:	6161                	addi	sp,sp,80
    80004cfe:	8082                	ret
      release(&pi->lock);
    80004d00:	8526                	mv	a0,s1
    80004d02:	ffffc097          	auipc	ra,0xffffc
    80004d06:	00e080e7          	jalr	14(ra) # 80000d10 <release>
      return -1;
    80004d0a:	59fd                	li	s3,-1
    80004d0c:	bff9                	j	80004cea <piperead+0xc4>

0000000080004d0e <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004d0e:	de010113          	addi	sp,sp,-544
    80004d12:	20113c23          	sd	ra,536(sp)
    80004d16:	20813823          	sd	s0,528(sp)
    80004d1a:	20913423          	sd	s1,520(sp)
    80004d1e:	21213023          	sd	s2,512(sp)
    80004d22:	ffce                	sd	s3,504(sp)
    80004d24:	fbd2                	sd	s4,496(sp)
    80004d26:	f7d6                	sd	s5,488(sp)
    80004d28:	f3da                	sd	s6,480(sp)
    80004d2a:	efde                	sd	s7,472(sp)
    80004d2c:	ebe2                	sd	s8,464(sp)
    80004d2e:	e7e6                	sd	s9,456(sp)
    80004d30:	e3ea                	sd	s10,448(sp)
    80004d32:	ff6e                	sd	s11,440(sp)
    80004d34:	1400                	addi	s0,sp,544
    80004d36:	892a                	mv	s2,a0
    80004d38:	dea43423          	sd	a0,-536(s0)
    80004d3c:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d40:	ffffd097          	auipc	ra,0xffffd
    80004d44:	ce8080e7          	jalr	-792(ra) # 80001a28 <myproc>
    80004d48:	84aa                	mv	s1,a0

  begin_op();
    80004d4a:	fffff097          	auipc	ra,0xfffff
    80004d4e:	46c080e7          	jalr	1132(ra) # 800041b6 <begin_op>

  if((ip = namei(path)) == 0){
    80004d52:	854a                	mv	a0,s2
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	252080e7          	jalr	594(ra) # 80003fa6 <namei>
    80004d5c:	c93d                	beqz	a0,80004dd2 <exec+0xc4>
    80004d5e:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	a90080e7          	jalr	-1392(ra) # 800037f0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d68:	04000713          	li	a4,64
    80004d6c:	4681                	li	a3,0
    80004d6e:	e4840613          	addi	a2,s0,-440
    80004d72:	4581                	li	a1,0
    80004d74:	8556                	mv	a0,s5
    80004d76:	fffff097          	auipc	ra,0xfffff
    80004d7a:	d2e080e7          	jalr	-722(ra) # 80003aa4 <readi>
    80004d7e:	04000793          	li	a5,64
    80004d82:	00f51a63          	bne	a0,a5,80004d96 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    80004d86:	e4842703          	lw	a4,-440(s0)
    80004d8a:	464c47b7          	lui	a5,0x464c4
    80004d8e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d92:	04f70663          	beq	a4,a5,80004dde <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d96:	8556                	mv	a0,s5
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	cba080e7          	jalr	-838(ra) # 80003a52 <iunlockput>
    end_op();
    80004da0:	fffff097          	auipc	ra,0xfffff
    80004da4:	494080e7          	jalr	1172(ra) # 80004234 <end_op>
  }
  return -1;
    80004da8:	557d                	li	a0,-1
}
    80004daa:	21813083          	ld	ra,536(sp)
    80004dae:	21013403          	ld	s0,528(sp)
    80004db2:	20813483          	ld	s1,520(sp)
    80004db6:	20013903          	ld	s2,512(sp)
    80004dba:	79fe                	ld	s3,504(sp)
    80004dbc:	7a5e                	ld	s4,496(sp)
    80004dbe:	7abe                	ld	s5,488(sp)
    80004dc0:	7b1e                	ld	s6,480(sp)
    80004dc2:	6bfe                	ld	s7,472(sp)
    80004dc4:	6c5e                	ld	s8,464(sp)
    80004dc6:	6cbe                	ld	s9,456(sp)
    80004dc8:	6d1e                	ld	s10,448(sp)
    80004dca:	7dfa                	ld	s11,440(sp)
    80004dcc:	22010113          	addi	sp,sp,544
    80004dd0:	8082                	ret
    end_op();
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	462080e7          	jalr	1122(ra) # 80004234 <end_op>
    return -1;
    80004dda:	557d                	li	a0,-1
    80004ddc:	b7f9                	j	80004daa <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004dde:	8526                	mv	a0,s1
    80004de0:	ffffd097          	auipc	ra,0xffffd
    80004de4:	d0c080e7          	jalr	-756(ra) # 80001aec <proc_pagetable>
    80004de8:	8b2a                	mv	s6,a0
    80004dea:	d555                	beqz	a0,80004d96 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dec:	e6842783          	lw	a5,-408(s0)
    80004df0:	e8045703          	lhu	a4,-384(s0)
    80004df4:	c735                	beqz	a4,80004e60 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004df6:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004df8:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004dfc:	6a05                	lui	s4,0x1
    80004dfe:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004e02:	dee43023          	sd	a4,-544(s0)
  uint64 pa;

  if((va % PGSIZE) != 0)
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    80004e06:	6d85                	lui	s11,0x1
    80004e08:	7d7d                	lui	s10,0xfffff
    80004e0a:	ac1d                	j	80005040 <exec+0x332>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004e0c:	00004517          	auipc	a0,0x4
    80004e10:	8c450513          	addi	a0,a0,-1852 # 800086d0 <syscalls+0x2a0>
    80004e14:	ffffb097          	auipc	ra,0xffffb
    80004e18:	732080e7          	jalr	1842(ra) # 80000546 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004e1c:	874a                	mv	a4,s2
    80004e1e:	009c86bb          	addw	a3,s9,s1
    80004e22:	4581                	li	a1,0
    80004e24:	8556                	mv	a0,s5
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	c7e080e7          	jalr	-898(ra) # 80003aa4 <readi>
    80004e2e:	2501                	sext.w	a0,a0
    80004e30:	1aa91863          	bne	s2,a0,80004fe0 <exec+0x2d2>
  for(i = 0; i < sz; i += PGSIZE){
    80004e34:	009d84bb          	addw	s1,s11,s1
    80004e38:	013d09bb          	addw	s3,s10,s3
    80004e3c:	1f74f263          	bgeu	s1,s7,80005020 <exec+0x312>
    pa = walkaddr(pagetable, va + i);
    80004e40:	02049593          	slli	a1,s1,0x20
    80004e44:	9181                	srli	a1,a1,0x20
    80004e46:	95e2                	add	a1,a1,s8
    80004e48:	855a                	mv	a0,s6
    80004e4a:	ffffc097          	auipc	ra,0xffffc
    80004e4e:	29c080e7          	jalr	668(ra) # 800010e6 <walkaddr>
    80004e52:	862a                	mv	a2,a0
    if(pa == 0)
    80004e54:	dd45                	beqz	a0,80004e0c <exec+0xfe>
      n = PGSIZE;
    80004e56:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004e58:	fd49f2e3          	bgeu	s3,s4,80004e1c <exec+0x10e>
      n = sz - i;
    80004e5c:	894e                	mv	s2,s3
    80004e5e:	bf7d                	j	80004e1c <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    80004e60:	4481                	li	s1,0
  iunlockput(ip);
    80004e62:	8556                	mv	a0,s5
    80004e64:	fffff097          	auipc	ra,0xfffff
    80004e68:	bee080e7          	jalr	-1042(ra) # 80003a52 <iunlockput>
  end_op();
    80004e6c:	fffff097          	auipc	ra,0xfffff
    80004e70:	3c8080e7          	jalr	968(ra) # 80004234 <end_op>
  p = myproc();
    80004e74:	ffffd097          	auipc	ra,0xffffd
    80004e78:	bb4080e7          	jalr	-1100(ra) # 80001a28 <myproc>
    80004e7c:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004e7e:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e82:	6785                	lui	a5,0x1
    80004e84:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004e86:	97a6                	add	a5,a5,s1
    80004e88:	777d                	lui	a4,0xfffff
    80004e8a:	8ff9                	and	a5,a5,a4
    80004e8c:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004e90:	6609                	lui	a2,0x2
    80004e92:	963e                	add	a2,a2,a5
    80004e94:	85be                	mv	a1,a5
    80004e96:	855a                	mv	a0,s6
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	632080e7          	jalr	1586(ra) # 800014ca <uvmalloc>
    80004ea0:	8c2a                	mv	s8,a0
  ip = 0;
    80004ea2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    80004ea4:	12050e63          	beqz	a0,80004fe0 <exec+0x2d2>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ea8:	75f9                	lui	a1,0xffffe
    80004eaa:	95aa                	add	a1,a1,a0
    80004eac:	855a                	mv	a0,s6
    80004eae:	ffffd097          	auipc	ra,0xffffd
    80004eb2:	83e080e7          	jalr	-1986(ra) # 800016ec <uvmclear>
  stackbase = sp - PGSIZE;
    80004eb6:	7afd                	lui	s5,0xfffff
    80004eb8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004eba:	df043783          	ld	a5,-528(s0)
    80004ebe:	6388                	ld	a0,0(a5)
    80004ec0:	c925                	beqz	a0,80004f30 <exec+0x222>
    80004ec2:	e8840993          	addi	s3,s0,-376
    80004ec6:	f8840c93          	addi	s9,s0,-120
  sp = sz;
    80004eca:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004ecc:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004ece:	ffffc097          	auipc	ra,0xffffc
    80004ed2:	00e080e7          	jalr	14(ra) # 80000edc <strlen>
    80004ed6:	0015079b          	addiw	a5,a0,1
    80004eda:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ede:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ee2:	13596363          	bltu	s2,s5,80005008 <exec+0x2fa>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ee6:	df043d83          	ld	s11,-528(s0)
    80004eea:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80004eee:	8552                	mv	a0,s4
    80004ef0:	ffffc097          	auipc	ra,0xffffc
    80004ef4:	fec080e7          	jalr	-20(ra) # 80000edc <strlen>
    80004ef8:	0015069b          	addiw	a3,a0,1
    80004efc:	8652                	mv	a2,s4
    80004efe:	85ca                	mv	a1,s2
    80004f00:	855a                	mv	a0,s6
    80004f02:	ffffd097          	auipc	ra,0xffffd
    80004f06:	81c080e7          	jalr	-2020(ra) # 8000171e <copyout>
    80004f0a:	10054363          	bltz	a0,80005010 <exec+0x302>
    ustack[argc] = sp;
    80004f0e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004f12:	0485                	addi	s1,s1,1
    80004f14:	008d8793          	addi	a5,s11,8
    80004f18:	def43823          	sd	a5,-528(s0)
    80004f1c:	008db503          	ld	a0,8(s11)
    80004f20:	c911                	beqz	a0,80004f34 <exec+0x226>
    if(argc >= MAXARG)
    80004f22:	09a1                	addi	s3,s3,8
    80004f24:	fb3c95e3          	bne	s9,s3,80004ece <exec+0x1c0>
  sz = sz1;
    80004f28:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f2c:	4a81                	li	s5,0
    80004f2e:	a84d                	j	80004fe0 <exec+0x2d2>
  sp = sz;
    80004f30:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004f32:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f34:	00349793          	slli	a5,s1,0x3
    80004f38:	f9078793          	addi	a5,a5,-112
    80004f3c:	97a2                	add	a5,a5,s0
    80004f3e:	ee07bc23          	sd	zero,-264(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f42:	00148693          	addi	a3,s1,1
    80004f46:	068e                	slli	a3,a3,0x3
    80004f48:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f4c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004f50:	01597663          	bgeu	s2,s5,80004f5c <exec+0x24e>
  sz = sz1;
    80004f54:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80004f58:	4a81                	li	s5,0
    80004f5a:	a059                	j	80004fe0 <exec+0x2d2>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f5c:	e8840613          	addi	a2,s0,-376
    80004f60:	85ca                	mv	a1,s2
    80004f62:	855a                	mv	a0,s6
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	7ba080e7          	jalr	1978(ra) # 8000171e <copyout>
    80004f6c:	0a054663          	bltz	a0,80005018 <exec+0x30a>
  p->trapframe->a1 = sp;
    80004f70:	058bb783          	ld	a5,88(s7)
    80004f74:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f78:	de843783          	ld	a5,-536(s0)
    80004f7c:	0007c703          	lbu	a4,0(a5)
    80004f80:	cf11                	beqz	a4,80004f9c <exec+0x28e>
    80004f82:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f84:	02f00693          	li	a3,47
    80004f88:	a039                	j	80004f96 <exec+0x288>
      last = s+1;
    80004f8a:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    80004f8e:	0785                	addi	a5,a5,1
    80004f90:	fff7c703          	lbu	a4,-1(a5)
    80004f94:	c701                	beqz	a4,80004f9c <exec+0x28e>
    if(*s == '/')
    80004f96:	fed71ce3          	bne	a4,a3,80004f8e <exec+0x280>
    80004f9a:	bfc5                	j	80004f8a <exec+0x27c>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f9c:	4641                	li	a2,16
    80004f9e:	de843583          	ld	a1,-536(s0)
    80004fa2:	158b8513          	addi	a0,s7,344
    80004fa6:	ffffc097          	auipc	ra,0xffffc
    80004faa:	f04080e7          	jalr	-252(ra) # 80000eaa <safestrcpy>
  oldpagetable = p->pagetable;
    80004fae:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    80004fb2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    80004fb6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004fba:	058bb783          	ld	a5,88(s7)
    80004fbe:	e6043703          	ld	a4,-416(s0)
    80004fc2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fc4:	058bb783          	ld	a5,88(s7)
    80004fc8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fcc:	85ea                	mv	a1,s10
    80004fce:	ffffd097          	auipc	ra,0xffffd
    80004fd2:	bba080e7          	jalr	-1094(ra) # 80001b88 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fd6:	0004851b          	sext.w	a0,s1
    80004fda:	bbc1                	j	80004daa <exec+0x9c>
    80004fdc:	de943c23          	sd	s1,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004fe0:	df843583          	ld	a1,-520(s0)
    80004fe4:	855a                	mv	a0,s6
    80004fe6:	ffffd097          	auipc	ra,0xffffd
    80004fea:	ba2080e7          	jalr	-1118(ra) # 80001b88 <proc_freepagetable>
  if(ip){
    80004fee:	da0a94e3          	bnez	s5,80004d96 <exec+0x88>
  return -1;
    80004ff2:	557d                	li	a0,-1
    80004ff4:	bb5d                	j	80004daa <exec+0x9c>
    80004ff6:	de943c23          	sd	s1,-520(s0)
    80004ffa:	b7dd                	j	80004fe0 <exec+0x2d2>
    80004ffc:	de943c23          	sd	s1,-520(s0)
    80005000:	b7c5                	j	80004fe0 <exec+0x2d2>
    80005002:	de943c23          	sd	s1,-520(s0)
    80005006:	bfe9                	j	80004fe0 <exec+0x2d2>
  sz = sz1;
    80005008:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000500c:	4a81                	li	s5,0
    8000500e:	bfc9                	j	80004fe0 <exec+0x2d2>
  sz = sz1;
    80005010:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005014:	4a81                	li	s5,0
    80005016:	b7e9                	j	80004fe0 <exec+0x2d2>
  sz = sz1;
    80005018:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000501c:	4a81                	li	s5,0
    8000501e:	b7c9                	j	80004fe0 <exec+0x2d2>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005020:	df843483          	ld	s1,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005024:	e0843783          	ld	a5,-504(s0)
    80005028:	0017869b          	addiw	a3,a5,1
    8000502c:	e0d43423          	sd	a3,-504(s0)
    80005030:	e0043783          	ld	a5,-512(s0)
    80005034:	0387879b          	addiw	a5,a5,56
    80005038:	e8045703          	lhu	a4,-384(s0)
    8000503c:	e2e6d3e3          	bge	a3,a4,80004e62 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005040:	2781                	sext.w	a5,a5
    80005042:	e0f43023          	sd	a5,-512(s0)
    80005046:	03800713          	li	a4,56
    8000504a:	86be                	mv	a3,a5
    8000504c:	e1040613          	addi	a2,s0,-496
    80005050:	4581                	li	a1,0
    80005052:	8556                	mv	a0,s5
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	a50080e7          	jalr	-1456(ra) # 80003aa4 <readi>
    8000505c:	03800793          	li	a5,56
    80005060:	f6f51ee3          	bne	a0,a5,80004fdc <exec+0x2ce>
    if(ph.type != ELF_PROG_LOAD)
    80005064:	e1042783          	lw	a5,-496(s0)
    80005068:	4705                	li	a4,1
    8000506a:	fae79de3          	bne	a5,a4,80005024 <exec+0x316>
    if(ph.memsz < ph.filesz)
    8000506e:	e3843603          	ld	a2,-456(s0)
    80005072:	e3043783          	ld	a5,-464(s0)
    80005076:	f8f660e3          	bltu	a2,a5,80004ff6 <exec+0x2e8>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000507a:	e2043783          	ld	a5,-480(s0)
    8000507e:	963e                	add	a2,a2,a5
    80005080:	f6f66ee3          	bltu	a2,a5,80004ffc <exec+0x2ee>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    80005084:	85a6                	mv	a1,s1
    80005086:	855a                	mv	a0,s6
    80005088:	ffffc097          	auipc	ra,0xffffc
    8000508c:	442080e7          	jalr	1090(ra) # 800014ca <uvmalloc>
    80005090:	dea43c23          	sd	a0,-520(s0)
    80005094:	d53d                	beqz	a0,80005002 <exec+0x2f4>
    if(ph.vaddr % PGSIZE != 0)
    80005096:	e2043c03          	ld	s8,-480(s0)
    8000509a:	de043783          	ld	a5,-544(s0)
    8000509e:	00fc77b3          	and	a5,s8,a5
    800050a2:	ff9d                	bnez	a5,80004fe0 <exec+0x2d2>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050a4:	e1842c83          	lw	s9,-488(s0)
    800050a8:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050ac:	f60b8ae3          	beqz	s7,80005020 <exec+0x312>
    800050b0:	89de                	mv	s3,s7
    800050b2:	4481                	li	s1,0
    800050b4:	b371                	j	80004e40 <exec+0x132>

00000000800050b6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050b6:	7179                	addi	sp,sp,-48
    800050b8:	f406                	sd	ra,40(sp)
    800050ba:	f022                	sd	s0,32(sp)
    800050bc:	ec26                	sd	s1,24(sp)
    800050be:	e84a                	sd	s2,16(sp)
    800050c0:	1800                	addi	s0,sp,48
    800050c2:	892e                	mv	s2,a1
    800050c4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    800050c6:	fdc40593          	addi	a1,s0,-36
    800050ca:	ffffe097          	auipc	ra,0xffffe
    800050ce:	b48080e7          	jalr	-1208(ra) # 80002c12 <argint>
    800050d2:	04054063          	bltz	a0,80005112 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050d6:	fdc42703          	lw	a4,-36(s0)
    800050da:	47bd                	li	a5,15
    800050dc:	02e7ed63          	bltu	a5,a4,80005116 <argfd+0x60>
    800050e0:	ffffd097          	auipc	ra,0xffffd
    800050e4:	948080e7          	jalr	-1720(ra) # 80001a28 <myproc>
    800050e8:	fdc42703          	lw	a4,-36(s0)
    800050ec:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffd801a>
    800050f0:	078e                	slli	a5,a5,0x3
    800050f2:	953e                	add	a0,a0,a5
    800050f4:	611c                	ld	a5,0(a0)
    800050f6:	c395                	beqz	a5,8000511a <argfd+0x64>
    return -1;
  if(pfd)
    800050f8:	00090463          	beqz	s2,80005100 <argfd+0x4a>
    *pfd = fd;
    800050fc:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005100:	4501                	li	a0,0
  if(pf)
    80005102:	c091                	beqz	s1,80005106 <argfd+0x50>
    *pf = f;
    80005104:	e09c                	sd	a5,0(s1)
}
    80005106:	70a2                	ld	ra,40(sp)
    80005108:	7402                	ld	s0,32(sp)
    8000510a:	64e2                	ld	s1,24(sp)
    8000510c:	6942                	ld	s2,16(sp)
    8000510e:	6145                	addi	sp,sp,48
    80005110:	8082                	ret
    return -1;
    80005112:	557d                	li	a0,-1
    80005114:	bfcd                	j	80005106 <argfd+0x50>
    return -1;
    80005116:	557d                	li	a0,-1
    80005118:	b7fd                	j	80005106 <argfd+0x50>
    8000511a:	557d                	li	a0,-1
    8000511c:	b7ed                	j	80005106 <argfd+0x50>

000000008000511e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000511e:	1101                	addi	sp,sp,-32
    80005120:	ec06                	sd	ra,24(sp)
    80005122:	e822                	sd	s0,16(sp)
    80005124:	e426                	sd	s1,8(sp)
    80005126:	1000                	addi	s0,sp,32
    80005128:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	8fe080e7          	jalr	-1794(ra) # 80001a28 <myproc>
    80005132:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005134:	0d050793          	addi	a5,a0,208
    80005138:	4501                	li	a0,0
    8000513a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000513c:	6398                	ld	a4,0(a5)
    8000513e:	cb19                	beqz	a4,80005154 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005140:	2505                	addiw	a0,a0,1
    80005142:	07a1                	addi	a5,a5,8
    80005144:	fed51ce3          	bne	a0,a3,8000513c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005148:	557d                	li	a0,-1
}
    8000514a:	60e2                	ld	ra,24(sp)
    8000514c:	6442                	ld	s0,16(sp)
    8000514e:	64a2                	ld	s1,8(sp)
    80005150:	6105                	addi	sp,sp,32
    80005152:	8082                	ret
      p->ofile[fd] = f;
    80005154:	01a50793          	addi	a5,a0,26
    80005158:	078e                	slli	a5,a5,0x3
    8000515a:	963e                	add	a2,a2,a5
    8000515c:	e204                	sd	s1,0(a2)
      return fd;
    8000515e:	b7f5                	j	8000514a <fdalloc+0x2c>

0000000080005160 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005160:	715d                	addi	sp,sp,-80
    80005162:	e486                	sd	ra,72(sp)
    80005164:	e0a2                	sd	s0,64(sp)
    80005166:	fc26                	sd	s1,56(sp)
    80005168:	f84a                	sd	s2,48(sp)
    8000516a:	f44e                	sd	s3,40(sp)
    8000516c:	f052                	sd	s4,32(sp)
    8000516e:	ec56                	sd	s5,24(sp)
    80005170:	0880                	addi	s0,sp,80
    80005172:	89ae                	mv	s3,a1
    80005174:	8ab2                	mv	s5,a2
    80005176:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005178:	fb040593          	addi	a1,s0,-80
    8000517c:	fffff097          	auipc	ra,0xfffff
    80005180:	e48080e7          	jalr	-440(ra) # 80003fc4 <nameiparent>
    80005184:	892a                	mv	s2,a0
    80005186:	12050e63          	beqz	a0,800052c2 <create+0x162>
    return 0;

  ilock(dp);
    8000518a:	ffffe097          	auipc	ra,0xffffe
    8000518e:	666080e7          	jalr	1638(ra) # 800037f0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005192:	4601                	li	a2,0
    80005194:	fb040593          	addi	a1,s0,-80
    80005198:	854a                	mv	a0,s2
    8000519a:	fffff097          	auipc	ra,0xfffff
    8000519e:	b34080e7          	jalr	-1228(ra) # 80003cce <dirlookup>
    800051a2:	84aa                	mv	s1,a0
    800051a4:	c921                	beqz	a0,800051f4 <create+0x94>
    iunlockput(dp);
    800051a6:	854a                	mv	a0,s2
    800051a8:	fffff097          	auipc	ra,0xfffff
    800051ac:	8aa080e7          	jalr	-1878(ra) # 80003a52 <iunlockput>
    ilock(ip);
    800051b0:	8526                	mv	a0,s1
    800051b2:	ffffe097          	auipc	ra,0xffffe
    800051b6:	63e080e7          	jalr	1598(ra) # 800037f0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051ba:	2981                	sext.w	s3,s3
    800051bc:	4789                	li	a5,2
    800051be:	02f99463          	bne	s3,a5,800051e6 <create+0x86>
    800051c2:	0444d783          	lhu	a5,68(s1)
    800051c6:	37f9                	addiw	a5,a5,-2
    800051c8:	17c2                	slli	a5,a5,0x30
    800051ca:	93c1                	srli	a5,a5,0x30
    800051cc:	4705                	li	a4,1
    800051ce:	00f76c63          	bltu	a4,a5,800051e6 <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    800051d2:	8526                	mv	a0,s1
    800051d4:	60a6                	ld	ra,72(sp)
    800051d6:	6406                	ld	s0,64(sp)
    800051d8:	74e2                	ld	s1,56(sp)
    800051da:	7942                	ld	s2,48(sp)
    800051dc:	79a2                	ld	s3,40(sp)
    800051de:	7a02                	ld	s4,32(sp)
    800051e0:	6ae2                	ld	s5,24(sp)
    800051e2:	6161                	addi	sp,sp,80
    800051e4:	8082                	ret
    iunlockput(ip);
    800051e6:	8526                	mv	a0,s1
    800051e8:	fffff097          	auipc	ra,0xfffff
    800051ec:	86a080e7          	jalr	-1942(ra) # 80003a52 <iunlockput>
    return 0;
    800051f0:	4481                	li	s1,0
    800051f2:	b7c5                	j	800051d2 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    800051f4:	85ce                	mv	a1,s3
    800051f6:	00092503          	lw	a0,0(s2)
    800051fa:	ffffe097          	auipc	ra,0xffffe
    800051fe:	45c080e7          	jalr	1116(ra) # 80003656 <ialloc>
    80005202:	84aa                	mv	s1,a0
    80005204:	c521                	beqz	a0,8000524c <create+0xec>
  ilock(ip);
    80005206:	ffffe097          	auipc	ra,0xffffe
    8000520a:	5ea080e7          	jalr	1514(ra) # 800037f0 <ilock>
  ip->major = major;
    8000520e:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80005212:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    80005216:	4a05                	li	s4,1
    80005218:	05449523          	sh	s4,74(s1)
  iupdate(ip);
    8000521c:	8526                	mv	a0,s1
    8000521e:	ffffe097          	auipc	ra,0xffffe
    80005222:	506080e7          	jalr	1286(ra) # 80003724 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005226:	2981                	sext.w	s3,s3
    80005228:	03498a63          	beq	s3,s4,8000525c <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000522c:	40d0                	lw	a2,4(s1)
    8000522e:	fb040593          	addi	a1,s0,-80
    80005232:	854a                	mv	a0,s2
    80005234:	fffff097          	auipc	ra,0xfffff
    80005238:	cb0080e7          	jalr	-848(ra) # 80003ee4 <dirlink>
    8000523c:	06054b63          	bltz	a0,800052b2 <create+0x152>
  iunlockput(dp);
    80005240:	854a                	mv	a0,s2
    80005242:	fffff097          	auipc	ra,0xfffff
    80005246:	810080e7          	jalr	-2032(ra) # 80003a52 <iunlockput>
  return ip;
    8000524a:	b761                	j	800051d2 <create+0x72>
    panic("create: ialloc");
    8000524c:	00003517          	auipc	a0,0x3
    80005250:	4a450513          	addi	a0,a0,1188 # 800086f0 <syscalls+0x2c0>
    80005254:	ffffb097          	auipc	ra,0xffffb
    80005258:	2f2080e7          	jalr	754(ra) # 80000546 <panic>
    dp->nlink++;  // for ".."
    8000525c:	04a95783          	lhu	a5,74(s2)
    80005260:	2785                	addiw	a5,a5,1
    80005262:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    80005266:	854a                	mv	a0,s2
    80005268:	ffffe097          	auipc	ra,0xffffe
    8000526c:	4bc080e7          	jalr	1212(ra) # 80003724 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005270:	40d0                	lw	a2,4(s1)
    80005272:	00003597          	auipc	a1,0x3
    80005276:	48e58593          	addi	a1,a1,1166 # 80008700 <syscalls+0x2d0>
    8000527a:	8526                	mv	a0,s1
    8000527c:	fffff097          	auipc	ra,0xfffff
    80005280:	c68080e7          	jalr	-920(ra) # 80003ee4 <dirlink>
    80005284:	00054f63          	bltz	a0,800052a2 <create+0x142>
    80005288:	00492603          	lw	a2,4(s2)
    8000528c:	00003597          	auipc	a1,0x3
    80005290:	47c58593          	addi	a1,a1,1148 # 80008708 <syscalls+0x2d8>
    80005294:	8526                	mv	a0,s1
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	c4e080e7          	jalr	-946(ra) # 80003ee4 <dirlink>
    8000529e:	f80557e3          	bgez	a0,8000522c <create+0xcc>
      panic("create dots");
    800052a2:	00003517          	auipc	a0,0x3
    800052a6:	46e50513          	addi	a0,a0,1134 # 80008710 <syscalls+0x2e0>
    800052aa:	ffffb097          	auipc	ra,0xffffb
    800052ae:	29c080e7          	jalr	668(ra) # 80000546 <panic>
    panic("create: dirlink");
    800052b2:	00003517          	auipc	a0,0x3
    800052b6:	46e50513          	addi	a0,a0,1134 # 80008720 <syscalls+0x2f0>
    800052ba:	ffffb097          	auipc	ra,0xffffb
    800052be:	28c080e7          	jalr	652(ra) # 80000546 <panic>
    return 0;
    800052c2:	84aa                	mv	s1,a0
    800052c4:	b739                	j	800051d2 <create+0x72>

00000000800052c6 <sys_dup>:
{
    800052c6:	7179                	addi	sp,sp,-48
    800052c8:	f406                	sd	ra,40(sp)
    800052ca:	f022                	sd	s0,32(sp)
    800052cc:	ec26                	sd	s1,24(sp)
    800052ce:	e84a                	sd	s2,16(sp)
    800052d0:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800052d2:	fd840613          	addi	a2,s0,-40
    800052d6:	4581                	li	a1,0
    800052d8:	4501                	li	a0,0
    800052da:	00000097          	auipc	ra,0x0
    800052de:	ddc080e7          	jalr	-548(ra) # 800050b6 <argfd>
    return -1;
    800052e2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800052e4:	02054363          	bltz	a0,8000530a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800052e8:	fd843903          	ld	s2,-40(s0)
    800052ec:	854a                	mv	a0,s2
    800052ee:	00000097          	auipc	ra,0x0
    800052f2:	e30080e7          	jalr	-464(ra) # 8000511e <fdalloc>
    800052f6:	84aa                	mv	s1,a0
    return -1;
    800052f8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052fa:	00054863          	bltz	a0,8000530a <sys_dup+0x44>
  filedup(f);
    800052fe:	854a                	mv	a0,s2
    80005300:	fffff097          	auipc	ra,0xfffff
    80005304:	332080e7          	jalr	818(ra) # 80004632 <filedup>
  return fd;
    80005308:	87a6                	mv	a5,s1
}
    8000530a:	853e                	mv	a0,a5
    8000530c:	70a2                	ld	ra,40(sp)
    8000530e:	7402                	ld	s0,32(sp)
    80005310:	64e2                	ld	s1,24(sp)
    80005312:	6942                	ld	s2,16(sp)
    80005314:	6145                	addi	sp,sp,48
    80005316:	8082                	ret

0000000080005318 <sys_read>:
{
    80005318:	7179                	addi	sp,sp,-48
    8000531a:	f406                	sd	ra,40(sp)
    8000531c:	f022                	sd	s0,32(sp)
    8000531e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005320:	fe840613          	addi	a2,s0,-24
    80005324:	4581                	li	a1,0
    80005326:	4501                	li	a0,0
    80005328:	00000097          	auipc	ra,0x0
    8000532c:	d8e080e7          	jalr	-626(ra) # 800050b6 <argfd>
    return -1;
    80005330:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005332:	04054163          	bltz	a0,80005374 <sys_read+0x5c>
    80005336:	fe440593          	addi	a1,s0,-28
    8000533a:	4509                	li	a0,2
    8000533c:	ffffe097          	auipc	ra,0xffffe
    80005340:	8d6080e7          	jalr	-1834(ra) # 80002c12 <argint>
    return -1;
    80005344:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005346:	02054763          	bltz	a0,80005374 <sys_read+0x5c>
    8000534a:	fd840593          	addi	a1,s0,-40
    8000534e:	4505                	li	a0,1
    80005350:	ffffe097          	auipc	ra,0xffffe
    80005354:	8e4080e7          	jalr	-1820(ra) # 80002c34 <argaddr>
    return -1;
    80005358:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000535a:	00054d63          	bltz	a0,80005374 <sys_read+0x5c>
  return fileread(f, p, n);
    8000535e:	fe442603          	lw	a2,-28(s0)
    80005362:	fd843583          	ld	a1,-40(s0)
    80005366:	fe843503          	ld	a0,-24(s0)
    8000536a:	fffff097          	auipc	ra,0xfffff
    8000536e:	454080e7          	jalr	1108(ra) # 800047be <fileread>
    80005372:	87aa                	mv	a5,a0
}
    80005374:	853e                	mv	a0,a5
    80005376:	70a2                	ld	ra,40(sp)
    80005378:	7402                	ld	s0,32(sp)
    8000537a:	6145                	addi	sp,sp,48
    8000537c:	8082                	ret

000000008000537e <sys_write>:
{
    8000537e:	7179                	addi	sp,sp,-48
    80005380:	f406                	sd	ra,40(sp)
    80005382:	f022                	sd	s0,32(sp)
    80005384:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005386:	fe840613          	addi	a2,s0,-24
    8000538a:	4581                	li	a1,0
    8000538c:	4501                	li	a0,0
    8000538e:	00000097          	auipc	ra,0x0
    80005392:	d28080e7          	jalr	-728(ra) # 800050b6 <argfd>
    return -1;
    80005396:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80005398:	04054163          	bltz	a0,800053da <sys_write+0x5c>
    8000539c:	fe440593          	addi	a1,s0,-28
    800053a0:	4509                	li	a0,2
    800053a2:	ffffe097          	auipc	ra,0xffffe
    800053a6:	870080e7          	jalr	-1936(ra) # 80002c12 <argint>
    return -1;
    800053aa:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053ac:	02054763          	bltz	a0,800053da <sys_write+0x5c>
    800053b0:	fd840593          	addi	a1,s0,-40
    800053b4:	4505                	li	a0,1
    800053b6:	ffffe097          	auipc	ra,0xffffe
    800053ba:	87e080e7          	jalr	-1922(ra) # 80002c34 <argaddr>
    return -1;
    800053be:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800053c0:	00054d63          	bltz	a0,800053da <sys_write+0x5c>
  return filewrite(f, p, n);
    800053c4:	fe442603          	lw	a2,-28(s0)
    800053c8:	fd843583          	ld	a1,-40(s0)
    800053cc:	fe843503          	ld	a0,-24(s0)
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	4b0080e7          	jalr	1200(ra) # 80004880 <filewrite>
    800053d8:	87aa                	mv	a5,a0
}
    800053da:	853e                	mv	a0,a5
    800053dc:	70a2                	ld	ra,40(sp)
    800053de:	7402                	ld	s0,32(sp)
    800053e0:	6145                	addi	sp,sp,48
    800053e2:	8082                	ret

00000000800053e4 <sys_close>:
{
    800053e4:	1101                	addi	sp,sp,-32
    800053e6:	ec06                	sd	ra,24(sp)
    800053e8:	e822                	sd	s0,16(sp)
    800053ea:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800053ec:	fe040613          	addi	a2,s0,-32
    800053f0:	fec40593          	addi	a1,s0,-20
    800053f4:	4501                	li	a0,0
    800053f6:	00000097          	auipc	ra,0x0
    800053fa:	cc0080e7          	jalr	-832(ra) # 800050b6 <argfd>
    return -1;
    800053fe:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005400:	02054463          	bltz	a0,80005428 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005404:	ffffc097          	auipc	ra,0xffffc
    80005408:	624080e7          	jalr	1572(ra) # 80001a28 <myproc>
    8000540c:	fec42783          	lw	a5,-20(s0)
    80005410:	07e9                	addi	a5,a5,26
    80005412:	078e                	slli	a5,a5,0x3
    80005414:	953e                	add	a0,a0,a5
    80005416:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000541a:	fe043503          	ld	a0,-32(s0)
    8000541e:	fffff097          	auipc	ra,0xfffff
    80005422:	266080e7          	jalr	614(ra) # 80004684 <fileclose>
  return 0;
    80005426:	4781                	li	a5,0
}
    80005428:	853e                	mv	a0,a5
    8000542a:	60e2                	ld	ra,24(sp)
    8000542c:	6442                	ld	s0,16(sp)
    8000542e:	6105                	addi	sp,sp,32
    80005430:	8082                	ret

0000000080005432 <sys_fstat>:
{
    80005432:	1101                	addi	sp,sp,-32
    80005434:	ec06                	sd	ra,24(sp)
    80005436:	e822                	sd	s0,16(sp)
    80005438:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000543a:	fe840613          	addi	a2,s0,-24
    8000543e:	4581                	li	a1,0
    80005440:	4501                	li	a0,0
    80005442:	00000097          	auipc	ra,0x0
    80005446:	c74080e7          	jalr	-908(ra) # 800050b6 <argfd>
    return -1;
    8000544a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000544c:	02054563          	bltz	a0,80005476 <sys_fstat+0x44>
    80005450:	fe040593          	addi	a1,s0,-32
    80005454:	4505                	li	a0,1
    80005456:	ffffd097          	auipc	ra,0xffffd
    8000545a:	7de080e7          	jalr	2014(ra) # 80002c34 <argaddr>
    return -1;
    8000545e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    80005460:	00054b63          	bltz	a0,80005476 <sys_fstat+0x44>
  return filestat(f, st);
    80005464:	fe043583          	ld	a1,-32(s0)
    80005468:	fe843503          	ld	a0,-24(s0)
    8000546c:	fffff097          	auipc	ra,0xfffff
    80005470:	2e0080e7          	jalr	736(ra) # 8000474c <filestat>
    80005474:	87aa                	mv	a5,a0
}
    80005476:	853e                	mv	a0,a5
    80005478:	60e2                	ld	ra,24(sp)
    8000547a:	6442                	ld	s0,16(sp)
    8000547c:	6105                	addi	sp,sp,32
    8000547e:	8082                	ret

0000000080005480 <sys_link>:
{
    80005480:	7169                	addi	sp,sp,-304
    80005482:	f606                	sd	ra,296(sp)
    80005484:	f222                	sd	s0,288(sp)
    80005486:	ee26                	sd	s1,280(sp)
    80005488:	ea4a                	sd	s2,272(sp)
    8000548a:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000548c:	08000613          	li	a2,128
    80005490:	ed040593          	addi	a1,s0,-304
    80005494:	4501                	li	a0,0
    80005496:	ffffd097          	auipc	ra,0xffffd
    8000549a:	7c0080e7          	jalr	1984(ra) # 80002c56 <argstr>
    return -1;
    8000549e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054a0:	10054e63          	bltz	a0,800055bc <sys_link+0x13c>
    800054a4:	08000613          	li	a2,128
    800054a8:	f5040593          	addi	a1,s0,-176
    800054ac:	4505                	li	a0,1
    800054ae:	ffffd097          	auipc	ra,0xffffd
    800054b2:	7a8080e7          	jalr	1960(ra) # 80002c56 <argstr>
    return -1;
    800054b6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054b8:	10054263          	bltz	a0,800055bc <sys_link+0x13c>
  begin_op();
    800054bc:	fffff097          	auipc	ra,0xfffff
    800054c0:	cfa080e7          	jalr	-774(ra) # 800041b6 <begin_op>
  if((ip = namei(old)) == 0){
    800054c4:	ed040513          	addi	a0,s0,-304
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	ade080e7          	jalr	-1314(ra) # 80003fa6 <namei>
    800054d0:	84aa                	mv	s1,a0
    800054d2:	c551                	beqz	a0,8000555e <sys_link+0xde>
  ilock(ip);
    800054d4:	ffffe097          	auipc	ra,0xffffe
    800054d8:	31c080e7          	jalr	796(ra) # 800037f0 <ilock>
  if(ip->type == T_DIR){
    800054dc:	04449703          	lh	a4,68(s1)
    800054e0:	4785                	li	a5,1
    800054e2:	08f70463          	beq	a4,a5,8000556a <sys_link+0xea>
  ip->nlink++;
    800054e6:	04a4d783          	lhu	a5,74(s1)
    800054ea:	2785                	addiw	a5,a5,1
    800054ec:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054f0:	8526                	mv	a0,s1
    800054f2:	ffffe097          	auipc	ra,0xffffe
    800054f6:	232080e7          	jalr	562(ra) # 80003724 <iupdate>
  iunlock(ip);
    800054fa:	8526                	mv	a0,s1
    800054fc:	ffffe097          	auipc	ra,0xffffe
    80005500:	3b6080e7          	jalr	950(ra) # 800038b2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005504:	fd040593          	addi	a1,s0,-48
    80005508:	f5040513          	addi	a0,s0,-176
    8000550c:	fffff097          	auipc	ra,0xfffff
    80005510:	ab8080e7          	jalr	-1352(ra) # 80003fc4 <nameiparent>
    80005514:	892a                	mv	s2,a0
    80005516:	c935                	beqz	a0,8000558a <sys_link+0x10a>
  ilock(dp);
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	2d8080e7          	jalr	728(ra) # 800037f0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005520:	00092703          	lw	a4,0(s2)
    80005524:	409c                	lw	a5,0(s1)
    80005526:	04f71d63          	bne	a4,a5,80005580 <sys_link+0x100>
    8000552a:	40d0                	lw	a2,4(s1)
    8000552c:	fd040593          	addi	a1,s0,-48
    80005530:	854a                	mv	a0,s2
    80005532:	fffff097          	auipc	ra,0xfffff
    80005536:	9b2080e7          	jalr	-1614(ra) # 80003ee4 <dirlink>
    8000553a:	04054363          	bltz	a0,80005580 <sys_link+0x100>
  iunlockput(dp);
    8000553e:	854a                	mv	a0,s2
    80005540:	ffffe097          	auipc	ra,0xffffe
    80005544:	512080e7          	jalr	1298(ra) # 80003a52 <iunlockput>
  iput(ip);
    80005548:	8526                	mv	a0,s1
    8000554a:	ffffe097          	auipc	ra,0xffffe
    8000554e:	460080e7          	jalr	1120(ra) # 800039aa <iput>
  end_op();
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	ce2080e7          	jalr	-798(ra) # 80004234 <end_op>
  return 0;
    8000555a:	4781                	li	a5,0
    8000555c:	a085                	j	800055bc <sys_link+0x13c>
    end_op();
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	cd6080e7          	jalr	-810(ra) # 80004234 <end_op>
    return -1;
    80005566:	57fd                	li	a5,-1
    80005568:	a891                	j	800055bc <sys_link+0x13c>
    iunlockput(ip);
    8000556a:	8526                	mv	a0,s1
    8000556c:	ffffe097          	auipc	ra,0xffffe
    80005570:	4e6080e7          	jalr	1254(ra) # 80003a52 <iunlockput>
    end_op();
    80005574:	fffff097          	auipc	ra,0xfffff
    80005578:	cc0080e7          	jalr	-832(ra) # 80004234 <end_op>
    return -1;
    8000557c:	57fd                	li	a5,-1
    8000557e:	a83d                	j	800055bc <sys_link+0x13c>
    iunlockput(dp);
    80005580:	854a                	mv	a0,s2
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	4d0080e7          	jalr	1232(ra) # 80003a52 <iunlockput>
  ilock(ip);
    8000558a:	8526                	mv	a0,s1
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	264080e7          	jalr	612(ra) # 800037f0 <ilock>
  ip->nlink--;
    80005594:	04a4d783          	lhu	a5,74(s1)
    80005598:	37fd                	addiw	a5,a5,-1
    8000559a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000559e:	8526                	mv	a0,s1
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	184080e7          	jalr	388(ra) # 80003724 <iupdate>
  iunlockput(ip);
    800055a8:	8526                	mv	a0,s1
    800055aa:	ffffe097          	auipc	ra,0xffffe
    800055ae:	4a8080e7          	jalr	1192(ra) # 80003a52 <iunlockput>
  end_op();
    800055b2:	fffff097          	auipc	ra,0xfffff
    800055b6:	c82080e7          	jalr	-894(ra) # 80004234 <end_op>
  return -1;
    800055ba:	57fd                	li	a5,-1
}
    800055bc:	853e                	mv	a0,a5
    800055be:	70b2                	ld	ra,296(sp)
    800055c0:	7412                	ld	s0,288(sp)
    800055c2:	64f2                	ld	s1,280(sp)
    800055c4:	6952                	ld	s2,272(sp)
    800055c6:	6155                	addi	sp,sp,304
    800055c8:	8082                	ret

00000000800055ca <sys_unlink>:
{
    800055ca:	7151                	addi	sp,sp,-240
    800055cc:	f586                	sd	ra,232(sp)
    800055ce:	f1a2                	sd	s0,224(sp)
    800055d0:	eda6                	sd	s1,216(sp)
    800055d2:	e9ca                	sd	s2,208(sp)
    800055d4:	e5ce                	sd	s3,200(sp)
    800055d6:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055d8:	08000613          	li	a2,128
    800055dc:	f3040593          	addi	a1,s0,-208
    800055e0:	4501                	li	a0,0
    800055e2:	ffffd097          	auipc	ra,0xffffd
    800055e6:	674080e7          	jalr	1652(ra) # 80002c56 <argstr>
    800055ea:	18054163          	bltz	a0,8000576c <sys_unlink+0x1a2>
  begin_op();
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	bc8080e7          	jalr	-1080(ra) # 800041b6 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800055f6:	fb040593          	addi	a1,s0,-80
    800055fa:	f3040513          	addi	a0,s0,-208
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	9c6080e7          	jalr	-1594(ra) # 80003fc4 <nameiparent>
    80005606:	84aa                	mv	s1,a0
    80005608:	c979                	beqz	a0,800056de <sys_unlink+0x114>
  ilock(dp);
    8000560a:	ffffe097          	auipc	ra,0xffffe
    8000560e:	1e6080e7          	jalr	486(ra) # 800037f0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005612:	00003597          	auipc	a1,0x3
    80005616:	0ee58593          	addi	a1,a1,238 # 80008700 <syscalls+0x2d0>
    8000561a:	fb040513          	addi	a0,s0,-80
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	696080e7          	jalr	1686(ra) # 80003cb4 <namecmp>
    80005626:	14050a63          	beqz	a0,8000577a <sys_unlink+0x1b0>
    8000562a:	00003597          	auipc	a1,0x3
    8000562e:	0de58593          	addi	a1,a1,222 # 80008708 <syscalls+0x2d8>
    80005632:	fb040513          	addi	a0,s0,-80
    80005636:	ffffe097          	auipc	ra,0xffffe
    8000563a:	67e080e7          	jalr	1662(ra) # 80003cb4 <namecmp>
    8000563e:	12050e63          	beqz	a0,8000577a <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005642:	f2c40613          	addi	a2,s0,-212
    80005646:	fb040593          	addi	a1,s0,-80
    8000564a:	8526                	mv	a0,s1
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	682080e7          	jalr	1666(ra) # 80003cce <dirlookup>
    80005654:	892a                	mv	s2,a0
    80005656:	12050263          	beqz	a0,8000577a <sys_unlink+0x1b0>
  ilock(ip);
    8000565a:	ffffe097          	auipc	ra,0xffffe
    8000565e:	196080e7          	jalr	406(ra) # 800037f0 <ilock>
  if(ip->nlink < 1)
    80005662:	04a91783          	lh	a5,74(s2)
    80005666:	08f05263          	blez	a5,800056ea <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000566a:	04491703          	lh	a4,68(s2)
    8000566e:	4785                	li	a5,1
    80005670:	08f70563          	beq	a4,a5,800056fa <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005674:	4641                	li	a2,16
    80005676:	4581                	li	a1,0
    80005678:	fc040513          	addi	a0,s0,-64
    8000567c:	ffffb097          	auipc	ra,0xffffb
    80005680:	6dc080e7          	jalr	1756(ra) # 80000d58 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005684:	4741                	li	a4,16
    80005686:	f2c42683          	lw	a3,-212(s0)
    8000568a:	fc040613          	addi	a2,s0,-64
    8000568e:	4581                	li	a1,0
    80005690:	8526                	mv	a0,s1
    80005692:	ffffe097          	auipc	ra,0xffffe
    80005696:	508080e7          	jalr	1288(ra) # 80003b9a <writei>
    8000569a:	47c1                	li	a5,16
    8000569c:	0af51563          	bne	a0,a5,80005746 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056a0:	04491703          	lh	a4,68(s2)
    800056a4:	4785                	li	a5,1
    800056a6:	0af70863          	beq	a4,a5,80005756 <sys_unlink+0x18c>
  iunlockput(dp);
    800056aa:	8526                	mv	a0,s1
    800056ac:	ffffe097          	auipc	ra,0xffffe
    800056b0:	3a6080e7          	jalr	934(ra) # 80003a52 <iunlockput>
  ip->nlink--;
    800056b4:	04a95783          	lhu	a5,74(s2)
    800056b8:	37fd                	addiw	a5,a5,-1
    800056ba:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056be:	854a                	mv	a0,s2
    800056c0:	ffffe097          	auipc	ra,0xffffe
    800056c4:	064080e7          	jalr	100(ra) # 80003724 <iupdate>
  iunlockput(ip);
    800056c8:	854a                	mv	a0,s2
    800056ca:	ffffe097          	auipc	ra,0xffffe
    800056ce:	388080e7          	jalr	904(ra) # 80003a52 <iunlockput>
  end_op();
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	b62080e7          	jalr	-1182(ra) # 80004234 <end_op>
  return 0;
    800056da:	4501                	li	a0,0
    800056dc:	a84d                	j	8000578e <sys_unlink+0x1c4>
    end_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	b56080e7          	jalr	-1194(ra) # 80004234 <end_op>
    return -1;
    800056e6:	557d                	li	a0,-1
    800056e8:	a05d                	j	8000578e <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056ea:	00003517          	auipc	a0,0x3
    800056ee:	04650513          	addi	a0,a0,70 # 80008730 <syscalls+0x300>
    800056f2:	ffffb097          	auipc	ra,0xffffb
    800056f6:	e54080e7          	jalr	-428(ra) # 80000546 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056fa:	04c92703          	lw	a4,76(s2)
    800056fe:	02000793          	li	a5,32
    80005702:	f6e7f9e3          	bgeu	a5,a4,80005674 <sys_unlink+0xaa>
    80005706:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000570a:	4741                	li	a4,16
    8000570c:	86ce                	mv	a3,s3
    8000570e:	f1840613          	addi	a2,s0,-232
    80005712:	4581                	li	a1,0
    80005714:	854a                	mv	a0,s2
    80005716:	ffffe097          	auipc	ra,0xffffe
    8000571a:	38e080e7          	jalr	910(ra) # 80003aa4 <readi>
    8000571e:	47c1                	li	a5,16
    80005720:	00f51b63          	bne	a0,a5,80005736 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005724:	f1845783          	lhu	a5,-232(s0)
    80005728:	e7a1                	bnez	a5,80005770 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000572a:	29c1                	addiw	s3,s3,16
    8000572c:	04c92783          	lw	a5,76(s2)
    80005730:	fcf9ede3          	bltu	s3,a5,8000570a <sys_unlink+0x140>
    80005734:	b781                	j	80005674 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005736:	00003517          	auipc	a0,0x3
    8000573a:	01250513          	addi	a0,a0,18 # 80008748 <syscalls+0x318>
    8000573e:	ffffb097          	auipc	ra,0xffffb
    80005742:	e08080e7          	jalr	-504(ra) # 80000546 <panic>
    panic("unlink: writei");
    80005746:	00003517          	auipc	a0,0x3
    8000574a:	01a50513          	addi	a0,a0,26 # 80008760 <syscalls+0x330>
    8000574e:	ffffb097          	auipc	ra,0xffffb
    80005752:	df8080e7          	jalr	-520(ra) # 80000546 <panic>
    dp->nlink--;
    80005756:	04a4d783          	lhu	a5,74(s1)
    8000575a:	37fd                	addiw	a5,a5,-1
    8000575c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005760:	8526                	mv	a0,s1
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	fc2080e7          	jalr	-62(ra) # 80003724 <iupdate>
    8000576a:	b781                	j	800056aa <sys_unlink+0xe0>
    return -1;
    8000576c:	557d                	li	a0,-1
    8000576e:	a005                	j	8000578e <sys_unlink+0x1c4>
    iunlockput(ip);
    80005770:	854a                	mv	a0,s2
    80005772:	ffffe097          	auipc	ra,0xffffe
    80005776:	2e0080e7          	jalr	736(ra) # 80003a52 <iunlockput>
  iunlockput(dp);
    8000577a:	8526                	mv	a0,s1
    8000577c:	ffffe097          	auipc	ra,0xffffe
    80005780:	2d6080e7          	jalr	726(ra) # 80003a52 <iunlockput>
  end_op();
    80005784:	fffff097          	auipc	ra,0xfffff
    80005788:	ab0080e7          	jalr	-1360(ra) # 80004234 <end_op>
  return -1;
    8000578c:	557d                	li	a0,-1
}
    8000578e:	70ae                	ld	ra,232(sp)
    80005790:	740e                	ld	s0,224(sp)
    80005792:	64ee                	ld	s1,216(sp)
    80005794:	694e                	ld	s2,208(sp)
    80005796:	69ae                	ld	s3,200(sp)
    80005798:	616d                	addi	sp,sp,240
    8000579a:	8082                	ret

000000008000579c <sys_open>:

uint64
sys_open(void)
{
    8000579c:	7131                	addi	sp,sp,-192
    8000579e:	fd06                	sd	ra,184(sp)
    800057a0:	f922                	sd	s0,176(sp)
    800057a2:	f526                	sd	s1,168(sp)
    800057a4:	f14a                	sd	s2,160(sp)
    800057a6:	ed4e                	sd	s3,152(sp)
    800057a8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057aa:	08000613          	li	a2,128
    800057ae:	f5040593          	addi	a1,s0,-176
    800057b2:	4501                	li	a0,0
    800057b4:	ffffd097          	auipc	ra,0xffffd
    800057b8:	4a2080e7          	jalr	1186(ra) # 80002c56 <argstr>
    return -1;
    800057bc:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    800057be:	0c054163          	bltz	a0,80005880 <sys_open+0xe4>
    800057c2:	f4c40593          	addi	a1,s0,-180
    800057c6:	4505                	li	a0,1
    800057c8:	ffffd097          	auipc	ra,0xffffd
    800057cc:	44a080e7          	jalr	1098(ra) # 80002c12 <argint>
    800057d0:	0a054863          	bltz	a0,80005880 <sys_open+0xe4>

  begin_op();
    800057d4:	fffff097          	auipc	ra,0xfffff
    800057d8:	9e2080e7          	jalr	-1566(ra) # 800041b6 <begin_op>

  if(omode & O_CREATE){
    800057dc:	f4c42783          	lw	a5,-180(s0)
    800057e0:	2007f793          	andi	a5,a5,512
    800057e4:	cbdd                	beqz	a5,8000589a <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    800057e6:	4681                	li	a3,0
    800057e8:	4601                	li	a2,0
    800057ea:	4589                	li	a1,2
    800057ec:	f5040513          	addi	a0,s0,-176
    800057f0:	00000097          	auipc	ra,0x0
    800057f4:	970080e7          	jalr	-1680(ra) # 80005160 <create>
    800057f8:	892a                	mv	s2,a0
    if(ip == 0){
    800057fa:	c959                	beqz	a0,80005890 <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800057fc:	04491703          	lh	a4,68(s2)
    80005800:	478d                	li	a5,3
    80005802:	00f71763          	bne	a4,a5,80005810 <sys_open+0x74>
    80005806:	04695703          	lhu	a4,70(s2)
    8000580a:	47a5                	li	a5,9
    8000580c:	0ce7ec63          	bltu	a5,a4,800058e4 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005810:	fffff097          	auipc	ra,0xfffff
    80005814:	db8080e7          	jalr	-584(ra) # 800045c8 <filealloc>
    80005818:	89aa                	mv	s3,a0
    8000581a:	10050263          	beqz	a0,8000591e <sys_open+0x182>
    8000581e:	00000097          	auipc	ra,0x0
    80005822:	900080e7          	jalr	-1792(ra) # 8000511e <fdalloc>
    80005826:	84aa                	mv	s1,a0
    80005828:	0e054663          	bltz	a0,80005914 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000582c:	04491703          	lh	a4,68(s2)
    80005830:	478d                	li	a5,3
    80005832:	0cf70463          	beq	a4,a5,800058fa <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005836:	4789                	li	a5,2
    80005838:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    8000583c:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005840:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005844:	f4c42783          	lw	a5,-180(s0)
    80005848:	0017c713          	xori	a4,a5,1
    8000584c:	8b05                	andi	a4,a4,1
    8000584e:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005852:	0037f713          	andi	a4,a5,3
    80005856:	00e03733          	snez	a4,a4
    8000585a:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000585e:	4007f793          	andi	a5,a5,1024
    80005862:	c791                	beqz	a5,8000586e <sys_open+0xd2>
    80005864:	04491703          	lh	a4,68(s2)
    80005868:	4789                	li	a5,2
    8000586a:	08f70f63          	beq	a4,a5,80005908 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    8000586e:	854a                	mv	a0,s2
    80005870:	ffffe097          	auipc	ra,0xffffe
    80005874:	042080e7          	jalr	66(ra) # 800038b2 <iunlock>
  end_op();
    80005878:	fffff097          	auipc	ra,0xfffff
    8000587c:	9bc080e7          	jalr	-1604(ra) # 80004234 <end_op>

  return fd;
}
    80005880:	8526                	mv	a0,s1
    80005882:	70ea                	ld	ra,184(sp)
    80005884:	744a                	ld	s0,176(sp)
    80005886:	74aa                	ld	s1,168(sp)
    80005888:	790a                	ld	s2,160(sp)
    8000588a:	69ea                	ld	s3,152(sp)
    8000588c:	6129                	addi	sp,sp,192
    8000588e:	8082                	ret
      end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	9a4080e7          	jalr	-1628(ra) # 80004234 <end_op>
      return -1;
    80005898:	b7e5                	j	80005880 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    8000589a:	f5040513          	addi	a0,s0,-176
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	708080e7          	jalr	1800(ra) # 80003fa6 <namei>
    800058a6:	892a                	mv	s2,a0
    800058a8:	c905                	beqz	a0,800058d8 <sys_open+0x13c>
    ilock(ip);
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	f46080e7          	jalr	-186(ra) # 800037f0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058b2:	04491703          	lh	a4,68(s2)
    800058b6:	4785                	li	a5,1
    800058b8:	f4f712e3          	bne	a4,a5,800057fc <sys_open+0x60>
    800058bc:	f4c42783          	lw	a5,-180(s0)
    800058c0:	dba1                	beqz	a5,80005810 <sys_open+0x74>
      iunlockput(ip);
    800058c2:	854a                	mv	a0,s2
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	18e080e7          	jalr	398(ra) # 80003a52 <iunlockput>
      end_op();
    800058cc:	fffff097          	auipc	ra,0xfffff
    800058d0:	968080e7          	jalr	-1688(ra) # 80004234 <end_op>
      return -1;
    800058d4:	54fd                	li	s1,-1
    800058d6:	b76d                	j	80005880 <sys_open+0xe4>
      end_op();
    800058d8:	fffff097          	auipc	ra,0xfffff
    800058dc:	95c080e7          	jalr	-1700(ra) # 80004234 <end_op>
      return -1;
    800058e0:	54fd                	li	s1,-1
    800058e2:	bf79                	j	80005880 <sys_open+0xe4>
    iunlockput(ip);
    800058e4:	854a                	mv	a0,s2
    800058e6:	ffffe097          	auipc	ra,0xffffe
    800058ea:	16c080e7          	jalr	364(ra) # 80003a52 <iunlockput>
    end_op();
    800058ee:	fffff097          	auipc	ra,0xfffff
    800058f2:	946080e7          	jalr	-1722(ra) # 80004234 <end_op>
    return -1;
    800058f6:	54fd                	li	s1,-1
    800058f8:	b761                	j	80005880 <sys_open+0xe4>
    f->type = FD_DEVICE;
    800058fa:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    800058fe:	04691783          	lh	a5,70(s2)
    80005902:	02f99223          	sh	a5,36(s3)
    80005906:	bf2d                	j	80005840 <sys_open+0xa4>
    itrunc(ip);
    80005908:	854a                	mv	a0,s2
    8000590a:	ffffe097          	auipc	ra,0xffffe
    8000590e:	ff4080e7          	jalr	-12(ra) # 800038fe <itrunc>
    80005912:	bfb1                	j	8000586e <sys_open+0xd2>
      fileclose(f);
    80005914:	854e                	mv	a0,s3
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	d6e080e7          	jalr	-658(ra) # 80004684 <fileclose>
    iunlockput(ip);
    8000591e:	854a                	mv	a0,s2
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	132080e7          	jalr	306(ra) # 80003a52 <iunlockput>
    end_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	90c080e7          	jalr	-1780(ra) # 80004234 <end_op>
    return -1;
    80005930:	54fd                	li	s1,-1
    80005932:	b7b9                	j	80005880 <sys_open+0xe4>

0000000080005934 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005934:	7175                	addi	sp,sp,-144
    80005936:	e506                	sd	ra,136(sp)
    80005938:	e122                	sd	s0,128(sp)
    8000593a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	87a080e7          	jalr	-1926(ra) # 800041b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005944:	08000613          	li	a2,128
    80005948:	f7040593          	addi	a1,s0,-144
    8000594c:	4501                	li	a0,0
    8000594e:	ffffd097          	auipc	ra,0xffffd
    80005952:	308080e7          	jalr	776(ra) # 80002c56 <argstr>
    80005956:	02054963          	bltz	a0,80005988 <sys_mkdir+0x54>
    8000595a:	4681                	li	a3,0
    8000595c:	4601                	li	a2,0
    8000595e:	4585                	li	a1,1
    80005960:	f7040513          	addi	a0,s0,-144
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	7fc080e7          	jalr	2044(ra) # 80005160 <create>
    8000596c:	cd11                	beqz	a0,80005988 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	0e4080e7          	jalr	228(ra) # 80003a52 <iunlockput>
  end_op();
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	8be080e7          	jalr	-1858(ra) # 80004234 <end_op>
  return 0;
    8000597e:	4501                	li	a0,0
}
    80005980:	60aa                	ld	ra,136(sp)
    80005982:	640a                	ld	s0,128(sp)
    80005984:	6149                	addi	sp,sp,144
    80005986:	8082                	ret
    end_op();
    80005988:	fffff097          	auipc	ra,0xfffff
    8000598c:	8ac080e7          	jalr	-1876(ra) # 80004234 <end_op>
    return -1;
    80005990:	557d                	li	a0,-1
    80005992:	b7fd                	j	80005980 <sys_mkdir+0x4c>

0000000080005994 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005994:	7135                	addi	sp,sp,-160
    80005996:	ed06                	sd	ra,152(sp)
    80005998:	e922                	sd	s0,144(sp)
    8000599a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000599c:	fffff097          	auipc	ra,0xfffff
    800059a0:	81a080e7          	jalr	-2022(ra) # 800041b6 <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059a4:	08000613          	li	a2,128
    800059a8:	f7040593          	addi	a1,s0,-144
    800059ac:	4501                	li	a0,0
    800059ae:	ffffd097          	auipc	ra,0xffffd
    800059b2:	2a8080e7          	jalr	680(ra) # 80002c56 <argstr>
    800059b6:	04054a63          	bltz	a0,80005a0a <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    800059ba:	f6c40593          	addi	a1,s0,-148
    800059be:	4505                	li	a0,1
    800059c0:	ffffd097          	auipc	ra,0xffffd
    800059c4:	252080e7          	jalr	594(ra) # 80002c12 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059c8:	04054163          	bltz	a0,80005a0a <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    800059cc:	f6840593          	addi	a1,s0,-152
    800059d0:	4509                	li	a0,2
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	240080e7          	jalr	576(ra) # 80002c12 <argint>
     argint(1, &major) < 0 ||
    800059da:	02054863          	bltz	a0,80005a0a <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059de:	f6841683          	lh	a3,-152(s0)
    800059e2:	f6c41603          	lh	a2,-148(s0)
    800059e6:	458d                	li	a1,3
    800059e8:	f7040513          	addi	a0,s0,-144
    800059ec:	fffff097          	auipc	ra,0xfffff
    800059f0:	774080e7          	jalr	1908(ra) # 80005160 <create>
     argint(2, &minor) < 0 ||
    800059f4:	c919                	beqz	a0,80005a0a <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059f6:	ffffe097          	auipc	ra,0xffffe
    800059fa:	05c080e7          	jalr	92(ra) # 80003a52 <iunlockput>
  end_op();
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	836080e7          	jalr	-1994(ra) # 80004234 <end_op>
  return 0;
    80005a06:	4501                	li	a0,0
    80005a08:	a031                	j	80005a14 <sys_mknod+0x80>
    end_op();
    80005a0a:	fffff097          	auipc	ra,0xfffff
    80005a0e:	82a080e7          	jalr	-2006(ra) # 80004234 <end_op>
    return -1;
    80005a12:	557d                	li	a0,-1
}
    80005a14:	60ea                	ld	ra,152(sp)
    80005a16:	644a                	ld	s0,144(sp)
    80005a18:	610d                	addi	sp,sp,160
    80005a1a:	8082                	ret

0000000080005a1c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a1c:	7135                	addi	sp,sp,-160
    80005a1e:	ed06                	sd	ra,152(sp)
    80005a20:	e922                	sd	s0,144(sp)
    80005a22:	e526                	sd	s1,136(sp)
    80005a24:	e14a                	sd	s2,128(sp)
    80005a26:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a28:	ffffc097          	auipc	ra,0xffffc
    80005a2c:	000080e7          	jalr	ra # 80001a28 <myproc>
    80005a30:	892a                	mv	s2,a0
  
  begin_op();
    80005a32:	ffffe097          	auipc	ra,0xffffe
    80005a36:	784080e7          	jalr	1924(ra) # 800041b6 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a3a:	08000613          	li	a2,128
    80005a3e:	f6040593          	addi	a1,s0,-160
    80005a42:	4501                	li	a0,0
    80005a44:	ffffd097          	auipc	ra,0xffffd
    80005a48:	212080e7          	jalr	530(ra) # 80002c56 <argstr>
    80005a4c:	04054b63          	bltz	a0,80005aa2 <sys_chdir+0x86>
    80005a50:	f6040513          	addi	a0,s0,-160
    80005a54:	ffffe097          	auipc	ra,0xffffe
    80005a58:	552080e7          	jalr	1362(ra) # 80003fa6 <namei>
    80005a5c:	84aa                	mv	s1,a0
    80005a5e:	c131                	beqz	a0,80005aa2 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a60:	ffffe097          	auipc	ra,0xffffe
    80005a64:	d90080e7          	jalr	-624(ra) # 800037f0 <ilock>
  if(ip->type != T_DIR){
    80005a68:	04449703          	lh	a4,68(s1)
    80005a6c:	4785                	li	a5,1
    80005a6e:	04f71063          	bne	a4,a5,80005aae <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a72:	8526                	mv	a0,s1
    80005a74:	ffffe097          	auipc	ra,0xffffe
    80005a78:	e3e080e7          	jalr	-450(ra) # 800038b2 <iunlock>
  iput(p->cwd);
    80005a7c:	15093503          	ld	a0,336(s2)
    80005a80:	ffffe097          	auipc	ra,0xffffe
    80005a84:	f2a080e7          	jalr	-214(ra) # 800039aa <iput>
  end_op();
    80005a88:	ffffe097          	auipc	ra,0xffffe
    80005a8c:	7ac080e7          	jalr	1964(ra) # 80004234 <end_op>
  p->cwd = ip;
    80005a90:	14993823          	sd	s1,336(s2)
  return 0;
    80005a94:	4501                	li	a0,0
}
    80005a96:	60ea                	ld	ra,152(sp)
    80005a98:	644a                	ld	s0,144(sp)
    80005a9a:	64aa                	ld	s1,136(sp)
    80005a9c:	690a                	ld	s2,128(sp)
    80005a9e:	610d                	addi	sp,sp,160
    80005aa0:	8082                	ret
    end_op();
    80005aa2:	ffffe097          	auipc	ra,0xffffe
    80005aa6:	792080e7          	jalr	1938(ra) # 80004234 <end_op>
    return -1;
    80005aaa:	557d                	li	a0,-1
    80005aac:	b7ed                	j	80005a96 <sys_chdir+0x7a>
    iunlockput(ip);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	fa2080e7          	jalr	-94(ra) # 80003a52 <iunlockput>
    end_op();
    80005ab8:	ffffe097          	auipc	ra,0xffffe
    80005abc:	77c080e7          	jalr	1916(ra) # 80004234 <end_op>
    return -1;
    80005ac0:	557d                	li	a0,-1
    80005ac2:	bfd1                	j	80005a96 <sys_chdir+0x7a>

0000000080005ac4 <sys_exec>:

uint64
sys_exec(void)
{
    80005ac4:	7145                	addi	sp,sp,-464
    80005ac6:	e786                	sd	ra,456(sp)
    80005ac8:	e3a2                	sd	s0,448(sp)
    80005aca:	ff26                	sd	s1,440(sp)
    80005acc:	fb4a                	sd	s2,432(sp)
    80005ace:	f74e                	sd	s3,424(sp)
    80005ad0:	f352                	sd	s4,416(sp)
    80005ad2:	ef56                	sd	s5,408(sp)
    80005ad4:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005ad6:	08000613          	li	a2,128
    80005ada:	f4040593          	addi	a1,s0,-192
    80005ade:	4501                	li	a0,0
    80005ae0:	ffffd097          	auipc	ra,0xffffd
    80005ae4:	176080e7          	jalr	374(ra) # 80002c56 <argstr>
    return -1;
    80005ae8:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80005aea:	0c054b63          	bltz	a0,80005bc0 <sys_exec+0xfc>
    80005aee:	e3840593          	addi	a1,s0,-456
    80005af2:	4505                	li	a0,1
    80005af4:	ffffd097          	auipc	ra,0xffffd
    80005af8:	140080e7          	jalr	320(ra) # 80002c34 <argaddr>
    80005afc:	0c054263          	bltz	a0,80005bc0 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005b00:	10000613          	li	a2,256
    80005b04:	4581                	li	a1,0
    80005b06:	e4040513          	addi	a0,s0,-448
    80005b0a:	ffffb097          	auipc	ra,0xffffb
    80005b0e:	24e080e7          	jalr	590(ra) # 80000d58 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b12:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005b16:	89a6                	mv	s3,s1
    80005b18:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b1a:	02000a13          	li	s4,32
    80005b1e:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b22:	00391513          	slli	a0,s2,0x3
    80005b26:	e3040593          	addi	a1,s0,-464
    80005b2a:	e3843783          	ld	a5,-456(s0)
    80005b2e:	953e                	add	a0,a0,a5
    80005b30:	ffffd097          	auipc	ra,0xffffd
    80005b34:	048080e7          	jalr	72(ra) # 80002b78 <fetchaddr>
    80005b38:	02054a63          	bltz	a0,80005b6c <sys_exec+0xa8>
      goto bad;
    }
    if(uarg == 0){
    80005b3c:	e3043783          	ld	a5,-464(s0)
    80005b40:	c3b9                	beqz	a5,80005b86 <sys_exec+0xc2>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b42:	ffffb097          	auipc	ra,0xffffb
    80005b46:	02a080e7          	jalr	42(ra) # 80000b6c <kalloc>
    80005b4a:	85aa                	mv	a1,a0
    80005b4c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b50:	cd11                	beqz	a0,80005b6c <sys_exec+0xa8>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b52:	6605                	lui	a2,0x1
    80005b54:	e3043503          	ld	a0,-464(s0)
    80005b58:	ffffd097          	auipc	ra,0xffffd
    80005b5c:	072080e7          	jalr	114(ra) # 80002bca <fetchstr>
    80005b60:	00054663          	bltz	a0,80005b6c <sys_exec+0xa8>
    if(i >= NELEM(argv)){
    80005b64:	0905                	addi	s2,s2,1
    80005b66:	09a1                	addi	s3,s3,8
    80005b68:	fb491be3          	bne	s2,s4,80005b1e <sys_exec+0x5a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b6c:	f4040913          	addi	s2,s0,-192
    80005b70:	6088                	ld	a0,0(s1)
    80005b72:	c531                	beqz	a0,80005bbe <sys_exec+0xfa>
    kfree(argv[i]);
    80005b74:	ffffb097          	auipc	ra,0xffffb
    80005b78:	efa080e7          	jalr	-262(ra) # 80000a6e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b7c:	04a1                	addi	s1,s1,8
    80005b7e:	ff2499e3          	bne	s1,s2,80005b70 <sys_exec+0xac>
  return -1;
    80005b82:	597d                	li	s2,-1
    80005b84:	a835                	j	80005bc0 <sys_exec+0xfc>
      argv[i] = 0;
    80005b86:	0a8e                	slli	s5,s5,0x3
    80005b88:	fc0a8793          	addi	a5,s5,-64 # ffffffffffffefc0 <end+0xffffffff7ffd7fc0>
    80005b8c:	00878ab3          	add	s5,a5,s0
    80005b90:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005b94:	e4040593          	addi	a1,s0,-448
    80005b98:	f4040513          	addi	a0,s0,-192
    80005b9c:	fffff097          	auipc	ra,0xfffff
    80005ba0:	172080e7          	jalr	370(ra) # 80004d0e <exec>
    80005ba4:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba6:	f4040993          	addi	s3,s0,-192
    80005baa:	6088                	ld	a0,0(s1)
    80005bac:	c911                	beqz	a0,80005bc0 <sys_exec+0xfc>
    kfree(argv[i]);
    80005bae:	ffffb097          	auipc	ra,0xffffb
    80005bb2:	ec0080e7          	jalr	-320(ra) # 80000a6e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb6:	04a1                	addi	s1,s1,8
    80005bb8:	ff3499e3          	bne	s1,s3,80005baa <sys_exec+0xe6>
    80005bbc:	a011                	j	80005bc0 <sys_exec+0xfc>
  return -1;
    80005bbe:	597d                	li	s2,-1
}
    80005bc0:	854a                	mv	a0,s2
    80005bc2:	60be                	ld	ra,456(sp)
    80005bc4:	641e                	ld	s0,448(sp)
    80005bc6:	74fa                	ld	s1,440(sp)
    80005bc8:	795a                	ld	s2,432(sp)
    80005bca:	79ba                	ld	s3,424(sp)
    80005bcc:	7a1a                	ld	s4,416(sp)
    80005bce:	6afa                	ld	s5,408(sp)
    80005bd0:	6179                	addi	sp,sp,464
    80005bd2:	8082                	ret

0000000080005bd4 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bd4:	7139                	addi	sp,sp,-64
    80005bd6:	fc06                	sd	ra,56(sp)
    80005bd8:	f822                	sd	s0,48(sp)
    80005bda:	f426                	sd	s1,40(sp)
    80005bdc:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bde:	ffffc097          	auipc	ra,0xffffc
    80005be2:	e4a080e7          	jalr	-438(ra) # 80001a28 <myproc>
    80005be6:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005be8:	fd840593          	addi	a1,s0,-40
    80005bec:	4501                	li	a0,0
    80005bee:	ffffd097          	auipc	ra,0xffffd
    80005bf2:	046080e7          	jalr	70(ra) # 80002c34 <argaddr>
    return -1;
    80005bf6:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005bf8:	0e054063          	bltz	a0,80005cd8 <sys_pipe+0x104>
  if(pipealloc(&rf, &wf) < 0)
    80005bfc:	fc840593          	addi	a1,s0,-56
    80005c00:	fd040513          	addi	a0,s0,-48
    80005c04:	fffff097          	auipc	ra,0xfffff
    80005c08:	dd6080e7          	jalr	-554(ra) # 800049da <pipealloc>
    return -1;
    80005c0c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c0e:	0c054563          	bltz	a0,80005cd8 <sys_pipe+0x104>
  fd0 = -1;
    80005c12:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c16:	fd043503          	ld	a0,-48(s0)
    80005c1a:	fffff097          	auipc	ra,0xfffff
    80005c1e:	504080e7          	jalr	1284(ra) # 8000511e <fdalloc>
    80005c22:	fca42223          	sw	a0,-60(s0)
    80005c26:	08054c63          	bltz	a0,80005cbe <sys_pipe+0xea>
    80005c2a:	fc843503          	ld	a0,-56(s0)
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	4f0080e7          	jalr	1264(ra) # 8000511e <fdalloc>
    80005c36:	fca42023          	sw	a0,-64(s0)
    80005c3a:	06054963          	bltz	a0,80005cac <sys_pipe+0xd8>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c3e:	4691                	li	a3,4
    80005c40:	fc440613          	addi	a2,s0,-60
    80005c44:	fd843583          	ld	a1,-40(s0)
    80005c48:	68a8                	ld	a0,80(s1)
    80005c4a:	ffffc097          	auipc	ra,0xffffc
    80005c4e:	ad4080e7          	jalr	-1324(ra) # 8000171e <copyout>
    80005c52:	02054063          	bltz	a0,80005c72 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c56:	4691                	li	a3,4
    80005c58:	fc040613          	addi	a2,s0,-64
    80005c5c:	fd843583          	ld	a1,-40(s0)
    80005c60:	0591                	addi	a1,a1,4
    80005c62:	68a8                	ld	a0,80(s1)
    80005c64:	ffffc097          	auipc	ra,0xffffc
    80005c68:	aba080e7          	jalr	-1350(ra) # 8000171e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c6c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c6e:	06055563          	bgez	a0,80005cd8 <sys_pipe+0x104>
    p->ofile[fd0] = 0;
    80005c72:	fc442783          	lw	a5,-60(s0)
    80005c76:	07e9                	addi	a5,a5,26
    80005c78:	078e                	slli	a5,a5,0x3
    80005c7a:	97a6                	add	a5,a5,s1
    80005c7c:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c80:	fc042783          	lw	a5,-64(s0)
    80005c84:	07e9                	addi	a5,a5,26
    80005c86:	078e                	slli	a5,a5,0x3
    80005c88:	00f48533          	add	a0,s1,a5
    80005c8c:	00053023          	sd	zero,0(a0)
    fileclose(rf);
    80005c90:	fd043503          	ld	a0,-48(s0)
    80005c94:	fffff097          	auipc	ra,0xfffff
    80005c98:	9f0080e7          	jalr	-1552(ra) # 80004684 <fileclose>
    fileclose(wf);
    80005c9c:	fc843503          	ld	a0,-56(s0)
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	9e4080e7          	jalr	-1564(ra) # 80004684 <fileclose>
    return -1;
    80005ca8:	57fd                	li	a5,-1
    80005caa:	a03d                	j	80005cd8 <sys_pipe+0x104>
    if(fd0 >= 0)
    80005cac:	fc442783          	lw	a5,-60(s0)
    80005cb0:	0007c763          	bltz	a5,80005cbe <sys_pipe+0xea>
      p->ofile[fd0] = 0;
    80005cb4:	07e9                	addi	a5,a5,26
    80005cb6:	078e                	slli	a5,a5,0x3
    80005cb8:	97a6                	add	a5,a5,s1
    80005cba:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cbe:	fd043503          	ld	a0,-48(s0)
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	9c2080e7          	jalr	-1598(ra) # 80004684 <fileclose>
    fileclose(wf);
    80005cca:	fc843503          	ld	a0,-56(s0)
    80005cce:	fffff097          	auipc	ra,0xfffff
    80005cd2:	9b6080e7          	jalr	-1610(ra) # 80004684 <fileclose>
    return -1;
    80005cd6:	57fd                	li	a5,-1
}
    80005cd8:	853e                	mv	a0,a5
    80005cda:	70e2                	ld	ra,56(sp)
    80005cdc:	7442                	ld	s0,48(sp)
    80005cde:	74a2                	ld	s1,40(sp)
    80005ce0:	6121                	addi	sp,sp,64
    80005ce2:	8082                	ret
	...

0000000080005cf0 <kernelvec>:
    80005cf0:	7111                	addi	sp,sp,-256
    80005cf2:	e006                	sd	ra,0(sp)
    80005cf4:	e40a                	sd	sp,8(sp)
    80005cf6:	e80e                	sd	gp,16(sp)
    80005cf8:	ec12                	sd	tp,24(sp)
    80005cfa:	f016                	sd	t0,32(sp)
    80005cfc:	f41a                	sd	t1,40(sp)
    80005cfe:	f81e                	sd	t2,48(sp)
    80005d00:	fc22                	sd	s0,56(sp)
    80005d02:	e0a6                	sd	s1,64(sp)
    80005d04:	e4aa                	sd	a0,72(sp)
    80005d06:	e8ae                	sd	a1,80(sp)
    80005d08:	ecb2                	sd	a2,88(sp)
    80005d0a:	f0b6                	sd	a3,96(sp)
    80005d0c:	f4ba                	sd	a4,104(sp)
    80005d0e:	f8be                	sd	a5,112(sp)
    80005d10:	fcc2                	sd	a6,120(sp)
    80005d12:	e146                	sd	a7,128(sp)
    80005d14:	e54a                	sd	s2,136(sp)
    80005d16:	e94e                	sd	s3,144(sp)
    80005d18:	ed52                	sd	s4,152(sp)
    80005d1a:	f156                	sd	s5,160(sp)
    80005d1c:	f55a                	sd	s6,168(sp)
    80005d1e:	f95e                	sd	s7,176(sp)
    80005d20:	fd62                	sd	s8,184(sp)
    80005d22:	e1e6                	sd	s9,192(sp)
    80005d24:	e5ea                	sd	s10,200(sp)
    80005d26:	e9ee                	sd	s11,208(sp)
    80005d28:	edf2                	sd	t3,216(sp)
    80005d2a:	f1f6                	sd	t4,224(sp)
    80005d2c:	f5fa                	sd	t5,232(sp)
    80005d2e:	f9fe                	sd	t6,240(sp)
    80005d30:	c95fc0ef          	jal	ra,800029c4 <kerneltrap>
    80005d34:	6082                	ld	ra,0(sp)
    80005d36:	6122                	ld	sp,8(sp)
    80005d38:	61c2                	ld	gp,16(sp)
    80005d3a:	7282                	ld	t0,32(sp)
    80005d3c:	7322                	ld	t1,40(sp)
    80005d3e:	73c2                	ld	t2,48(sp)
    80005d40:	7462                	ld	s0,56(sp)
    80005d42:	6486                	ld	s1,64(sp)
    80005d44:	6526                	ld	a0,72(sp)
    80005d46:	65c6                	ld	a1,80(sp)
    80005d48:	6666                	ld	a2,88(sp)
    80005d4a:	7686                	ld	a3,96(sp)
    80005d4c:	7726                	ld	a4,104(sp)
    80005d4e:	77c6                	ld	a5,112(sp)
    80005d50:	7866                	ld	a6,120(sp)
    80005d52:	688a                	ld	a7,128(sp)
    80005d54:	692a                	ld	s2,136(sp)
    80005d56:	69ca                	ld	s3,144(sp)
    80005d58:	6a6a                	ld	s4,152(sp)
    80005d5a:	7a8a                	ld	s5,160(sp)
    80005d5c:	7b2a                	ld	s6,168(sp)
    80005d5e:	7bca                	ld	s7,176(sp)
    80005d60:	7c6a                	ld	s8,184(sp)
    80005d62:	6c8e                	ld	s9,192(sp)
    80005d64:	6d2e                	ld	s10,200(sp)
    80005d66:	6dce                	ld	s11,208(sp)
    80005d68:	6e6e                	ld	t3,216(sp)
    80005d6a:	7e8e                	ld	t4,224(sp)
    80005d6c:	7f2e                	ld	t5,232(sp)
    80005d6e:	7fce                	ld	t6,240(sp)
    80005d70:	6111                	addi	sp,sp,256
    80005d72:	10200073          	sret
    80005d76:	00000013          	nop
    80005d7a:	00000013          	nop
    80005d7e:	0001                	nop

0000000080005d80 <timervec>:
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	e10c                	sd	a1,0(a0)
    80005d86:	e510                	sd	a2,8(a0)
    80005d88:	e914                	sd	a3,16(a0)
    80005d8a:	710c                	ld	a1,32(a0)
    80005d8c:	7510                	ld	a2,40(a0)
    80005d8e:	6194                	ld	a3,0(a1)
    80005d90:	96b2                	add	a3,a3,a2
    80005d92:	e194                	sd	a3,0(a1)
    80005d94:	4589                	li	a1,2
    80005d96:	14459073          	csrw	sip,a1
    80005d9a:	6914                	ld	a3,16(a0)
    80005d9c:	6510                	ld	a2,8(a0)
    80005d9e:	610c                	ld	a1,0(a0)
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	30200073          	mret
	...

0000000080005daa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005daa:	1141                	addi	sp,sp,-16
    80005dac:	e422                	sd	s0,8(sp)
    80005dae:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005db0:	0c0007b7          	lui	a5,0xc000
    80005db4:	4705                	li	a4,1
    80005db6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005db8:	c3d8                	sw	a4,4(a5)
}
    80005dba:	6422                	ld	s0,8(sp)
    80005dbc:	0141                	addi	sp,sp,16
    80005dbe:	8082                	ret

0000000080005dc0 <plicinithart>:

void
plicinithart(void)
{
    80005dc0:	1141                	addi	sp,sp,-16
    80005dc2:	e406                	sd	ra,8(sp)
    80005dc4:	e022                	sd	s0,0(sp)
    80005dc6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	c34080e7          	jalr	-972(ra) # 800019fc <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005dd0:	0085171b          	slliw	a4,a0,0x8
    80005dd4:	0c0027b7          	lui	a5,0xc002
    80005dd8:	97ba                	add	a5,a5,a4
    80005dda:	40200713          	li	a4,1026
    80005dde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005de2:	00d5151b          	slliw	a0,a0,0xd
    80005de6:	0c2017b7          	lui	a5,0xc201
    80005dea:	97aa                	add	a5,a5,a0
    80005dec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005df0:	60a2                	ld	ra,8(sp)
    80005df2:	6402                	ld	s0,0(sp)
    80005df4:	0141                	addi	sp,sp,16
    80005df6:	8082                	ret

0000000080005df8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005df8:	1141                	addi	sp,sp,-16
    80005dfa:	e406                	sd	ra,8(sp)
    80005dfc:	e022                	sd	s0,0(sp)
    80005dfe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005e00:	ffffc097          	auipc	ra,0xffffc
    80005e04:	bfc080e7          	jalr	-1028(ra) # 800019fc <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e08:	00d5151b          	slliw	a0,a0,0xd
    80005e0c:	0c2017b7          	lui	a5,0xc201
    80005e10:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e12:	43c8                	lw	a0,4(a5)
    80005e14:	60a2                	ld	ra,8(sp)
    80005e16:	6402                	ld	s0,0(sp)
    80005e18:	0141                	addi	sp,sp,16
    80005e1a:	8082                	ret

0000000080005e1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e1c:	1101                	addi	sp,sp,-32
    80005e1e:	ec06                	sd	ra,24(sp)
    80005e20:	e822                	sd	s0,16(sp)
    80005e22:	e426                	sd	s1,8(sp)
    80005e24:	1000                	addi	s0,sp,32
    80005e26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	bd4080e7          	jalr	-1068(ra) # 800019fc <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e30:	00d5151b          	slliw	a0,a0,0xd
    80005e34:	0c2017b7          	lui	a5,0xc201
    80005e38:	97aa                	add	a5,a5,a0
    80005e3a:	c3c4                	sw	s1,4(a5)
}
    80005e3c:	60e2                	ld	ra,24(sp)
    80005e3e:	6442                	ld	s0,16(sp)
    80005e40:	64a2                	ld	s1,8(sp)
    80005e42:	6105                	addi	sp,sp,32
    80005e44:	8082                	ret

0000000080005e46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e46:	1141                	addi	sp,sp,-16
    80005e48:	e406                	sd	ra,8(sp)
    80005e4a:	e022                	sd	s0,0(sp)
    80005e4c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005e4e:	479d                	li	a5,7
    80005e50:	04a7cb63          	blt	a5,a0,80005ea6 <free_desc+0x60>
    panic("virtio_disk_intr 1");
  if(disk.free[i])
    80005e54:	0001e717          	auipc	a4,0x1e
    80005e58:	1ac70713          	addi	a4,a4,428 # 80024000 <disk>
    80005e5c:	972a                	add	a4,a4,a0
    80005e5e:	6789                	lui	a5,0x2
    80005e60:	97ba                	add	a5,a5,a4
    80005e62:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005e66:	eba1                	bnez	a5,80005eb6 <free_desc+0x70>
    panic("virtio_disk_intr 2");
  disk.desc[i].addr = 0;
    80005e68:	00451713          	slli	a4,a0,0x4
    80005e6c:	00020797          	auipc	a5,0x20
    80005e70:	1947b783          	ld	a5,404(a5) # 80026000 <disk+0x2000>
    80005e74:	97ba                	add	a5,a5,a4
    80005e76:	0007b023          	sd	zero,0(a5)
  disk.free[i] = 1;
    80005e7a:	0001e717          	auipc	a4,0x1e
    80005e7e:	18670713          	addi	a4,a4,390 # 80024000 <disk>
    80005e82:	972a                	add	a4,a4,a0
    80005e84:	6789                	lui	a5,0x2
    80005e86:	97ba                	add	a5,a5,a4
    80005e88:	4705                	li	a4,1
    80005e8a:	00e78c23          	sb	a4,24(a5) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    80005e8e:	00020517          	auipc	a0,0x20
    80005e92:	18a50513          	addi	a0,a0,394 # 80026018 <disk+0x2018>
    80005e96:	ffffc097          	auipc	ra,0xffffc
    80005e9a:	576080e7          	jalr	1398(ra) # 8000240c <wakeup>
}
    80005e9e:	60a2                	ld	ra,8(sp)
    80005ea0:	6402                	ld	s0,0(sp)
    80005ea2:	0141                	addi	sp,sp,16
    80005ea4:	8082                	ret
    panic("virtio_disk_intr 1");
    80005ea6:	00003517          	auipc	a0,0x3
    80005eaa:	8ca50513          	addi	a0,a0,-1846 # 80008770 <syscalls+0x340>
    80005eae:	ffffa097          	auipc	ra,0xffffa
    80005eb2:	698080e7          	jalr	1688(ra) # 80000546 <panic>
    panic("virtio_disk_intr 2");
    80005eb6:	00003517          	auipc	a0,0x3
    80005eba:	8d250513          	addi	a0,a0,-1838 # 80008788 <syscalls+0x358>
    80005ebe:	ffffa097          	auipc	ra,0xffffa
    80005ec2:	688080e7          	jalr	1672(ra) # 80000546 <panic>

0000000080005ec6 <virtio_disk_init>:
{
    80005ec6:	1101                	addi	sp,sp,-32
    80005ec8:	ec06                	sd	ra,24(sp)
    80005eca:	e822                	sd	s0,16(sp)
    80005ecc:	e426                	sd	s1,8(sp)
    80005ece:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ed0:	00003597          	auipc	a1,0x3
    80005ed4:	8d058593          	addi	a1,a1,-1840 # 800087a0 <syscalls+0x370>
    80005ed8:	00020517          	auipc	a0,0x20
    80005edc:	1d050513          	addi	a0,a0,464 # 800260a8 <disk+0x20a8>
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	cec080e7          	jalr	-788(ra) # 80000bcc <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ee8:	100017b7          	lui	a5,0x10001
    80005eec:	4398                	lw	a4,0(a5)
    80005eee:	2701                	sext.w	a4,a4
    80005ef0:	747277b7          	lui	a5,0x74727
    80005ef4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005ef8:	0ef71063          	bne	a4,a5,80005fd8 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005efc:	100017b7          	lui	a5,0x10001
    80005f00:	43dc                	lw	a5,4(a5)
    80005f02:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f04:	4705                	li	a4,1
    80005f06:	0ce79963          	bne	a5,a4,80005fd8 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f0a:	100017b7          	lui	a5,0x10001
    80005f0e:	479c                	lw	a5,8(a5)
    80005f10:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005f12:	4709                	li	a4,2
    80005f14:	0ce79263          	bne	a5,a4,80005fd8 <virtio_disk_init+0x112>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f18:	100017b7          	lui	a5,0x10001
    80005f1c:	47d8                	lw	a4,12(a5)
    80005f1e:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f20:	554d47b7          	lui	a5,0x554d4
    80005f24:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f28:	0af71863          	bne	a4,a5,80005fd8 <virtio_disk_init+0x112>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f2c:	100017b7          	lui	a5,0x10001
    80005f30:	4705                	li	a4,1
    80005f32:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f34:	470d                	li	a4,3
    80005f36:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f38:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f3a:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f3e:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fd775f>
    80005f42:	8f75                	and	a4,a4,a3
    80005f44:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f46:	472d                	li	a4,11
    80005f48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4a:	473d                	li	a4,15
    80005f4c:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005f4e:	6705                	lui	a4,0x1
    80005f50:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f52:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f56:	5bdc                	lw	a5,52(a5)
    80005f58:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f5a:	c7d9                	beqz	a5,80005fe8 <virtio_disk_init+0x122>
  if(max < NUM)
    80005f5c:	471d                	li	a4,7
    80005f5e:	08f77d63          	bgeu	a4,a5,80005ff8 <virtio_disk_init+0x132>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f62:	100014b7          	lui	s1,0x10001
    80005f66:	47a1                	li	a5,8
    80005f68:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005f6a:	6609                	lui	a2,0x2
    80005f6c:	4581                	li	a1,0
    80005f6e:	0001e517          	auipc	a0,0x1e
    80005f72:	09250513          	addi	a0,a0,146 # 80024000 <disk>
    80005f76:	ffffb097          	auipc	ra,0xffffb
    80005f7a:	de2080e7          	jalr	-542(ra) # 80000d58 <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    80005f7e:	0001e717          	auipc	a4,0x1e
    80005f82:	08270713          	addi	a4,a4,130 # 80024000 <disk>
    80005f86:	00c75793          	srli	a5,a4,0xc
    80005f8a:	2781                	sext.w	a5,a5
    80005f8c:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct VRingDesc *) disk.pages;
    80005f8e:	00020797          	auipc	a5,0x20
    80005f92:	07278793          	addi	a5,a5,114 # 80026000 <disk+0x2000>
    80005f96:	e398                	sd	a4,0(a5)
  disk.avail = (uint16*)(((char*)disk.desc) + NUM*sizeof(struct VRingDesc));
    80005f98:	0001e717          	auipc	a4,0x1e
    80005f9c:	0e870713          	addi	a4,a4,232 # 80024080 <disk+0x80>
    80005fa0:	e798                	sd	a4,8(a5)
  disk.used = (struct UsedArea *) (disk.pages + PGSIZE);
    80005fa2:	0001f717          	auipc	a4,0x1f
    80005fa6:	05e70713          	addi	a4,a4,94 # 80025000 <disk+0x1000>
    80005faa:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    80005fac:	4705                	li	a4,1
    80005fae:	00e78c23          	sb	a4,24(a5)
    80005fb2:	00e78ca3          	sb	a4,25(a5)
    80005fb6:	00e78d23          	sb	a4,26(a5)
    80005fba:	00e78da3          	sb	a4,27(a5)
    80005fbe:	00e78e23          	sb	a4,28(a5)
    80005fc2:	00e78ea3          	sb	a4,29(a5)
    80005fc6:	00e78f23          	sb	a4,30(a5)
    80005fca:	00e78fa3          	sb	a4,31(a5)
}
    80005fce:	60e2                	ld	ra,24(sp)
    80005fd0:	6442                	ld	s0,16(sp)
    80005fd2:	64a2                	ld	s1,8(sp)
    80005fd4:	6105                	addi	sp,sp,32
    80005fd6:	8082                	ret
    panic("could not find virtio disk");
    80005fd8:	00002517          	auipc	a0,0x2
    80005fdc:	7d850513          	addi	a0,a0,2008 # 800087b0 <syscalls+0x380>
    80005fe0:	ffffa097          	auipc	ra,0xffffa
    80005fe4:	566080e7          	jalr	1382(ra) # 80000546 <panic>
    panic("virtio disk has no queue 0");
    80005fe8:	00002517          	auipc	a0,0x2
    80005fec:	7e850513          	addi	a0,a0,2024 # 800087d0 <syscalls+0x3a0>
    80005ff0:	ffffa097          	auipc	ra,0xffffa
    80005ff4:	556080e7          	jalr	1366(ra) # 80000546 <panic>
    panic("virtio disk max queue too short");
    80005ff8:	00002517          	auipc	a0,0x2
    80005ffc:	7f850513          	addi	a0,a0,2040 # 800087f0 <syscalls+0x3c0>
    80006000:	ffffa097          	auipc	ra,0xffffa
    80006004:	546080e7          	jalr	1350(ra) # 80000546 <panic>

0000000080006008 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006008:	7175                	addi	sp,sp,-144
    8000600a:	e506                	sd	ra,136(sp)
    8000600c:	e122                	sd	s0,128(sp)
    8000600e:	fca6                	sd	s1,120(sp)
    80006010:	f8ca                	sd	s2,112(sp)
    80006012:	f4ce                	sd	s3,104(sp)
    80006014:	f0d2                	sd	s4,96(sp)
    80006016:	ecd6                	sd	s5,88(sp)
    80006018:	e8da                	sd	s6,80(sp)
    8000601a:	e4de                	sd	s7,72(sp)
    8000601c:	e0e2                	sd	s8,64(sp)
    8000601e:	fc66                	sd	s9,56(sp)
    80006020:	f86a                	sd	s10,48(sp)
    80006022:	f46e                	sd	s11,40(sp)
    80006024:	0900                	addi	s0,sp,144
    80006026:	8aaa                	mv	s5,a0
    80006028:	8d2e                	mv	s10,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000602a:	00c52c83          	lw	s9,12(a0)
    8000602e:	001c9c9b          	slliw	s9,s9,0x1
    80006032:	1c82                	slli	s9,s9,0x20
    80006034:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006038:	00020517          	auipc	a0,0x20
    8000603c:	07050513          	addi	a0,a0,112 # 800260a8 <disk+0x20a8>
    80006040:	ffffb097          	auipc	ra,0xffffb
    80006044:	c1c080e7          	jalr	-996(ra) # 80000c5c <acquire>
  for(int i = 0; i < 3; i++){
    80006048:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000604a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000604c:	0001ec17          	auipc	s8,0x1e
    80006050:	fb4c0c13          	addi	s8,s8,-76 # 80024000 <disk>
    80006054:	6b89                	lui	s7,0x2
  for(int i = 0; i < 3; i++){
    80006056:	4b0d                	li	s6,3
    80006058:	a0ad                	j	800060c2 <virtio_disk_rw+0xba>
      disk.free[i] = 0;
    8000605a:	00fc0733          	add	a4,s8,a5
    8000605e:	975e                	add	a4,a4,s7
    80006060:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006064:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006066:	0207c563          	bltz	a5,80006090 <virtio_disk_rw+0x88>
  for(int i = 0; i < 3; i++){
    8000606a:	2905                	addiw	s2,s2,1
    8000606c:	0611                	addi	a2,a2,4 # 2004 <_entry-0x7fffdffc>
    8000606e:	19690c63          	beq	s2,s6,80006206 <virtio_disk_rw+0x1fe>
    idx[i] = alloc_desc();
    80006072:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006074:	00020717          	auipc	a4,0x20
    80006078:	fa470713          	addi	a4,a4,-92 # 80026018 <disk+0x2018>
    8000607c:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000607e:	00074683          	lbu	a3,0(a4)
    80006082:	fee1                	bnez	a3,8000605a <virtio_disk_rw+0x52>
  for(int i = 0; i < NUM; i++){
    80006084:	2785                	addiw	a5,a5,1
    80006086:	0705                	addi	a4,a4,1
    80006088:	fe979be3          	bne	a5,s1,8000607e <virtio_disk_rw+0x76>
    idx[i] = alloc_desc();
    8000608c:	57fd                	li	a5,-1
    8000608e:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006090:	01205d63          	blez	s2,800060aa <virtio_disk_rw+0xa2>
    80006094:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006096:	000a2503          	lw	a0,0(s4)
    8000609a:	00000097          	auipc	ra,0x0
    8000609e:	dac080e7          	jalr	-596(ra) # 80005e46 <free_desc>
      for(int j = 0; j < i; j++)
    800060a2:	2d85                	addiw	s11,s11,1
    800060a4:	0a11                	addi	s4,s4,4
    800060a6:	ff2d98e3          	bne	s11,s2,80006096 <virtio_disk_rw+0x8e>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060aa:	00020597          	auipc	a1,0x20
    800060ae:	ffe58593          	addi	a1,a1,-2 # 800260a8 <disk+0x20a8>
    800060b2:	00020517          	auipc	a0,0x20
    800060b6:	f6650513          	addi	a0,a0,-154 # 80026018 <disk+0x2018>
    800060ba:	ffffc097          	auipc	ra,0xffffc
    800060be:	1d2080e7          	jalr	466(ra) # 8000228c <sleep>
  for(int i = 0; i < 3; i++){
    800060c2:	f8040a13          	addi	s4,s0,-128
{
    800060c6:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800060c8:	894e                	mv	s2,s3
    800060ca:	b765                	j	80006072 <virtio_disk_rw+0x6a>
  disk.desc[idx[0]].next = idx[1];

  disk.desc[idx[1]].addr = (uint64) b->data;
  disk.desc[idx[1]].len = BSIZE;
  if(write)
    disk.desc[idx[1]].flags = 0; // device reads b->data
    800060cc:	00020717          	auipc	a4,0x20
    800060d0:	f3473703          	ld	a4,-204(a4) # 80026000 <disk+0x2000>
    800060d4:	973e                	add	a4,a4,a5
    800060d6:	00071623          	sh	zero,12(a4)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060da:	0001e517          	auipc	a0,0x1e
    800060de:	f2650513          	addi	a0,a0,-218 # 80024000 <disk>
    800060e2:	00020717          	auipc	a4,0x20
    800060e6:	f1e70713          	addi	a4,a4,-226 # 80026000 <disk+0x2000>
    800060ea:	6314                	ld	a3,0(a4)
    800060ec:	96be                	add	a3,a3,a5
    800060ee:	00c6d603          	lhu	a2,12(a3)
    800060f2:	00166613          	ori	a2,a2,1
    800060f6:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060fa:	f8842683          	lw	a3,-120(s0)
    800060fe:	6310                	ld	a2,0(a4)
    80006100:	97b2                	add	a5,a5,a2
    80006102:	00d79723          	sh	a3,14(a5)

  disk.info[idx[0]].status = 0;
    80006106:	20048613          	addi	a2,s1,512 # 10001200 <_entry-0x6fffee00>
    8000610a:	0612                	slli	a2,a2,0x4
    8000610c:	962a                	add	a2,a2,a0
    8000610e:	02060823          	sb	zero,48(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80006112:	00469793          	slli	a5,a3,0x4
    80006116:	630c                	ld	a1,0(a4)
    80006118:	95be                	add	a1,a1,a5
    8000611a:	6689                	lui	a3,0x2
    8000611c:	03068693          	addi	a3,a3,48 # 2030 <_entry-0x7fffdfd0>
    80006120:	96ca                	add	a3,a3,s2
    80006122:	96aa                	add	a3,a3,a0
    80006124:	e194                	sd	a3,0(a1)
  disk.desc[idx[2]].len = 1;
    80006126:	6314                	ld	a3,0(a4)
    80006128:	96be                	add	a3,a3,a5
    8000612a:	4585                	li	a1,1
    8000612c:	c68c                	sw	a1,8(a3)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    8000612e:	6314                	ld	a3,0(a4)
    80006130:	96be                	add	a3,a3,a5
    80006132:	4509                	li	a0,2
    80006134:	00a69623          	sh	a0,12(a3)
  disk.desc[idx[2]].next = 0;
    80006138:	6314                	ld	a3,0(a4)
    8000613a:	97b6                	add	a5,a5,a3
    8000613c:	00079723          	sh	zero,14(a5)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006140:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006144:	03563423          	sd	s5,40(a2)

  // avail[0] is flags
  // avail[1] tells the device how far to look in avail[2...].
  // avail[2...] are desc[] indices the device should process.
  // we only tell device the first index in our chain of descriptors.
  disk.avail[2 + (disk.avail[1] % NUM)] = idx[0];
    80006148:	6714                	ld	a3,8(a4)
    8000614a:	0026d783          	lhu	a5,2(a3)
    8000614e:	8b9d                	andi	a5,a5,7
    80006150:	0789                	addi	a5,a5,2
    80006152:	0786                	slli	a5,a5,0x1
    80006154:	96be                	add	a3,a3,a5
    80006156:	00969023          	sh	s1,0(a3)
  __sync_synchronize();
    8000615a:	0ff0000f          	fence
  disk.avail[1] = disk.avail[1] + 1;
    8000615e:	6718                	ld	a4,8(a4)
    80006160:	00275783          	lhu	a5,2(a4)
    80006164:	2785                	addiw	a5,a5,1
    80006166:	00f71123          	sh	a5,2(a4)

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000616a:	100017b7          	lui	a5,0x10001
    8000616e:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006172:	004aa783          	lw	a5,4(s5)
    80006176:	02b79163          	bne	a5,a1,80006198 <virtio_disk_rw+0x190>
    sleep(b, &disk.vdisk_lock);
    8000617a:	00020917          	auipc	s2,0x20
    8000617e:	f2e90913          	addi	s2,s2,-210 # 800260a8 <disk+0x20a8>
  while(b->disk == 1) {
    80006182:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80006184:	85ca                	mv	a1,s2
    80006186:	8556                	mv	a0,s5
    80006188:	ffffc097          	auipc	ra,0xffffc
    8000618c:	104080e7          	jalr	260(ra) # 8000228c <sleep>
  while(b->disk == 1) {
    80006190:	004aa783          	lw	a5,4(s5)
    80006194:	fe9788e3          	beq	a5,s1,80006184 <virtio_disk_rw+0x17c>
  }

  disk.info[idx[0]].b = 0;
    80006198:	f8042483          	lw	s1,-128(s0)
    8000619c:	20048713          	addi	a4,s1,512
    800061a0:	0712                	slli	a4,a4,0x4
    800061a2:	0001e797          	auipc	a5,0x1e
    800061a6:	e5e78793          	addi	a5,a5,-418 # 80024000 <disk>
    800061aa:	97ba                	add	a5,a5,a4
    800061ac:	0207b423          	sd	zero,40(a5)
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061b0:	00020917          	auipc	s2,0x20
    800061b4:	e5090913          	addi	s2,s2,-432 # 80026000 <disk+0x2000>
    800061b8:	a019                	j	800061be <virtio_disk_rw+0x1b6>
      i = disk.desc[i].next;
    800061ba:	00e7d483          	lhu	s1,14(a5)
    free_desc(i);
    800061be:	8526                	mv	a0,s1
    800061c0:	00000097          	auipc	ra,0x0
    800061c4:	c86080e7          	jalr	-890(ra) # 80005e46 <free_desc>
    if(disk.desc[i].flags & VRING_DESC_F_NEXT)
    800061c8:	0492                	slli	s1,s1,0x4
    800061ca:	00093783          	ld	a5,0(s2)
    800061ce:	97a6                	add	a5,a5,s1
    800061d0:	00c7d703          	lhu	a4,12(a5)
    800061d4:	8b05                	andi	a4,a4,1
    800061d6:	f375                	bnez	a4,800061ba <virtio_disk_rw+0x1b2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061d8:	00020517          	auipc	a0,0x20
    800061dc:	ed050513          	addi	a0,a0,-304 # 800260a8 <disk+0x20a8>
    800061e0:	ffffb097          	auipc	ra,0xffffb
    800061e4:	b30080e7          	jalr	-1232(ra) # 80000d10 <release>
}
    800061e8:	60aa                	ld	ra,136(sp)
    800061ea:	640a                	ld	s0,128(sp)
    800061ec:	74e6                	ld	s1,120(sp)
    800061ee:	7946                	ld	s2,112(sp)
    800061f0:	79a6                	ld	s3,104(sp)
    800061f2:	7a06                	ld	s4,96(sp)
    800061f4:	6ae6                	ld	s5,88(sp)
    800061f6:	6b46                	ld	s6,80(sp)
    800061f8:	6ba6                	ld	s7,72(sp)
    800061fa:	6c06                	ld	s8,64(sp)
    800061fc:	7ce2                	ld	s9,56(sp)
    800061fe:	7d42                	ld	s10,48(sp)
    80006200:	7da2                	ld	s11,40(sp)
    80006202:	6149                	addi	sp,sp,144
    80006204:	8082                	ret
  if(write)
    80006206:	01a037b3          	snez	a5,s10
    8000620a:	f6f42823          	sw	a5,-144(s0)
  buf0.reserved = 0;
    8000620e:	f6042a23          	sw	zero,-140(s0)
  buf0.sector = sector;
    80006212:	f7943c23          	sd	s9,-136(s0)
  disk.desc[idx[0]].addr = (uint64) kvmpa((uint64) &buf0);
    80006216:	f8042483          	lw	s1,-128(s0)
    8000621a:	00449913          	slli	s2,s1,0x4
    8000621e:	00020997          	auipc	s3,0x20
    80006222:	de298993          	addi	s3,s3,-542 # 80026000 <disk+0x2000>
    80006226:	0009ba03          	ld	s4,0(s3)
    8000622a:	9a4a                	add	s4,s4,s2
    8000622c:	f7040513          	addi	a0,s0,-144
    80006230:	ffffb097          	auipc	ra,0xffffb
    80006234:	ef8080e7          	jalr	-264(ra) # 80001128 <kvmpa>
    80006238:	00aa3023          	sd	a0,0(s4)
  disk.desc[idx[0]].len = sizeof(buf0);
    8000623c:	0009b783          	ld	a5,0(s3)
    80006240:	97ca                	add	a5,a5,s2
    80006242:	4741                	li	a4,16
    80006244:	c798                	sw	a4,8(a5)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006246:	0009b783          	ld	a5,0(s3)
    8000624a:	97ca                	add	a5,a5,s2
    8000624c:	4705                	li	a4,1
    8000624e:	00e79623          	sh	a4,12(a5)
  disk.desc[idx[0]].next = idx[1];
    80006252:	f8442783          	lw	a5,-124(s0)
    80006256:	0009b703          	ld	a4,0(s3)
    8000625a:	974a                	add	a4,a4,s2
    8000625c:	00f71723          	sh	a5,14(a4)
  disk.desc[idx[1]].addr = (uint64) b->data;
    80006260:	0792                	slli	a5,a5,0x4
    80006262:	0009b703          	ld	a4,0(s3)
    80006266:	973e                	add	a4,a4,a5
    80006268:	058a8693          	addi	a3,s5,88
    8000626c:	e314                	sd	a3,0(a4)
  disk.desc[idx[1]].len = BSIZE;
    8000626e:	0009b703          	ld	a4,0(s3)
    80006272:	973e                	add	a4,a4,a5
    80006274:	40000693          	li	a3,1024
    80006278:	c714                	sw	a3,8(a4)
  if(write)
    8000627a:	e40d19e3          	bnez	s10,800060cc <virtio_disk_rw+0xc4>
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    8000627e:	00020717          	auipc	a4,0x20
    80006282:	d8273703          	ld	a4,-638(a4) # 80026000 <disk+0x2000>
    80006286:	973e                	add	a4,a4,a5
    80006288:	4689                	li	a3,2
    8000628a:	00d71623          	sh	a3,12(a4)
    8000628e:	b5b1                	j	800060da <virtio_disk_rw+0xd2>

0000000080006290 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006290:	1101                	addi	sp,sp,-32
    80006292:	ec06                	sd	ra,24(sp)
    80006294:	e822                	sd	s0,16(sp)
    80006296:	e426                	sd	s1,8(sp)
    80006298:	e04a                	sd	s2,0(sp)
    8000629a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000629c:	00020517          	auipc	a0,0x20
    800062a0:	e0c50513          	addi	a0,a0,-500 # 800260a8 <disk+0x20a8>
    800062a4:	ffffb097          	auipc	ra,0xffffb
    800062a8:	9b8080e7          	jalr	-1608(ra) # 80000c5c <acquire>

  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    800062ac:	00020717          	auipc	a4,0x20
    800062b0:	d5470713          	addi	a4,a4,-684 # 80026000 <disk+0x2000>
    800062b4:	02075783          	lhu	a5,32(a4)
    800062b8:	6b18                	ld	a4,16(a4)
    800062ba:	00275683          	lhu	a3,2(a4)
    800062be:	8ebd                	xor	a3,a3,a5
    800062c0:	8a9d                	andi	a3,a3,7
    800062c2:	cab9                	beqz	a3,80006318 <virtio_disk_intr+0x88>
    int id = disk.used->elems[disk.used_idx].id;

    if(disk.info[id].status != 0)
    800062c4:	0001e917          	auipc	s2,0x1e
    800062c8:	d3c90913          	addi	s2,s2,-708 # 80024000 <disk>
      panic("virtio_disk_intr status");
    
    disk.info[id].b->disk = 0;   // disk is done with buf
    wakeup(disk.info[id].b);

    disk.used_idx = (disk.used_idx + 1) % NUM;
    800062cc:	00020497          	auipc	s1,0x20
    800062d0:	d3448493          	addi	s1,s1,-716 # 80026000 <disk+0x2000>
    int id = disk.used->elems[disk.used_idx].id;
    800062d4:	078e                	slli	a5,a5,0x3
    800062d6:	973e                	add	a4,a4,a5
    800062d8:	435c                	lw	a5,4(a4)
    if(disk.info[id].status != 0)
    800062da:	20078713          	addi	a4,a5,512
    800062de:	0712                	slli	a4,a4,0x4
    800062e0:	974a                	add	a4,a4,s2
    800062e2:	03074703          	lbu	a4,48(a4)
    800062e6:	ef21                	bnez	a4,8000633e <virtio_disk_intr+0xae>
    disk.info[id].b->disk = 0;   // disk is done with buf
    800062e8:	20078793          	addi	a5,a5,512
    800062ec:	0792                	slli	a5,a5,0x4
    800062ee:	97ca                	add	a5,a5,s2
    800062f0:	7798                	ld	a4,40(a5)
    800062f2:	00072223          	sw	zero,4(a4)
    wakeup(disk.info[id].b);
    800062f6:	7788                	ld	a0,40(a5)
    800062f8:	ffffc097          	auipc	ra,0xffffc
    800062fc:	114080e7          	jalr	276(ra) # 8000240c <wakeup>
    disk.used_idx = (disk.used_idx + 1) % NUM;
    80006300:	0204d783          	lhu	a5,32(s1)
    80006304:	2785                	addiw	a5,a5,1
    80006306:	8b9d                	andi	a5,a5,7
    80006308:	02f49023          	sh	a5,32(s1)
  while((disk.used_idx % NUM) != (disk.used->id % NUM)){
    8000630c:	6898                	ld	a4,16(s1)
    8000630e:	00275683          	lhu	a3,2(a4)
    80006312:	8a9d                	andi	a3,a3,7
    80006314:	fcf690e3          	bne	a3,a5,800062d4 <virtio_disk_intr+0x44>
  }
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006318:	10001737          	lui	a4,0x10001
    8000631c:	533c                	lw	a5,96(a4)
    8000631e:	8b8d                	andi	a5,a5,3
    80006320:	d37c                	sw	a5,100(a4)

  release(&disk.vdisk_lock);
    80006322:	00020517          	auipc	a0,0x20
    80006326:	d8650513          	addi	a0,a0,-634 # 800260a8 <disk+0x20a8>
    8000632a:	ffffb097          	auipc	ra,0xffffb
    8000632e:	9e6080e7          	jalr	-1562(ra) # 80000d10 <release>
}
    80006332:	60e2                	ld	ra,24(sp)
    80006334:	6442                	ld	s0,16(sp)
    80006336:	64a2                	ld	s1,8(sp)
    80006338:	6902                	ld	s2,0(sp)
    8000633a:	6105                	addi	sp,sp,32
    8000633c:	8082                	ret
      panic("virtio_disk_intr status");
    8000633e:	00002517          	auipc	a0,0x2
    80006342:	4d250513          	addi	a0,a0,1234 # 80008810 <syscalls+0x3e0>
    80006346:	ffffa097          	auipc	ra,0xffffa
    8000634a:	200080e7          	jalr	512(ra) # 80000546 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051573          	csrrw	a0,sscratch,a0
    80007004:	02153423          	sd	ra,40(a0)
    80007008:	02253823          	sd	sp,48(a0)
    8000700c:	02353c23          	sd	gp,56(a0)
    80007010:	04453023          	sd	tp,64(a0)
    80007014:	04553423          	sd	t0,72(a0)
    80007018:	04653823          	sd	t1,80(a0)
    8000701c:	04753c23          	sd	t2,88(a0)
    80007020:	f120                	sd	s0,96(a0)
    80007022:	f524                	sd	s1,104(a0)
    80007024:	fd2c                	sd	a1,120(a0)
    80007026:	e150                	sd	a2,128(a0)
    80007028:	e554                	sd	a3,136(a0)
    8000702a:	e958                	sd	a4,144(a0)
    8000702c:	ed5c                	sd	a5,152(a0)
    8000702e:	0b053023          	sd	a6,160(a0)
    80007032:	0b153423          	sd	a7,168(a0)
    80007036:	0b253823          	sd	s2,176(a0)
    8000703a:	0b353c23          	sd	s3,184(a0)
    8000703e:	0d453023          	sd	s4,192(a0)
    80007042:	0d553423          	sd	s5,200(a0)
    80007046:	0d653823          	sd	s6,208(a0)
    8000704a:	0d753c23          	sd	s7,216(a0)
    8000704e:	0f853023          	sd	s8,224(a0)
    80007052:	0f953423          	sd	s9,232(a0)
    80007056:	0fa53823          	sd	s10,240(a0)
    8000705a:	0fb53c23          	sd	s11,248(a0)
    8000705e:	11c53023          	sd	t3,256(a0)
    80007062:	11d53423          	sd	t4,264(a0)
    80007066:	11e53823          	sd	t5,272(a0)
    8000706a:	11f53c23          	sd	t6,280(a0)
    8000706e:	140022f3          	csrr	t0,sscratch
    80007072:	06553823          	sd	t0,112(a0)
    80007076:	00853103          	ld	sp,8(a0)
    8000707a:	02053203          	ld	tp,32(a0)
    8000707e:	01053283          	ld	t0,16(a0)
    80007082:	00053303          	ld	t1,0(a0)
    80007086:	18031073          	csrw	satp,t1
    8000708a:	12000073          	sfence.vma
    8000708e:	8282                	jr	t0

0000000080007090 <userret>:
    80007090:	18059073          	csrw	satp,a1
    80007094:	12000073          	sfence.vma
    80007098:	07053283          	ld	t0,112(a0)
    8000709c:	14029073          	csrw	sscratch,t0
    800070a0:	02853083          	ld	ra,40(a0)
    800070a4:	03053103          	ld	sp,48(a0)
    800070a8:	03853183          	ld	gp,56(a0)
    800070ac:	04053203          	ld	tp,64(a0)
    800070b0:	04853283          	ld	t0,72(a0)
    800070b4:	05053303          	ld	t1,80(a0)
    800070b8:	05853383          	ld	t2,88(a0)
    800070bc:	7120                	ld	s0,96(a0)
    800070be:	7524                	ld	s1,104(a0)
    800070c0:	7d2c                	ld	a1,120(a0)
    800070c2:	6150                	ld	a2,128(a0)
    800070c4:	6554                	ld	a3,136(a0)
    800070c6:	6958                	ld	a4,144(a0)
    800070c8:	6d5c                	ld	a5,152(a0)
    800070ca:	0a053803          	ld	a6,160(a0)
    800070ce:	0a853883          	ld	a7,168(a0)
    800070d2:	0b053903          	ld	s2,176(a0)
    800070d6:	0b853983          	ld	s3,184(a0)
    800070da:	0c053a03          	ld	s4,192(a0)
    800070de:	0c853a83          	ld	s5,200(a0)
    800070e2:	0d053b03          	ld	s6,208(a0)
    800070e6:	0d853b83          	ld	s7,216(a0)
    800070ea:	0e053c03          	ld	s8,224(a0)
    800070ee:	0e853c83          	ld	s9,232(a0)
    800070f2:	0f053d03          	ld	s10,240(a0)
    800070f6:	0f853d83          	ld	s11,248(a0)
    800070fa:	10053e03          	ld	t3,256(a0)
    800070fe:	10853e83          	ld	t4,264(a0)
    80007102:	11053f03          	ld	t5,272(a0)
    80007106:	11853f83          	ld	t6,280(a0)
    8000710a:	14051573          	csrrw	a0,sscratch,a0
    8000710e:	10200073          	sret
	...
