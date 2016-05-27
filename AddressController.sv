module AddressController(clk, rst, change, forward, address);	
  parameter width = 32;
	 
	input logic clk;
	input logic rst;
	input logic change;
	input logic forward;
	output reg[width-1:0] address = 0;

	always_ff @(posedge clk) begin
		if(rst) address <= 0;
		else if (change)
			address <= forward ? address + 1 : address - 1;
		else address <= address;
	end
endmodule
		