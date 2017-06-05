module BlinkFunction
#(
	// Parameter Declarations
	parameter BASE_CLK = 50000000,	//FPGA base clock frequency obtained internally
	parameter TARGET_FREQUENCY = 1,	//Frequency to obtain at the output
	parameter MAXIMUM_VALUE = CountValue(TARGET_FREQUENCY,BASE_CLK),	//Count to obtain the target frequency
	parameter NBITS_FOR_COUNTER = CeilLog2(MAXIMUM_VALUE)					//Length for the count
)
(
	// Input Ports
	input clk,
	input reset,
	input start,

	// Output Ports
	output freqOut,
	output ledOut 	
);


enum logic [1:0] {INITIAL, LED_ON, LED_OFF} state; 
bit counter_6;
bit counter_4;
bit flag_6;
bit flag_4;
bit ledOut_b;
bit freqOut_b;
bit start_enable;
logic [1:0] count_b;
logic clk_1_Hz;

FrequencyGenerator
#(
	// Parameter Declarations
	.BASE_CLK(BASE_CLK),							//FPGA base clock frequency obtained internally
	.TARGET_FREQUENCY(TARGET_FREQUENCY),	//Frequency to obtain at the output
	.MAXIMUM_VALUE(MAXIMUM_VALUE),			//Count to obtain the target frequency
	.NBITS_FOR_COUNTER(NBITS_FOR_COUNTER)	//Length for the count
)
frequencyOut
(
	// Input Ports
	.clk(clk),		//Internal clock
	.reset(reset),	//Asynchronous low-active reset
	.enable(start_enable),	//Enable signal
	.flag(clk_1_Hz)		//Generated frequency
);


CounterWithFunction
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(300_000_000),			//Count to obtain the target frequency
	.NBITS_FOR_COUNTER(32)	//Length for the count
)
Counter_6
(
	// Input Ports
	.clk(clk),		//Internal clock
	.reset(reset),	//Asynchronous low-active reset
	.enable(counter_6),	//Enable signal
	.flag(flag_6),	//Generated frequency
	.CountOut()
);


CounterWithFunction
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(200_000_000),			//Count to obtain the target frequency
	.NBITS_FOR_COUNTER(32)	//Length for the count
)
Counter_4
(
	// Input Ports
	.clk(clk),		//Internal clock
	.reset(reset),	//Asynchronous low-active reset
	.enable(counter_4),	//Enable signal
	.flag(flag_4),	//Generated frequency
	.CountOut()
);

/*------------------------------------------------------------------------------------------*/
/*Asignacion de estado, proceso secuencial*/
always_ff@(posedge clk, negedge reset) begin
	if(reset == 1'b0)
		begin
			state <= INITIAL;
			count_b <= 1'b0;
		end
	else 
		case(state)
			INITIAL:
				if(start == 1'b1)
					state <= LED_ON;
				else
				begin
					count_b <= 1'b0;
					state <= INITIAL;		
				end
			LED_ON:
				if (flag_6 == 1'b1)
					state <= LED_OFF;
				else 
					state <= LED_ON;	
			LED_OFF:
				if(flag_4 == 1'b1)
					begin
						count_b <= count_b + 1'b1;
						if(count_b == 2)
							state <= INITIAL;
						else 
							state <= LED_ON;
					end
				else
					state <= LED_OFF;		
			default:
					state <= INITIAL;

			endcase
end//end always
/*------------------------------------------------------------------------------------------*/
/*Asignación de salidas,proceso combintorio*/
always_comb begin
 case(state)
		INITIAL: 
				begin
					start_enable = 1'b0;
					counter_6 = 1'b0;
					counter_4 = 1'b0;
					ledOut_b = 1'b0;
				end
		LED_ON: 
			begin
				counter_4 = 1'b0;
				counter_6 = 1'b1;
				ledOut_b = 1'b1;
				start_enable = 1'b1;
			end
		LED_OFF:
			begin
				counter_4 = 1'b1;
				counter_6 = 1'b0;
				ledOut_b = 1'b0;
				start_enable = 1'b1;
			end
	default: 		
			begin
				counter_6 = 1'b0;
				counter_4 = 1'b0;
				ledOut_b = 1'b0;
				start_enable = 1'b0;
			end

	endcase
end
assign freqOut = clk_1_Hz;
assign ledOut = ledOut_b; 
	
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
