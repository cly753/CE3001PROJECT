`include "define.v"

module Reg_File (
	input Clock, Reset, Wen,
	input [`RSIZE-1:0] RAddr1, RAddr2, WAddr,
	input [`DSIZE-1:0] WData, 
	output [`DSIZE-1:0] RData1, RData2);

reg [`DSIZE-1:0] RegFile[0:15]; // RegFile[15] is Return Address register for JAL

always@(posedge Clock) begin
	if(!Reset) begin
		RegFile[0]  <= 0;
		RegFile[1]  <= 0;
		RegFile[2]  <= 0;
		RegFile[3]  <= 0;
		RegFile[4]  <= 0;
		RegFile[5]  <= 0;
		RegFile[6]  <= 0;
		RegFile[7]  <= 0;
		RegFile[8]  <= 0;
		RegFile[9]  <= 0;
		RegFile[10]  <= 0;
		RegFile[11]  <= 0;
		RegFile[12]  <= 0;
		RegFile[13]  <= 0;
		RegFile[14]  <= 0;
		RegFile[15]  <= 0;
	end else begin
		RegFile[WAddr] <= ((Wen == 1) && (WAddr != 0)) ? WData : RegFile[WAddr];
	end
end

// assign RData1 = RegFile[RAddr1];
// assign RData2 = RegFile[RAddr2];

// bypass writing
assign RData1 = ((WAddr == RAddr1) && (WAddr != 0 && WAddr != 15)) ? WData : RegFile[RAddr1];
assign RData2 = ((WAddr == RAddr2) && (WAddr != 0 && WAddr != 15)) ? WData : RegFile[RAddr2];

endmodule
