  module top#(parameter NUMBER_OF_THREADS = 128)
  (start_mm, rrow, rcol, acc, ack_elem, clk, reset_n,
          ticks, ack_ticks, elem_rdy, mm_done,
          start_read, din, read_done);

  localparam DATA_WIDTH = 32, ADDR_WIDTH = 4;

  input start_mm, ack_elem, clk, reset_n;
  output [31:0] acc;
  output [4:0] rrow, rcol;
  output reg [31:0] ticks;
  input ack_ticks;
  output elem_rdy, mm_done;
  output read_done;
  input start_read;
  input [31:0] din;

  //wire [4:0] row, col;
  //wire dp_go;
  //wire [31:0] q_a, q_b;
 // wire [31:0] dp_data_a, dp_data_b;
  //wire dp_we_a, dp_we_b;
 // wire [7:0] dp_linear_addr_a, dp_linear_addr_b;
 // wire [3:0] dp_state ; // ADED
  //wire [7:0] mr_addr_a, mr_addr_b;
 // wire [31:0] mr_data_a, mr_data_b;
 // wire mr_we_a, mr_we_b;
  wire [4:0] a1,a2,a3; 
  wire is_reading,readA,readB;
  wire [3:0] read_row,read_col;
  //wire [3:0] value_row,value_col;
  wire [(NUMBER_OF_THREADS-1):0] finished ;
  wire [(NUMBER_OF_THREADS-1):0] dp_done ;
  wire [(NUMBER_OF_THREADS-1):0] unused ;
  wire [31:0] data;
  wire [31:0] all_acc [0:15][0:15];
  wire fninshed_and_pin;
  
  assign fninshed_and_pin = & finished;
  assign acc = all_acc[rrow][rcol];


  matrix_reader2 u1 (
  .is_reading(is_reading),
  .start_read(start_read),
  .din(din), 
  .reset_n(reset_n), 
  .clk(clk), 
  .a1(a1), .a2(a2), .a3(a3),
  .row(read_row),.col(read_col), 
  .read_done(read_done),
  .readA(readA),.readB(readB),.data(data)
  );


  collector c1(
  .start_mm(start_mm), 
  .a1(a1), .a3(a3), 
  .r(rrow), .c(rcol),
  .finished(fninshed_and_pin), .elem_rdy(elem_rdy), .mm_done(mm_done), 
  .clk(clk), .reset_n(reset_n), 
  .ack_elem(ack_elem), .ack_ticks(ack_ticks)
  );
  
/*
  thread_unit #(0,0) u0(
  .clk(clk),.reset_n(reset_n),
  .a1(a1),.a2(a2),.a3(a3),
  .start_mm(start_mm),
  .readA(readA),.readB(readB),
  .row(read_row),.col(read_col),
  .Din(data),
  .acc(all_acc[0][0]),
  .finished(finished[0]),.dp_done(dp_done[0]),.unused(unused[0]),.ack_ticks(ack_ticks)
);
*/


  genvar i;
  
  generate for(i=0;i<NUMBER_OF_THREADS;i=i+1) begin : all_threads
	thread_unit #(i/16,i%16) 
	u0
(
  .clk(clk),.reset_n(reset_n),
  .a1(a1),.a2(a2),.a3(a3),
  .start_mm(start_mm),
  .readA(readA),.readB(readB),
  .row(read_row),.col(read_col),
  .Din(data),
  .acc(all_acc[i/16][i%16]),
  .finished(finished[i]),.dp_done(dp_done[i]),.unused(unused[i]),.ack_ticks(ack_ticks)
);
	end
  endgenerate

  localparam s0 = 0, s1 = 1, s2 = 2  ,s3 = 3; 
  reg [1:0] latency_calc_state;

  always @(posedge clk)
    if (~reset_n)
      latency_calc_state <= s0;

 else 
 /*
  case (latency_calc_state)
    s0: 
      if (start_mm) begin
        latency_calc_state <= s1;
        ticks <= 0;
	end
    
    s1: 
      if (~mm_done) begin 
        ticks <= ticks + 1;
      end

      else 
        latency_calc_state <= s2;
      
    
    s2: 
      if (~ack_ticks) 
        latency_calc_state <= s3;
	 
	 s3:
		if(ack_ticks) latency_calc_state <= s0;

    default: latency_calc_state <= s0;   
   
  endcase
  */
  
  case (latency_calc_state)
    s0: 
      if (~start_mm) begin
        latency_calc_state <= s1;
		  end
    
    s1: 
		if(start_mm) begin
			ticks <= 0;
			latency_calc_state <= s2;
			end
	 s2:
      if (~fninshed_and_pin) begin 
        ticks <= ticks + 1;
      end

      else 
        latency_calc_state <= s0;
 

    default: latency_calc_state <= s0;   
  endcase
endmodule
