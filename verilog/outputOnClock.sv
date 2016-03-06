module outputOnClock (Clock, in, out);
	input Clock, in;
	reg [1:0] ns, ps;
	reg inClk;
	
	// when out is true, the the button was pressed once
	output out;
	// State encoding.
	parameter [1:0] A = 0, B = 1, C = 2;
	// Next State logic
	always @(*)
		case (ps)
			2'b00: 	if (inClk) ns = B;
						else ns = A;
			2'b01: 	if (inClk) ns = C;
						else ns = A;
			2'b10: 	if (inClk) ns = C;
						else ns = A;
			default: ns = A;
		endcase
		
	assign out = ps[0];
	
	always @(posedge Clock) 
	begin
		ps <= ns;
		inClk <= in;
	end
endmodule

module outputOnClock_testbench();
	reg clk, in, out;
	
	outputOnClock dut (clk, in, out);
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial clk=1;
		always begin
			#(CLOCK_PERIOD/2);
			clk = ~clk;
		end
		
	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		in <= 1; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 1; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 1; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 1; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 1; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		in <= 0; 
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop; // End the simulation.
	end
endmodule