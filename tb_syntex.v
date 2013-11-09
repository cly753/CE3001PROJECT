`include "define.v"

module tv_syntex();

reg [3:0] opcode;

initial begin

  opcode = 4'b1000;

  case(opcode)
  `ADD:
    $display("passed");
  default:
    $display("failed");
  endcase
end

endmodule