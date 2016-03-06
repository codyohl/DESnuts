module lfsr(rst, clk, out);
input clk;
input rst;
output reg [8:0] out = 9'b000000000;

	always @(posedge clk) begin
		out[8] <= out[7] ^ rst;
		out[7] <= out[6];
		out[6] <= out[5];
		out[5] <= out[4];
		out[4] <= out[3];
		out[3] <= out[2];
		out[2] <= out[1];
		out[1] <= out[0];
		out[0] <= ~ (out[4] ^ out[8] );
	end
endmodule
