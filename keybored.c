`timescale 1ns / 1ps

// This code was provided by India Gang ( https://www.instructables.com/id/PS2-Keyboard-for-FPGA/ )
// Go India Go!
// Jk but it's from that site, idk if the guy's acc in a gang called India Gang

module Keyboard(
	input CLOCK_50,	//board clock
  	input PS2_CLK,	//keyboard clock and data signals
  	input PS2_DATA,
   	output reg [7:0] KEYSTROKE // Output the key that was pressed
   );

	// Valid inputs for Tron With Friends are Arrows and WASD
	wire [7:0] ARROW_UP = 8'h75;
	wire [7:0] ARROW_DOWN = 8'h72;
	wire [7:0] ARROW_LEFT = 8'h6B;
	wire [7:0] ARROW_RIGHT = 8'h74;
	wire [7:0] W = 8'h1D;
 	wire [7:0] A = 8'h1C;
 	wire [7:0] S = 8'h1B;
 	wire [7:0] D = 8'h23;
	wire [7:0] SPACE = 8'h29;

	reg read;				//this is 1 if still waits to receive more bits 
	reg [11:0] count_reading;		//this is used to detect how much time passed since it received the previous codeword
	reg PREVIOUS_STATE;			//used to check the previous state of the keyboard clock signal to know if it changed
	reg scan_err;				//this becomes one if an error was received somewhere in the packet
	reg [10:0] scan_code;			//this stores 11 received bits
	reg [7:0] CODEWORD;			//this stores only the DATA codeword
	reg TRIG_ARR;				//this is triggered when full 11 bits are received
	reg [3:0]COUNT;				//tells how many bits were received until now (from 0 to 11)
	reg TRIGGER = 0;			//This acts as a 250 times slower than the board clock. 
	reg [7:0]DOWNCOUNTER = 0;		//This is used together with TRIGGER - look the code

	//Set initial values
	initial begin
		PREVIOUS_STATE = 1;		
		scan_err = 0;		
		scan_code = 0;
		COUNT = 0;			
		CODEWORD = 0;
		LED = 0;
		read = 0;
		count_reading = 0;
		KEYSTROKE = 0;
	end

	always @(posedge CLK) begin				//This reduces the frequency 250 times
		if (DOWNCOUNTER < 249) begin			//and uses variable TRIGGER as the new board clock 
			DOWNCOUNTER <= DOWNCOUNTER + 1;
			TRIGGER <= 0;
		end
		else begin
			DOWNCOUNTER <= 0;
			TRIGGER <= 1;
		end
	end
	
	always @(posedge CLK) begin	
		if (TRIGGER) begin
			if (read)				//if it still waits to read full packet of 11 bits, then (read == 1)
				count_reading <= count_reading + 1;	//and it counts up this variable
			else 						//and later if check to see how big this value is.
				count_reading <= 0;			//if it is too big, then it resets the received data
		end
	end


	always @(posedge CLK) begin		
	if (TRIGGER) begin						//If the down counter (CLK/250) is ready
		if (PS2_CLK != PREVIOUS_STATE) begin			//if the state of Clock pin changed from previous state
			if (!PS2_CLK) begin				//and if the keyboard clock is at falling edge
				read <= 1;				//mark down that it is still reading for the next bit
				scan_err <= 0;				//no errors
				scan_code[10:0] <= {PS2_DATA, scan_code[10:1]};	//add up the data received by shifting bits and adding one new bit
				COUNT <= COUNT + 1;			//
			end
		end
		else if (COUNT == 11) begin				//if it already received 11 bits
			COUNT <= 0;
			read <= 0;					//mark down that reading stopped
			TRIG_ARR <= 1;					//trigger out that the full pack of 11bits was received
			//calculate scan_err using parity bit
			if (!scan_code[10] || scan_code[0] || !(scan_code[1]^scan_code[2]^scan_code[3]^scan_code[4]
				^scan_code[5]^scan_code[6]^scan_code[7]^scan_code[8]
				^scan_code[9]))
				scan_err <= 1;
			else 
				scan_err <= 0;
		end	
		else  begin						//if it yet not received full pack of 11 bits
			TRIG_ARR <= 0;					//tell that the packet of 11bits was not received yet
			if (COUNT < 11 && count_reading >= 4000) begin	//and if after a certain time no more bits were received, then
				COUNT <= 0;				//reset the number of bits received
				read <= 0;				//and wait for the next packet
			end
		end
	PREVIOUS_STATE <= PS2_CLK;					//mark down the previous state of the keyboard clock
	end
	end


	always @(posedge CLK) begin
		if (TRIGGER) begin					//if the 250 times slower than board clock triggers
			if (TRIG_ARR) begin				//and if a full packet of 11 bits was received
				if (scan_err) begin			//BUT if the packet was NOT OK
					CODEWORD <= 8'd0;		//then reset the codeword register
				end
				else begin
					CODEWORD <= scan_code[8:1];	//else drop down the unnecessary  bits and transport the 7 DATA bits to CODEWORD reg
				end				//notice, that the codeword is also reversed! This is because the first bit to received
			end					//is supposed to be the last bit in the codeword…
			else CODEWORD <= 8'd0;				//not a full packet received, thus reset codeword
		end
		else CODEWORD <= 8'd0;					//no clock trigger, no data…
	end
	
	always @(posedge CLK) begin
		if (CODEWORD == ARROW_UP)				//if the CODEWORD has the same code as the ARROW_UP code
			LED <= LED + 1;					//count up the LED register to light up LEDs
		else if (CODEWORD == ARROW_DOWN)			//or if the ARROW_DOWN was pressed, then
			LED <= LED - 1;					//count down LED register 

	end

	// Controls for TurfWars
	  always @(posedge CLOCK_50) begin
	    if (CODEWORD == ARROW_UP)
	      KEYSTROKE <= 4'b0000;
	    else if (CODEWORD == ARROW_DOWN)
	      KEYSTROKE <= 4'b0001;
	    else if (CODEWORD == ARROW_LEFT)
	      KEYSTROKE <= 4'b0010;
	    else if (CODEWORD == ARROW_RIGHT)
	      KEYSTROKE <= 4'b0011;
	    else if (CODEWORD == W)
	      KEYSTROKE <= 4'b0100;
	    else if (CODEWORD == S)
	      KEYSTROKE <= 4'b0101;
	    else if (CODEWORD == A)
	      KEYSTROKE <= 4'b0110;
	    else if (CODEWORD == D)
	      KEYSTROKE <= 4'b0111;
	    else if (CODEWORD == SPACE)
	      KEYSTROKE <= 4'b1111;
endmodule
