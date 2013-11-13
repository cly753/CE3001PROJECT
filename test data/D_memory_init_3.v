// EXEC
// 0
// 7
// 10
// 20
// // EXEC to EXEC
// 0
// 7
// 10
// 20
// 6
// // JR
// 0
// 7
// 10
// 20
// // JAL
// 0
// 7
// 10
// 20
// // cannot write to R15
// 0
// 10
// 20
// // BEQ
// 0
// 10
// 10
// 20
// // BEQ false
// 0
// 10
// 11
// 20
// // data hazard: one/two clock cycle behind (LW)
// 0
// 10
// 20
// // data hazard: three clock cycle behind (LW)
// 0
// 10
// 20
// // data hazard: one/two clock cycle behind (non-LW)
// 0
// 10
// 20
// // functional test
// 0
// 10
// 20
// -2
// // LHB LLB
// 0000000000000000
// 1010101010101010
// LW SW
// 0
// 10
