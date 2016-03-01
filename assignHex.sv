module assignHex(clk, Reset, newInput, set, out);
output reg [6:0] out;
input[3:0] set;
input clk, Reset, newInput;
reg ps;
reg [6:0] hexout;

always @(posedge clk)
	begin	
		ps <= newInput;			//why does this wait a clock cycle?
		if(Reset)
			hexout <= 7'b1000000;
		else if(ps) begin	
			case(set)
			4'b0000: hexout <= 7'b1000000;
			4'b0001: hexout <= 7'b1111001;
			4'b0010: hexout <= 7'b0100100;
			4'b0011: hexout <= 7'b0110000;
			4'b0100: hexout <= 7'b0011001;
			endcase
		end
	end
		
assign out = hexout;

endmodule

module assignHex_testbench();
	reg [6:0] out;
	reg[3:0] set;
	reg clk, Reset, newInput;
	reg ps;
	reg [6:0] hexout;
	
	assignHex dut (clk, Reset, newInput, set, out);
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial clk=1;
		always begin
			#(CLOCK_PERIOD/2);
			clk = ~clk;
		end
		
	// Set up the inputs to the design. Each line is a clock cycle.
	integer i;
	initial begin
		Reset <= 1;
		newInput <= 0;
		set <= 4'b0000;
		@(posedge clk);
		Reset <= 0;
		@(posedge clk);
		@(posedge clk);
		newInput <= 0;
		@(posedge clk);
		@(posedge clk);
		set <= 4'b0001;
		newInput <= 1;
		@(posedge clk);
		set <= 4'b0010;
		newInput <= 1;
		//test all set inputs.
		for(i = 0; i <16; i++) begin
			set <= i; @(posedge clk);
		end 
		Reset <= 1;
		@(posedge clk);
		Reset <= 0;
		@(posedge clk);
		@(posedge clk);
		set <= 4'b0011;
		newInput <= 1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		newInput <= 0;
		@(posedge clk);
		newInput <= 1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		set <= set + 1'b1;
		@(posedge clk);
		@(posedge clk);
		$stop; // End the simulation.
	end
endmodule