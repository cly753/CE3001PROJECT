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
// B	NE, (PC+1)+(-7)
// 
// Machine code in 16-bit Hex
// No-OP instruction: 0000
//
8404
8505
8100
8201
0312
9202
9303
8102
8203
0312
9202
9303
1445
C1F9
