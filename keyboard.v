module keyboard(clk, data, dir, reset);

	input [3:0] data;
	input clk;

	output reg [4:0] dir;
	output reg reset = 0;

	reg [7:0] code;
	reg [10:0]keyCode, previousCode;
	reg recordNext = 0;
    
	integer count = 0;
	
	always@(negedge clk)
	begin
		case(~data)
			4'b0001: dir <= 5'b00010;
			4'b0010: dir <= 5'b10000;
			4'b0100: dir <= 5'b01000;
			4'b1000: dir <= 5'b00100;
			default: dir <= dir;
		endcase
	end
endmodule
