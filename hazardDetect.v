`include "define.v"

module hazardDetect(input [15:0] instr_in, input clk, input rst, output reg hazard);

// instr[0] -> current instruction
// instr[1] -> last instruction and so on
reg [15:0] instr[0:3]; 
// destination[i] records whether instr[i] writes to a storage unit (either RF or D-mem)
reg destination [0:3]; 

always @(posedge clk or posedge rst) begin
    if (rst) begin
        instr[0] = 16'd0;
        instr[1] = 16'd0;
        instr[2] = 16'd0;
        instr[3] = 16'd0;
        destination[0] = 1'b0;
        destination[1] = 1'b0;
        destination[2] = 1'b0;
        destination[3] = 1'b0;
    end
    else if(!hazard) begin
        instr[1] <= instr[0];
        instr[2] <= instr[1];
        instr[3] <= instr[2];

        destination[1] <= destination[0];
        destination[2] <= destination[0];
        destination[3] <= destination[0];
    end
end

always @* begin // ignore JAL
    instr[0] = instr_in;
    // arithmetic operations will definately write to RF
    if (instr[0][15] == 1'b0) begin
        destination[0] = 1'b1;
    // memory operation & load immediate will write to either RF or D-mem
    end else if (instr[0][15:14] == 2'b10 && instr[0][15:12] != 4'b1001) begin
        destination[0] = 1'b1;
    end
end

// harzard detection
always @* begin
    hazard = 1'b0;
    // if current instr is ADD SUB AND OR
    if (instr[0][15:14] == 2'b00) begin
        // if source of current instr is the same as destination of any one of the 3 previous instr, assert harzard
        // note that an arithmetic operation reads 2 registers, both of which will be checked
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end else if ((instr[0][3:0] == instr[1][11:8] && destination[1]) || (instr[0][3:0] == instr[2][11:8] && destination[2]) || (instr[0][3:0] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    // if current instr is SLL SRL SRA RL
    end else if (instr[0][15:14] == 2'b01) begin
        // note that: each logical operation only reads one source
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end

    end else if (instr[0][15:12] == `SW) begin
        // note that: SW reads 2 registers, one specifying data, one specifying address
        if ((instr[0][11:8] == instr[1][11:8] && destination[1]) || (instr[0][11:8] == instr[2][11:8] && destination[2]) || (instr[0][11:8] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end else if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end else if (instr[0][15:12] == `LW) begin
        // note that: LW reads only 1 registers
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    // if current instr is load immediate
    end else if (instr[0][15:12] == `LHB || instr[0][15:12] == `LLB || instr[0][15:12] == `JR || instr[0][15:12] == `EXEC) begin
        // note that: Load Imm reads only 1 register
        if ((instr[0][11:8] == instr[1][11:8] && destination[1]) || (instr[0][11:8] == instr[2][11:8] && destination[2]) || (instr[0][11:8] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end
end
endmodule