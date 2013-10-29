`include "define.v"

module alu (
	input [`DSIZE-1:0] A, B,
	input [2:0] op,
	input [3:0] imm,
	input clk,
	output reg [`DSIZE-1:0] Out);

wire [`DSIZE-1:0] tempOut;
wire z, v, n;
reg [2:0] flag; // [Z, V, N]

assign z = tempOut==16'd0?1:0;
assign v = op == 3'b000 || op == 3'b001?~A[16]^B[16]^tempOut:0;
assign n = op == 3'b000 || op == 3'b001?tempOut[16]&~v;

always @(*) begin
	case (op)
		`ADD: tempOut = A + B;
		`SUB: tempOut = A - B;
		`AND: tempOut = A & B;
		`OR : tempOut = A | B;
		`SLL: tempOut = A << imm;
		`RL : tempOut = A << imm | A >> 16-imm;
		`SRL: tempOut = A >> imm;
		`SRA: tempOut = $signed(A) >>> imm;
	endcase
end

always @(posedge clk) begin
	Out <= tempOut;
	
	if (op != 3'b100 && op != 3'b101 && op != 3'b110 && op != 3'b111) begin
		flag[0] <= z;
		flag[1] <= v
		flag[2] <= n;
	end
end

endmodule
