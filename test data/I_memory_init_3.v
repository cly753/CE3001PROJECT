// EXEC
8101
8202
8303
f100
0423
0523
0623
0723
// order: 7 4 5 6 7
//
// EXEC to EXEC
8101
8202
8303
f100
0423
0523
0623
f400
// order: 4 5 6
//
// JR
8101
8202
8303
e100
0423
0523
0623
0723
// order: 7
//
// JAL
8101
8202
8303
d003
0423
0523
0623
0723
// order: 7, R15 = 4
//
// cannot write to R15
8101
8202
0f12
// result: R15 = 0
//
// BEQ
8101
8202
8303
1112
c003
0423
0523
0623
0723
// order: 7
//
// BEQ false
8101
8202
8303
1112
c003
0423
0523
0623
0723
// order: 4 5 6 7 

//
// data hazard: one/two clock cycle behind (LW)
8101
8202
0312
// result: R3 = 30
//
// data hazard: three clock cycle behind (LW)
8101
8202
0000
0312
// result: R3 = 30
//
// data hazard: one/two clock cycle behind (non-LW)
8101
8202
0312
0413
// result: R4 = 40
//
// functional test
8101
8202
8303
0412
1512
2612
3712
4834
5934
6a34
7b34
// result:
//
// LHB LLB
8101
8202
a3f0
b4f0
// order: 4 5
//
// LW SW
8101
9102
8202
9203
// order: R1 M2 R2 M3