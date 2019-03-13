module TronWithFriends ();
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [10:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign writeEn = SW[10];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(out_x),
			.y(out_y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

	wire load_x, load_y;
	wire out_x, out_y, out_colour;
    
    // Instansiate datapath
	datapath d0(
				.clk(CLOCK_50), 
				.reset_n(resetn),
				
				.in_x(SW[7:0]), 
				.in_y(SW[6:0]), 
				.in_colour(SW[9:7]), 

				.load_x(load_x),
				.load_y(load_y),

				.out_x(out_x),
				.out_y(out_y),
				.out_colour(colour)
			);

    // Instansiate FSM control
    control c0(
				.clk(CLOCK_50),
				.reset_n(resetn),
				.writeEn(writeEn),
				
				.in_write_x(KEY[1]),
				.in_write_y(KEY[2]),

				.load_x(load_x),
				.load_y(load_y),
				.load_output(KEY[3])
			);

endmodule

module datapath(
				input clk, 
				input reset_n,
				input [7:0] in_x, 
				input [6:0] in_y, 
				input [2:0] in_colour, 
				input load_x,
				input load_y,
				output reg [7:0] out_x,
				output reg [6:0] out_y,
				output reg [2:0] out_colour
				);

	always@(posedge clk)
	begin
	// Case: Reset
	if(!reset_n)
		begin
			out_x <= 8'b0;
			out_y <= 7'b0;
			out_colour <= 3'b0;
		end
	// Case: Load coords and colours
	else
		begin
			// Load x
			if(load_x)
				out_x <= in_x;
			// Load y
			if(load_y)
				out_y <= in_y;
			// Load colour
			out_colour <= in_colour;
		end
	end
endmodule

module control(
				input clk,
				input reset_n,
				input writeEn,
				input in_write_x,
				input in_write_y,
				output reg load_x,
				output reg load_y,
				output reg load_output
				);

	
    reg [3:0] current_state, next_state;
	localparam S_LOAD_X = 3'd0,
			   S_LOAD_Y = 3'd1,
			   S_LOAD_OUTPUT = 3'd2;
	
	// Reset_n
	always@(posedge clk)
	begin: resets
		if(!reset_n)
			current_state <= S_LOAD_X;
		else
			current_state <= next_state;
	end
	
	// Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
					// 1. Load X
					S_LOAD_X: 
					begin
					if(writeEn)
						next_state = S_LOAD_OUTPUT;
					else if(in_write_x)
						next_state = S_LOAD_X;
					else if(in_write_y)
						next_state = S_LOAD_Y;
					end
		
					// 2. Load Y
					S_LOAD_Y:
					begin
					if(writeEn)
						next_state = S_LOAD_OUTPUT;
					else if(in_write_x)
						next_state = S_LOAD_X;
					else if(in_write_y)
						next_state = S_LOAD_Y;
					end

					// 3. Load Output
					S_LOAD_OUTPUT:
					begin
					if(writeEn)
						next_state = S_LOAD_OUTPUT;
					else if(in_write_x)
						next_state = S_LOAD_X;
					else if(in_write_y)
						next_state = S_LOAD_Y;
					end
					default: next_state = S_LOAD_X;
				endcase
    end // state_table
	
	// Update outputs
	always@(*)
	begin: outputs
		// Reset output
		load_x = 1'b0;
		load_y = 1'b0;
		load_output = 1'b0;
		
		case(current_state)
			S_LOAD_X:
				load_x = 1'b1;
			S_LOAD_Y:
				load_y = 1'b1;
			S_LOAD_OUTPUT:
				load_output = 1'b1;
		endcase
	end
endmodule
