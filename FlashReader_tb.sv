module FlashReader_tb();
  logic clk;
  
  	//Interface to flash:	
	logic 					waitrequest; 
  logic 			read;
	logic[31:0] 			readdata;
	logic 					readdatavalid;
  logic[3:0] 	byteenable;
	
	//Interface address controller:
	logic 			inc;
	logic			 dec;
	logic 			reset;
	
	//Interface to audio register:
	logic 			enable;
	logic[15:0]  audioout;
	
	//interface to slowClockTrigger:
	logic			 			samplenow; //this is not edge sensitive

  FlashReader dut(
    .clk(clk),
    .waitrequest(waitrequest),
    .read(read),
    .readdata(readdata),
    .readdatavalid(readdatavalid),
    .byteenable(byteenable),
    .inc(inc),
    .dec(dec),
    .reset(reset),
    .enable(enable),
    .audioout(audioout),
    .samplenow(samplenow)
  );
  
  initial begin
    forever begin
      clk = 1; #1;
      clk = 0; #1;
    end
  end
  
  initial begin
    waitrequest = 0;
    readdata = 0;
    readdatavalid = 0;
    samplenow = 0;
    #10;
    samplenow = 1;
    #2;
    samplenow = 0;
    #10
    readdatavalid = 1;
    readdata = 32'd256;
    #2;
    readdatavalid = 0;
    #20;
    samplenow = 1;
    #2;
    samplenow = 0;
    #20;
    readdatavalid = 1;
    readdata = 32'd256;
    #2;
    readdatavalid = 0;
    #20;
    
    $stop;
  end
endmodule