`default_nettype none

//FlashReader will read data from 
//the flash memory, and pass it to the audio controller.
module FlashReader(
	input logic  			clk, 
	input	logic				rst,
	
	//Interface to flash:	
	input logic				flsh_waitrequest, 
	output logic 			flsh_read, 
	input logic[31:0]		flsh_readdata,
	input logic 			flsh_readdatavalid,
	output logic[3:0] 	flsh_byteenable,
	
	//Interface address controller:
	output logic 			address_inc,
	output logic			address_dec,
	output logic 			address_rst,
	
	//Interface to audio register:
	output logic 			audio_enable,
	output logic[15:0]   audio_out,
	
	//interface to slowClockTrigger:
	input	logic	 			startsamplenow //this is not edge sensitive
	);
	input logic clk;
	
	
	assign flsh_byteenable = 4'b1111; //for simplicity, just get all 32 bits everytime.
	wire start = startsamplenow; //for now, we start if the sample clock tells us.

	//state assignment. In this FSM, its very difficult to encode the state bits as outputs.
	//for example, we have no idea what readdata may be, and that must be passed as an output.
	//instead, we will register the outputs to avoid glitches.
	
	logic state[3:0];
	localparam idlea = 4'b0000;
	localparam a1 = 4'b0001;
	localparam a2 = 4'b0010;
	
	localparam idleb = 4'b0011;
	localparam b1 = 4'b0100;
	localparam b2 = 4'b0101;
	localparam b3 = 4'b0110;
	
	//next state logic:
	always_ff @(posedge clk or negedge rst)
	 begin
	      if (~rst)
			begin
			   state <= idlea;
		   end else
			begin
					case (state)
					idlea : if (start)
								state <= a1;				    
							 else					 
								state <= idlea;
					a1 :	state <= idlea;
					
					default: state <= idlea;
			endcase
			end
	end
	
	//output logic
	always_comb
		case(state)
			idlea:   begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_enable = 0;
						audio_out = 0;
						end
			
			a1:	   begin 
						flsh_read = 1;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_enable = 0;
						audio_out = 0;
						end
			
			default: begin 
						flsh_read = 0;
						address_inc = 0;
						address_dec = 0;
						address_rst = 0;
						audio_enable = 0;
						audio_out = 0;
						end
		endcase
	

	endmodule