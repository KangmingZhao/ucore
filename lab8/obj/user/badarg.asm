
obj/__user_badarg.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <__panic>:
  800020:	715d                	addi	sp,sp,-80
  800022:	e822                	sd	s0,16(sp)
  800024:	fc3e                	sd	a5,56(sp)
  800026:	8432                	mv	s0,a2
  800028:	103c                	addi	a5,sp,40
  80002a:	862e                	mv	a2,a1
  80002c:	85aa                	mv	a1,a0
  80002e:	00000517          	auipc	a0,0x0
  800032:	79250513          	addi	a0,a0,1938 # 8007c0 <main+0xec>
  800036:	ec06                	sd	ra,24(sp)
  800038:	f436                	sd	a3,40(sp)
  80003a:	f83a                	sd	a4,48(sp)
  80003c:	e0c2                	sd	a6,64(sp)
  80003e:	e4c6                	sd	a7,72(sp)
  800040:	e43e                	sd	a5,8(sp)
  800042:	158000ef          	jal	ra,80019a <cprintf>
  800046:	65a2                	ld	a1,8(sp)
  800048:	8522                	mv	a0,s0
  80004a:	12a000ef          	jal	ra,800174 <vcprintf>
  80004e:	00000517          	auipc	a0,0x0
  800052:	7ea50513          	addi	a0,a0,2026 # 800838 <main+0x164>
  800056:	144000ef          	jal	ra,80019a <cprintf>
  80005a:	5559                	li	a0,-10
  80005c:	0c6000ef          	jal	ra,800122 <exit>

0000000000800060 <__warn>:
  800060:	715d                	addi	sp,sp,-80
  800062:	e822                	sd	s0,16(sp)
  800064:	fc3e                	sd	a5,56(sp)
  800066:	8432                	mv	s0,a2
  800068:	103c                	addi	a5,sp,40
  80006a:	862e                	mv	a2,a1
  80006c:	85aa                	mv	a1,a0
  80006e:	00000517          	auipc	a0,0x0
  800072:	77250513          	addi	a0,a0,1906 # 8007e0 <main+0x10c>
  800076:	ec06                	sd	ra,24(sp)
  800078:	f436                	sd	a3,40(sp)
  80007a:	f83a                	sd	a4,48(sp)
  80007c:	e0c2                	sd	a6,64(sp)
  80007e:	e4c6                	sd	a7,72(sp)
  800080:	e43e                	sd	a5,8(sp)
  800082:	118000ef          	jal	ra,80019a <cprintf>
  800086:	65a2                	ld	a1,8(sp)
  800088:	8522                	mv	a0,s0
  80008a:	0ea000ef          	jal	ra,800174 <vcprintf>
  80008e:	00000517          	auipc	a0,0x0
  800092:	7aa50513          	addi	a0,a0,1962 # 800838 <main+0x164>
  800096:	104000ef          	jal	ra,80019a <cprintf>
  80009a:	60e2                	ld	ra,24(sp)
  80009c:	6442                	ld	s0,16(sp)
  80009e:	6161                	addi	sp,sp,80
  8000a0:	8082                	ret

00000000008000a2 <syscall>:
  8000a2:	7175                	addi	sp,sp,-144
  8000a4:	f8ba                	sd	a4,112(sp)
  8000a6:	e0ba                	sd	a4,64(sp)
  8000a8:	0118                	addi	a4,sp,128
  8000aa:	e42a                	sd	a0,8(sp)
  8000ac:	ecae                	sd	a1,88(sp)
  8000ae:	f0b2                	sd	a2,96(sp)
  8000b0:	f4b6                	sd	a3,104(sp)
  8000b2:	fcbe                	sd	a5,120(sp)
  8000b4:	e142                	sd	a6,128(sp)
  8000b6:	e546                	sd	a7,136(sp)
  8000b8:	f42e                	sd	a1,40(sp)
  8000ba:	f832                	sd	a2,48(sp)
  8000bc:	fc36                	sd	a3,56(sp)
  8000be:	f03a                	sd	a4,32(sp)
  8000c0:	e4be                	sd	a5,72(sp)
  8000c2:	4522                	lw	a0,8(sp)
  8000c4:	55a2                	lw	a1,40(sp)
  8000c6:	5642                	lw	a2,48(sp)
  8000c8:	56e2                	lw	a3,56(sp)
  8000ca:	4706                	lw	a4,64(sp)
  8000cc:	47a6                	lw	a5,72(sp)
  8000ce:	00000073          	ecall
  8000d2:	ce2a                	sw	a0,28(sp)
  8000d4:	4572                	lw	a0,28(sp)
  8000d6:	6149                	addi	sp,sp,144
  8000d8:	8082                	ret

00000000008000da <sys_exit>:
  8000da:	85aa                	mv	a1,a0
  8000dc:	4505                	li	a0,1
  8000de:	fc5ff06f          	j	8000a2 <syscall>

00000000008000e2 <sys_fork>:
  8000e2:	4509                	li	a0,2
  8000e4:	fbfff06f          	j	8000a2 <syscall>

00000000008000e8 <sys_wait>:
  8000e8:	862e                	mv	a2,a1
  8000ea:	85aa                	mv	a1,a0
  8000ec:	450d                	li	a0,3
  8000ee:	fb5ff06f          	j	8000a2 <syscall>

00000000008000f2 <sys_yield>:
  8000f2:	4529                	li	a0,10
  8000f4:	fafff06f          	j	8000a2 <syscall>

00000000008000f8 <sys_putc>:
  8000f8:	85aa                	mv	a1,a0
  8000fa:	4579                	li	a0,30
  8000fc:	fa7ff06f          	j	8000a2 <syscall>

0000000000800100 <sys_open>:
  800100:	862e                	mv	a2,a1
  800102:	85aa                	mv	a1,a0
  800104:	06400513          	li	a0,100
  800108:	f9bff06f          	j	8000a2 <syscall>

000000000080010c <sys_close>:
  80010c:	85aa                	mv	a1,a0
  80010e:	06500513          	li	a0,101
  800112:	f91ff06f          	j	8000a2 <syscall>

0000000000800116 <sys_dup>:
  800116:	862e                	mv	a2,a1
  800118:	85aa                	mv	a1,a0
  80011a:	08200513          	li	a0,130
  80011e:	f85ff06f          	j	8000a2 <syscall>

0000000000800122 <exit>:
  800122:	1141                	addi	sp,sp,-16
  800124:	e406                	sd	ra,8(sp)
  800126:	fb5ff0ef          	jal	ra,8000da <sys_exit>
  80012a:	00000517          	auipc	a0,0x0
  80012e:	6d650513          	addi	a0,a0,1750 # 800800 <main+0x12c>
  800132:	068000ef          	jal	ra,80019a <cprintf>
  800136:	a001                	j	800136 <exit+0x14>

0000000000800138 <fork>:
  800138:	fabff06f          	j	8000e2 <sys_fork>

000000000080013c <waitpid>:
  80013c:	fadff06f          	j	8000e8 <sys_wait>

0000000000800140 <yield>:
  800140:	fb3ff06f          	j	8000f2 <sys_yield>

0000000000800144 <_start>:
  800144:	0d4000ef          	jal	ra,800218 <umain>
  800148:	a001                	j	800148 <_start+0x4>

000000000080014a <open>:
  80014a:	1582                	slli	a1,a1,0x20
  80014c:	9181                	srli	a1,a1,0x20
  80014e:	fb3ff06f          	j	800100 <sys_open>

0000000000800152 <close>:
  800152:	fbbff06f          	j	80010c <sys_close>

0000000000800156 <dup2>:
  800156:	fc1ff06f          	j	800116 <sys_dup>

000000000080015a <cputch>:
  80015a:	1141                	addi	sp,sp,-16
  80015c:	e022                	sd	s0,0(sp)
  80015e:	e406                	sd	ra,8(sp)
  800160:	842e                	mv	s0,a1
  800162:	f97ff0ef          	jal	ra,8000f8 <sys_putc>
  800166:	401c                	lw	a5,0(s0)
  800168:	60a2                	ld	ra,8(sp)
  80016a:	2785                	addiw	a5,a5,1
  80016c:	c01c                	sw	a5,0(s0)
  80016e:	6402                	ld	s0,0(sp)
  800170:	0141                	addi	sp,sp,16
  800172:	8082                	ret

0000000000800174 <vcprintf>:
  800174:	1101                	addi	sp,sp,-32
  800176:	872e                	mv	a4,a1
  800178:	75dd                	lui	a1,0xffff7
  80017a:	86aa                	mv	a3,a0
  80017c:	0070                	addi	a2,sp,12
  80017e:	00000517          	auipc	a0,0x0
  800182:	fdc50513          	addi	a0,a0,-36 # 80015a <cputch>
  800186:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  80018a:	ec06                	sd	ra,24(sp)
  80018c:	c602                	sw	zero,12(sp)
  80018e:	19a000ef          	jal	ra,800328 <vprintfmt>
  800192:	60e2                	ld	ra,24(sp)
  800194:	4532                	lw	a0,12(sp)
  800196:	6105                	addi	sp,sp,32
  800198:	8082                	ret

000000000080019a <cprintf>:
  80019a:	711d                	addi	sp,sp,-96
  80019c:	02810313          	addi	t1,sp,40
  8001a0:	f42e                	sd	a1,40(sp)
  8001a2:	75dd                	lui	a1,0xffff7
  8001a4:	f832                	sd	a2,48(sp)
  8001a6:	fc36                	sd	a3,56(sp)
  8001a8:	e0ba                	sd	a4,64(sp)
  8001aa:	86aa                	mv	a3,a0
  8001ac:	0050                	addi	a2,sp,4
  8001ae:	00000517          	auipc	a0,0x0
  8001b2:	fac50513          	addi	a0,a0,-84 # 80015a <cputch>
  8001b6:	871a                	mv	a4,t1
  8001b8:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <error_string+0xffffffffff7f6101>
  8001bc:	ec06                	sd	ra,24(sp)
  8001be:	e4be                	sd	a5,72(sp)
  8001c0:	e8c2                	sd	a6,80(sp)
  8001c2:	ecc6                	sd	a7,88(sp)
  8001c4:	e41a                	sd	t1,8(sp)
  8001c6:	c202                	sw	zero,4(sp)
  8001c8:	160000ef          	jal	ra,800328 <vprintfmt>
  8001cc:	60e2                	ld	ra,24(sp)
  8001ce:	4512                	lw	a0,4(sp)
  8001d0:	6125                	addi	sp,sp,96
  8001d2:	8082                	ret

00000000008001d4 <initfd>:
  8001d4:	1101                	addi	sp,sp,-32
  8001d6:	87ae                	mv	a5,a1
  8001d8:	e426                	sd	s1,8(sp)
  8001da:	85b2                	mv	a1,a2
  8001dc:	84aa                	mv	s1,a0
  8001de:	853e                	mv	a0,a5
  8001e0:	e822                	sd	s0,16(sp)
  8001e2:	ec06                	sd	ra,24(sp)
  8001e4:	f67ff0ef          	jal	ra,80014a <open>
  8001e8:	842a                	mv	s0,a0
  8001ea:	00054463          	bltz	a0,8001f2 <initfd+0x1e>
  8001ee:	00951863          	bne	a0,s1,8001fe <initfd+0x2a>
  8001f2:	8522                	mv	a0,s0
  8001f4:	60e2                	ld	ra,24(sp)
  8001f6:	6442                	ld	s0,16(sp)
  8001f8:	64a2                	ld	s1,8(sp)
  8001fa:	6105                	addi	sp,sp,32
  8001fc:	8082                	ret
  8001fe:	8526                	mv	a0,s1
  800200:	f53ff0ef          	jal	ra,800152 <close>
  800204:	85a6                	mv	a1,s1
  800206:	8522                	mv	a0,s0
  800208:	f4fff0ef          	jal	ra,800156 <dup2>
  80020c:	84aa                	mv	s1,a0
  80020e:	8522                	mv	a0,s0
  800210:	f43ff0ef          	jal	ra,800152 <close>
  800214:	8426                	mv	s0,s1
  800216:	bff1                	j	8001f2 <initfd+0x1e>

0000000000800218 <umain>:
  800218:	1101                	addi	sp,sp,-32
  80021a:	e822                	sd	s0,16(sp)
  80021c:	e426                	sd	s1,8(sp)
  80021e:	842a                	mv	s0,a0
  800220:	84ae                	mv	s1,a1
  800222:	4601                	li	a2,0
  800224:	00000597          	auipc	a1,0x0
  800228:	5f458593          	addi	a1,a1,1524 # 800818 <main+0x144>
  80022c:	4501                	li	a0,0
  80022e:	ec06                	sd	ra,24(sp)
  800230:	fa5ff0ef          	jal	ra,8001d4 <initfd>
  800234:	02054263          	bltz	a0,800258 <umain+0x40>
  800238:	4605                	li	a2,1
  80023a:	00000597          	auipc	a1,0x0
  80023e:	61e58593          	addi	a1,a1,1566 # 800858 <main+0x184>
  800242:	4505                	li	a0,1
  800244:	f91ff0ef          	jal	ra,8001d4 <initfd>
  800248:	02054563          	bltz	a0,800272 <umain+0x5a>
  80024c:	85a6                	mv	a1,s1
  80024e:	8522                	mv	a0,s0
  800250:	484000ef          	jal	ra,8006d4 <main>
  800254:	ecfff0ef          	jal	ra,800122 <exit>
  800258:	86aa                	mv	a3,a0
  80025a:	00000617          	auipc	a2,0x0
  80025e:	5c660613          	addi	a2,a2,1478 # 800820 <main+0x14c>
  800262:	45e9                	li	a1,26
  800264:	00000517          	auipc	a0,0x0
  800268:	5dc50513          	addi	a0,a0,1500 # 800840 <main+0x16c>
  80026c:	df5ff0ef          	jal	ra,800060 <__warn>
  800270:	b7e1                	j	800238 <umain+0x20>
  800272:	86aa                	mv	a3,a0
  800274:	00000617          	auipc	a2,0x0
  800278:	5ec60613          	addi	a2,a2,1516 # 800860 <main+0x18c>
  80027c:	45f5                	li	a1,29
  80027e:	00000517          	auipc	a0,0x0
  800282:	5c250513          	addi	a0,a0,1474 # 800840 <main+0x16c>
  800286:	ddbff0ef          	jal	ra,800060 <__warn>
  80028a:	b7c9                	j	80024c <umain+0x34>

000000000080028c <strnlen>:
  80028c:	c185                	beqz	a1,8002ac <strnlen+0x20>
  80028e:	00054783          	lbu	a5,0(a0)
  800292:	cf89                	beqz	a5,8002ac <strnlen+0x20>
  800294:	4781                	li	a5,0
  800296:	a021                	j	80029e <strnlen+0x12>
  800298:	00074703          	lbu	a4,0(a4)
  80029c:	c711                	beqz	a4,8002a8 <strnlen+0x1c>
  80029e:	0785                	addi	a5,a5,1
  8002a0:	00f50733          	add	a4,a0,a5
  8002a4:	fef59ae3          	bne	a1,a5,800298 <strnlen+0xc>
  8002a8:	853e                	mv	a0,a5
  8002aa:	8082                	ret
  8002ac:	4781                	li	a5,0
  8002ae:	853e                	mv	a0,a5
  8002b0:	8082                	ret

00000000008002b2 <printnum>:
  8002b2:	02071893          	slli	a7,a4,0x20
  8002b6:	7139                	addi	sp,sp,-64
  8002b8:	0208d893          	srli	a7,a7,0x20
  8002bc:	e456                	sd	s5,8(sp)
  8002be:	0316fab3          	remu	s5,a3,a7
  8002c2:	f822                	sd	s0,48(sp)
  8002c4:	f426                	sd	s1,40(sp)
  8002c6:	f04a                	sd	s2,32(sp)
  8002c8:	ec4e                	sd	s3,24(sp)
  8002ca:	fc06                	sd	ra,56(sp)
  8002cc:	e852                	sd	s4,16(sp)
  8002ce:	84aa                	mv	s1,a0
  8002d0:	89ae                	mv	s3,a1
  8002d2:	8932                	mv	s2,a2
  8002d4:	fff7841b          	addiw	s0,a5,-1
  8002d8:	2a81                	sext.w	s5,s5
  8002da:	0516f163          	bleu	a7,a3,80031c <printnum+0x6a>
  8002de:	8a42                	mv	s4,a6
  8002e0:	00805863          	blez	s0,8002f0 <printnum+0x3e>
  8002e4:	347d                	addiw	s0,s0,-1
  8002e6:	864e                	mv	a2,s3
  8002e8:	85ca                	mv	a1,s2
  8002ea:	8552                	mv	a0,s4
  8002ec:	9482                	jalr	s1
  8002ee:	f87d                	bnez	s0,8002e4 <printnum+0x32>
  8002f0:	1a82                	slli	s5,s5,0x20
  8002f2:	020ada93          	srli	s5,s5,0x20
  8002f6:	00000797          	auipc	a5,0x0
  8002fa:	7aa78793          	addi	a5,a5,1962 # 800aa0 <error_string+0xc8>
  8002fe:	9abe                	add	s5,s5,a5
  800300:	7442                	ld	s0,48(sp)
  800302:	000ac503          	lbu	a0,0(s5)
  800306:	70e2                	ld	ra,56(sp)
  800308:	6a42                	ld	s4,16(sp)
  80030a:	6aa2                	ld	s5,8(sp)
  80030c:	864e                	mv	a2,s3
  80030e:	85ca                	mv	a1,s2
  800310:	69e2                	ld	s3,24(sp)
  800312:	7902                	ld	s2,32(sp)
  800314:	8326                	mv	t1,s1
  800316:	74a2                	ld	s1,40(sp)
  800318:	6121                	addi	sp,sp,64
  80031a:	8302                	jr	t1
  80031c:	0316d6b3          	divu	a3,a3,a7
  800320:	87a2                	mv	a5,s0
  800322:	f91ff0ef          	jal	ra,8002b2 <printnum>
  800326:	b7e9                	j	8002f0 <printnum+0x3e>

0000000000800328 <vprintfmt>:
  800328:	7119                	addi	sp,sp,-128
  80032a:	f4a6                	sd	s1,104(sp)
  80032c:	f0ca                	sd	s2,96(sp)
  80032e:	ecce                	sd	s3,88(sp)
  800330:	e4d6                	sd	s5,72(sp)
  800332:	e0da                	sd	s6,64(sp)
  800334:	fc5e                	sd	s7,56(sp)
  800336:	f862                	sd	s8,48(sp)
  800338:	ec6e                	sd	s11,24(sp)
  80033a:	fc86                	sd	ra,120(sp)
  80033c:	f8a2                	sd	s0,112(sp)
  80033e:	e8d2                	sd	s4,80(sp)
  800340:	f466                	sd	s9,40(sp)
  800342:	f06a                	sd	s10,32(sp)
  800344:	89aa                	mv	s3,a0
  800346:	892e                	mv	s2,a1
  800348:	84b2                	mv	s1,a2
  80034a:	8db6                	mv	s11,a3
  80034c:	8b3a                	mv	s6,a4
  80034e:	5bfd                	li	s7,-1
  800350:	00000a97          	auipc	s5,0x0
  800354:	52ca8a93          	addi	s5,s5,1324 # 80087c <main+0x1a8>
  800358:	05e00c13          	li	s8,94
  80035c:	000dc503          	lbu	a0,0(s11)
  800360:	02500793          	li	a5,37
  800364:	001d8413          	addi	s0,s11,1
  800368:	00f50f63          	beq	a0,a5,800386 <vprintfmt+0x5e>
  80036c:	c529                	beqz	a0,8003b6 <vprintfmt+0x8e>
  80036e:	02500a13          	li	s4,37
  800372:	a011                	j	800376 <vprintfmt+0x4e>
  800374:	c129                	beqz	a0,8003b6 <vprintfmt+0x8e>
  800376:	864a                	mv	a2,s2
  800378:	85a6                	mv	a1,s1
  80037a:	0405                	addi	s0,s0,1
  80037c:	9982                	jalr	s3
  80037e:	fff44503          	lbu	a0,-1(s0)
  800382:	ff4519e3          	bne	a0,s4,800374 <vprintfmt+0x4c>
  800386:	00044603          	lbu	a2,0(s0)
  80038a:	02000813          	li	a6,32
  80038e:	4a01                	li	s4,0
  800390:	4881                	li	a7,0
  800392:	5d7d                	li	s10,-1
  800394:	5cfd                	li	s9,-1
  800396:	05500593          	li	a1,85
  80039a:	4525                	li	a0,9
  80039c:	fdd6071b          	addiw	a4,a2,-35
  8003a0:	0ff77713          	andi	a4,a4,255
  8003a4:	00140d93          	addi	s11,s0,1
  8003a8:	22e5e363          	bltu	a1,a4,8005ce <vprintfmt+0x2a6>
  8003ac:	070a                	slli	a4,a4,0x2
  8003ae:	9756                	add	a4,a4,s5
  8003b0:	4318                	lw	a4,0(a4)
  8003b2:	9756                	add	a4,a4,s5
  8003b4:	8702                	jr	a4
  8003b6:	70e6                	ld	ra,120(sp)
  8003b8:	7446                	ld	s0,112(sp)
  8003ba:	74a6                	ld	s1,104(sp)
  8003bc:	7906                	ld	s2,96(sp)
  8003be:	69e6                	ld	s3,88(sp)
  8003c0:	6a46                	ld	s4,80(sp)
  8003c2:	6aa6                	ld	s5,72(sp)
  8003c4:	6b06                	ld	s6,64(sp)
  8003c6:	7be2                	ld	s7,56(sp)
  8003c8:	7c42                	ld	s8,48(sp)
  8003ca:	7ca2                	ld	s9,40(sp)
  8003cc:	7d02                	ld	s10,32(sp)
  8003ce:	6de2                	ld	s11,24(sp)
  8003d0:	6109                	addi	sp,sp,128
  8003d2:	8082                	ret
  8003d4:	4705                	li	a4,1
  8003d6:	008b0613          	addi	a2,s6,8
  8003da:	01174463          	blt	a4,a7,8003e2 <vprintfmt+0xba>
  8003de:	28088563          	beqz	a7,800668 <vprintfmt+0x340>
  8003e2:	000b3683          	ld	a3,0(s6)
  8003e6:	4741                	li	a4,16
  8003e8:	8b32                	mv	s6,a2
  8003ea:	a86d                	j	8004a4 <vprintfmt+0x17c>
  8003ec:	00144603          	lbu	a2,1(s0)
  8003f0:	4a05                	li	s4,1
  8003f2:	846e                	mv	s0,s11
  8003f4:	b765                	j	80039c <vprintfmt+0x74>
  8003f6:	000b2503          	lw	a0,0(s6)
  8003fa:	864a                	mv	a2,s2
  8003fc:	85a6                	mv	a1,s1
  8003fe:	0b21                	addi	s6,s6,8
  800400:	9982                	jalr	s3
  800402:	bfa9                	j	80035c <vprintfmt+0x34>
  800404:	4705                	li	a4,1
  800406:	008b0a13          	addi	s4,s6,8
  80040a:	01174463          	blt	a4,a7,800412 <vprintfmt+0xea>
  80040e:	24088563          	beqz	a7,800658 <vprintfmt+0x330>
  800412:	000b3403          	ld	s0,0(s6)
  800416:	26044563          	bltz	s0,800680 <vprintfmt+0x358>
  80041a:	86a2                	mv	a3,s0
  80041c:	8b52                	mv	s6,s4
  80041e:	4729                	li	a4,10
  800420:	a051                	j	8004a4 <vprintfmt+0x17c>
  800422:	000b2783          	lw	a5,0(s6)
  800426:	46e1                	li	a3,24
  800428:	0b21                	addi	s6,s6,8
  80042a:	41f7d71b          	sraiw	a4,a5,0x1f
  80042e:	8fb9                	xor	a5,a5,a4
  800430:	40e7873b          	subw	a4,a5,a4
  800434:	1ce6c163          	blt	a3,a4,8005f6 <vprintfmt+0x2ce>
  800438:	00371793          	slli	a5,a4,0x3
  80043c:	00000697          	auipc	a3,0x0
  800440:	59c68693          	addi	a3,a3,1436 # 8009d8 <error_string>
  800444:	97b6                	add	a5,a5,a3
  800446:	639c                	ld	a5,0(a5)
  800448:	1a078763          	beqz	a5,8005f6 <vprintfmt+0x2ce>
  80044c:	873e                	mv	a4,a5
  80044e:	00001697          	auipc	a3,0x1
  800452:	85a68693          	addi	a3,a3,-1958 # 800ca8 <error_string+0x2d0>
  800456:	8626                	mv	a2,s1
  800458:	85ca                	mv	a1,s2
  80045a:	854e                	mv	a0,s3
  80045c:	25a000ef          	jal	ra,8006b6 <printfmt>
  800460:	bdf5                	j	80035c <vprintfmt+0x34>
  800462:	00144603          	lbu	a2,1(s0)
  800466:	2885                	addiw	a7,a7,1
  800468:	846e                	mv	s0,s11
  80046a:	bf0d                	j	80039c <vprintfmt+0x74>
  80046c:	4705                	li	a4,1
  80046e:	008b0613          	addi	a2,s6,8
  800472:	01174463          	blt	a4,a7,80047a <vprintfmt+0x152>
  800476:	1e088e63          	beqz	a7,800672 <vprintfmt+0x34a>
  80047a:	000b3683          	ld	a3,0(s6)
  80047e:	4721                	li	a4,8
  800480:	8b32                	mv	s6,a2
  800482:	a00d                	j	8004a4 <vprintfmt+0x17c>
  800484:	03000513          	li	a0,48
  800488:	864a                	mv	a2,s2
  80048a:	85a6                	mv	a1,s1
  80048c:	e042                	sd	a6,0(sp)
  80048e:	9982                	jalr	s3
  800490:	864a                	mv	a2,s2
  800492:	85a6                	mv	a1,s1
  800494:	07800513          	li	a0,120
  800498:	9982                	jalr	s3
  80049a:	0b21                	addi	s6,s6,8
  80049c:	ff8b3683          	ld	a3,-8(s6)
  8004a0:	6802                	ld	a6,0(sp)
  8004a2:	4741                	li	a4,16
  8004a4:	87e6                	mv	a5,s9
  8004a6:	8626                	mv	a2,s1
  8004a8:	85ca                	mv	a1,s2
  8004aa:	854e                	mv	a0,s3
  8004ac:	e07ff0ef          	jal	ra,8002b2 <printnum>
  8004b0:	b575                	j	80035c <vprintfmt+0x34>
  8004b2:	000b3703          	ld	a4,0(s6)
  8004b6:	0b21                	addi	s6,s6,8
  8004b8:	1e070063          	beqz	a4,800698 <vprintfmt+0x370>
  8004bc:	00170413          	addi	s0,a4,1
  8004c0:	19905563          	blez	s9,80064a <vprintfmt+0x322>
  8004c4:	02d00613          	li	a2,45
  8004c8:	14c81963          	bne	a6,a2,80061a <vprintfmt+0x2f2>
  8004cc:	00074703          	lbu	a4,0(a4)
  8004d0:	0007051b          	sext.w	a0,a4
  8004d4:	c90d                	beqz	a0,800506 <vprintfmt+0x1de>
  8004d6:	000d4563          	bltz	s10,8004e0 <vprintfmt+0x1b8>
  8004da:	3d7d                	addiw	s10,s10,-1
  8004dc:	037d0363          	beq	s10,s7,800502 <vprintfmt+0x1da>
  8004e0:	864a                	mv	a2,s2
  8004e2:	85a6                	mv	a1,s1
  8004e4:	180a0c63          	beqz	s4,80067c <vprintfmt+0x354>
  8004e8:	3701                	addiw	a4,a4,-32
  8004ea:	18ec7963          	bleu	a4,s8,80067c <vprintfmt+0x354>
  8004ee:	03f00513          	li	a0,63
  8004f2:	9982                	jalr	s3
  8004f4:	0405                	addi	s0,s0,1
  8004f6:	fff44703          	lbu	a4,-1(s0)
  8004fa:	3cfd                	addiw	s9,s9,-1
  8004fc:	0007051b          	sext.w	a0,a4
  800500:	f979                	bnez	a0,8004d6 <vprintfmt+0x1ae>
  800502:	e5905de3          	blez	s9,80035c <vprintfmt+0x34>
  800506:	3cfd                	addiw	s9,s9,-1
  800508:	864a                	mv	a2,s2
  80050a:	85a6                	mv	a1,s1
  80050c:	02000513          	li	a0,32
  800510:	9982                	jalr	s3
  800512:	e40c85e3          	beqz	s9,80035c <vprintfmt+0x34>
  800516:	3cfd                	addiw	s9,s9,-1
  800518:	864a                	mv	a2,s2
  80051a:	85a6                	mv	a1,s1
  80051c:	02000513          	li	a0,32
  800520:	9982                	jalr	s3
  800522:	fe0c92e3          	bnez	s9,800506 <vprintfmt+0x1de>
  800526:	bd1d                	j	80035c <vprintfmt+0x34>
  800528:	4705                	li	a4,1
  80052a:	008b0613          	addi	a2,s6,8
  80052e:	01174463          	blt	a4,a7,800536 <vprintfmt+0x20e>
  800532:	12088663          	beqz	a7,80065e <vprintfmt+0x336>
  800536:	000b3683          	ld	a3,0(s6)
  80053a:	4729                	li	a4,10
  80053c:	8b32                	mv	s6,a2
  80053e:	b79d                	j	8004a4 <vprintfmt+0x17c>
  800540:	00144603          	lbu	a2,1(s0)
  800544:	02d00813          	li	a6,45
  800548:	846e                	mv	s0,s11
  80054a:	bd89                	j	80039c <vprintfmt+0x74>
  80054c:	864a                	mv	a2,s2
  80054e:	85a6                	mv	a1,s1
  800550:	02500513          	li	a0,37
  800554:	9982                	jalr	s3
  800556:	b519                	j	80035c <vprintfmt+0x34>
  800558:	000b2d03          	lw	s10,0(s6)
  80055c:	00144603          	lbu	a2,1(s0)
  800560:	0b21                	addi	s6,s6,8
  800562:	846e                	mv	s0,s11
  800564:	e20cdce3          	bgez	s9,80039c <vprintfmt+0x74>
  800568:	8cea                	mv	s9,s10
  80056a:	5d7d                	li	s10,-1
  80056c:	bd05                	j	80039c <vprintfmt+0x74>
  80056e:	00144603          	lbu	a2,1(s0)
  800572:	03000813          	li	a6,48
  800576:	846e                	mv	s0,s11
  800578:	b515                	j	80039c <vprintfmt+0x74>
  80057a:	fd060d1b          	addiw	s10,a2,-48
  80057e:	00144603          	lbu	a2,1(s0)
  800582:	846e                	mv	s0,s11
  800584:	fd06071b          	addiw	a4,a2,-48
  800588:	0006031b          	sext.w	t1,a2
  80058c:	fce56ce3          	bltu	a0,a4,800564 <vprintfmt+0x23c>
  800590:	0405                	addi	s0,s0,1
  800592:	002d171b          	slliw	a4,s10,0x2
  800596:	00044603          	lbu	a2,0(s0)
  80059a:	01a706bb          	addw	a3,a4,s10
  80059e:	0016969b          	slliw	a3,a3,0x1
  8005a2:	006686bb          	addw	a3,a3,t1
  8005a6:	fd06071b          	addiw	a4,a2,-48
  8005aa:	fd068d1b          	addiw	s10,a3,-48
  8005ae:	0006031b          	sext.w	t1,a2
  8005b2:	fce57fe3          	bleu	a4,a0,800590 <vprintfmt+0x268>
  8005b6:	b77d                	j	800564 <vprintfmt+0x23c>
  8005b8:	fffcc713          	not	a4,s9
  8005bc:	977d                	srai	a4,a4,0x3f
  8005be:	00ecf7b3          	and	a5,s9,a4
  8005c2:	00144603          	lbu	a2,1(s0)
  8005c6:	00078c9b          	sext.w	s9,a5
  8005ca:	846e                	mv	s0,s11
  8005cc:	bbc1                	j	80039c <vprintfmt+0x74>
  8005ce:	864a                	mv	a2,s2
  8005d0:	85a6                	mv	a1,s1
  8005d2:	02500513          	li	a0,37
  8005d6:	9982                	jalr	s3
  8005d8:	fff44703          	lbu	a4,-1(s0)
  8005dc:	02500793          	li	a5,37
  8005e0:	8da2                	mv	s11,s0
  8005e2:	d6f70de3          	beq	a4,a5,80035c <vprintfmt+0x34>
  8005e6:	02500713          	li	a4,37
  8005ea:	1dfd                	addi	s11,s11,-1
  8005ec:	fffdc783          	lbu	a5,-1(s11)
  8005f0:	fee79de3          	bne	a5,a4,8005ea <vprintfmt+0x2c2>
  8005f4:	b3a5                	j	80035c <vprintfmt+0x34>
  8005f6:	00000697          	auipc	a3,0x0
  8005fa:	6a268693          	addi	a3,a3,1698 # 800c98 <error_string+0x2c0>
  8005fe:	8626                	mv	a2,s1
  800600:	85ca                	mv	a1,s2
  800602:	854e                	mv	a0,s3
  800604:	0b2000ef          	jal	ra,8006b6 <printfmt>
  800608:	bb91                	j	80035c <vprintfmt+0x34>
  80060a:	00000717          	auipc	a4,0x0
  80060e:	68670713          	addi	a4,a4,1670 # 800c90 <error_string+0x2b8>
  800612:	00000417          	auipc	s0,0x0
  800616:	67f40413          	addi	s0,s0,1663 # 800c91 <error_string+0x2b9>
  80061a:	853a                	mv	a0,a4
  80061c:	85ea                	mv	a1,s10
  80061e:	e03a                	sd	a4,0(sp)
  800620:	e442                	sd	a6,8(sp)
  800622:	c6bff0ef          	jal	ra,80028c <strnlen>
  800626:	40ac8cbb          	subw	s9,s9,a0
  80062a:	6702                	ld	a4,0(sp)
  80062c:	01905f63          	blez	s9,80064a <vprintfmt+0x322>
  800630:	6822                	ld	a6,8(sp)
  800632:	0008079b          	sext.w	a5,a6
  800636:	e43e                	sd	a5,8(sp)
  800638:	6522                	ld	a0,8(sp)
  80063a:	864a                	mv	a2,s2
  80063c:	85a6                	mv	a1,s1
  80063e:	e03a                	sd	a4,0(sp)
  800640:	3cfd                	addiw	s9,s9,-1
  800642:	9982                	jalr	s3
  800644:	6702                	ld	a4,0(sp)
  800646:	fe0c99e3          	bnez	s9,800638 <vprintfmt+0x310>
  80064a:	00074703          	lbu	a4,0(a4)
  80064e:	0007051b          	sext.w	a0,a4
  800652:	e80512e3          	bnez	a0,8004d6 <vprintfmt+0x1ae>
  800656:	b319                	j	80035c <vprintfmt+0x34>
  800658:	000b2403          	lw	s0,0(s6)
  80065c:	bb6d                	j	800416 <vprintfmt+0xee>
  80065e:	000b6683          	lwu	a3,0(s6)
  800662:	4729                	li	a4,10
  800664:	8b32                	mv	s6,a2
  800666:	bd3d                	j	8004a4 <vprintfmt+0x17c>
  800668:	000b6683          	lwu	a3,0(s6)
  80066c:	4741                	li	a4,16
  80066e:	8b32                	mv	s6,a2
  800670:	bd15                	j	8004a4 <vprintfmt+0x17c>
  800672:	000b6683          	lwu	a3,0(s6)
  800676:	4721                	li	a4,8
  800678:	8b32                	mv	s6,a2
  80067a:	b52d                	j	8004a4 <vprintfmt+0x17c>
  80067c:	9982                	jalr	s3
  80067e:	bd9d                	j	8004f4 <vprintfmt+0x1cc>
  800680:	864a                	mv	a2,s2
  800682:	85a6                	mv	a1,s1
  800684:	02d00513          	li	a0,45
  800688:	e042                	sd	a6,0(sp)
  80068a:	9982                	jalr	s3
  80068c:	8b52                	mv	s6,s4
  80068e:	408006b3          	neg	a3,s0
  800692:	4729                	li	a4,10
  800694:	6802                	ld	a6,0(sp)
  800696:	b539                	j	8004a4 <vprintfmt+0x17c>
  800698:	01905663          	blez	s9,8006a4 <vprintfmt+0x37c>
  80069c:	02d00713          	li	a4,45
  8006a0:	f6e815e3          	bne	a6,a4,80060a <vprintfmt+0x2e2>
  8006a4:	00000417          	auipc	s0,0x0
  8006a8:	5ed40413          	addi	s0,s0,1517 # 800c91 <error_string+0x2b9>
  8006ac:	02800513          	li	a0,40
  8006b0:	02800713          	li	a4,40
  8006b4:	b50d                	j	8004d6 <vprintfmt+0x1ae>

00000000008006b6 <printfmt>:
  8006b6:	7139                	addi	sp,sp,-64
  8006b8:	02010313          	addi	t1,sp,32
  8006bc:	f03a                	sd	a4,32(sp)
  8006be:	871a                	mv	a4,t1
  8006c0:	ec06                	sd	ra,24(sp)
  8006c2:	f43e                	sd	a5,40(sp)
  8006c4:	f842                	sd	a6,48(sp)
  8006c6:	fc46                	sd	a7,56(sp)
  8006c8:	e41a                	sd	t1,8(sp)
  8006ca:	c5fff0ef          	jal	ra,800328 <vprintfmt>
  8006ce:	60e2                	ld	ra,24(sp)
  8006d0:	6121                	addi	sp,sp,64
  8006d2:	8082                	ret

00000000008006d4 <main>:
  8006d4:	1101                	addi	sp,sp,-32
  8006d6:	ec06                	sd	ra,24(sp)
  8006d8:	e822                	sd	s0,16(sp)
  8006da:	a5fff0ef          	jal	ra,800138 <fork>
  8006de:	c169                	beqz	a0,8007a0 <main+0xcc>
  8006e0:	842a                	mv	s0,a0
  8006e2:	0aa05063          	blez	a0,800782 <main+0xae>
  8006e6:	4581                	li	a1,0
  8006e8:	557d                	li	a0,-1
  8006ea:	a53ff0ef          	jal	ra,80013c <waitpid>
  8006ee:	c93d                	beqz	a0,800764 <main+0x90>
  8006f0:	458d                	li	a1,3
  8006f2:	05fa                	slli	a1,a1,0x1e
  8006f4:	8522                	mv	a0,s0
  8006f6:	a47ff0ef          	jal	ra,80013c <waitpid>
  8006fa:	c531                	beqz	a0,800746 <main+0x72>
  8006fc:	006c                	addi	a1,sp,12
  8006fe:	8522                	mv	a0,s0
  800700:	a3dff0ef          	jal	ra,80013c <waitpid>
  800704:	e115                	bnez	a0,800728 <main+0x54>
  800706:	4732                	lw	a4,12(sp)
  800708:	67b1                	lui	a5,0xc
  80070a:	eaf78793          	addi	a5,a5,-337 # beaf <__panic-0x7f4171>
  80070e:	00f71d63          	bne	a4,a5,800728 <main+0x54>
  800712:	00000517          	auipc	a0,0x0
  800716:	65650513          	addi	a0,a0,1622 # 800d68 <error_string+0x390>
  80071a:	a81ff0ef          	jal	ra,80019a <cprintf>
  80071e:	60e2                	ld	ra,24(sp)
  800720:	6442                	ld	s0,16(sp)
  800722:	4501                	li	a0,0
  800724:	6105                	addi	sp,sp,32
  800726:	8082                	ret
  800728:	00000697          	auipc	a3,0x0
  80072c:	60868693          	addi	a3,a3,1544 # 800d30 <error_string+0x358>
  800730:	00000617          	auipc	a2,0x0
  800734:	59860613          	addi	a2,a2,1432 # 800cc8 <error_string+0x2f0>
  800738:	45c9                	li	a1,18
  80073a:	00000517          	auipc	a0,0x0
  80073e:	5a650513          	addi	a0,a0,1446 # 800ce0 <error_string+0x308>
  800742:	8dfff0ef          	jal	ra,800020 <__panic>
  800746:	00000697          	auipc	a3,0x0
  80074a:	5c268693          	addi	a3,a3,1474 # 800d08 <error_string+0x330>
  80074e:	00000617          	auipc	a2,0x0
  800752:	57a60613          	addi	a2,a2,1402 # 800cc8 <error_string+0x2f0>
  800756:	45c5                	li	a1,17
  800758:	00000517          	auipc	a0,0x0
  80075c:	58850513          	addi	a0,a0,1416 # 800ce0 <error_string+0x308>
  800760:	8c1ff0ef          	jal	ra,800020 <__panic>
  800764:	00000697          	auipc	a3,0x0
  800768:	58c68693          	addi	a3,a3,1420 # 800cf0 <error_string+0x318>
  80076c:	00000617          	auipc	a2,0x0
  800770:	55c60613          	addi	a2,a2,1372 # 800cc8 <error_string+0x2f0>
  800774:	45c1                	li	a1,16
  800776:	00000517          	auipc	a0,0x0
  80077a:	56a50513          	addi	a0,a0,1386 # 800ce0 <error_string+0x308>
  80077e:	8a3ff0ef          	jal	ra,800020 <__panic>
  800782:	00000697          	auipc	a3,0x0
  800786:	53e68693          	addi	a3,a3,1342 # 800cc0 <error_string+0x2e8>
  80078a:	00000617          	auipc	a2,0x0
  80078e:	53e60613          	addi	a2,a2,1342 # 800cc8 <error_string+0x2f0>
  800792:	45bd                	li	a1,15
  800794:	00000517          	auipc	a0,0x0
  800798:	54c50513          	addi	a0,a0,1356 # 800ce0 <error_string+0x308>
  80079c:	885ff0ef          	jal	ra,800020 <__panic>
  8007a0:	00000517          	auipc	a0,0x0
  8007a4:	51050513          	addi	a0,a0,1296 # 800cb0 <error_string+0x2d8>
  8007a8:	9f3ff0ef          	jal	ra,80019a <cprintf>
  8007ac:	4429                	li	s0,10
  8007ae:	347d                	addiw	s0,s0,-1
  8007b0:	991ff0ef          	jal	ra,800140 <yield>
  8007b4:	fc6d                	bnez	s0,8007ae <main+0xda>
  8007b6:	6531                	lui	a0,0xc
  8007b8:	eaf50513          	addi	a0,a0,-337 # beaf <__panic-0x7f4171>
  8007bc:	967ff0ef          	jal	ra,800122 <exit>
