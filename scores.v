module scores(p1, p2, enable, reset, who);
    input p1; // player 1 won
    input p2; // player 2 won
    input enable; // someone won
    input reset; // reset game

    wire who; // 0 for if p1 won, 1 if p2
    wire scores;
    assign who = enable & y; // either x or y is 1, never both and never are they both 0.
    counter c(.enable(enable), 
              .clk(who),
              .clear_b(reset),
              .out(scores)
              )
endmodule

module bit_counter(in, clk, clear_b, out);
	input clk, clear_b, in;
	output reg out;
	always @(posedge clk, negedge clear_b)
	begin
		if (clear_b == 1'b0)
			out <= 1'b0;
		else if (in == 1'b1)
			out <= ~out;
	end
endmodule

module counter(enable, clk, clear_b, out);
	input enable, clk, clear_b;
	output [7:0] out;
	
	wire w0, w1, w2, w3, w4, w5, w6;
	assign w0 = enable & out[0];
	assign w1 = w0 & out[1];
	assign w2 = w1 & out[2];
	assign w3 = w2 & out[3];
	assign w4 = w3 & out[4];
	assign w5 = w4 & out[5];
	assign w6 = w5 & out[6];
	
	bit_counter t0(enable, clk, clear_b, out[0]);
	bit_counter t1(w0, clk, clear_b, out[1]);
	bit_counter t2(w1, clk, clear_b, out[2]);
	bit_counter t3(w2, clk, clear_b, out[3]);
	bit_counter t4(w3, clk, clear_b, out[4]);
	bit_counter t5(w4, clk, clear_b, out[5]);
	bit_counter t6(w5, clk, clear_b, out[6]);
	bit_counter t7(w6, clk, clear_b, out[7]);
	

endmodule

module datapath(
    input enable,
    input data_in,
    input ld_alu_out, 
    input ld_x, ld_a, ld_b, ld_c,
    input ld_r,
    input alu_op, 
    input [1:0] alu_select_a, alu_select_b,
    output reg [7:0] data_result
    );
    
    // input registers
    reg [7:0] a, b, c, x;

    // output of the alu
    reg [7:0] alu_out;
    // alu input muxes
    reg [7:0] alu_a, alu_b;
    
    // Registers a, b, c, x with respective input logic
    always@(posedge clk) begin
        if(!resetn) begin
            a <= 8'b0; 
            b <= 8'b0; 
            c <= 8'b0; 
            x <= 8'b0; 
        end
        else begin
            if(ld_a)
                a <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_b)
                b <= ld_alu_out ? alu_out : data_in; // load alu_out if load_alu_out signal is high, otherwise load from data_in
            if(ld_x)
                x <= data_in;

            if(ld_c)
                c <= data_in;
        end
    end
 
    // Output result register
    always@(posedge clk) begin
        if(!resetn) begin
            data_result <= 8'b0; 
        end
        else 
            if(ld_r)
                data_result <= alu_out;
    end

    // The ALU input multiplexers
    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = x;
            default: alu_a = 8'b0;
        endcase

        case (alu_select_b)
            2'd0:
                alu_b = a;
            2'd1:
                alu_b = b;
            2'd2:
                alu_b = c;
            2'd3:
                alu_b = x;
            default: alu_b = 8'b0;
        endcase
    end

    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                   alu_out = alu_a + alu_b; //performs addition
               end
            1: begin
                   alu_out = alu_a * alu_b; //performs multiplication
               end
            default: alu_out = 8'b0;
        endcase
    end
    
endmodule


module Lab_4b(SW, HEX0, CLOCK_50);
	input CLOCK_50; // Clock on machine
	input [8:0] SW; // 1:0: frequency; 2: enable; 3: reset_n; 7:4: load; 8: par_load
	output [6:0] HEX0; // Displays counter
	wire [3:0] cout;
	counter c0(SW[2], SW[7:4], SW[8], CLOCK_50, SW[3], SW[1:0], cout);
	hex h0(cout, HEX0);


endmodule


module counter(enable, load, par_load, clk, reset_n, frequency, out);
	input clk, enable, par_load, reset_n;
	input [1:0] frequency;
	input [3:0] load;
	output [3:0] out;
	
	wire [27:0] w1hz, w05hz, w025hz;
	reg cenable;
	
	ratedivider r1hz(enable, {2'b00, 26'd49999999}, clk, reset_n, w1hz);
	ratedivider r05hz(enable, {1'b0, 27'd99999999}, clk, reset_n, w05hz);
	ratedivider r025hz(enable, {28'd499999999}, clk, reset_n, w025hz);
	
	always @(*)
		begin
			case(frequency)
				2'b00: cenable = enable;
				2'b01: cenable = (w1hz == 0) ? 1 : 0;
				2'b10: cenable = (w05hz == 0) ? 1 : 0;
				2'b11: cenable = (w025hz == 0) ? 1 : 0;
			endcase
		end
		
	displaycounter d(cenable, load, par_load, clk, reset_n, out);

endmodule


module displaycounter(enable, load, par_load, clk, reset_n, q);
	input enable, clk, par_load, reset_n;
	input [3:0] load;
	output reg [3:0] q;
	
	always @(posedge clk, negedge reset_n)
	begin
		if (reset_n == 1'b0)
			q <= 4'b0000;
		else if (par_load == 1'b1)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 4'b1111)
					q <= 4'b0000;
				else
					q <= q + 1'b1;
			end
	end
endmodule


module ratedivider(enable, load, clk, reset_n, q);
	input enable, clk, reset_n;
	input [27:0] load;
	output reg [27:0] q;
	
	always @(posedge clk)
	begin
		if (reset_n == 1'b0)
			q <= load;
		else if (enable == 1'b1)
			begin
				if (q == 0)
					q <= load;
				else
					q <= q - 1'b1;
			end
	end
endmodule


// HEX

module hex(in,out);
	input [3:0] in;
	output [6:0] out;
	
	zero m1(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[0])
		);
	one m2(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[1])
		);
	two m3(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[2])
		);
	three m4(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[3])
		);
   four m5(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[4])
		);
	five m6(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[5])
		);
	six m7(
		.a(in[0]),
		.b(in[1]),
		.c(in[2]),
		.d(in[3]),
		.m(out[6])
		);
endmodule

module zero(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((b & c) | (~a & d) | (~a & ~c) | (~b & ~c & d) | (a & c & ~d) | (b & ~c & ~d));
endmodule

module one(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((~c & ~a) | (~c & ~d) | (d & a & ~b) | (~d & a & b) | (~d & ~a & ~b));
endmodule

module two(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((c & ~d) | (~c & d) | (a & ~c) | (a & ~b) | (~d & ~a & ~b));
endmodule

module three(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((c & a & ~b) | (c & ~a & b) | (d & ~a & ~b) | (~c & ~a & ~b) | (~c & a & b) | (b & ~c & ~d));
endmodule

module four(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;

   assign m = ~((b & d) | (~a & d) | (~c & ~a) | (c & d & ~b) | (~d & ~a & b));
endmodule

module five(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((b & d) | (~a & d) | (~a & c) | (~a & ~b) | (~b & c & ~d) | (~b & ~c & d));
endmodule

module six(a,b,c,d,m);
	input a;
	input b;
	input c;
	input d;
	output m;
	
	assign m = ~((d & a) | (d & b) | (~c & b) | (~a & c & ~d) | (~b & c & ~d) | (~b & ~c & d));
endmodule