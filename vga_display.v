`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Boston University
// Engineer: Zafar M. Takhirov
// 
// Create Date:    12:59:40 04/12/2011 
// Design Name: EC311 Support Files
// Module Name:    vga_display 
// Project Name: Lab5 / Lab6 / Project
// Target Devices: xc6slx16-3csg324
// Tool versions: XILINX ISE 13.3
// Description: 
//
// Dependencies: vga_controller_640_60
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_display(rst, clk, R, G, B, HS, VS, R_control, G_control, B_control, up, down, left, right, led, a);
	input rst;	// global reset
	input clk;	// 100MHz clk
	
	
	///// 7 Seg
	output [6:0] led;
	output [3:0] a;
	
	// color inputs for a given pixel
	input [2:0] R_control, G_control;
	input [1:0] B_control; 
	
	//State Machine Parameters//
	parameter S_IDLE = 0;		//0000
	parameter S_UP = 1;			//0001
	parameter S_DOWN = 2;		//0010
	parameter S_LEFT = 4;		//0100
	parameter S_RIGHT = 8;		//1000
	
	reg [3:0] state, next_state;
	reg [3:0] ballstate, ballnext;
	reg [13:0] hitcount;
	reg ballVert;
	
	parameter ball_left = 1;
	parameter ball_right = 2;
	parameter rad = 10;
	///////////////////////////
	
	input up,down,left,right;
	reg [10:0] x_AI, y_AI;
	reg [10:0] x_play, y_play;
	reg [10:0] x_ball, y_ball;
	reg slow_clk; //For player speed
	reg ball_clock; //For ball speed
		
	initial begin							//Initialize positions of gameObjects
		x_play = 50; y_play = 240;
		x_ball = 360; y_ball = 240;
		x_AI = 560; y_AI = 240;
		
	end	
	
	// color outputs to show on display (current pixel)
	output reg [2:0] R, G;
	output reg [1:0] B;
	
	// Synchronization signals
	output HS;
	output VS;
	
	// controls:
	wire [10:0] hcount, vcount;	// coordinates for the current pixel
	wire blank;	// signal to indicate the current coordinate is blank
	//wire figure;	// the figure you want to display
	reg figure;
	
	/////////////////////////////////////////////////////
	// Begin clock division
	parameter N = 2;	// parameter for clock division
	reg clk_25Mhz;
	reg [N-1:0] count;
	always @ (posedge clk) begin
		count <= count + 1'b1;
		clk_25Mhz <= count[N-1];
	end
	// End clock division
	/////////////////////////////////////////////////////
	
	////////////////////////////////////////////
    // slow clock for position update - optional
    reg [19:0] slow_count;
    always @ (posedge clk)begin
        slow_count = slow_count + 1'b1;		//Count up a really big number
        slow_clk = slow_count[19];				//After 2^23-1, you'll get a 1;
    end
    /////////////////////////////////////////
	 
	 //clock for ball
	 reg[20:0] slow_ball;
	 always @ (posedge clk) begin
		slow_ball = slow_ball + 1'b1;
		ball_clock = slow_ball[20];
	end
	
	//Boundaries to draw the board, paddles, and ball
	assign player = (hcount >= x_play & hcount <= (x_play + 10) & vcount >= y_play & vcount <= (y_play + 100));
	assign AI = (hcount >= x_AI & hcount <= (x_AI + 10) & vcount >= y_AI & vcount <= (y_AI + 100));
	assign ball = ((hcount-x_ball)*(hcount-x_ball)+(vcount-y_ball)*(vcount-y_ball)<rad*rad);
	
	assign game = (((hcount>10)&(hcount<=30)   &  (vcount>120)&(vcount<180))|
						((hcount>30)&(hcount<=50)   &  (vcount>100)&(vcount<200))|
						((hcount>50)&(hcount<=70)   &  ((vcount>80)&(vcount<120) | (vcount>180)&(vcount<220)))|
						((hcount>70)&(hcount<=90)   &  ((vcount>80)&(vcount<100) | (vcount>200)&(vcount<220)))|
						((hcount>90)&(hcount<=110)  &  ((vcount>80)&(vcount<100) | (vcount>200)&(vcount<220)  | (vcount>140)&(vcount<160) ))|
						((hcount>110)&(hcount<=150) &  ((vcount>80)&(vcount<100) | (vcount>140)&(vcount<220)))|
						
     					((hcount>170)&(hcount<=190) &  (vcount>120)&(vcount<220))|
						((hcount>190)&(hcount<=210) &  (vcount>100)&(vcount<220))|
						((hcount>210)&(hcount<=230) &  ((vcount>80)&(vcount<120) | (vcount>160)&(vcount<180)))|
						((hcount>230)&(hcount<=250) &  ((vcount>80)&(vcount<100) | (vcount>160)&(vcount<180)))|
						((hcount>250)&(hcount<=270) &  ((vcount>80)&(vcount<120) | (vcount>160)&(vcount<180)))|
						((hcount>270)&(hcount<=290) &  (vcount>100)&(vcount<220))| 
						((hcount>290)&(hcount<=310) &  (vcount>120)&(vcount<220))|
						 
						((hcount>330)&(hcount<=370) &  (vcount>80) &(vcount<220))|
						((hcount>370)&(hcount<=390) &  (vcount>100)&(vcount<160))|
						((hcount>390)&(hcount<=410) &  (vcount>120)&(vcount<180))|
						((hcount>410)&(hcount<=430) &  (vcount>100)&(vcount<160))|
						((hcount>430)&(hcount<=470) &  (vcount>80) &(vcount<220))|
						 
						((hcount>490)&(hcount<=530) &  (vcount>80) &(vcount<220))|
						((hcount>530)&(hcount<=610) &  ((vcount>80)&(vcount<100) | (vcount>200)&(vcount<220)  | (vcount>140)&(vcount<160) ))|
						((hcount>610)&(hcount<=630) &  ((vcount>80)&(vcount<100) | (vcount>200)&(vcount<220)))
						)
						;
						 
	assign over = (((hcount>10)&(hcount<=30)   &  (vcount>260)&(vcount<360))|
						((hcount>30)&(hcount<=50)   &  (vcount>240)&(vcount<380))|
						((hcount>50)&(hcount<=110)  &  ((vcount>240)&(vcount<260)| (vcount>360)&(vcount<380)))|
						((hcount>110)&(hcount<=130) &  (vcount>240)&(vcount<380))|
						((hcount>130)&(hcount<=150) &  (vcount>260)&(vcount<360))|
						
     					((hcount>170)&(hcount<=190) &  (vcount>240)&(vcount<320))|
						((hcount>190)&(hcount<=210) &  (vcount>240)&(vcount<340))|
						((hcount>210)&(hcount<=230) &  (vcount>320)&(vcount<360))|
						((hcount>230)&(hcount<=250) &  (vcount>340)&(vcount<380))|
						((hcount>250)&(hcount<=270) &  (vcount>320)&(vcount<360))|
						((hcount>270)&(hcount<=290) &  (vcount>240)&(vcount<340))|
						((hcount>290)&(hcount<=310) &  (vcount>240)&(vcount<320))|
						 
						((hcount>330)&(hcount<=370) &  (vcount>240)&(vcount<380))|
						((hcount>370)&(hcount<=450) &  ((vcount>240)&(vcount<260)| (vcount>300)&(vcount<320)  | (vcount>360)&(vcount<380) ))|
						((hcount>450)&(hcount<=470) &  ((vcount>240)&(vcount<260)| (vcount>360)&(vcount<380)))|

						((hcount>490)&(hcount<=530) &  (vcount>240)&(vcount<380))|
						((hcount>530)&(hcount<=550) &  ((vcount>240)&(vcount<260)| (vcount>320)&(vcount<340)))|
						((hcount>550)&(hcount<=570) &  ((vcount>240)&(vcount<260)| (vcount>320)&(vcount<360)))|
						((hcount>570)&(hcount<=590) &  ((vcount>240)&(vcount<260)| (vcount>300)&(vcount<380)))|
						((hcount>590)&(hcount<=610) &  ((vcount>240)&(vcount<320)| (vcount>340)&(vcount<380)))|
						((hcount>610)&(hcount<=630) &  ((vcount>260)&(vcount<260)| (vcount>360)&(vcount<380)))
						)
						;
	
//	assign eyes = (hcount >= 220 & hcount <= 240 & vcount >= 100 & vcount <= 250) | (hcount >= 400 & hcount <= 420 & vcount >= 100 & vcount <= 250);
//	assign mouth = (hcount >= 200 & hcount <= 220 & vcount >= 300 & vcount <= 450) | (hcount >= 420 & hcount <= 440 & vcount >= 300 & vcount <= 450) | (hcount >=220 & hcount <= 420 & vcount >=300 & vcount <= 320);
	
	assign board = (hcount >= 0 & hcount <= 640 & vcount >= 45 & vcount <=50) | (hcount >= 0 & hcount <= 640 & vcount >= 450 & vcount <=455);
	
	initial begin
		ballstate = ball_right;
		ballnext = ball_right;
		hitcount = 0;
		ballVert = 0;
	end
	
	always @ (posedge ball_clock) begin
		ballstate = ballnext;
		if(rst) begin
			ballstate = ball_left;
		end
	end
	
	assign collideX = (x_ball - 10) < (x_play + 10) & (x_ball - 10) > x_play;
	assign collideY = (y_ball + 10) >= (y_play) & (y_ball + 10) <= (y_play + 100);
	
	assign collideAIX = (x_ball + 10) < (x_AI + 10) & (x_ball + 10) > x_AI;
	assign collideAIY = (y_ball + 10) >= (y_AI) & (y_ball + 10) <= (y_AI+ 100);
	/////////////////////////////////////////
	//////Ball movement state machine////////
	/////////////////////////////////////////
	always @ (posedge ball_clock) begin
	
		if(rst) begin
			x_ball = 360; y_ball = 240;
			ballnext = ball_right;
			hitcount = 0;
		end
	
		if ((y_ball - 10) <= 50) ballVert = 0;
		else if ((y_ball + 10) >= 450) ballVert = 1;
	
		case(ballstate)
			ball_left: begin
				x_ball = x_ball - hitcount/2 - 3;
				if (collideX & collideY) begin		//If you hit the paddle, reverse directions
					x_ball =(x_ball + 2*(hitcount/2 + 3));
					ballnext = ball_right;				//Speedy balls
					hitcount = hitcount + 1;
				end
				
				if (ballVert == 0) y_ball = y_ball + hitcount/6 + 2;		//Vertical Motion
				else y_ball = y_ball - hitcount/6 - 2;
				
				
				if (x_ball < 25)
				ballnext = 4'b0;		//Go to default case
				
			end								
			
			ball_right: begin
				x_ball = x_ball + hitcount/2 + 3;
				if (collideAIX & collideAIY) begin			//If the AI hit the ball
					x_ball = (x_ball - 2*(hitcount/2 + 3));
					ballnext = ball_left;
				end
					
				if (ballVert == 0) y_ball = y_ball + hitcount/4 + 2;		//Vertical Motion
				else y_ball = y_ball - hitcount/4 - 2;
				
				if (x_ball > 620) begin
					///Should probably put in some sort of win screen or something. Or this would be where you increment score I suppose.
					x_ball = 360;
					hitcount = 0;
				end
			end
					
			
			default: begin

			end
		endcase
	end
	
	////////////////////////////////////////////
	/////////Player State Machine///////////////
	////////////////////////////////////////////
    
    always @ (posedge slow_clk)begin
        state = next_state; 
    end

    always @ (posedge slow_clk) begin
		if(rst) begin 
			x_play = 50; y_play = 240;
		end
        case (state)
            S_IDLE: next_state = {right,left,down,up}; // if input is 0000
            S_UP: begin // if input is 0001
                if (y_play >= 50) y_play = y_play - 5;
                next_state = {right,left,down,up};
				end
            S_DOWN: begin // if input is 0010
					if (y_play <= 350) y_play = y_play + 5;
					next_state = {right,left,down,up};
				end
				S_LEFT: begin //0100
					x_play = x_play;
					next_state = {right, left, down, up};
				end
				S_RIGHT: begin // 1000
					x_play = x_play;
					next_state = {right, left, down, up};
				end
				default: next_state = 4'b0000;
        endcase
    end
	 /////////////////////////////////////////
	 //////////AI Machine//////////////
	 ////////////////////////////////////////
	 
	 always @ (posedge slow_clk) begin
		if (rst) begin
			x_AI = 560;           
		end
		if(y_AI >=50) begin
			if(y_AI + 50 >= y_ball + 12) y_AI = y_AI - 2;
		end
		if(y_AI+100 <= 450) begin
			if(y_AI + 50 <= y_ball + 12) y_AI = y_AI + 2;		//If past center, move it in right direction.
		end
	 end
	 
	
	// Call driver
	vga_controller_640_60 vc(
		.rst(rst), 
		.pixel_clk(clk_25Mhz), 
		.HS(HS), 
		.VS(VS), 
		.hcounter(hcount), 
		.vcounter(vcount), 
		.blank(blank));
		
	bin_to_4_led(.clk(clk),.num(hitcount),.led(led),.a(a));
	
	// draw figure;

	always @ (posedge clk) begin
		if(x_ball > 30) figure = ~blank & (player | ball | board | AI);
		else if(x_ball <= 30) figure = ~blank & (game | over);
	end

//	assign figure = ~blank & (player | ball);
	
	// send colors:
	always @ (posedge clk) begin
		if (figure) begin	// if you are within the valid region
			if(x_ball > 30) begin	//If you are within play
				if(ball | board) begin
					R = 3'b111;
					G = 3'b111;
					B = 2'b11;
				end
				else if(AI) begin
					R = R_control;
					G = ~G_control;
					B = B_control;
				end
				else begin
					R = R_control;
					G = G_control;
					B = B_control;
				end
			end
			else begin	//If you are game over
				R = R_control;
				G = G_control;
				B = B_control;
			end
		end
		else begin	// if you are outside the valid region
			R = 0;
			G = 0;
			B = 0;
		end
	end

endmodule
