`timescale  1ns / 10 ps

`include    "ROB.sv"
`include    "stand_delay.v"
`include    "my_coder.v"
`include    "my_arb_rr.v"

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
reg     [SWIDTH - 1:0]  mem_rsp_ID      ;
reg     [DWIDTH - 1:0]  mem_rsp_data    ;
localparam  mem_rsp_rnd_seed = 32'h1d76993a;
wire                    mem_rsp_val_delay_done;


reg     [ROB_SIZE - 1:0]    mem_req_scale;

reg     [SWIDTH : 0]                cell_busy_N;
reg     [ROB_SIZE - 1:0]            mem_req_wait_cell = 0;
reg     [SWIDTH - 1:0]              mem_rsp_priority_pnt = 0;
integer                             mem_rsp_priority_pnt_ceed = 32'h1d76993a;
wire    [ROB_SIZE - 1:0]            mem_rsp_gnt;
wire    [SWIDTH - 1:0]              mem_rsp_gnt_cell;


assign  mem_rsp_val = |mem_rsp_gnt & mem_rsp_val_delay_done;
assign  mem_rsp_ID  = mem_rsp_gnt_cell;
assign  mem_rsp_data = mem_rsp_gnt_cell;
            

stand_delay     #(  .DELAY_MAX_PTR  ( 4 ),  .DELAY_START_EN ( 1 ), .DELAY_SEED (mem_rsp_rnd_seed) )
    mem_rsp_delay (
        .clk,  .rst_,
        .delay_start    ( mem_rsp_val ),
        .delay_done     ( mem_rsp_val_delay_done ),
        .delay_high     ( 1'b0 )
);            
            
            
genvar  CELL_i;
generate
    for ( CELL_i = 0; CELL_i < ROB_SIZE; CELL_i++ )  begin:  CELL_i_blk
    always @( posedge clk )
        if ( mem_rsp_val & mem_rsp_ID == CELL_i )
            mem_req_wait_cell[CELL_i] <= 0;
        else if ( mem_req_val & mem_req_ID == CELL_i )
            mem_req_wait_cell[CELL_i] <= 1;
    end
endgenerate

my_arb_rr
#(
        .REQ_NUM                                ( ROB_SIZE                                 ),
        .REQ_NUM_WIDTH                          ( SWIDTH                           )
)
mem_rsp_arb (
        .requests                               ( mem_req_wait_cell                       ),                   // Вектор запросов
        .priority_pnt                           ( mem_rsp_priority_pnt                    ),               // Указатель на запрос с наивысшем приоритетом
        .grant                                  ( mem_rsp_gnt                             )                       // Вектор с указанием выбранного запроса
);    

my_coder #( .N(ROB_SIZE),  .PTR(SWIDTH) )
    mem_rsp_gnt_coder (
        .in          (mem_rsp_gnt),
        .out         (mem_rsp_gnt_cell),
        .multi_in    ());

    always @( posedge clk )
        if ( mem_rsp_val )
            mem_rsp_priority_pnt <= $dist_uniform(mem_rsp_priority_pnt_ceed  , 0, ROB_SIZE - 1);

            
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
