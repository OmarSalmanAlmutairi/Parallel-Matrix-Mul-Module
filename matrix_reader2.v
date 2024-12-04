module matrix_reader2 (is_reading, start_read, din, reset_n, clk,
a1, a2, a3,row,col, read_done,readA,readB,data);

  input start_read, reset_n, clk;
  input [31:0] din;
  output reg [4:0] a1;
  output reg [4:0] a2;
  output reg [4:0] a3;
  output reg [3:0] row,col;
  output read_done;
  output is_reading; 
  output reg readA,readB;
  output reg [31:0] data;

localparam s0 = 0, s1 = 1, s2 = 2, s3 = 3, s4 = 4, s5 = 5,
  s6 = 6, s7 = 7, s8 = 8, s9 = 9, s10 = 10,s11=11;

reg [3:0] state;
reg [7:0] szA, szB, c;

assign read_done = (state == s11);
assign is_reading = ~((state == s0) || (state == s1));
  //assign row_address = 


always @(posedge clk) begin
  if (~reset_n) begin
    state <= s0;
	 readA <= 0;
	 readB <=0;
	 data <=0;
  end else begin
    case (state)
      // Reading al
      s0: begin
        if (~start_read) begin
          state <= s1;
        end
      end
      
      s1: begin
        if (start_read) begin
          state <= s2;
          a1 <= din;
        end
      end
      
      // Reading a2
      s2: begin
        if (~start_read) begin
          state <= s3;
        end
      end
      
      s3: begin
        if (start_read) begin
          state <= s4;
          a2 <= din;
          szA <= a1*din;
        end
      end
      
      // Reading a3
      s4: begin
        if (~start_read) begin
          state <= s5;
        end
      end
      
      s5: begin
        if (start_read) begin
          state <= s6;
          a3 <= din;
          szB <= a2*din;
          c <= 0;
        end
      end
      
      // Reading Matrix A elements
      s6: begin
        if (~start_read) begin
          state <= s7;
        end
      end
      
      s7: begin
        if (start_read) begin
			 row <= c/a2;
			 col <= c%a2;
			 data <= din;
          c <= (c == szA-1) ? 0 : c+1;
		    state <= (c == szA-1) ? s8 : s6;
	  //readA <= (c == szA-1) ? 0:1;
	       readA <= 1;
	  //readB <= (c == szA-1) ? 1:0;
        end
      end
      
      // Reading Matrix B elements
      s8: begin
        if (~start_read) begin
          state <= s9;
        end
      end
      
      s9: begin
        if (start_read) begin
			 row <= c/a3;
			 col <= c%a3;
			 data <= din;
          c <= c + 1;
	  state <= (c == szB-1) ? s10 : s8;
	 // readB <= (c == szA-1) ? 0:1;
	 readB <=1;
	 readA <= 0;
        end
      end
      
      // Final state
      s10: begin
        state <= s11;
      end
		//new final
		s11: begin
        state <= s0;
		  readB <= 0;
      end
		
      
      default: begin
        state <= s0;
      end
      
    endcase
  end
end

endmodule
