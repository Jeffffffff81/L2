module AddressController(clk, rst, change, forward, address);	
	parameter width = 32;
	parameter MAX_ADDRESS = 0;
	
	input logic clk;
	input logic rst;
	input logic change;
	input logic forward;
	output reg[width-1:0] address = 0;

	always_ff @(posedge clk) begin
		if(rst) address <= 0; 
		
		else if (change) begin
			if (!forward && address == 0)
				address <= MAX_ADDRESS; //If we are going backwards, we want to loop to max address.
			else
				address <= forward ? address + 1 : address - 1;
		end
		else address <= address;
	end
endmodule
		