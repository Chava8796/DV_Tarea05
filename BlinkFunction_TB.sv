timeunit 1ps; //It specifies the time unit that all the delay will take in the simulation.
timeprecision 1ps;// It specifies the resolution in the simulation.

module BlinkFunction_TB;

	parameter BASE_CLK = 50000000;		//FPGA base clock frequency obtained internally
	parameter TARGET_FREQUENCY = 12500000;	//Frequency to obtain at the output
	parameter MAXIMUM_VALUE = CountValue(TARGET_FREQUENCY,BASE_CLK); //Count to obtain the target frequency
	parameter NBITS_FOR_COUNTER = CeilLog2(MAXIMUM_VALUE);			//Length for the count

 // Input Ports
bit clk = 0;	//Internal clock
bit reset;		//Asynchronous low-active reset
bit enable;		//Enable signal
	
  // Output Ports
logic freqOut;			//Generated frequency
logic ledOut;			//Generated frequency
logic [1:0] countB;

BlinkFunction
#(
	// Parameter Declarations
	.BASE_CLK(BASE_CLK),							//FPGA base clock frequency obtained internally
	.TARGET_FREQUENCY(TARGET_FREQUENCY),	//Frequency to obtain at the output
	.MAXIMUM_VALUE(MAXIMUM_VALUE),			//Count to obtain the target frequency
	.NBITS_FOR_COUNTER(NBITS_FOR_COUNTER)	//Length for the count
)
DUT
(
	// Input Ports
	.clk(clk),			//Internal clock
	.reset(reset),		//Asynchronous low-active reset
	.start(enable),	//Enable signal
	
	// Output Ports
	.freqOut(freqOut),
	.countB(countB),
	.ledOut(ledOut) 
);

//Procedural assignments
/*********************************************************/
initial // Clock generator
  begin
    forever #2 clk = !clk;
  end
/*********************************************************/
initial begin // reset generator
	#0 reset = 0;
	#5 reset = 1;
end

/*********************************************************/
initial begin // enable
	#0 enable = 0;
	#6 enable = 1;
	#50 enable = 0;
end

/*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
   
 /*Log Function*/
     function integer CeilLog2;	//Obtain the necessary count length
	  input integer data;			//Target count as input
       integer i,result;
       begin
          for(i=0; 2**i < data; i=i+1)	//Base-2 exponential to obtain bit length
             result = i + 1;
          CeilLog2 = result;
       end
    endfunction

/*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 
  
 /*Counter Function*/
	function integer CountValue;	//Obtain the necessary count value to generate the target frequency
		input integer frequency;	//Target frequency
		input integer base_clk;		//Base FPGA clock
		integer result;
		result = base_clk/(2*frequency); //Simple operation to obtain the value due to the nature of the frequency generation
		CountValue = result;
	endfunction
 
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/

endmodule 