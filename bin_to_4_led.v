`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:16:08 12/15/2015 
// Design Name: 
// Module Name:    bin_to_4_led 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module bin_to_4_led(clk, num, led, a);

	input clk;
	

	input  [13:0]num;


	output reg [6:0] led;
	output reg [3:0] a;
	

	wire [27:0] segs;
	wire [15:0] bcd;
	reg slow_clk;
	initial slow_clk=0;

	bin_to_bcd conv(slow_clk, num, bcd[15:12],bcd[11:8],bcd[7:4],bcd[3:0]);

	dec_to_led led0(bcd[15:12], segs[27:21]);

	dec_to_led led1(bcd[11:8], segs[20:14]);

	dec_to_led led2(bcd[7:4], segs[13:7]);

	dec_to_led led3(bcd[3:0], segs[6:0]);

	

	reg [16:0] slow_count;	

	initial slow_count=0;

	always @ (posedge clk)begin

		slow_count = slow_count + 1'b1;	

		slow_clk = slow_count[16];

	end

	

	reg [1:0] led_c;

	initial led_c = 0;

	

	always @(posedge slow_clk) led_c = led_c+1;




	always @(posedge slow_clk)

	case(led_c)

		2'b00: begin

			led = segs[6:0];

			a = 4'b1110;

		end

		2'b01: begin

			led = segs[13:7];

			a = 4'b1101;

		end

		2'b10: begin

			led = segs[20:14];

			a = 4'b1011;

		end

		2'b11: begin

			led = segs[27:21];

			a = 4'b0111;

		end

	endcase
endmodule

module bin_to_bcd(slow_clk, num, t,h,d,o);

	input slow_clk;

	input [13:0] num;

	output reg[3:0] t,h,d,o;

	

	integer i;

	always@(slow_clk)

	begin

		t = 4'd0;

		h = 4'd0;

		d = 4'd0;

		o = 4'd0;

		for(i=13; i>=0; i=i-1)

		begin

			if(t>=5)

				t = t+3;

			if(h>=5)

				h = h+3;

			if(d>=5)

				d = d+3;

			if(o>=5)

				o = o+3;

			t = t << 1;

			t[0] = h[3];

			h = h << 1;

			h[0] = d[3];

			d = d << 1;

			d[0] = o[3];

			o = o << 1;

			o[0] = num[i];

		end

	end		
endmodule

module dec_to_led(BCD, SevenSeg);

	input [3:0]BCD; 

	output reg [6:0] SevenSeg;

	always @(BCD)

	case(BCD)

		4'b0000: SevenSeg = 7'b0000001;

		4'b0001: SevenSeg = 7'b1001111;

		4'b0010: SevenSeg = 7'b0010010;

		4'b0011: SevenSeg = 7'b0000110;

		4'b0100: SevenSeg = 7'b1001100;

		4'b0101: SevenSeg = 7'b0100100;

		4'b0110: SevenSeg = 7'b0100000;

		4'b0111: SevenSeg = 7'b0001111;

		4'b1000: SevenSeg = 7'b0000000;

		4'b1001: SevenSeg = 7'b0000100;

		default: SevenSeg = 7'b1111111;

	endcase

endmodule