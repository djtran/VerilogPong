`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:35:39 12/08/2015 
// Design Name: 
// Module Name:    BinaryToSegment 
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
module binary_to_segment(bin,seven);
input [3:0] bin;
output reg [6:0] seven; //Assume MSB is A, and LSB is G

initial //Initial block, used for correct simulations
    seven=0;

always @ (*)
    case(bin)
        0:  seven = 7'b0000001;//  Some code here
        1:  seven = 7'b1001111;//  and here
        2:  seven = 7'b0010010;  //  .........
        3:	seven = 7'b0000110;
		  4:	seven = 7'b1001100;
		  5:	seven = 7'b0100100;
		  6:	seven = 7'b0100000;
		  7:	seven = 7'b0001111;
		  8:	seven = 7'b0000000;
		  9:	seven = 7'b0001100;
		  //0 means that it'll light up
		  //			     ABCDEFG
        default:
		  seven = 7'b1111111;
    endcase
endmodule   