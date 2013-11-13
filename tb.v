`include "define.v"

module tb();

reg clk, rst;

datapath CPU(.clk(clk), .rst(rst));

always #5 clk <= ~clk;

initial begin

  clk = 1'b0;
  rst = 1'b1;

  #1000
  rst = 1'b0;

  #2000
  $finish;
end
endmodule
  
