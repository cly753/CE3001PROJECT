`include "define.v"


module Control(input [15:0] control_input, input clk, input [2:0] flag, input rst,
  output reg WriteEn, output reg MemEn, output reg [2:0] ALUOp, output reg [10:0] sel);

  reg [3:0] opcode;
  reg bResult;
  //reg selLHB;
  reg [3:0] concode;
  reg [15:0] instr [4:0];
  
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
  concode = instr[0][11:8];
end

// make branch resolution according to flags
// bResult = 1 means the branch should be taken
always @* begin // for B instruction
  bResult = 1'b0;
  
  if (opcode == `B) begin
    case (concode)
      `BEQ: begin
        if (flag[0] == 1'b1) begin
          bResult = 1'b1;
        end
      end
      `BNE: begin
        if (flag[0] == 1'b0) begin
          bResult = 1'b1;
        end
      end
      `BGT: begin
        if (flag[0] == 1'b0 && flag[2] == 1'b0) begin
          bResult = 1'b1;
        end
      end
      `BLT: begin
        if (flag[2] == 1'b1) begin
          bResult = 1'b1;
        end
      end
      `BGE: begin
        if (flag[0] == 1'b1 || (flag[0] == 1'b0 && flag[2] == 1'b0)) begin
          bResult = 1'b1;
        end
      end
      `BLE: begin
        if (flag[0] == 1'b1 || flag[2] == 1'b1) begin
          bResult = 1'b1;
        end
      end
      `BOF: begin
        if (flag[1] == 1'b1) begin
          bResult = 1'b1;
        end
      end
    endcase
  end
end
        
    
always @* begin

  if (rst) begin
    {ALUOp, sel, WriteEn, MemEn} = 16'b000_1_0000000000_00;
  end else begin
    ALUOp = opcode[2:0];
    
    
    case (opcode)
      `ADD: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10; // set all don't care to 1;
      end
      `SUB: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10;
      end
      `AND: begin
        {sel, WriteEn, MemEn} = 13'b1_1_000110_110_10;
      end
      3'b011: begin
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
        ALUOp = `ADD;
      end
      `SW: begin
        {sel, WriteEn, MemEn} = 13'b1_1_011011_110_01;
        ALUOp = `ADD;
      end
      `LHB: begin
        {sel, WriteEn, MemEn} = 13'b0_1_100010_110_10;
      end
      `LLB: begin
        {sel, WriteEn, MemEn} = 12'b1_100000_110_10;
        ALUOp = `AND;
      end
      //`B: begin
      //  {sel, WriteEn, MemEn} = 12'b0_111111_111_00;
      //end
      `B: begin
        if (instr[1][15] == 1'b0) begin // if last instruction is arithmetic instruction, pc continue, let next cycle to determine
            {sel, WriteEn, MemEn} = 13'b1_1_111111_110_00;
        end else if (bResult == 1'b1) begin
            {sel, WriteEn, MemEn} = 13'b1_1_111111_001_00;
        end else begin
            {sel, WriteEn, MemEn} = 13'b1_1_111111_110_00;
        end
      end
      `JAL: begin
        {sel, WriteEn, MemEn} = 13'b1_0_101111_101_00;
      end
      `JR: begin
        {sel, WriteEn, MemEn} = 13'b1_0_111111_101_00;
      end
      `EXEC: begin
        {sel, WriteEn, MemEn} = 13'b1_0_111111_111_00;
      end
      default: begin
      end
    endcase

    // if (opcode == `LHB)
    //   sel[10] = 1'b1;
    // else
    //   sel[10] = 1'b0;
    
    if (instr[1][15:12] == `B && bResult == 1'b1) begin // if instr[1] is not arithmetic operation, no need to wait
      {sel, WriteEn, MemEn} = 13'b1_1_111111_001_00;
    end/*  else if (instr[0][15:14] != 2'b11) begin
      sel[9] = 1'b1;
      WriteEn = 1'b1;
      MemEn = 1'b1;
    end */
     
    if (instr[1][15:12] == `JR) begin
      sel[0] = 1'b1;
      sel[1] = 1'b1;
      WriteEn = 1'b0;
      MemEn = 1'b0;
    end   
    
    // if last instruction is EXEC, 
    if (instr[1][15:12] == `EXEC) begin
      sel[9] = 1'b0; //hold PC
      sel[0] = 1'b1; //
      WriteEn = 1'b0;
      MemEn = 1'b0;
    end
    
    // if last last instruction is EXEC
    if (instr[2][15:12] == `EXEC) begin
      sel[9] = 1'b1;
      sel[0] = 1'b0;
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
