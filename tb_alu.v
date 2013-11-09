`include "define.v"

module tb_alu();

reg [15:0] A, B;
reg [2:0] opcode;
reg [3:0] imm;
reg clk;

wire [15:0] out;
wire [2:0] flag;

alu uut_alu(.Data1(A), .Data2(B), .op(opcode), .imm(imm), .Out(out), .flag(flag));

always #5 clk = ~clk;

initial begin

clk = 0;


#10
$display("testing flag[2] Z");
opcode = 3'b000;
A = 16'd3;
B = 16'b1111_1111_1111_1101; // -3

#10
if (flag[2] == 1'b0 && out == 3'd0)
  $display("ADD to 0, correct");
else
  $display("ADD to 0, wrong");

opcode = 3'b001;
A = 16'b1111_1111_1111_1101;
B = 16'b1111_1111_1111_1101;

#10
if (flag[2] == 1'b0 && out == 16'd0)
  $display("SUB to 0, correct");
else
  $display("SUB to 0, wrong");

opcode = 3'b0010;
A = 16'b1010_1111_0000_0101;
B = 16'b0101_0000_1111_1010;

#10
if (flag[2] == 1'b0 && out == 16'd0)
  $display("AND to 0, correct");
else
  $display("AND to 0, wrong");
  
opcode = 3'b0011;
A = 16'b0000_0000_0000_0000;
B = 16'b0000_0000_1000_0000;

#10
if (flag[2] != 1'b0 && out != 16'd0)
  $display("OR to 0, correct");
else
  $display("OR to 0, wrong");

  
//
// not complete
//


end
endmodule
