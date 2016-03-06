module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input CLOCK_50; // 50MHz clock.
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	input [3:0] KEY; // True when not pressed, False when pressed
	input [9:0] SW;
	
	// Generate clk off of CLOCK_50, whichClock picks rate.
	wire [31:0] clk;
	parameter whichClock = 25;
	clock_divider cdiv (CLOCK_50, clk);
	// Hook up FSM inputs and outputs.
	//wire reset, w, out;
	
	//assign sw0 = SW[0];
	//assign sw1 = SW[1];
	
	simple s (clk[whichClock], SW[0], SW[1], LEDR[3:0]);
	
	// Show signals on LEDRs so we can see what is happening.
	
	//assign LEDR = { clk[whichClock], 1'b0, reset, 2'b0, out};
endmodule


// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	input clock;
	output [31:0] divided_clocks;
	reg [31:0] divided_clocks;
	initial
		divided_clocks = 0;
	always @(posedge clock)
		divided_clocks = divided_clocks + 1;
endmodule


module simple (clk, sw0, sw1, out);
	input clk, sw0, sw1;
	output reg [3:0] out;
	reg [3:0] ps; // Present State
	
	// State encoding.
//	parameter [3:0] A = 3'b101, B = 3'b010, C = 3'b001, D = 3'b100;
	// Next State logic
//	always @(posedge clk)
//		case (ps)
//		A: if (sw0) ps = C;
//			else if (sw1) ps = D;
//			else ps = B;
//		B: if (sw0) ps = D;
//			else if (sw1) ps = C;
//			else ps = A;
//		C: if (sw0) ps = B;
//			else if (sw1) ps = D;
//			else ps = A;
//		D: if (sw0) ps = C;
//			else if (sw1) ps = B;
//			else ps = A;
//		default: ps = B;
		
		// State encoding.
	parameter [6:0] Z = 'b101001;
	
	wire [2:0] A = Z[2:0];
	wire [2:0] B = Z[3:1];
	wire [2:0] C = Z[5:3];
	wire [2:0] D = Z[4:2];
	
	// Next State logic
	always @(posedge clk)
		case (ps)
		A: if (sw0) ps = C;
			else if (sw1) ps = D;
			else ps = B;
		B: if (sw0) ps = D;
			else if (sw1) ps = C;
			else ps = A;
		C: if (sw0) ps = B;
			else if (sw1) ps = D;
			else ps = A;
		D: if (sw0) ps = C;
			else if (sw1) ps = B;
			else ps = A;
		default: ps = B;
		
	endcase
	
	// Output logic - could also be another always, or part of above block.
	assign out = ps;

endmodule

module simpleOriginal (clk, reset, w, out);
	input clk, reset, w;
	output reg out;
	reg [1:0] ps; // Present State
	reg [1:0] ns; // Next State
	// State encoding.
	parameter [1:0] A = 2'b00, B = 2'b01, C = 2'b10;
	// Next State logic
	always @(*)
		case (ps)
		A: if (w) ns = B;
		else ns = A;
		B: if (w) ns = C;
		else ns = A;
		C: if (w) ns = C;
		else ns = A;
		default: ns = 2'bxx;
	endcase
	
// Output logic - could also be another always, or part of above block.
	assign out = (ps == C);
	
// DFFs , sets the present state at each clock turn tot he correct position
	always @(posedge clk)
		if (reset)
			ps <= A;
		else
			ps <= ns;
endmodule

module simple_testbench();
	reg clk, reset, w;
	wire out;
	
	simple dut (clk, reset, w, out);
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial clk=1;
		always begin
			#(CLOCK_PERIOD/2);
			clk = ~clk;
		end
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		@(posedge clk);
		reset <= 1; @(posedge clk);
		reset <= 0; w <= 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		w <= 1; @(posedge clk);
		w <= 0; @(posedge clk);
		w <= 1; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		w <= 0; @(posedge clk);
		@(posedge clk);
		$stop; // End the simulation.
	end
endmodule


module DE1_SoC_testbench();
 wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
 wire [9:0] LEDR;
 reg [3:0] KEY;
 reg [9:0] SW;

 DE1_SoC dut (.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR,
.SW);

 // Try all combinations of inputs.
 integer i;
 initial begin
 SW[9] = 1'b0;
 SW[8] = 1'b0;
 for(i = 0; i <16; i++) begin
	SW[3:0] = i; #10;
 end
end
endmodule 