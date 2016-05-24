
//outputs 1'b1 (trigger) for one fastClock cycle on posedge of slowClock
module slowClockTrigger(input logic slowClock, input logic fastClock, output logic trigger);

	logic not_done = 0; 

	always_ff @(posedge slowClock, posedge fastClock)
		if(slowClock && not_done) {trigger, not_done} <= 2'b10; 
		else if (slowClock)      {trigger, not_done} <= 2'b00;
		else 		      {trigger, not_done} <= 2'b01; 
		
endmodule 