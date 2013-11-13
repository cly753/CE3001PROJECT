`include "define.v"

module hazardDetect(input [15:0] instr_in, input clk, input rst, output reg hazard);

reg [15:0] instr[0:1];

always @(posedge clk) begin
    if (rst) begin
        instr[0] = 16'd0;
        instr[1] = 16'd0;
    end else begin
        instr[1] <= instr[0];
    end
end

always @* begin
    hazard = 1'b0;
    // if a instruction is preceeded by a LW, stall it
    //----------------------------------------------------------------
    // notice:
    //      probably it isn't worth telling whether the instruction following
    //      LW is a read, or it reads from the same address that LW writes to
    //----------------------------------------------------------------
    if(instr[1][15:12] == `LW)
       hazard = 1;
end

endmodule