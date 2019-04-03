module scores(p1, p2, enable, reset, HEX7, HEX6, HEX5, HEX4);
	input p1; // player 1 won
    input p2; // player 2 won
    input enable; // someone won
    input reset; // reset game

   	output [6:0] HEX7, HEX6, HEX5, HEX4;

	wire [3:0] score1_dig1, score1_dig2, score2_dig1, score2_dig2;
	
	counter scorep1(enable, p1, reset, {score1_dig1, score1_dig2});
	counter scorep2(enable, p2, reset, {score2_dig1, score2_dig2});
	
    hex_display hexp1_1(score1_dig1, HEX7);
    hex_display hexp1_2(score1_dig2, HEX6);
    hex_display hexp2_1(score2_dig1, HEX5);
    hex_display hexp2_2(score2_dig2, HEX4);

endmodule

// Only up to 10
module counter(enable, clk, clear_b, out);
	input enable, clk, clear_b;
	output [3:0] out;
	
	wire w0, w1, w2, w3;
	assign w0 = enable & out[0];
	assign w1 = w0 & out[1];
	assign w2 = w1 & out[2];
	assign w3 = w2 & out[3];
	
	bit_counter t0(enable, clk, clear_b, out[0]);
	bit_counter t1(w0, clk, clear_b, out[1]);
	bit_counter t2(w1, clk, clear_b, out[2]);
	bit_counter t3(w2, clk, clear_b, out[3]);
endmodule

module bit_counter(in, clk, clear_b, out);
	input clk, clear_b, in;
	output reg out;
	always @ (posedge clk, negedge clear_b) 
	begin
		if (clear_b == 1'b0)
			out <= 1'b0;
		else if (in == 1'b1 && out<9)
			out <= out + 1;
		else if (in == 1'b1 && out==9)
			out <= 0;
	end
endmodule

module hex_display(IN, OUT);
    input [3:0] IN;
	 output reg [7:0] OUT;
	 
	 always @(*)
	 begin
		case(IN[3:0])
			4'b0000: OUT = 7'b1000000;
			4'b0001: OUT = 7'b1111001;
			4'b0010: OUT = 7'b0100100;
			4'b0011: OUT = 7'b0110000;
			4'b0100: OUT = 7'b0011001;
			4'b0101: OUT = 7'b0010010;
			4'b0110: OUT = 7'b0000010;
			4'b0111: OUT = 7'b1111000;
			4'b1000: OUT = 7'b0000000;
			4'b1001: OUT = 7'b0011000;
			// Default 0
			default: OUT = 7'b1000000;
		endcase

	end
endmodule