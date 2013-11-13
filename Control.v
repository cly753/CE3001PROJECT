`include "define.v"

// smart is always 0? what;s the point

module Control(input [15:0] control_input, input clk, input [2:0] flag, input rst, input hazard,
    output reg WriteEn, output reg MemEn, output reg [3:0] ALUOp, output reg [10:0] sel, output reg lhb); // if found a RAW, stop PC

    reg [3:0] opcode;
    reg bResult;
    reg bTemp;
    reg [3:0] concode;
    reg [15:0] instr [2:0];

    hazardDetect hd(.instr_in(control_input), .clk(clk), .rst(rst), .hazard(hazard));



always @(posedge clk) begin // shift register recording last 2 instruction in history
  if (!hazard) begin
    instr[1] <= instr[0];
    instr[2] <= instr[1];
  end
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
    {ALUOp, sel, WriteEn, MemEn} = 17'b0000_1_0000000000_00;
  end else begin
    ALUOp = opcode;
    case (opcode)
      `ADD: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10; // set all don't care to 1
      end
      `SUB: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10;
      end
      `AND: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10;
      end
      `OR: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10;
      end
      `SLL: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000010_110_10;
      end
      `SRL: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000010_110_10;
      end
      `SRA: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000010_110_10;
      end
      `RL: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000010_110_10;
      end
      `LW: begin
        {sel, WriteEn, MemEn} = 13'b1_1_011010_110_10;
      end
      `SW: begin
        {sel, WriteEn, MemEn} = 13'b1_1_111011_110_01;
      end
      `LHB: begin
        {sel, WriteEn, MemEn} = 13'b0_1_100010_110_10;
        lhb = 1'b1;
      end
      `LLB: begin
        {sel, WriteEn, MemEn} = 13'b1_1_100000_110_10;
        lhb = 1'b0;
      end
      `B: begin
        {sel, WriteEn, MemEn} = 13'b1_1_111111_110_00;
      end
      `JAL: begin
        {sel, WriteEn, MemEn} = 13'b1_0_101111_110_10;
      end
      `JR: begin
        {sel, WriteEn, MemEn} = 13'b1_0_111111_110_00;
      end
      `EXEC: begin
        {sel, WriteEn, MemEn} = 13'b1_0_111111_110_00;
      end
      default: begin
      end
    endcase

    // only JAL can write to R15
    if (instr[0][11:8] == 4'b1111 && instr[0][15:12] != `JAL) begin
      WriteEn = 1'b0;
    end

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
      instr[0] = 16'd0;
      {sel, WriteEn, MemEn} = 13'b1_1_111111_001_00;
    end
    
    if (instr[1][15:12] == `JR) begin
        instr[0] = 16'd0;
        sel[1] = 1'b1;
        sel[0] = 1'b1;
        sel[9] = 1'b1;
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end 

    if (instr[1][15:12] == `JAL) begin
        instr[0] = 16'd0;
        sel[0] = 1'b1;
        sel[1] = 1'b0;
        sel[2] = 1'b1;
        sel[9] = 1'b0;
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end

    if (instr[1][15:12] == `EXEC) begin  // if last instruction is EXEC, 
        instr[0] = 16'd0;
        sel[0] = 1'b1;   // let PC <= JUMP
        sel[1] = 1'b1;   // 
        sel[9] = 1'b0;   // stall PC
        WriteEn = 1'b0;
        MemEn = 1'b0;
    end
    
    if (instr[2][15:12] == `EXEC) begin  // if last last instruction is EXEC
      if (control_input[15:14] == 2'b11) begin
        instr[0] = 16'd0;
      end

      sel[0] = 1'b0;   // let PC <= PC+1
      sel[9] = 1'b1;   // release PC
      WriteEn = 1'b0;
      MemEn = 1'b0;
    end

    if (hazard) begin // flush current instruction (disable )
      {sel[9], WriteEn, MemEn} = 13'b0_00;
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
//--------------------------------------------------------------------

