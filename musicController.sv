module musicController(clk, keyboard_input, forward, pause, restart, kybrd_data_ready);

 input logic clk;
 input logic kybrd_data_ready;
 input logic [7:0] keyboard_input;
 output reg forward = 1;
 output reg pause = 1;
 output reg restart = 0;

 parameter character_B = 8'h42;
 parameter character_D = 8'h44;
 parameter character_E = 8'h45;
 parameter character_F = 8'h46;	
 parameter character_R = 8'h52; 
 
 always_ff @(posedge clk)
begin
	if(keyboard_input == character_F)
		forward <= 1'b1;
	else if(keyboard_input == character_B)
		forward <= 1'b0;
	else if(keyboard_input == character_E)
		pause <= 1'b0;
	else if(keyboard_input == character_D)
		pause <= 1'b1;
	else if((keyboard_input == character_R) && kybrd_data_ready)
		restart <= 1'b1;
	else
		restart <= 1'b0;
	end
endmodule