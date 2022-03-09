`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:44:11 12/01/2021 
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
		input 		     clk,
		input 	 [5:0]  starting_col, starting_row, 	// indicii punctului de start
		input  			  maze_in, 											// ofera informatii despre punctul de coordonate [row, col]
		output reg [5:0] row, col,	 							// selecteaza un rând si o coloana din labirint
		output reg		  maze_oe,											// output enable (activeaza citirea din labirint la rândul si coloana date) - semnal sincron	
		output reg		  maze_we, 											// write enable (activeaza scrierea în labirint la rândul si coloana date) - semnal sincron
		output reg		  done);	
		

	reg [4:0] state, next_state;
	reg [3:0] direction;  // Directia de deplasare
	reg ok;
	reg [6:0] x,y;
	// SUD - 0 
	// EST - 1
	// NORD - 2
	// VEST - 3
	`define S 0
	`define E 1
	`define N 2
	`define V 3


	`define Marcare_stare 0  //Marchez cu "2: pozitia curenta
	`define Verificare_finish 1  //Verific daca am gasit iesirea din labirint
	`define Citire_test_curve_90_deg 2  //Citesc daca mai am perete in dreapta mea
	`define Test_curve_90_deg 3  //Verific daca mai am sau nu perete in dreapta mea
	`define Curve_90_deg 4  //Fac curba la dreapta(Daca nu mai am perete in dreapta mea)
	`define Citire_test_turn_90_deg 5  //Citesc ce am in fata mea(Daca am perete in dreapta mea)
	`define Test_turn_90_deg 6  //Verific daca am sau nu perete in fata mea
	`define Turn_90_deg 7  //Daca am perete in fata mea, ma rotesc 90 de grade
	`define Move_forward 8	//Daca nu am perete in fata mea, fac pasul inainte
	`define Finish_reached 9	//Starea in care am ajuns la finish

	
	
	always @(posedge clk)   //Partea secventiala
	begin
		state <= next_state;
	end
	
	
	
	always @(*)  //Partea combinationala
	begin
		maze_oe=0;
		maze_we=0;
		case(state)
		`Marcare_stare:  //Marchez cu "2" pozitia curenta
		begin
			
				row=x;
				col=y;
				maze_we=1;
				next_state=`Verificare_finish;  //Urmatoarea stare este cea de verificare a finsh ului
		end
		
		
		`Verificare_finish:  //Verific daca am ajuns sau nu la iesirea din labirint
		begin
			if(x==63 || x==0 || y==63  || y==0)
			begin
				next_state=`Finish_reached;  //Daca am gasit iesirea, merg in starea de finish_reached
			end
			else
			begin
				next_state=`Citire_test_curve_90_deg;  //Daca nu am gasit iesirea, merg sa vad daca mai am perete in dreapta mea
			end
		end
		
		
		`Citire_test_curve_90_deg:  // Citesc ce am in dreapta mea(daca am in continuare mana dreapta pe zid)
		begin
			//Tin cont de directia de deplasare pentru stabilirea elementului din dreapta mea
			if(direction==`S)  
			begin
				row=x;
				col=y-1;
				maze_oe=1;
			end
			
			if(direction==`E)
			begin
				row=x+1;
				col=y;
				maze_oe=1;
			end
				
			if(direction==`N)
			begin
				row=x;
				col=y+1;
				maze_oe=1;
			end
					
			if(direction==`V)
			begin
				row=x-1;
				col=y;
				maze_oe=1;
			end
			next_state=`Test_curve_90_deg;  //Merg sa verific daca elementul din dreapta mea e zid sau nu
		end
		
		
		`Test_curve_90_deg:  //Verific daca in dreapta mea am zid sau nu
		begin
			if(maze_in==0)  // Daca in dreapta mea nu mai am perete, ma rotesc la dreapta si ma si mut pe pozitia noua (Fac curba)
			begin
				next_state=`Curve_90_deg;  //Fac curba
			end	
			if(maze_in==1)  // Daca in dreapta mea am perete, ma uit sa vad ce am in fata mea (Sa vad daca fac rotatie)
			begin
				next_state=`Citire_test_turn_90_deg;  //Merg mai departe si citesc ce am in fata mea
			end
		end
		
		
		`Curve_90_deg:  // Ma rotesc la dreapta si ma mut pe pozitia noua
		begin
			if(direction==`S)
			begin
				direction=`V;
				y=y-1;
			end 
			else	if(direction==`E)
			begin
				direction=`S;
				x=x+1;
			end
			else if(direction==`N)
			begin
				direction=`E;
				y=y+1;
			end
			else if(direction==`V)
			begin
				direction=`N;
				x=x-1;
			end
			next_state=`Marcare_stare;
		end
		
		
		`Citire_test_turn_90_deg: // Verificare ce am in fata mea (Daca am zid sau nu)
		begin
			if(direction==`S)
			begin
				row=x+1;
				col=y;
				maze_oe=1;
			end
			if(direction==`E)
			begin
				row=x;
				col=y+1;
				maze_oe=1;
			end
			if(direction==`N)
			begin
				row=x-1;
				col=y;
				maze_oe=1;
			end
			if(direction==`V)
			begin
				row=x;
				col=y-1;
				maze_oe=1;
			end
			next_state=`Test_turn_90_deg;
		end
		
		
		`Test_turn_90_deg: // Verific ce am in fata mea si decid daca ma rotesc pe loc sau fac pasul inainte(daca nu am obstacol in fata)
		begin 
			if(maze_in==1)  //Daca in fata mea am zid, ma rotesc spre stanga( pe loc )
			begin
				next_state=`Turn_90_deg;  //Ma rotesc la stanga pe loc
			end 
			if(maze_in==0) // Daca in fata mea nu am zid, fac pasul inainte
			begin
				next_state=`Move_forward;  //Fac pasul in fata
			end	
		end
		
		
		`Turn_90_deg:  //Ma rotesc la stanga(pe loc)
		begin
			if(direction==`S)
				begin
					direction=`E;
				end 
				else	if(direction==`E)
				begin
					direction=`N;
				end
				else if(direction==`N)
				begin
					direction=`V;
				end
				else if(direction==`V)
				begin
					direction=`S;
				end
				next_state=`Marcare_stare;
		end
		
		
		`Move_forward:  //Fac pasul inainte
		begin
			if(direction==`S)
			begin
				x=x+1;
			end 
			else if(direction==`E)
			begin
				y=y+1;
			end
			else if(direction==`N)
			begin
				x=x-1;
			end
			else if(direction==`V)
			begin
				y=y-1;
			end
			next_state=`Marcare_stare;
		end
		 
		 
		 `Finish_reached:  //Am ajuns la iesire
		 begin   
			done=1;
			//next_state=`Finish_reached;
		 end
		 
		 
		 default:  // Default - starea initiala(setez coordonatele initiale si aleg arbitrat o directie de deplasare default)
		 begin
			direction=`S;
			x=starting_row;
			y=starting_col;
			next_state=`Marcare_stare;
		 end
		 
		 endcase
	end

endmodule
