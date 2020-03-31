`ifndef _STAND_DELAY__V_

`define _STAND_DELAY__V_


`timescale	1 ns / 1 ns

module	stand_delay	#(
parameter	DELAY_MAX_PTR = 5,
            DELAY_MIN = 0,
            DELAY_START_EN = 1,
            DELAY_START_CNT = 10,
            DELAY_SEED = 32'h1d76993a
)(
input		clk,
input		rst_,
input		delay_start,
output		delay_done,
input       delay_high
);

integer     delay_seed = DELAY_SEED;
reg [31:0]  rand_gen = $random(delay_seed); 
reg	[31:0]	delay_cnt;

wire        delay_cnt_reset;
reg         delay_init_done;
always @( posedge clk )
    if ( ~rst_ ) 
        delay_init_done <= DELAY_START_EN ? 1'b0 : 1'b1;
    else if ( ~delay_init_done & delay_cnt == 1 )
        delay_init_done <= 1'b1;


always @( posedge clk )
	if ( ~rst_ ) 
		delay_cnt <= DELAY_START_EN ? DELAY_START_CNT : 0;
	else if ( delay_cnt_reset ) begin
		delay_cnt <= ( DELAY_MIN == 0 ) ? ( ( rand_gen[DELAY_MAX_PTR] ) ? rand_gen : 0 ) : 
                                            rand_gen[DELAY_MAX_PTR - 1:0] < DELAY_MIN ? DELAY_MIN : rand_gen;
        rand_gen <= $random(delay_seed);
    end
	else
		delay_cnt <= ( ~delay_done ) ? delay_cnt - 1 : 0;


assign  delay_cnt_reset = delay_done & delay_start;

assign	delay_done = ~( |delay_cnt[DELAY_MAX_PTR - 1:0] ) & ( delay_high & delay_cnt[DELAY_MAX_PTR + 2:DELAY_MAX_PTR] == 0 | ~delay_high ) & delay_init_done;


endmodule

`endif

