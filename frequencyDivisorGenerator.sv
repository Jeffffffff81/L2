
/*
* Module: frequencyDivisorGenerator 
*
* inputs: key_0, key_1, key_2
* outputs: frequency_divisor
*
* This module generates the appropriate divisor in ordet to play the song 
* at a certain speed. Its default speed is 22KHz. 
*
*/

module frequencyDivisorGenerator(
				key_0, key_1, key_2,
				 clk, 
				frequency_divisor);
parameter max_divisor = 11236000, min_divisor = 100;

wire [31:0] next_speed_down, next_speed_up; 

input logic key_0, key_1, key_2, clk; 
output reg[31:0] frequency_divisor = 32'd1136; 

//next_speed_down and next_speed_up values
assign next_speed_up = (frequency_divisor - 1) > min_divisor ? frequency_divisor - 1 : frequency_divisor;
assign next_speed_down = (frequency_divisor + 1) < max_divisor ? frequency_divisor + 1 : frequency_divisor;   
									

//register to control next frequency output 							
always_ff @(posedge clk)
	begin 
		if (key_2 == 1'b1)        frequency_divisor <= 32'd1136;  //47800  1136
		else if (key_0 == 1'b1)	  frequency_divisor <= next_speed_up; //decrease the divisor 
		else if (key_1 == 1'b1)	  frequency_divisor <= next_speed_down; //increase the divisor 
	end	

endmodule 