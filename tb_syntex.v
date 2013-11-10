`include "define.v"

module tv_syntex();

//reg [3:0] opcode;
reg [7:0] eightBit;
reg [15:0] sixteenBit;

initial begin

  // opcode = 4'b1000;

  // case(opcode)
  // `ADD:
  //   $display("passed");
  // default:
  //   $display("failed");
  // endcase
  eightBit = 16'b11111111;
  #10
  sixteenBit = eightBit;
  if (sixteenBit == 16'b0000_0000_1111_1111) begin
      $display("passed. %b", sixteenBit);
  end

  #10
  sixteenBit = $signed(eightBit);
  if (sixteenBit == 16'b1111_1111_1111_1111) begin
      $display("passed. %b", sixteenBit);
  end

end

endmodule