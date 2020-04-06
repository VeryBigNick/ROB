`timescale  1ns / 10 ps

`include    "ROB.sv"
`include	"mem_model.sv"
`include    "stand_delay.v"
// `include    "my_coder.v"
// `include    "my_arb_rr.v"

module  tb;

localparam   ROB_SIZE    = 16;
localparam   SWIDTH      = 4 ;
localparam   AWIDTH      = 40;
localparam   DWIDTH      = 32;
localparam   PWIDTH      = 32;
localparam   IDWIDTH     = 16;

reg     clk;
initial clk = 0;
always #1 clk = ~clk; 
reg     rst_;
initial begin
    rst_ = 0;
#10;
    rst_ = 1;
end

wire                    req_val     ;
reg     [AWIDTH - 1:0]  req_addr    = 0;
reg     [IDWIDTH - 1:0] req_ID      = 0;
reg     [PWIDTH - 1:0]  req_param   = 0;
wire                    req_ready   ;
localparam              req_seed_delay = 32'h1d76993a;
reg 					req_delay_high = 1'b0;
reg		[9:0]			req_ready_n_cnt = 0;


stand_delay     #(  .DELAY_MAX_PTR  ( 3 ),  .DELAY_START_EN ( 1 ), .DELAY_SEED (req_seed_delay) )
    req_delay (
        .clk,  .rst_,
        .delay_start    ( req_val & req_ready ),
        .delay_done     ( req_val ),
        .delay_high     ( req_delay_high )
);
always @( posedge clk )
    if ( req_val & req_ready )  begin
        req_addr <= req_addr + 1;
        req_ID <= req_ID + 1;
        req_param <= req_param + 1;
    end


wire                    rsp_val     ;
wire    [DWIDTH - 1:0]  rsp_data    ;
wire    [IDWIDTH - 1:0] rsp_ID      ;
wire    [PWIDTH - 1:0]  rsp_param   ;
wire                    rsp_ready   ;
localparam  rsp_ready_rnd_seed       = 32'h1d76993a;
reg						rsp_ready_delay_high = 1'b0;

stand_delay     #(  .DELAY_MAX_PTR  ( 4 ),  .DELAY_START_EN ( 1 ), .DELAY_SEED (rsp_ready_rnd_seed) )
    rsp_ready_delay (
        .clk,  .rst_,
        .delay_start    ( rsp_val & rsp_ready ),
        .delay_done     ( rsp_ready ),
        .delay_high     ( rsp_ready_delay_high )
);

always @( posedge clk )
	if ( ~req_delay_high & ~req_ready )	begin
		if ( req_ready_n_cnt == 10'd20 )	begin
			req_delay_high <= 1'b1;
			req_ready_n_cnt <= 10'h0;
		end
		else
			req_ready_n_cnt <= req_ready_n_cnt + 1;
	end
	else if ( req_delay_high & req_ready )	begin
		if ( req_ready_n_cnt == 10'd100 )	begin
			req_delay_high <= 1'b0;
			req_ready_n_cnt <= 10'h0;
		end
		else
			req_ready_n_cnt <= req_ready_n_cnt + 1;
	end
	else
			req_ready_n_cnt <= 10'h0;
		

wire                    mem_req_val     ;
wire    [AWIDTH - 1:0]  mem_req_addr    ;
wire    [SWIDTH - 1:0]  mem_req_ID      ;

wire                    mem_rsp_val     ;
wire    [SWIDTH - 1:0]  mem_rsp_ID      ;
wire    [DWIDTH - 1:0]  mem_rsp_data    ;

mem_model #(
		.MEM_SIZE   (ROB_SIZE),
		.IDWIDTH    (SWIDTH  ),
		.AWIDTH     (AWIDTH  ),
		.DWIDTH     (DWIDTH  )
)
	mem (
        .clk             ,
        .rst_            ,

		.mem_req_val     ,
		.mem_req_addr    ,
		.mem_req_ID      ,
		.mem_rsp_val     ,
		.mem_rsp_ID      ,
		.mem_rsp_data    
);


            
ROB #(
        .ROB_SIZE                               ( ROB_SIZE     ),
        .SWIDTH                                 ( SWIDTH       ),
        .AWIDTH                                 ( AWIDTH       ),
        .DWIDTH                                 ( DWIDTH       ),
        .PWIDTH                                 ( PWIDTH       ),
        .IDWIDTH                                ( IDWIDTH      )
)
dut (
        .clk                                    ( clk          ),
        .rst_                                   ( rst_         ),

        .req_val                                ( req_val      ),
        .req_addr                               ( req_addr     ),
        .req_ID                                 ( req_ID       ),
        .req_param                              ( req_param    ),
        .req_ready                              ( req_ready    ),

        .rsp_val                                ( rsp_val      ),
        .rsp_data                               ( rsp_data     ),
        .rsp_ID                                 ( rsp_ID       ),
        .rsp_param                              ( rsp_param    ),
        .rsp_ready                              ( rsp_ready    ),

        .mem_req_val                            ( mem_req_val  ),
        .mem_req_addr                           ( mem_req_addr ),
        .mem_req_ID                             ( mem_req_ID   ),

        .mem_rsp_val                            ( mem_rsp_val  ),
        .mem_rsp_ID                             ( mem_rsp_ID   ),
        .mem_rsp_data                           ( mem_rsp_data )

);

reg     [IDWIDTH - 1:0] rsp_ID_etalon  = 0;

always @( posedge clk )
    if ( rst_ & rsp_val & rsp_ready )   begin
        rsp_ID_etalon <= rsp_ID_etalon + 1;
        if ( rsp_ID !== rsp_ID_etalon )  begin
            $display("ERROR rsp_ID");
            $stop;        
        end
        if ( rsp_data[SWIDTH - 1:0] !== rsp_ID_etalon[SWIDTH - 1:0] )  begin
            $display("ERROR rsp_data");
            $stop;        
        end
    end
    


        
endmodule
