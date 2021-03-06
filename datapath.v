`include "define.v"
module datapath(clk,rst);
  input clk,rst;
  
  wire [`ISIZE-1:0] Iaddress,Daddress,IF_PCplus1,IF_currPC;
  wire [`DSIZE-1:0] Idata_out,data_in,Ddata_out;
  wire [`DSIZE-1:0] WData,RData1,RData2;
  wire [`DSIZE-1:0] AOut,Adata1_in,Adata2_in,S8extend_out,S12extend_out,S4extend_out;
  wire [`RSIZE-1:0] RAddr1,RAddr2,WAddr;
  wire [`RSIZE-1:0] imm;
  wire [3:0] ALUop, Aop;
  
  wire Dwrite_en,RFwen,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,lhb,lhbc; 
  wire WriteEn,MemEn;
  wire [`DSIZE-1:0] s1_out,s2_out,s3_out,s5_out,s6_out,s7_out,s8_out,s10_out;
  wire [`DSIZE-1:0] LHBout;
  wire [`DSIZE-1:0] s4_out,s9_out,sL_out, sh_out;
  wire [10:0] control_out;
  wire [2:0] flag;
  wire [7:0] LHBimm;
  wire hazard; 

  //data forwarding
  wire [`DSIZE-1:0] DFs1_out,DFs2_out;

  
  reg s51,s61,s71,s72,s81,s82,s83,sL1,sL2,lhbMiddle;
  reg WriteEn1,WriteEn2,WriteEn3,MemEn1,MemEn2;
  reg [`RSIZE-1:0]s4_out1,s4_out2,s4_out3,imm1,RAddr11;
  reg [3:0] ALUop1;
  reg [`ISIZE-1:0]PC,IF_PCplus11,IF_PCplus12;
  reg [`DSIZE-1:0]RData11,s7_out1,S8extend_out1,S12extend_out1,S4extend_out1;
  reg [7:0] LHBimm1; 
  reg rstControl;
  reg [`DSIZE-1:0] RData12,RData21;
// data forwarding
  reg [`RSIZE-1:0] s9_out1;
  reg [`DSIZE-1:0] DFs2_out1;
   
//instatiate block I-memory, register file, alu, D-memory,control block
I_memory im(
  .address(Iaddress),      
  .data_out(Idata_out),    
  .clk(clk),
  .rst(rst)
);
D_memory dm(
  .address(Daddress),    
  .data_in(data_in),         
  .data_out(Ddata_out),    
  .clk(clk),
  .rst(rst),
  .write_en(Dwrite_en));
Reg_File rf(
	.Clock(clk), .Reset(rst),.Wen(RFwen),
	.RAddr1(RAddr1),.RAddr2(RAddr2),.WAddr(WAddr),
	.WData(WData), 
	.RData1(RData1),.RData2(RData2)
	);
alu al(
	.Data1(Adata1_in), .Data2(Adata2_in),
	.op(Aop),
	.imm(imm1),
	.clk(clk),
	 .Out(AOut),.flag(flag));
//control block to be implemented
Control con(
  .control_input(Idata_out),
  .clk(clk),
  .WriteEn(WriteEn),
  .MemEn(MemEn),
  .ALUOp(ALUop),
  .sel(control_out),
  .rst(rst),
  .flag(flag),
  .hazard(hazard),
  .lhb(lhbc)
  );

LXBunit lxb(
  .dataRd(DFs2_out),
  .imm(LHBimm1),
  .clk(clk),
  .out(LHBout),
  .lhb(lhb)
  );
hazardDetect hazDec (
  .instr_in(Idata_out),
  .clk(clk),
  .rst(rst), 
  .hazard(hazard)
  );

//sign extend and zero extend
assign S8extend_out = $signed(Idata_out[7:0]);
assign S12extend_out = $signed(Idata_out[11:0]);
assign S4extend_out = $signed(Idata_out[3:0]);

//assign all selections
assign s1 = control_out[0];
assign s2 = control_out[1];
assign s3 = control_out[2];
assign s4 = control_out[3];
assign s5 = control_out[4];
assign s6 = control_out[5];
assign s7 = control_out[6];
assign s8 = control_out[7];
assign s9 = control_out[8];
assign s10 = control_out[9];
assign sL = control_out[10];

// all selections
assign s1_out = (s1)? s2_out:IF_PCplus1;
assign s2_out = (s2)? DFs2_out:(s3_out+IF_PCplus11);
assign s3_out = (s3)? S12extend_out1:S8extend_out1;
assign s4_out = (s4)? 4'b1111:Idata_out[11:8];
assign s5_out = (s51)? DFs1_out:S4extend_out1;
assign s6_out = (s61)? DFs2_out:S4extend_out1;
assign s7_out = (s72)? IF_PCplus12:sL_out;
assign s8_out = (s83)? Ddata_out:s7_out1;
assign s9_out = (s9)? Idata_out[11:8]:Idata_out[3:0];
assign s10_out = (s10)? s1_out:IF_currPC;
assign sL_out = (sL2)? AOut:LHBout;
assign sh_out = (hazard)? IF_currPC:s1_out; 

//wire into RF and Control
assign RAddr1 = Idata_out[7:4]; // -cly            
assign RAddr2 = s9_out; // -cly
assign imm = RAddr2;
assign Aop = ALUop1;
assign RFwen = WriteEn3;
assign Dwrite_en=MemEn2;
assign WAddr = s4_out3;
assign WData = s8_out;

assign Daddress=sL_out;
assign IF_currPC=PC;
assign IF_PCplus1=IF_currPC + 1'b1;
assign Iaddress=sh_out;
assign Adata1_in = s5_out;
assign Adata2_in = s6_out;
assign data_in = DFs2_out1;
assign lhb=lhbMiddle;

//data forwarding mux

assign DFs1_out = (WriteEn2 && s4_out2 == RAddr11)? s7_out:((WriteEn3 && s4_out3 == RAddr11)? s8_out:RData11); 
assign DFs2_out = (WriteEn2 && s4_out2 == s9_out1)? s7_out:((WriteEn3 && s4_out3 == s9_out1)? s8_out:RData21);




assign LHBimm=Idata_out[7:0];

always @(posedge clk)
begin
  rstControl <= rst; // synchronize the rst signal
  s51<=s5;
  s61<=s6;
  s71<=s7;
  s72<=s71;
  s81<=s8;
  s82<=s81;
  s83<=s82;
  sL1<=sL;
  sL2<=sL1;
  IF_PCplus11<=IF_PCplus1;
  IF_PCplus12<=IF_PCplus11;	
  S8extend_out1<=S8extend_out;
  S12extend_out1<=S12extend_out;
  imm1<=imm;
  ALUop1<=ALUop;
  RData11<=RData1;
  WriteEn1<=WriteEn;
  WriteEn2<=WriteEn1;
  WriteEn3<=WriteEn2;
  MemEn1<=MemEn;
  MemEn2<=MemEn1;
  s4_out1<=s4_out;
  s4_out2<=s4_out1;
  s4_out3<=s4_out2;
  s7_out1<=s7_out;

  PC<=rst?16'b1111_1111_1111_1111:s10_out;

  LHBimm1<=LHBimm;
  RData12<=DFs1_out;
  RData21<=RData2;
  DFs2_out1<=DFs2_out;
  RAddr11<=RAddr1; // -cly
  s9_out1<=s9_out; 
  S4extend_out1<=S4extend_out; 
  lhbMiddle<=lhbc;
end
endmodule





	
	 


