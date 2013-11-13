// `include "define.v"

// module Icache(input [`MEM_SPACE-1] address, input Wen,
//   input clk, input rst,
//   output reg [`ISIZE-1:0] data_out, output miss);

//   reg [`ISIZE-1:0] cache [0:3][0:1]; // [address, instruction]

//   always @(posedge clk) begin
//     if (rst) begin
//       cache[0][0] = 16'd0;
//       cache[1][0] = 16'd0;
//       cache[2][0] = 16'd0;
//       cache[3][0] = 16'd0;

//       cache[0][1] = 16'd0;
//       cache[1][1] = 16'd0;
//       cache[2][1] = 16'd0;
//       cache[3][1] = 16'd0;
//     end else begin
//       miss = 1'b0;
//       if (!(address^cache[0][0]) begin
//         data_out = cache[0][1];
//       end else if (!(address^cache[1][0])) begin
//         data_out = cache[1][1];
//       end else if (!(address^cache[2][0])) begin
//         data_out = cache[2][1];
//       end else if (!(address^cache[3][0])) begin
//         data_out = cache[3][1];
//       end else begin
//         miss = 1'b1;
//       end
//     end
//   end