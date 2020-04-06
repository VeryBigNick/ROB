`timescale  1ns / 10 ps

`include    "stand_delay.v"
`include    "my_coder.v"
`include    "my_arb_rr.v"

module	mem_model #(
parameter   MEM_SIZE    = 128,
            IDWIDTH     = 4 ,
            AWIDTH      = 32,
            DWIDTH      = 32
)(
input   wire    clk,
input   wire    rst_,

input	wire                    mem_req_val     ,
input	wire    [AWIDTH - 1:0]  mem_req_addr    ,
input	wire    [IDWIDTH - 1:0] mem_req_ID      ,
										
output	wire                    mem_rsp_val     ,
output	reg     [IDWIDTH - 1:0] mem_rsp_ID      ,
output	reg     [DWIDTH - 1:0]  mem_rsp_data    

);

localparam  mem_rsp_rnd_seed = 32'h1d76993a;
wire                    mem_rsp_val_delay_done;

reg     [MEM_SIZE - 1:0]            mem_req_wait_cell = 0;
reg     [IDWIDTH - 1:0]             mem_rsp_priority_pnt = 0;
integer                             mem_rsp_priority_pnt_ceed = 32'h1d76993a;
wire    [MEM_SIZE - 1:0]            mem_rsp_gnt;
wire    [IDWIDTH - 1:0]             mem_rsp_gnt_cell;


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
    for ( CELL_i = 0; CELL_i < MEM_SIZE; CELL_i++ )  begin:  CELL_i_blk
    always @( posedge clk )
        if ( mem_rsp_val & mem_rsp_ID == CELL_i )
            mem_req_wait_cell[CELL_i] <= 0;
        else if ( mem_req_val & mem_req_ID == CELL_i )
            mem_req_wait_cell[CELL_i] <= 1;
    end
endgenerate

my_arb_rr
#(
        .REQ_NUM                                ( MEM_SIZE                                 ),
        .REQ_NUM_WIDTH                          ( IDWIDTH                           )
)
mem_rsp_arb (
        .requests                               ( mem_req_wait_cell                       ),
        .priority_pnt                           ( mem_rsp_priority_pnt                    ),
        .grant                                  ( mem_rsp_gnt                             ) 
);    

my_coder #( .N(MEM_SIZE),  .PTR(IDWIDTH) )
    mem_rsp_gnt_coder (
        .in          (mem_rsp_gnt),
        .out         (mem_rsp_gnt_cell),
        .multi_in    ());

    always @( posedge clk )
        if ( mem_rsp_val )
            mem_rsp_priority_pnt <= $dist_uniform(mem_rsp_priority_pnt_ceed  , 0, MEM_SIZE - 1);

endmodule