module slowClockTrigger(input logic clk22, input logic clk50, output logic trigger);

	logic not_done = 0; 

	always_ff @(posedge clk22, posedge clk50)
		if(clk22 && not_done) {trigger, not_done} <= 2'b10; 
		else if (clk22)      {trigger, not_done} <= 2'b00;
		else 		      {trigger, not_done} <= 2'b01; 
		
endmodule 