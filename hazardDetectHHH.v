`include "define.v"

module hazardDetectHHH(input [15:0] instr_in, input clk, input rst, output reg hazard);

reg [15:0] instr[0:3]; // instr[0] -> current instruction // instr[1] -> last instruction and so on
reg destination [0:3]; // destination[i] records whether instr[i] writes to a storage unit (either RF or D-mem)

always @(posedge clk) begin
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
    else begin
        instr[1] <= instr[0];
        instr[2] <= instr[1];
        instr[3] <= instr[2];

        destination[1] <= destination[0];
        destination[2] <= destination[0];
        destination[3] <= destination[0];
    end
end

always @* begin
    instr[0] = instr_in;
    if (instr[0][15] == 1'b0) begin // arithmetic operations will definately write to RF
        destination[0] = 1'b1;
    end else if (instr[0][15:14] == 2'b10 && instr[0][15:12] != `SW) begin // LW LLB LHB will write to RF or D-mem
        destination[0] = 1'b1;
    end else if (instr[0][15:12] == `JAL) begin
        destination[0] = 1'b1;
    end
end

always @* begin
    hazard = 1'b0;
    
    if (instr[0][15:14] == 2'b00) begin // if source of current instr is the same as destination of any one of the 3 previous instr, assert harzard // an arithmetic operation reads 2 registers, both of which will be checked
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end else if ((instr[0][3:0] == instr[1][11:8] && destination[1]) || (instr[0][3:0] == instr[2][11:8] && destination[2]) || (instr[0][3:0] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    
    end else if (instr[0][15:14] == 2'b01) begin // note that: each logical operation only reads one source
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end else if (instr[0][15:12] == `SW) begin // SW reads 2 registers, one specifying data, one specifying address
        if ((instr[0][11:8] == instr[1][11:8] && destination[1]) || (instr[0][11:8] == instr[2][11:8] && destination[2]) || (instr[0][11:8] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end else if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end else if (instr[0][15:12] == `LW) begin // LW reads 1 registers
        if ((instr[0][7:4] == instr[1][11:8] && destination[1]) || (instr[0][7:4] == instr[2][11:8] && destination[2]) || (instr[0][7:4] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end else if (instr[0][15:12] == `LHB || instr[0][15:12] == `LLB || instr[0][15:12] == `JR || instr[0][15:12] == `EXEC) begin // Load Imm reads 1 register
        if ((instr[0][11:8] == instr[1][11:8] && destination[1]) || (instr[0][11:8] == instr[2][11:8] && destination[2]) || (instr[0][11:8] == instr[3][11:8] && destination[3])) begin
            hazard = 1'b1;
        end
    end
end

//------------------------------------------------------------------------
// version 2:
// harzard detection based on only 1 history instruction
//------------------------------------------------------------------------
// always @* begin
//     CU_stall = 0;       // active high, tell the control unit to stall the CPU
//     CU_disable = 0;     // active high, tell the control unit to disable the current instruction in ID

//     // if read instruction follows a LW instruction
//     // tells ctrl_unit to stall and disable the current instruction
//     if(instr[1][15:12] == `LW && instr[0] =  )

endmodule