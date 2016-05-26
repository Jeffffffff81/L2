module MusicPlayer(clk, kybrd_forward, kybrd_pause, startsamplenow, flsh_address, 
	flsh_waitrequest,flsh_read,flsh_readdata,flsh_readdatavalid,flsh_byteenable, audio_data);
	
	//I/O:
	input logic clk;
	input logic kybrd_forward, kybrd_pause;
	input logic startsamplenow;
	output logic[22:0] flsh_address;
	input logic[31:0] flsh_readdata;
	input logic flsh_waitrequest, flsh_readdatavalid;
	output logic flsh_read;
	output logic[3:0] flsh_byteenable;
	output logic [15:0] audio_data;
	
	//internal wires:
	wire address_inc, address_dec, address_rst;
	wire audio_enable;
	wire[15:0] audio_fsmout;
	

	//The FlashReader FSM:
	FlashReader flashReader(
		.clk(clk),
		.rst(1'b1),
		.flsh_waitrequest(flsh_waitrequest),
		.flsh_read(flsh_read),
		.flsh_readdata(flsh_readdata),
		.flsh_readdatavalid(flsh_readdatavalid),
		.flsh_byteenable(flsh_byteenable),
		.address_inc(address_inc),
		.address_dec(address_dec),
		.address_rst(address_rst),
		.audio_enable(audio_enable),
		.audio_out(audio_fsmout),
		.startsamplenow(startsamplenow)
	);
	
	//Address controller. Connected between FlashReader and Flash Interface:
	AddressController addresscontroller(
	 .clk(clk),
	 .inc(address_inc),
	 .dec(address_dec),
	 .rst(address_rst),
	 .address(flsh_address)
	);
	
	//register with enable to hold audio data:
	always_ff @(posedge clk)
		if(audio_enable) audio_data = audio_fsmout;
		else audio_data = audio_data;
	
	
endmodule