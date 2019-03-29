`include "keyboard.v"

module TronWithFriends
	(
		CLOCK_50,							//	On Board 50 MHz
        KEY,								// User defined input
        SW,									// User defined input
		  PS2_KBCLK, PS2_KBDAT,			// Keybored input
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   							//	VGA Clock
		VGA_HS,								//	VGA H_SYNC
		VGA_VS,								//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,							//	VGA SYNC
		VGA_R, 		  						//	VGA Red[9:0]
		VGA_G,								//	VGA Green[9:0]
		VGA_B   							//	VGA Blue[9:0]
	);

	input	CLOCK_50;						//	50 MHz
	input   [17:0]   SW;					// User defined input
	input   [3:0]   KEY;					// User defined input

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output	VGA_CLK;	   					//	VGA Clock
	output	VGA_HS;							//	VGA H_SYNC
	output	VGA_VS;							//	VGA V_SYNC
	output	VGA_BLANK_N;					//	VGA BLANK
	output	VGA_SYNC_N;						//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;					//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;							// Reset key
	assign resetn = KEY[1];					// Reset key
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	assign writeEn = KEY[0];

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(out_colour),
			.x(wire_x),
			.y(wire_y),
			.plot(1'b1),
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

	// Keybored
	input PS2_KBCLK, PS2_KBDAT;
	keyboard kb(
		.CLOCK_50(CLOCK_50),
		.PS2_CLK(PS2_KBCLK),
		.PS2_DATA(PS2_KBDAT),
		.KEYSTROKE(KEYSTROKE)
  );
  wire [4:0] KEYSTROKE;
		
	// Set up display outputs
	wire [2:0] out_colour;
	wire [7:0] wire_x;
	wire [7:0] wire_y;

	// Set up players
	wire [7:0] player_1x;
	wire [7:0] player_1y;
	wire [7:0] player_2x;
	wire [7:0] player_2y;

	/*
	What does this timer do?
	
	This timer is responsible for drawing pixels on the screen for both players. It has 2 colours set
	up by default. It moves players by 1 unit to the x and y coordinates for each coordinate.

	TODO: 
	- make movement based on user input using fsm
	*/
	timer t0(
				.clk(CLOCK_50),
				.reset(SW[11]),
				.x(wire_x),
				.y(wire_y),
				.player1x(player_1x),
				.player1y(player_1y),
				.player2x(player_2x),
				.player2y(player_2y),
				.colour(out_colour),
				.SW(SW[17:0]),
				.KEYSTROKE(KEYSTROKE)
				);

	/*
	What does this FSM do?

	This user takes user input, from keys, and determines calculates the user's next position by
	adjusting the x and y coordinates. We instantiate 2 of these: 1 for each player, and it is used
	in the timer to determine the pixel's new position.

	TODO: 
	- actually make the fsm
	*/


	/*
	What does this RAM do?

	This RAM stores all the used positions by both player. This is later used for collision detection
	and start the next round.

	TODO:
	- determine ram size for our screen resolution
	- make ram store values
	- make ram check input value before storing it. if it already exists, end the game by adding score + resetting
	*/


	/*
	What does this Reset do?

	Call this at any point to reset the board and award points to a specified player. This is done by taking in the
	winning player's colour as an input.

	TODO:
	- reset pixels (should be easy, just make a wire to the display)
	- award points (need scoreboard functionality for this)
	*/


	/*
	What does this Start do?

	Starts the game by connecting the clock to the timer. Simple.

	TODO:
	- make it
	*/


	/*
	What does this Scoreboard do?

	Keeps track of the score for each player and displays them on the HEX display.

	TODO:
	- store scoreboard in a RAM instance
	- output status to HEX display
	*/

endmodule


module timer(input clk, 
			input [17:0] SW,
			input reset,
			output reg [7:0] x,
			output reg [7:0] y,
			output reg [7:0] player1x,
			output reg [7:0] player1y,
			output reg [7:0] player2x,
			output reg [7:0] player2y,
			output reg [2:0] colour,
			input [4:0] KEYSTROKE
			);
	
	reg board [0:159][0:119];
	integer i;
	initial
	begin
		// Set player 1's start position
		player1x <= 8'b00000101;
		player1y <= 8'b00000101;

		// Set player 2's start position
		player2x <= 8'b01110000;
		player2y <= 8'b01101111;
		
		// Create the board
		board[5][5] = 1;
		board[112][111] = 1;
		// Set X borders
		for( i = 0; i <= 119; i = i+1 )
			begin
				board[0][i] = 1;
				board[159][i] = 1;
			end

		// Set Y borders
		for( i = 0; i <= 159; i = i+1 )
			begin
				board[i][0] = 1;
				board[i][119] = 1;
			end
	end
			
	// Initialize variables
	wire clkout;
	ratedivider r0(clk, clkout, reset);
	integer sanjam = 1;
	integer move_x1 = 1;
	integer move_y1 = 0;
	integer move_x2 = -1;
	integer move_y2 = 0;
	integer start_clear = 1;

	
	// On every clock pulse
	always @(posedge clkout) 
	begin
		if (reset)
		begin
			if(start_clear)
			begin
				// Set player 1's start position
				player1x <= 8'b00000101;
				player1y <= 8'b00000101;

				// Set player 2's start position
				player2x <= 8'b01110000;
				player2y <= 8'b01101111;
				start_clear <= 0;
			end

			if(sanjam)
			begin
				// Direction parser for player 1
				if(KEYSTROKE == 4'b0100)			// UP
				begin
					move_x1 = 0;
					move_y1 = -1;
				end
				else if(KEYSTROKE == 4'b0101)		// DOWN
				begin
					move_x1 = 0;
					move_y1 = 1;
				end
				else if(KEYSTROKE == 4'b0110)		// LEFT
				begin
					move_x1 = -1;
					move_y1 = 0;
				end
				else if(KEYSTROKE == 4'b0111)		// RIGHT
				begin
					move_x1 = 1;
					move_y1 = 0;
				end

				// Update and store player 1's position
				player1x <= player1x + move_x1;
				player1y <= player1y + move_y1;

				// TODO: Check if occupied
				if(board[player1x][player1y] == 1)
				begin
					// Add score 1 to player 2 (need jonsens scoreboard)
					// Round over screen (need working board to test mif)
					// Copy paste reset code from below (need working board to test reset)
					integer j;
				end
				else
					board[player1x][player1y] = 1;

				// Move player 1
				colour <= 3'b101;
				x <= player1x;
				y <= player1y;
				sanjam = 0;
			end
			else
			// Direction parser for player 2
			begin
				if(KEYSTROKE == 4'b0000)			// UP
				begin
					move_x2 = 0;
					move_y2 = -1;
				end
				else if(KEYSTROKE == 4'b0001)		// DOWN
				begin
					move_x2 = 0;
					move_y2 = 1;
				end
				else if(KEYSTROKE == 4'b0010)		// LEFT
				begin
					move_x2 = -1;
					move_y2 = 0;
				end
				else if(KEYSTROKE == 4'b0011)		// RIGHT
				begin
					move_x2 = 1;
					move_y2 = 0;
				end
				// Update and store player 2's position
				player2x <= player2x + move_x2;
				player2y <= player2y + move_y2;

				// TODO: Check if occupied
				if(board[player2x][player2y] == 1)
				begin
					// Add score 1 to player 1 (need jonsens scoreboard)
					// Round over screen (need working board to test mif)
					// Copy paste reset code from below (need working board to test reset)
					integer j;
				end
				else
					board[player2x][player2y] = 1;

				// Move player 2
				colour <= 3'b011;
				x <= player2x;
				y <= player2y;
				sanjam = 1;
			end
		end
		else
		// Reset
		begin
			// Reset position to start clearing
			if(start_clear)
			begin
				player1x <= 8'b00000000;
				player1y <= 8'b00000000;
				start_clear <= 0;
				move_x1 = 1;
				move_y1 = 0;
				move_x2 = -1;
				move_y2 = 0;
			end

			// Output black pixels to clear the screen
			colour <= 3'b000;
			player1x <= player1x + 1;
			if(player1x == 180)
			begin
				player1x <= 0;
				player1y <= player1y + 1;
			end

			x <= player1x;
			y <= player1y;

		end
	end
endmodule
	

module ratedivider(clk, clkout, reset);
	input clk;
	input reset;
	output reg clkout;
	reg [24:0] count;
	
	always @(posedge clk)
	begin
		if(reset)
		begin
			if (count < 2000000)
				count <= count + 1;
			else 
			begin
				count <= 0;
				clkout <= ~clkout;
			end
		end
		else
		begin
			clkout <= ~clkout;
		end
	end
endmodule
