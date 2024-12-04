module dot_product2#(parameter ADDR_WIDTH=4)
(start_mm,ack_ticks,clk,reset_n,a2,dp_done,acc,address,q_a,q_b);
input start_mm,clk,reset_n,ack_ticks;
input [3:0] a2;
output reg [31:0] acc;
output dp_done;
input [31:0] q_a, q_b;
output [ADDR_WIDTH-1:0] address;

reg [ADDR_WIDTH-1:0] i;

localparam s0=0,s1=1, s2=2, s3=3,s4=4;
localparam s1NO=5,s2NO=6;

reg [3:0] state;

assign dp_done = ( (state==s3) || (state==s4) );
assign address = i;


always @(posedge clk)
if (~reset_n) begin
	state <= s0;
	i <= 0;
	acc <= 0;
end
else 
begin
	case(state)
		s0:
			if(~start_mm) state <= s1;
			
		s1:if (start_mm)begin
			i <= 0;
			acc<=0;
			state <= s1NO;
			end
			
		s1NO:
			state<= s2;
			
		s2:
			if (i<a2) begin 
			acc<= acc + q_a*q_b;
			i<= i+1;
			state <= s2NO;
			end
			else
			state<= s3;
			
		s2NO:
			state<= s2;
		
		s3:
			if (~ack_ticks)  
				state<= s4;
			else
				state<=s3;
		s4:
			if (ack_ticks)
				state<=s0;
			else
				state<=s4;
		
		default:
			state<=s0;
	endcase
end
endmodule