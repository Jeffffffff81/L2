`default_nettype none

//FlashReader will read data from 
//the flash memory, and pass it to the audio controller.
module FlashReader(clk,rst,flsh_waitrequest,flsh_read,flsh_readdata,flsh_readdatavalid,flsh_byteenable,
	address_inc,address_dec,address_rst,audio_enable,audio_out,startsamplenow);
	
	input logic  			clk;
	input	logic				rst;
	
	//Interface to flash:	
	input logic				flsh_waitrequest;
	output logic 			flsh_read;
	input logic[31:0]		flsh_readdata;
	input logic 			flsh_readdatavalid;
	output logic[3:0] 	flsh_byteenable;
	
	//Interface address controller:
	output logic 			address_inc;
	output logic			address_dec;
	output logic 			address_rst;
	
	//Interface to audio register:
	output logic 			audio_enable;
	output logic[15:0]   audio_out;
	
	//interface to slowClockTrigger:
	input	logic	 			startsamplenow; //this is not edge sensitive
	
	assign flsh_byteenable = 4'b1111; //for simplicity, just get all 32 bits everytime.
	wire start = startsamplenow; //for now, we start if the sample clock tells us.

	//state assignment. In this FSM, its very difficult to encode the state bits as outputs.
	//for example, we have no idea what readdata may be, and that must be passed as an output.
	//instead, we will register the outputs to avoid glitches.
	
   logic[3:0] state;
	parameter idlea = 4'b0000;
	parameter a1 = 4'b0001;
	parameter a2 = 4'b0010;
	
	parameter idleb = 4'b0011;
	parameter b1 = 4'b0100;
	parameter b2 = 4'b0101;
	parameter b3 = 4'b0110;
	parameter b4 = 4'b0111; //extra state to ensure we dont increment the address while reading audio data
	
	//next state logic:
	always_ff @(posedge clk or negedge rst)
	 begin
	      if (~rst)
			begin
			   state <= idlea;
		   end else
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
							 if(!flsh_waitrequest && flsh_readdatavalid)
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
							 if(!flsh_waitrequest && flsh_readdatavalid)
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
	end
	
	//output logic
	assign audio_enable = flsh_readdatavalid;
	
	always_comb
		case(state)
			idlea:   begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = 0;
						end
			
			a1:	   begin 
						flsh_read = 1;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = 0;
						end
						
			a2:		begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = flsh_readdata[15:0];
						end
					
			idleb:	begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = flsh_readdata[15:0];
						end
						
			b1:		begin 
						flsh_read = 1;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = 0;
						end
					
			b2:		begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = flsh_readdata[31:16];
						end
						
			b3:	begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_out = flsh_readdata[31:16];
						end
					
			default: begin 
						flsh_read = 0;
						address_inc = 1;
						address_dec = 0;
						address_rst = 0;
						audio_out = flsh_readdata[31:16];
						end
		endcase
	

	endmodule