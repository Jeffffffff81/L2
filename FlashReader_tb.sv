module FlashReader_tb();
  logic 					clk;
	logic					rst;
	
	//Interface to flash:	
	logic 					flsh_waitrequest; 
  logic 			flsh_read;
	logic[31:0] 			flsh_readdata;
	logic 					flsh_readdatavalid;
	logic[3:0] 	flsh_byteenable;
	
	//Interface address controller:
	logic 			address_inc;
	logic			address_dec;
	logic 			address_rst;
	
	//Interface to audio register:
	logic 			audio_enable;
	logic[15:0]   audio_out;
	
	//interface to slowClockTrigger:
	logic			 			startsamplenow; //this is not edge sensitive
	
  
  initial begin
    forever begin
      clk = 1; #1;
      clk = 0; #1;
      rst = 1;
    end
  end
  
  initial begin
    startsamplenow = 0;
    #10;
    startsamplenow = 1;
    #2;
    startsamplenow = 0;
    #10
    $stop;
    
    $stop;
  end
endmodule