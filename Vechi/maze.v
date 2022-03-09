`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:33:27 12/01/2021 
// Design Name: 
// Module Name:    maze 
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
module maze(
		input 		          clk,
		input [maze_width - 1:0]  starting_col, starting_row, 	// indicii punctului de start
		input  			  maze_in, 											// ofera informa?ii despre punctul de coordonate [row, col]
		output reg [maze_width - 1:0] row, col,	 							// selecteaza un rând si o coloana din labirint
		output reg		  maze_oe,											// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
		output reg		  maze_we, 											// write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
		output reg		  done);	
		
	parameter maze_width = 6;
	reg [3:0] state, next_state;
	reg [2:0] direction;
	reg ok;
	reg [maze_width - 1:0] x,y;
	// SUD - 0 
	// EST - 1
	// NORD - 2
	// VEST - 3
	`define S 0
	`define E 1
	`define N 2
	`define V 3

	
	`define follow_wall 0
	`define mark_step 1
	`define turn_90_degrees 2
	`define curve_90_degrees 3
	`define finish_reached 4

	
	
	always @(posedge clk)   //Partea secventiala
	begin
		state <= next_state;
	end
	
	
	
	always @(*)  //Partea combinationala
	begin
		maze_oe=0;
		maze_we=0;
		case(state)
		
		`follow_wall:
		begin  // Follow wall
			maze_oe=1;
			ok=0;
			if(direction!=`S&&direction!=`N&&direction!=`E&&direction!=`V)
			begin
				direction=`S;
				x=starting_row;
				y=starting_col;
				done=0;
			end
			if(direction==`S)  // Directia de deplasare: SUD
			begin
				//maze_in[row][col]=2;
				row=x;
				col=y-1;
				if(maze_in==0)
				begin
					next_state=`curve_90_degrees;
					ok=1;
				end
				row=x+1;
				col=y;
				if(maze_in==1 && ok==0)
				begin
					next_state=`turn_90_degrees;
					ok=1;
				end
				if(ok==0)
				begin
					next_state=`mark_step;
				end
			end
			
			if(direction==`E)
			begin
				//maze_in[row][col]=2;
				row=x+1;
				col=y;
				if(maze_in==0)
				begin
					next_state=`curve_90_degrees;
					ok=1;
				end
				row=x;
				col=y+1;
				if(maze_in==1 && ok==0)
				begin
					next_state=`turn_90_degrees;
					ok=1;
				end 
				if(ok==0)
				begin
					next_state=`mark_step;
				end
				
				if(direction==`N)
				begin
					//maze_in[row][col]=2;
					row=x;
					col=y+1;
					if(maze_in==0)
					begin
						next_state=`curve_90_degrees;
						ok=1;
					end
					row=x-1;
					col=y;
					if(maze_in==1 && ok==0)
					begin
						next_state=`turn_90_degrees;
						ok=1;
					end
					if(ok==0)
					begin
						next_state=`mark_step;
					end
					
					if(direction==`V)
					begin
						//maze_in[row][col]=2;
						row=x-1;
						col=y;
						if(maze_in==0)
						begin
							next_state=`curve_90_degrees;
							ok=1;
						end 
						row=x;
						col=y-1;
						if(maze_in==1 && ok==0)
						begin
							next_state=`turn_90_degrees;
							ok=1;
						end
						if(ok==0)
						begin
							next_state=`mark_step;
						end
					end
				end
			end
		end
		
		
		`mark_step:
		begin
			ok=0;
			maze_we=1;
			if(direction==`S)
			begin
				row=x;
				col=y;
				maze_in=2;
				x=x+1;
				if(x>63)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			if(direction==`E)
			begin
				row=x;
				col=y;
				maze_in=2;
				y=y+1;
				if(y>63)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			if(direction==`N)
			begin
				row=x;
				col=y;
				maze_in=2;
				x=x-1;
				if(x<0)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			if(direction==`V)
			begin
				row=x;
				col=y;
				maze_in=2;
				y=y-1;
				if(y<0)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			if(ok==0)
			begin
				next_state=`follow_wall;
			end
			
		end
		
		
		`turn_90_degrees: 
		begin  //Turn 90 degrees Counter Clock-wise
			if(direction==`S)
			begin
				direction=`V;
			end 
			else	if(direction==`E)
			begin
				direction=`S;
			end
			else if(direction==`N)
			begin
				direction=`E;
			end
			else if(direction==`V)
			begin
				direction=`N;
			end
			next_state=`follow_wall;
		end
		 
		 `curve_90_degrees:
		 begin  //Curve 90 degrees
			maze_we=1;
			ok=0;
			if(direction==`S)
			begin
				direction=`V;
				row=x;
				col=y;
				maze_in=2;
				y=y-1;
				if(y<0)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end 
			else	if(direction==`E)
			begin
				direction=`S;
				row=x;
				col=y;
				maze_in=2;
				x=x+1;
				if(x>63)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			else if(direction==`N)
			begin
				direction=`E;
				row=x;
				col=y;
				maze_in=2;
				y=y+1;
				if(y>63)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			else if(direction==`V)
			begin
				direction=`N;
				row=x;
				col=y;
				maze_in=2;
				x=x-1;
				if(x<0)
				begin
					next_state=`finish_reached;
					ok=1;
				end
			end
			if(ok==0)
			begin
				next_state=`follow_wall;
			end
		 end
		 
		 `finish_reached:
		 begin   //Finish was reached
			done=1;
		 end
		 
		 endcase
	end

endmodule
