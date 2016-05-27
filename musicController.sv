module musicController(
	input logic clk,
	input logic [7:0] keyboard_input,
	output logic forward,
	output logic start
);

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
		start <= 1'b1;
	else if(keyboard_input == character_D)
		start <= 1'b0;
	end
endmodule

//sean is the best