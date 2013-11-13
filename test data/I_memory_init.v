// This file is used to initialize I_memory
//
// Assembly
// LW	R4, mem[R0+4]
// LW	R5, mem[R0+5]
// LW	R1, mem[R0+0]	// load 0 
// LW	R2, mem[R0+1]	// load 1
// ADD	R3, R1, R2	// additon
// SW	R2, mem[R0+2]	// store the 2nd operand in mem[2]
// SW	R3, mem[R0+3]	// store the addition in mem[3]
// LOOP:
// LW	R1, mem[R0+2]	// load 1st operand
// LW	R2, mem[R0+3]	// load 2nd operand
// ADD	R3, R1, R2	// additon
// SW	R2, mem[R0+2]	// store the 2nd operand in mem[2]
// SW	R3, mem[R0+3]	// store the addition in mem[3]
// SUB	R4, R4, R5
// B	EQ, (PC+1)+(-7)
// 
// Machine code in 16-bit Hex
// No-OP instruction: 0000
//
// original
// 8404
// 8505
// 8100
// 8201
// 0312
// 9202
// 9303
// 8103
// 8203
// 0312
// 9202
// 9303
// 1445
// C0F9
//
//
//
// arithmetic, shift, load/store, LLB, LHB, jump, flag, bypass
//
//
// test ADD SUB AND OR (passed)
// 0000
// 8101
// 8202
// 8303
// // data hazard
// 0000
// 0000
// 0000
// 0412
// 1512
// 2612
// 3712
// 0000
// 0000
// 0000
//
//
//
// test SLL SRL SRA RL (passed)
// 8101
// 0000
// 0000
// 0000
// 4213
// 5313
// 6413
// 7513
// 0000
// 0000
// 0000
// 0000
//
//
//
// test load/store (passed)
// 8101
// 0000
// 0000
// 0000
// 9102
// 0000
// 0000
// 0000
// 0000
//
//
//
// test LHB/LLB (passed)
// 8100
// 8201
// 0000
// 0000
// 0000
// a1ff
// b2f0
//
//
//
// test JAL (JR EXEC B) (passed)
// 8100
// 8201
// 0000
// 0000
// 0000
// d005
// 0312
// 1412
// 2512
// 3612
// 
//
//
// test JR (JAL EXEC B) (passed)
// 8100
// 8201
// 8302
// 0000
// 0000
// 0000
// e300
// 0312
// 1412
// 2512
// 3612
//
//
//
// test EXEC (JR JAL B) (passed)
// 8100
// 8201
// 8302
// 0000
// 0000
// 0000
// f300
// 0312
// 1412
// 2512
// d001
//
//
//
//
//
// test B (JR JAL EXEC)
8100
8201
8302
0000
0000
0000
1312
c703
0312
1412
2512
3612
4712
0000