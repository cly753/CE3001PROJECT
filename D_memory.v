 `include "define.v"

module D_memory(
  input [`MEM_SPACE-1:0] address,    
  input [`DSIZE-1:0] data_in,         
  output reg [`DSIZE-1:0] data_out,    
  input clk,
  input rst,
  input write_en
);
  reg [`DSIZE-1:0] memory [0:2**`MEM_SPACE-1];
  reg [8*`MAX_LINE_LENGTH:0] line; /* Line of text read from file */
  integer D_init, addr_inc, i, c, r;

  always @(posedge clk or posedge rst) // rst: active high
    begin
      if ( rst )  begin
          addr_inc = 0;

          //========
          //D_init = $fopen("D_memory_init.txt","r");
          D_init = $fopen("D_memory_init.v","r");
          //========
          
          while(!$feof(D_init)) begin
              c = $fgetc(D_init);
	      // check for comment
              if (c == "/" | c == "#" | c == "%")
                  r = $fgets(line, D_init);
              else begin
                  // Push the character back to the file then read the next time
                  r = $ungetc(c, D_init);

                  //========
                  r = $fscanf(D_init, "%d", memory[addr_inc]);
                  //r = $fscanf(D_init, "%h", memory[addr_inc]);
                  //========
                  $display("DM read line: %d", addr_inc);

                  addr_inc = addr_inc + 1;
              end
          end
          $fclose(D_init);
          for (i = addr_inc - 1; i < 2 ** `MEM_SPACE; i = i + 1) begin
              memory[i] = 16'h0000;
          end
      end else begin
          if (write_en) begin            // active-low write enable
              memory[address] <= data_in;
          end
          data_out <= memory[address];
      end
    end

endmodule
