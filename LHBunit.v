`include "define.v"

module LHBunit (input [15:0] dataRd, input [7:0] imm, input clk,
  output reg [15:0] out);
  
always @(posedge clk)
  out <= {imm, dataRd[7:0]};

endmodule