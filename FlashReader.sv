`default_nettype none

//FlashReader will read data from 
//the flash memory, and pass it to the audio controller.
module FlashReader(clk,kybrd_pause,flsh_waitrequest,flsh_read,flsh_readdata,flsh_readdatavalid,flsh_byteenable,
	address_change,audio_enable,audio_out,startsamplenow, debug);
	
	/************************I/O*************************/
	input logic  			clk;
	output logic [15:0]	debug;
	
	//keyboard interface:
	input logic 			kybrd_pause;
	
	//Interface to flash:	
	input logic				flsh_waitrequest;
	output logic 			flsh_read;
	input logic[31:0]		flsh_readdata;
	input logic 			flsh_readdatavalid;
	output logic[3:0] 	flsh_byteenable;
	
	//Interface address controller:
	output logic 			address_change;
	
	//Interface to audio register:
	output logic 			audio_enable;
	output logic[15:0]   audio_out;
	
	//interface to slowClockTrigger:
	input	logic	 			startsamplenow; //this is not edge sensitive
	
	/*****************************************************************/
	
	
	//internal wires:
	wire start = startsamplenow & !kybrd_pause;
			

	//state encoding: {state bits}, {flsh_read}, {address_change}, {audio_use_lower}
	//audio enable is not assigned to a state bit. it is directly assigned to flsh_readdatavalid.
   reg[6:0] state = 0;
	parameter idlea = 7'b0000_0_0_0;
	parameter a1 = 7'b0001_1_0_1;
	parameter a2 = 7'b0010_0_0_1;
	
	parameter idleb = 7'b0011_0_0_1;
	parameter b1 = 7'b0100_1_0_0;
	parameter b2 = 7'b0101_0_0_0;
	parameter b3 = 7'b0110_0_0_0;
	parameter b4 = 7'b0111_0_1_0; //extra state to ensure we dont increment the address while reading audio data
	
	//simple output logic:
	assign flsh_read = state[2];
	assign address_change = state[1];
	
	assign flsh_byteenable = 4'b1111; //TODO: include this in state bits
	assign audio_enable = flsh_readdatavalid;
	assign audio_out = state[0] ? flsh_readdata[15:0] : flsh_readdata[31:16];
	assign debug = {6'b0, flsh_waitrequest,flsh_readdatavalid,4'b0,state[6:3]};
	
	//next state logic:
	always_ff @(posedge clk)
			begin
					case (state)
					
					idlea: begin 
							 if (start)
								state <= a1;				    
							 else					 
								state <= idlea;
							 end
							 
					a1:	 begin 
							 state <= a2; 
							 end
							 
					a2:    begin 
							 if(flsh_readdatavalid) //DEBUG (no wait check) 
								state <= idleb;
							 else
								state <= a2;  
						    end
							 
					idleb: begin 
							 if (start)
								state <= b1;			    
							 else					 
								state <= idleb;
							 end
					
					b1:	 begin 
							 state <= b2;
							 end
					
					b2:    begin 
							 if(flsh_readdatavalid) //DEBUG (no wait check)
								state <= b3;
							 else
								state <= b2;
						    end
							 
					b3:	 begin
							 state <= b4;
							 end
							 
					b4:	 begin
							 state <= idlea;
							 end
		
					default: state <= idlea;
			endcase
		end
	
	endmodule