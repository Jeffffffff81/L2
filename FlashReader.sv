module FlashReader(
	//Interface to flash:
	input 					clk, 
	input 					waitrequest, 
	output logic 			read, 
	output logic[21:0] 	address,
	input[31:0] 			readdata,
	input 					readdatavalid,
	output logic[3:0] 	byteenable,
	
	//Interface to other things:
	output logic 			inc,
	output logic 			enable,
	input			 			samplenow, //this comes from the samplerate clock. It is not edge sensitive
	output[15:0] 			audio_out
	);
	
	
	assign byteenable = 4'b1111; //for simplicity, just get all 32 bits everytime.
	logic start = samplenow; //for now, we start if the sample clock tells us.
	
	logic[3:0] next_state, state;
	
	parameter IDLE_A = 4'b0000; //wait for start, set inc to 0
	parameter IDLE_B = 4'b0001; //wait for start, set enable to 0
	
	parameter S0_A = 4'b0010; //set read to one
	parameter S1_A = 4'b0011; //set read to 0, wait for !waitrequest and validdata, set audio_out and enable.
	
	parameter S0_B = 4'b0100;  //set read to one
	parameter S1_B = 4'b0101;	//set read to 0. same as S1_A
	parameter S2_B = 4'b0110;  //set inc to 1. set enable to 0
	
	always_ff @(posedge clk) begin
		casex({state, waitrequest, readdatavalid})
			{IDLE_A, 1'bX, 1'bX}: {next_state, inc} = (start) ? {S0_A, 1'b0} : {IDLE_A, 1'b0} ;
			{IDLE_B, 1'bX, 1'bX}: {next_state, enable} = (start) ? {S0_B, 1'b0} : {IDLE_B, 1'b0};
			
			{S0_A, 1'bX, 1'bX}: {next_state, read} = {S1_A, 1'b1};
			{S1_A, 1'b1, 1'bX}: {next_state, audio_out, enable} = {S1_A, readdata[15:0], 1'b0};
			{S1_A, 1'bX, 1'b0}: {next_state, audio_out, enable} = {S1_A, readdata[15:0], 1'b0};
			{S1_A, 1'b0, 1'b1}: {next_state, audio_out, enable} = {IDLE_B, readdata[15:0], 1'b1};
			
			{S0_B, 1'bX, 1'bX}: {next_state, read} = {S1_B, 1'b1};
			{S1_B, 1'b1, 1'bX}: {next_state, audio_out, enable} = {S1_B, readdata[31:16], 1'b0};	
			{S1_B, 1'bX, 1'b0}: {next_state, audio_out, enable} = {S1_B, readdata[31:16], 1'b0};
			{S1_B, 1'b0, 1'b1}: {next_state, audio_out, enable} = {S2_B, readdata[31:16], 1'b1};
			{S2_B}: {next_state, inc, enable} = {IDLE_A, 1'b1, 1'b0};
		endcase
	end
endmodule