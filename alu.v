`include "define.v"

//
//
// does it need a reset??? ==============================
//
//

module alu (
	input [`DSIZE-1:0] Data1, Data2,
	input [3:0] op,
	input [3:0] imm,
	input clk,
	output reg [`DSIZE-1:0] Out,
	output reg [2:0] flag); // [Z, V, N]
  
reg [`DSIZE-1:0] tempOut;

always @(*) begin
	case (op)
		`ADD: tempOut = Data1 + Data2;
		`SUB: tempOut = Data1 - Data2;
		`AND: tempOut = Data1 & Data2;
		4'b0011 : tempOut = Data1 | Data2;
		`SLL: tempOut = Data1 << imm;
		`RL : tempOut = Data1 << imm | Data1 >> 16-imm;
		`SRL: tempOut = Data1 >> imm;
		`SRA: tempOut = $signed(Data1) >>> imm;
		`LW : tempOut = Data1 + Data2;
		`SW : tempOut = Data1 + Data2;
		`LLB: tempOut = Data1 & Data2;
	endcase
end

always @(posedge clk) begin
	Out <= tempOut;

	if(op == `ADD || op == `SUB || op == `AND || op == 4'b0011) begin
		// flag Z
		flag[2] <= (tempOut == 16'd0);
		// flag v
		flag[1] <= (op==`ADD && (Data1[15]&&Data2[15]&&~tempOut[15] || ~Data1[15]&&~Data2[15]&&tempOut[15])) 
				||(op==`SUB && (Data1[15]&&~Data2[15]&&~tempOut[15] || ~Data1[15]&&Data2[15]&&tempOut[15]));
		if(op == `ADD || op == `SUB)
			// flag N
			flag[0] <= tempOut[15]&~flag[1];
	end
end

endmodule

	//------------------------------------------------------------
	//notice:
	//when op == ADD,SUB,AND,OR, flag Z and V will be set to either 0 or 1
	//when op == ADD,SUB, flag N will be set to either 0 or 1
	//otherwise, flag maintains its value
	//
	//overflow happens when:
	//1 ADD 1 = 0 or
	//0 ADD 0 = 1 or
	//1 SUB 0 = 0 or
	//0 SUB 1 = 1 
	//* 0, 1 means the MSB of Data1, Data2, tempOut	
	//------------------------------------------------------------