module counter(clk, reset, counter);
	parameter counter_width = 32;
	input clk;
	input reset;
	output reg[counter_width-1:0] counter = 0;
	
	always_ff @(posedge clk) begin
			if(reset) begin
				counter <= 0;
			end else begin
				counter <= counter + 1;
			end
		end
		
endmodule