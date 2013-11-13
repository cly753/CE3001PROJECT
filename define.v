`ifndef _define_
`define _define_

//
// change before informing your team-mate
//
`define ISIZE 16
`define DSIZE 16
`define RSIZE 4
`define MEM_SPACE 16
`define MAX_LINE_LENGTH 100

//
// change before informing your team-mate
//
`define ADD 4'b0000
`define SUB 4'b0001
`define AND 4'b0010
`define OR  4'b0011
`define SLL 4'b0100
`define SRL 4'b0101
`define SRA 4'b0110
`define RL  4'b0111

`define LW  4'b1000
`define SW  4'b1001
`define LHB 4'b1010
`define LLB 4'b1011
`define B   4'b1100
`define JAL 4'b1101
`define JR  4'b1110
`define EXEC 4'b1111

`define BEQ 3'b000
`define BNE 3'b001
`define BGT 3'b010
`define BLT 3'b011
`define BGE 3'b100
`define BLE 3'b101
`define BOF 3'b110
`define TRUE 3'b111

`endif