module collector(start_mm, a1, a3, r, c,finished, elem_rdy, mm_done, clk, reset_n, ack_elem, ack_ticks);
input start_mm , clk, reset_n,ack_elem,ack_ticks;
input  finished;
input [4:0] a1, a3;
output reg [4:0] r, c;
output elem_rdy, mm_done;


localparam s0=0 ,s1=1 ,s2=2 ,s3=3 ,s4=4,s5=5,s6=6,s7=7,s8=8,s9=9,s44=10,s99=11;

reg [3:0] state ;
wire start_upload;
assign mm_done = (state==s9 || state==s99);
assign elem_rdy = (state ==s4 || state ==s44);
assign start_upload = finished;

always @(posedge clk)
begin
	if(~reset_n) state<=s0;
	else case (state)
	
	s0: if(start_mm) state <= s1;
	s1: begin r<=0; c<=0; state <=s2; end
	s2: state <= s3;
	s3: if (start_upload) state <=s4;
	s4: if (~ack_elem)  state <=s44;
	s44: if(ack_elem) state <=s5;
	s5: begin c<=(c==a3-1)? 0:c+1; state<= s7; end
	s7: begin state <=s8; if(c==0) r <= r + 1; end
	s8: state <= (r==a1) ? s9:s2;
	s9: if(~ack_ticks) state <= s99;
	s99: if(ack_ticks) state <=s0;
	default: state <=s0;
	
	
	endcase
end
endmodule 