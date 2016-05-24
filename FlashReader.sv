module FlashReader(
	input 					clk, 
	
	//Interface to flash:	
	input 					waitrequest, 
	output logic 			read, 
	input[31:0] 			readdata,
	input 					readdatavalid,
	output logic[3:0] 	byteenable,
	
	//Interface address controller:
	output logic 			inc,
	output logic			 dec,
	output logic 			reset,
	
	//Interface to audio register:
	output logic 			enable,
	output logic[15:0]  audioout,
	
	//interface to slowClockTrigger:
	input			 			samplenow //this is not edge sensitive
	); 
	
	
	assign byteenable = 4'b1111; //for simplicity, just get all 32 bits everytime.
	assign start = samplenow; //for now, we start if the sample clock tells us.
	
	logic[3:0] next_state, state;
	
	parameter IDLE_A = 4'b0000; //wait for start, set inc to 0
	parameter S0_A = 4'b0001; //set read to one
	parameter S1_A = 4'b0010; //set read to 0, wait for !waitrequest and validdata, set audio_out and enable.
	
  parameter IDLE_B = 4'b0011; //wait for start, set enable to 0
	parameter S0_B = 4'b0100;  //set read to one
	parameter S1_B = 4'b0101;	//set read to 0. same as S1_A
	parameter S2_B = 4'b0110;  //set inc to 1. set enable to 0
	
	always_ff @(posedge clk)
		state <= next_state;
	
	always_comb 
	 casex(state)
	   default: begin
	             next_state = IDLE_A;
	             read = 1'b0;
	             inc = 1'b0;
	             dec = 1'b0;
	             reset = 1'b0;
	             enable = 1'b0;
	             audioout = 16'b0;
	            end
	            
	    IDLE_A: begin
	             if(start) 
	               next_state = S0_A;
	             else 
	               next_state = IDLE_A; 
	               
	             read = 1'b0;
	             inc = 1'b0;
	             dec = 1'b0;
	             reset = 1'b0;
	             enable = 1'b0;
	            end
	            
	    S0_A:   begin
	             next_state = S1_A;
	             read = 1'b1;
	            end  
	              
	    S1_A:   begin
	             if(!waitrequest & readdatavalid)
	               next_state = IDLE_B;
	             else
	               next_state = S1_A;
	             
	             read = 1'b0;
	             audioout = readdata[15:0];
	             enable = readdatavalid;
	            end
	            
	    IDLE_B: begin
	             if(start) 
	               next_state = S0_B;
	             else 
	               next_state = IDLE_B;
	             
	            	read = 1'b0;
	             inc = 1'b0;
	             dec = 1'b0;
	             reset = 1'b0;
	             enable = 1'b0;
	            end
	            
	     S0_B:  begin
	             next_state = S1_B;
	             read = 1'b1;
	            end
	     S1_B:  begin
	             if(!waitrequest & readdatavalid)
	               next_state = S2_B;
	             else
	               next_state = S1_B;
	             
	             read = 1'b0;
	             audioout = readdata[31:16];
	             enable = readdatavalid;
	            end
	      S2_B: begin
	             next_state = IDLE_A;
	             inc = 1'b1;
	             enable = 1'b0;
	            end
	             
	 endcase
	
	/*
	always_comb begin
		casex({state, waitrequest, readdatavalid})
			{IDLE_A, 1'bX, 1'bX}: {next_state, inc} = (start) ? {S0_A, 1'b0} : {IDLE_A, 1'b0} ;
			{IDLE_B, 1'bX, 1'bX}: {next_state, enable} = (start) ? {S0_B, 1'b0} : {IDLE_B, 1'b0};
			
			{S0_A, 1'bX, 1'bX}: {next_state, read} = {S1_A, 1'b1};
			{S1_A, 1'b1, 1'bX}: {next_state, audioout, enable} = {S1_A, readdata[15:0], 1'b0};
			{S1_A, 1'bX, 1'b0}: {next_state, audioout, enable} = {S1_A, readdata[15:0], 1'b0};
			{S1_A, 1'b0, 1'b1}: {next_state, audioout, enable} = {IDLE_B, readdata[15:0], 1'b1};
			
			{S0_B, 1'bX, 1'bX}: {next_state, read} = {S1_B, 1'b1};
			{S1_B, 1'b1, 1'bX}: {next_state, audioout, enable} = {S1_B, readdata[31:16], 1'b0};	
			{S1_B, 1'bX, 1'b0}: {next_state, audioout, enable} = {S1_B, readdata[31:16], 1'b0};
			{S1_B, 1'b0, 1'b1}: {next_state, audioout, enable} = {S2_B, readdata[31:16], 1'b1};
			{S2_B}: {next_state, inc, enable} = {IDLE_A, 1'b1, 1'b0};
			default: {next_state, read, inc, dec, reset, enable, audioout} = {IDLE_A, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 16'b0};
		endcase
	end*/
endmodule