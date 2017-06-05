module FrequencyGenerator
#(
	// Parameter Declarations
	parameter BASE_CLK = 50000000,	//FPGA base clock frequency obtained internally
	parameter TARGET_FREQUENCY = 100000,	//Frequency to obtain at the output
	parameter MAXIMUM_VALUE = CountValue(TARGET_FREQUENCY,BASE_CLK),	//Count to obtain the target frequency
	parameter NBITS_FOR_COUNTER = CeilLog2(MAXIMUM_VALUE)					//Length for the count
)

(
	// Input Ports
	input clk,		//Internal clock
	input reset,	//Asynchronous low-active reset
	input enable,	//Enable signal
	
	// Output Ports
	output flag		//Generated frequency
);

bit MaxValue_Bit;	//Variable for flag in the sequential process

logic [NBITS_FOR_COUNTER-1 : 0] Count_logic;	//Count parameter
	
	always_ff@(posedge clk or negedge reset) begin
		if (reset == 1'b0)
			begin
			Count_logic <= {NBITS_FOR_COUNTER{1'b0}};	//Starting conditions
			MaxValue_Bit <= 1'b0;							//Set an starting value for the frequency to alter properly
			end
		else begin
				if(enable == 1'b1)			//When it is enabled,
					if(Count_logic == MAXIMUM_VALUE - 1)		//It checks if it has reached its count value
						begin
						Count_logic <= 0;		//Reset the count value
						MaxValue_Bit <= ~(MaxValue_Bit);	//Change the output state to generate proper 50% work cycle
						end
					else
						Count_logic <= Count_logic + 1'b1;	//Keep counting until target value is reached
		end
	end

//---------------------------------------------------------------------------------------------
assign flag = MaxValue_Bit;		//Assign output
//----------------------------------------------------------------------------------------------

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
		result = base_clk/(2*frequency);	//Simple operation to obtain the value due to the nature of the frequency generation
		CountValue = result;
	endfunction
 
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 /*--------------------------------------------------------------------*/
 
 endmodule
 