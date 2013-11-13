`include "define.v"

module LXBunit (input [15:0] dataRd, input [7:0] imm, input clk, input lhb,
  output reg [15:0] out);
  
always @(posedge clk)begin
    if (lhb) begin
        out <= {imm, dataRd[7:0]};
    end else begin
        out <= $signed(imm);
    end
end

endmodule