`include "define.v"


module Control(input [15:0] control_input, input clk, input [2:0] flag, input rst,
    output reg WriteEn, output reg MemEn, output reg [3:0] ALUOp, output reg [10:0] sel, output reg smart); // if found a RAW, stop PC

    reg [3:0] opcode;
    reg bResult;
    reg bTemp;
    //reg selLHB;
    reg [3:0] concode;
    reg [15:0] instr [4:0];

    reg hazard;

    parameter STOP = 14'b1_1_0_111111_110_00; // disable all, PC stops, next Iaddress = PC // {smart, sel, WriteEn, MemEn} = STOP

    hazardDetect hd(.instr(control_input), .clk(clk), .rst(rst), .hazard(hazard));


// shift register to record last 4 instruction in history
always @(posedge clk) begin
  instr[1] <= instr[0];
  instr[2] <= instr[1];
  instr[3] <= instr[2];
  instr[4] <= instr[3];
end
    
always @* begin

  instr[0] = control_input;
  opcode = instr[0][15:12];
  concode = instr[1][11:8];



  bTemp = 1'b0;

  case (concode)
    `BEQ: begin
      if (flag[2] == 1'b1) begin
        bTemp = 1'b1;
      end
    end
    `BNE: begin
      if (flag[2] == 1'b0) begin
        bTemp = 1'b1;
      end
    end
    `BGT: begin
      if (flag[0] == 1'b0 && flag[2] == 1'b0) begin
        bTemp = 1'b1;
      end
    end
    `BLT: begin
      if (flag[0] == 1'b1) begin
        bTemp = 1'b1;
      end
    end
    `BGE: begin
      if (flag[2] == 1'b1 || (flag[0] == 1'b0 && flag[2] == 1'b0)) begin
        bTemp = 1'b1;
      end
    end
    `BLE: begin
      if (flag[0] == 1'b1 || flag[2] == 1'b1) begin
        bTemp = 1'b1;
      end
    end
    `BOF: begin
      if (flag[1] == 1'b1) begin
        bTemp = 1'b1;
      end
    end
    `TRUE: begin
      bTemp = 1'b1;
    end
  endcase

  bResult = bTemp;

  if (rst) begin
    {ALUOp, sel, WriteEn, MemEn} = 17'b000_0_1_0000000000_00;
  end else begin
    ALUOp = opcode;
    
    case (opcode)
      `ADD: begin
        {smart, sel, WriteEn, MemEn} = 14'b0_1_1_000110_110_10; // set all don't care to 1;
      end
      `SUB: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000110_110_10;
      end
      `AND: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000110_110_10;
      end
      `OR: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000110_110_10;
      end
      `SLL: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000010_110_10;
      end
      `SRL: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000010_110_10;
      end
      `SRA: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000010_110_10;
      end
      `RL: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_000010_110_10;
      end
      `LW: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_011010_110_10;
      end
      `SW: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_111101_110_01;
      end
      `LHB: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_0_1_100010_110_10;
      end
      `LLB: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_100000_110_10;
      end
      `B: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_1_111111_110_00;
      end
      `JAL: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_0_101111_110_10;
      end
      `JR: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_0_111111_110_00;
      end
      `EXEC: begin
        {smart, sel, WriteEn, MemEn} = 13'b0_1_0_111111_110_00;
      end
      default: begin
      end
    endcase

    if (inst[0][11:8] == 4'b1111 && instr[0][15:12] != `JAL) begin
      WriteEn = 1'b0;
    end

    //########################################
    //                                      ##
    // hazard dectection move to new module ##
    //                                      ##
    //########################################
    


    //------------------------------------------------------------
    // for an exmple of instruction sequence-
    //    A: arithmetic instr
    //    B: branch
    //    C: xxxx(don't care)

    // pipeline lay out:
    //   --stage-- ID  EXE  Mem
    //   --instr-- C    B    A
    //------------------------------------------------------------
    // The following if-else simply says
    // if:
    //    B is a branch, and bResult calculated in ID is "taken"
    //    (this result is calculated based on flags set by A, and
    //    since B's resolution depends on these flags, so the result
    //    actually refers to the resolution of B)
    //    
    // then:
    //    path will be cleared for 
    //------------------------------------------------------------
    if (instr[1][15:12] == `B && bResult == 1'b1) begin
      {sel, WriteEn, MemEn} = 13'b1_1_111111_001_00;
    end
     
    if (instr[1][15:12] == `JR) begin
        sel[1] = 1'b1;
        sel[0] = 1'b1;
        sel[9] = 1'b1;
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end 

    if (instr[1][15:12] == `JAL) begin
        sel[0] = 1'b1;
        sel[1] = 1'b0;
        sel[2] = 1'b1;
        sel[9] = 1'b0;
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end
    
    // if last instruction is EXEC, 
    if (instr[1][15:12] == `EXEC) begin
        sel[0] = 1'b1;
        sel[1] = 1'b1;
        sel[9] = 1'b0;
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end
    
    // if last last instruction is EXEC
    if (instr[2][15:12] == `EXEC) begin
      if (control_input[15:14] == 2'b11) begin
        instr[0] = 16'd0;
      end

      sel[0] = 1'b0;
      sel[9] = 1'b1;
      WriteEn = 1'b0;
      MemEn = 1'b0;
    end
  end
end

endmodule
//--------------------------------------------------------------------
//Control Signals:
// Sel[0]:PC_SEL
// Sel[1]:PC_BJ_RF
// Sel[2]:PC_Br_Jmp
// Sel[3]:RF_dest
// Sel[4]:ALUSrc1
// Sel[5]:ALUSrc2
// Sel[6]:ALU_PC1
// Sel[7]:Mem2Reg
// Sel[8]:RF_RsRd
// Sel[9]:PC_HOLD
// Sel[10]: 0 = LHBunit
// Sel[11]: 1 = direct from PC
//--------------------------------------------------------------------

