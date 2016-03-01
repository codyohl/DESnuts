module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	input CLOCK_50; // 50MHz clock.
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output [9:0] LEDR;
	input [3:0] KEY; // True when not pressed, False when pressed
	input [9:0] SW;
	
	wire [31:0] clk;
	 parameter whichClock = 24;
	 clock_divider cdiv (CLOCK_50, clk);
	
	wire RESET = ~KEY[0];
		
	wire[63:0] plainText = 64'h0000000000000000;
	wire[55:0] knownKey  = { SW[9], 3'b000, SW[8], 3'b000, SW[7], 3'b000, SW[6], 3'b000, SW[5], 3'b000, SW[4], 3'b000, SW[3], 3'b000, SW[2], 3'b000, SW[1], 3'b000, SW[0], 3'b000, 16'h0000 };
	wire[63:0] knownCipertext;
	
	reg[55:0] key;
	reg win;
	
	
	wire[63:0] ct1;
	wire[63:0] ct2;
	wire[63:0] ct3;
	wire[63:0] ct4;
	wire[63:0] ct5;
	wire[63:0] ct6;
	wire[63:0] ct7;
	wire[63:0] ct8;
	wire[63:0] ct9;
	wire[63:0] ct10;
	wire[63:0] ct11;
	wire[63:0] ct12;
	wire[63:0] ct13;
	wire[63:0] ct14;
	wire[63:0] ct15;
	wire[63:0] ct16;
	wire[63:0] ct17;
	wire[63:0] ct18;
	wire[63:0] ct19;
	wire[63:0] ct20;
	wire[63:0] ct21;
	wire[63:0] ct22;
	wire[63:0] ct23;
	wire[63:0] ct24;
	wire[63:0] ct25;
	wire[63:0] ct26;
	wire[63:0] ct27;
	wire[63:0] ct28;
	
	
	des knownDes(knownCipertext, plainText, knownKey, 0, CLOCK_50);

	des testDes1 (ct1, plainText, key + 0, 0, CLOCK_50);
	des testDes2 (ct2, plainText, key + 1, 0, CLOCK_50);
	des testDes3 (ct3, plainText, key + 2, 0, CLOCK_50);
	des testDes4 (ct4, plainText, key + 3, 0, CLOCK_50);
	des testDes5 (ct5, plainText, key + 4, 0, CLOCK_50);
	des testDes6 (ct6, plainText, key + 5, 0, CLOCK_50);
	des testDes7 (ct7, plainText, key + 6, 0, CLOCK_50);
	des testDes8 (ct8, plainText, key + 7, 0, CLOCK_50);
	des testDes9 (ct9, plainText, key + 8, 0, CLOCK_50);
	des testDes10 (ct10, plainText, key + 9, 0, CLOCK_50);
	des testDes11 (ct11, plainText, key + 10, 0, CLOCK_50);
	des testDes12 (ct12, plainText, key + 11, 0, CLOCK_50);
	des testDes13 (ct13, plainText, key + 12, 0, CLOCK_50);
	des testDes14 (ct14, plainText, key + 13, 0, CLOCK_50);
	des testDes15 (ct15, plainText, key + 14, 0, CLOCK_50);
	des testDes16 (ct16, plainText, key + 15, 0, CLOCK_50);
	des testDes17 (ct17, plainText, key + 16, 0, CLOCK_50);
	des testDes18 (ct18, plainText, key + 17, 0, CLOCK_50);
	des testDes19 (ct19, plainText, key + 18, 0, CLOCK_50);
	des testDes20 (ct20, plainText, key + 19, 0, CLOCK_50);
	des testDes21 (ct21, plainText, key + 20, 0, CLOCK_50);
	des testDes22 (ct22, plainText, key + 21, 0, CLOCK_50);
	des testDes23 (ct23, plainText, key + 22, 0, CLOCK_50);
	des testDes24 (ct24, plainText, key + 23, 0, CLOCK_50);
	des testDes25 (ct25, plainText, key + 24, 0, CLOCK_50);
	des testDes26 (ct26, plainText, key + 25, 0, CLOCK_50);
	des testDes27 (ct27, plainText, key + 26, 0, CLOCK_50);
	des testDes28 (ct28, plainText, key + 27, 0, CLOCK_50);
	
	always @(posedge CLOCK_50) begin
		if (RESET) begin
			key <= 0;
			win <= 0;
		end
		else
			key <= key + 28;
			
		if((ct1 == knownCipertext) ||
			(ct2 == knownCipertext) ||
			(ct3 == knownCipertext) ||
			(ct4 == knownCipertext) ||
			(ct5 == knownCipertext) ||
			(ct6 == knownCipertext) ||
			(ct7 == knownCipertext) ||
			(ct8 == knownCipertext) ||
			(ct9 == knownCipertext) ||
			(ct10 == knownCipertext) ||
			(ct11 == knownCipertext) ||
			(ct12 == knownCipertext) ||
			(ct13 == knownCipertext) ||
			(ct14 == knownCipertext) ||
			(ct15 == knownCipertext) ||
			(ct16 == knownCipertext) ||
			(ct17 == knownCipertext) ||
			(ct18 == knownCipertext) ||
			(ct19 == knownCipertext) ||
			(ct20 == knownCipertext) ||
			(ct21 == knownCipertext) ||
			(ct22 == knownCipertext) ||
			(ct23 == knownCipertext) ||
			(ct24 == knownCipertext) ||
			(ct25 == knownCipertext) ||
			(ct26 == knownCipertext) ||
			(ct27 == knownCipertext) ||
			(ct28 == knownCipertext))
			win <= 1;
	end
	
	assign LEDR[0] = win;
	
	
//	reg[7:0] secretCode, guessCode;
//	reg newGuess, oldInput, oldoldInput;
//	reg[3:0] marks;
//	
//	wire loadSecretButton, loadGuessButton, newInput;
//	
//	wire RESET = loadSecretButton | SW[9];
//	
//	//assigns unused hex values to be off initially.
//	assign HEX1 = 7'b1111;
//	assign HEX4 = 7'b1111111;
//	
	// Generate clk 15 off of CLOCK_50, whichClock picks rate.
	 
	//lfsr lfsrrrrr (RESET, clk[whichClock], LEDR);

//	
//	//two key entries for loading guess or secret code
//	outputOnClock a (clk[whichClock], ~KEY[0], loadSecretButton);
//	outputOnClock b (clk[whichClock], ~KEY[3], loadGuessButton);
//	
//	//sends the load guess through another clock cycle ..................................
//	outputOnClock c (clk[whichClock], loadGuessButton, newInput);
//	
//	//hex0 is number of guesses used, stops when won or lost. 
//	counter c1 (clk[whichClock], RESET, newGuess & (HEX2 != 7'b0011001) & (HEX0 != 7'b1111111),  HEX0 | 1'b1);
//	
//	wire firstMatch, secondMatch, thirdMatch, fourthMatch;
//	
//	wire[3:0] allMatches = firstMatch + secondMatch + thirdMatch + fourthMatch;
//	//wire[0:3] matchPositions = {firstMatch, secondMatch, thirdMatch, fourthMatch};
//	
//	checkCorrectPosition aa (clk[whichClock], RESET, newInput, guessCode[1:0], secretCode[1:0], firstMatch);
//	checkCorrectPosition bb (clk[whichClock], RESET, newInput, guessCode[3:2], secretCode[3:2], secondMatch);
//	checkCorrectPosition cc (clk[whichClock], RESET, newInput, guessCode[5:4], secretCode[5:4], thirdMatch);
//	checkCorrectPosition dd (clk[whichClock], RESET, newInput, guessCode[7:6], secretCode[7:6], fourthMatch);
//	
//	
//	wire onetwo, onethree, onefour, twoone, twofour, twothree, threeone, threetwo, threefour, fourone, fourtwo, fourthree;
//	
//	
//	
//	//////////////////QUESTION: WIRES OR REG?
//	
//	
//	
//	
//	//incorrect positions
//	reg incpos1, incpos2, incpos3, incpos4;
//	
//	//sequentially goes through each comparison. if a previous comparison marked an item, it doesnt call an incorrect position.
//	always @(*) begin
//	marks = 4'b0000;
//	if (~firstMatch) begin 
//		if(onetwo & ~secondMatch) begin
//			incpos1 = 1'b1;
//			marks = marks | 4'b0010;
//		end else  if (onethree & ~thirdMatch) begin
//			incpos1 = 1'b1;
//			marks = marks | 4'b0100;
//		end else  if (onefour & ~fourthMatch ) begin
//			incpos1 = 1'b1;
//			marks = marks | 4'b1000;
//		end else begin incpos1 = 1'b0; marks = 4'b0000; end
//	end
//	else incpos1 = 0;
//	if (~secondMatch) begin 
//		if(twoone & ~firstMatch & ~marks[0]) begin
//			incpos2 = 1'b1;
//			marks = marks | 4'b0001;
//		end else  if (twothree & ~thirdMatch & ~marks[2]) begin
//			incpos2 = 1'b1;
//			marks = marks | 4'b0100;
//		end else  if (twofour & ~fourthMatch & ~marks[3]) begin
//			incpos2 = 1'b1;
//			marks = marks | 4'b1000;
//		end else begin incpos2 = 1'b0; end
//	end
//	else incpos2 = 0;
//	if (~thirdMatch) begin 
//		if(threeone & ~firstMatch & ~marks[0]) begin
//			incpos3 = 1'b1;
//			marks = marks | 4'b0001;
//		end else  if (threetwo & ~secondMatch & ~marks[1]) begin
//			incpos3 = 1'b1;
//			marks = marks | 4'b0010;
//		end else  if (threefour & ~fourthMatch & ~marks[3]) begin
//			incpos3 = 1'b1;
//			marks = marks | 4'b1000;
//		end else begin incpos3 = 1'b0; end
//	end
//	else incpos3 = 0;
//	if (~fourthMatch) begin 
//		if(fourone & ~firstMatch & ~marks[0]) begin
//			incpos4 = 1'b1;
//			marks = marks | 4'b0001;
//		end else  if (fourtwo & ~secondMatch & ~marks[1]) begin
//			incpos4 = 1'b1;
//			marks = marks | 4'b0010;
//		end else  if (fourthree & ~thirdMatch & ~marks[2]) begin
//			incpos4 = 1'b1;
//			marks = marks | 4'b0100;
//		end else begin incpos4 = 1'b0; end
//	end
//	else incpos4 = 0;
//	end
//	
//	
//	//all incorrect and not marked items here
//	wire[3:0] allincorrect = incpos1 + incpos2 + incpos3 + incpos4;
//	
//	//gets data by comparing all items to all other items
//	
//	checkCorrectPosition aag (clk[whichClock], RESET, newInput, guessCode[1:0], secretCode[3:2], onetwo);
//	checkCorrectPosition bbg (clk[whichClock], RESET, newInput, guessCode[3:2], secretCode[5:4], twothree);
//	checkCorrectPosition ccg (clk[whichClock], RESET, newInput, guessCode[5:4], secretCode[7:6], threefour);
//	checkCorrectPosition ddg (clk[whichClock], RESET, newInput, guessCode[7:6], secretCode[1:0], fourone);
//	
//	checkCorrectPosition aagg (clk[whichClock], RESET, newInput, guessCode[1:0], secretCode[5:4], onethree);
//	checkCorrectPosition bbgg (clk[whichClock], RESET, newInput, guessCode[3:2], secretCode[7:6], twofour);
//	checkCorrectPosition ccgg (clk[whichClock], RESET, newInput, guessCode[5:4], secretCode[1:0], threeone);
//	checkCorrectPosition ddgg (clk[whichClock], RESET, newInput, guessCode[7:6], secretCode[3:2], fourtwo);
//	
//	checkCorrectPosition aaggg (clk[whichClock], RESET, newInput, guessCode[1:0], secretCode[7:6], onefour);
//	checkCorrectPosition bbggg (clk[whichClock], RESET, newInput, guessCode[3:2], secretCode[1:0], twoone);
//	checkCorrectPosition ccggg (clk[whichClock], RESET, newInput, guessCode[5:4], secretCode[3:2], threetwo);
//	checkCorrectPosition ddggg (clk[whichClock], RESET, newInput, guessCode[7:6], secretCode[5:4], fourthree);
//	
//	//////////////////////////////////test
//	
//	//exact match counter
//	assignHex c22 (clk[whichClock], RESET, newInput & (HEX2 != 7'b0011001) & (HEX0 != 7'b1111111), allMatches, HEX2);
//	//incorrect position counter
//	assignHex c33 (clk[whichClock], RESET, newInput & (HEX2 != 7'b0011001) & (HEX0 != 7'b1111111), allincorrect, HEX3);
//	
//	//uses buttons as user input for loading registers.
//	always @(posedge clk[whichClock]) begin
//		if(loadSecretButton) begin
//			secretCode <= SW[7:0];
//		end
//		if(loadGuessButton)begin
//			guessCode <= SW[7:0];
//			newGuess <= 1'b1;
//		end
//		else newGuess <= 1'b0;
//	end
//	
//
//	//tells when each player wins (when exact counter is 4)
//	winner w (clk[whichClock], RESET ,  1'b0 , HEX2 == 7'b0011001, HEX5);
	
endmodule





module DE1_SoC_testbench();
	reg clk;
	wire[6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	reg[3:0] KEY;
	wire[9:0] LEDR;
		reg[9:0] SW;
	
	DE1_SoC dut (clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);
	
	// Set up the clock.
	parameter CLOCK_PERIOD=100;
	initial clk=1;
		always begin
			#(CLOCK_PERIOD/2);
			clk = ~clk;
		end
		
	// Set up the inputs to the design. Each line is a clock cycle.
	integer i,j,k;
	initial begin
//		HEX0 <= 7'b0000000;
//		HEX1 <= 7'b0000000;
//		HEX2 <= 7'b0000000;
//		HEX3 <= 7'b0000000;HEX4 <= 7'b0000000;HEX5 <= 7'b0000000;
		KEY[3:0] <= 4'b1111;
		@(posedge clk);
		SW[9] <= 1; 
		@(posedge clk);
		SW[9]	<= 0;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		//guesses
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		
//		//try all possible secret codes
//		for(k = 0; k <128; k++) begin
//			SW[7:0] <= k;@(posedge clk);
//			//simulates reset by reloading key into secret code and resetting tries
//			KEY[0] <= 0;@(posedge clk);KEY[0] <= 1;@(posedge clk);
//			//test all set inputs. (max is 10 tries).
//			for(j = 0; j <128; j++) begin
//				for(i = j; i < j + 10; i++) begin
//					SW[7:0] <= i; @(posedge clk);KEY[3] <= 0;@(posedge clk);KEY[3] <= 1;@(posedge clk);
//				end 
//				//resets every ten
//				KEY[0] <= 0;@(posedge clk);KEY[0] <= 1;@(posedge clk);
//				//KEY[3] <= 0;@(posedge clk);KEY[3] <= 1;@(posedge clk);
//			end
//		end
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop; // End the simulation.
	end
endmodule

module clock_divider (clock, divided_clocks);
 input clock;
 output [31:0] divided_clocks;
 reg [31:0] divided_clocks;

 initial
 divided_clocks = 0;

 always @(posedge clock)
 divided_clocks = divided_clocks + 1;
endmodule
