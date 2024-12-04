module thread_unit #(parameter FIX_ROW=6,FIX_COL=8)
(clk,reset_n,a1,a2,a3,start_mm,readA,readB,row,col,Din,acc,finished,dp_done,unused,ack_ticks
	);
	
	input clk,reset_n,start_mm,readA,readB,ack_ticks;
	input [3:0] row,col,a1,a2,a3;
	input [31:0] Din;
	output finished,dp_done,unused;
	output [31:0] acc;
	
	
	wire range_cond,row_match_cond,col_match_cond,A_order_cond,B_order_cond;
		
	wire [3:0] a_address,b_address,dp_address;
	
	wire [4:0] real_a_address,real_b_address;
	
	wire [31:0] q_a,q_b;
	
	assign range_cond =((a1 >FIX_ROW) && (a3 >FIX_COL));
	assign row_match_cond = (FIX_ROW == row);
	assign col_match_cond = (FIX_COL == col);
	assign A_order_cond = readA;
	assign B_order_cond = readB;
	
	assign we_a = (range_cond && row_match_cond && A_order_cond);
	assign we_b = (range_cond && col_match_cond && B_order_cond);

	assign a_address = (we_a)? col:dp_address;
	assign b_address = ((we_b)? row:dp_address);
	
	assign real_a_address = {1'b0,a_address};
	assign real_b_address = {1'b1,b_address};
	assign unused = ~range_cond;
	
	assign finished = unused || dp_done;

	/*
	single_port_ram A_ram
(
	.data(Din),
	.addr(a_address),
	.we(we_a), .clk(clk),
	.q(q_a)
);

single_port_ram B_ram
(
	.data(Din),
	.addr(b_address),
	.we(we_b), .clk(clk),
	.q(q_b)
);*/

 true_dual_port_ram_single_clock r1
(
	.data_a(Din), .data_b(Din),
	.addr_a(real_a_address), .addr_b(real_b_address),
	.we_a(we_a), .we_b(we_b), .clk(clk),
	.q_a(q_a), .q_b(q_b)
);
	dot_product2 dp
(
	.start_mm(start_mm),
	.ack_ticks(ack_ticks),
	.clk(clk),
	.reset_n(reset_n),
	.a2(a2),
	.dp_done(dp_done),
	.acc(acc),
	.address(dp_address),
	.q_a(q_a),
	.q_b(q_b)
);

endmodule 