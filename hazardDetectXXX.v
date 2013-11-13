`include "define.v"

module hazardDetect(input [15:0] instr_in, input clk, input rst, output reg hazard);

reg [15:0] instr[0:1];
reg [3:0] rd;
reg temp;

always @(posedge clk) begin
    if (rst) begin
        instr[0] = 16'd0;
        instr[1] = 16'd0;
    end else begin
        instr[1] <= instr[0];
    end
end

always @* begin
    instr[0] = instr_in;
    rd = instr[1][11:8];
end

always @* begin
    // if a instruction is preceeded by a LW, stall it
    //----------------------------------------------------------------
    // responsibility:
    //      "hazard" will be asserted when the current instruction follows a LW
    //      and it reads from the same address that LW writes to
    // hazard:
    //      active-high signal to tell the control unit to disable the current
    //      instruction and fetch the current instruction again in next cycle
    // tricks:
    //      Appendix(a)
    //----------------------------------------------------------------
    temp = 1'b0;
    if(instr[1][15:12] == `LW) begin
        if (instr[0][15:14] == 2'b00 && (instr[0][7:4] == rd || instr[0][3:0] == rd)) begin // ADD SUB AND OR
            temp = 1'b1;
        end else if (instr[0][15:14] == 2'b01 && instr[0][7:4] == rd) begin // SLL SRL SRA RL
            temp = 1'b1;
        end else if (instr[0][15:12] == `LW && instr[0][7:4] == rd && instr[0][11:8] != rd) begin // LW SW
            temp = 1'b1;
        end else if (instr[0][15:12] == `SW && (instr[0][7:4] == rd || instr[0][11:8])) begin
            temp = 1'b1;
        end else if (instr[0][15:12] == `LHB && instr[0][11:8] == rd) begin // LHB
            temp = 1'b1;
        end else if (instr[0][15:13] == 3'b111 && instr[0][11:8] == rd) begin
            temp = 1'b1;
        end
    end
    hazard = temp;
end

endmodule


//----------------------------------------------------------------
// Appendix:
//      (a)use a temp to prevent spike in signals, for example, if there are
//      2 consecutive high, without using this temp harzard would looke like
//      ____|--||--|______ instead of _____|-----|_____