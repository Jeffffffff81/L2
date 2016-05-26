module AddressController(clk, inc, dec, rst, address);	
  parameter width = 32;
	 
	input logic clk;
	input logic inc;
	input logic dec;
	input logic rst;
	output reg[width-1:0] address = 0;

	always_ff @(posedge clk) begin
		if(rst) address <= 0;
		else if (dec) address <= address - 1;
		else if (inc) address <= address + 1;
		else address <= address;
	end
endmodule
		