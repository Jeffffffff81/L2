module AddressController(
	input clock,
	input inc,
	input dec,
	input reset,
	output reg[21:0] address = 0);
	
	always_ff @(posedge clock) begin
		if(reset) address <= 22'b0;
		else if (dec) address <= address - 1;
		else if (inc) address <= address + 1;
		else address <= address;
	end
endmodule
		