`ifndef _ROB__SV_ 

`define _ROB__SV_ 1 

`include    "rmem.v"

module  ROB #(
parameter   ROB_SIZE    = 128,
            SWIDTH      = 4 ,
            AWIDTH      = 32,
            DWIDTH      = 32,
            PWIDTH      = 10,
            IDWIDTH     = 16
)(
input   wire    clk,
input   wire    rst_,

input   wire                    req_val     ,
input   wire    [AWIDTH - 1:0]  req_addr    ,
input   wire    [IDWIDTH - 1:0] req_ID      ,
input   wire    [PWIDTH - 1:0]  req_param   ,
output  reg                     req_ready   ,

output  reg                     rsp_val     ,
output  reg     [DWIDTH - 1:0]  rsp_data    ,
output  reg     [IDWIDTH - 1:0] rsp_ID      ,
output  reg     [PWIDTH - 1:0]  rsp_param   ,
input   wire                    rsp_ready   ,

output  reg                     mem_req_val     ,
output  reg     [AWIDTH - 1:0]  mem_req_addr    ,
output  reg     [SWIDTH - 1:0]  mem_req_ID      ,
// input   wire                    mem_req_ready   ,

input   wire                    mem_rsp_val     ,
input   wire    [SWIDTH - 1:0]  mem_rsp_ID      ,
input   wire    [DWIDTH - 1:0]  mem_rsp_data    //,
// output  wire                    mem_rsp_ready     
  
);

function    [SWIDTH-1:0]   plus1;
    input   [SWIDTH-1:0]   ptr;
    input   integer        ptr_max;
    begin
        if ( ptr == ptr_max - 1 )
            plus1 = 0;
        else
            plus1 = ptr + 1'b1;
    end
endfunction

function    [SWIDTH-1:0]   minus1;
    input   [SWIDTH-1:0]   ptr;
    input   integer        ptr_max;
    begin
        if ( ptr == 0 )
            minus1 = ptr_max - 1;
        else
            minus1 = ptr - 1'b1;
    end
endfunction

localparam  ROB_PMEM_WIDTH = IDWIDTH + PWIDTH;
localparam  ROB_DMEM_WIDTH = DWIDTH;

wire                    ROB_put = req_val & req_ready;
wire                    ROB_get = rsp_val & rsp_ready;
reg     [SWIDTH - 1:0]  ROB_put_ptr;
reg     [SWIDTH - 1:0]  ROB_get_ptr;
// wire    [SWIDTH - 1:0]  ROB_rdy_ptr;

wire                            ROB_pmem_wr_val ;
wire    [SWIDTH - 1:0]          ROB_pmem_wr_addr;
wire    [ROB_PMEM_WIDTH - 1:0]  ROB_pmem_wr_data;
wire                            ROB_pmem_rd_val ;
wire    [SWIDTH - 1:0]          ROB_pmem_rd_addr;
wire    [ROB_PMEM_WIDTH - 1:0]  ROB_pmem_rd_data;

wire                            ROB_dmem_wr_val ;
wire    [SWIDTH - 1:0]          ROB_dmem_wr_addr;
wire    [ROB_DMEM_WIDTH - 1:0]  ROB_dmem_wr_data;
wire                            ROB_dmem_rd_val ;
wire    [SWIDTH - 1:0]          ROB_dmem_rd_addr;
wire    [ROB_DMEM_WIDTH - 1:0]  ROB_dmem_rd_data;

reg     [ROB_SIZE - 1:0]        ROB_drdy;

wire                            rd_to_rdy_val;
wire                            rdy_to_rsp_val;

reg     [SWIDTH - 1:0]          ROB_rd_st_ptr;

reg                             ROB_rdy_st_val ;
reg     [SWIDTH - 1:0]          ROB_rdy_st_ptr ;
reg                             ROB_rdy_st_drdy;

always @( posedge clk ) begin
    mem_req_val  <= ROB_put;
    mem_req_addr <= req_addr;
    mem_req_ID   <= ROB_put_ptr;
end

always @( posedge clk )
    if ( ~rst_ )
        ROB_put_ptr <= {SWIDTH{1'b0}};
    else
        ROB_put_ptr <= ROB_put ? ROB_put_ptr + 1'b1 : ROB_put_ptr;
        
always @( posedge clk )
    if ( ~rst_ )
        ROB_get_ptr <= {SWIDTH{1'b0}};
    else
        ROB_get_ptr <= ROB_get ? ROB_get_ptr + 1'b1 : ROB_get_ptr;
        
always @(posedge clk)
    if ( ~rst_ )
        req_ready <= 1'b1;
    else
        req_ready <= ( ( plus1(ROB_put_ptr,ROB_SIZE) == ROB_get_ptr ) & ROB_put & ~ROB_get ) ? 1'b0 :
                     ( ~req_ready & ROB_get )                                                ? 1'b1 : req_ready;

assign  ROB_pmem_wr_val     = ROB_put;
assign  ROB_pmem_wr_addr    = ROB_put_ptr;
assign  ROB_pmem_wr_data    = {req_ID, req_param};

assign  ROB_dmem_wr_val     = mem_rsp_val;
assign  ROB_dmem_wr_addr    = mem_rsp_ID;
assign  ROB_dmem_wr_data    = mem_rsp_data;

genvar  GCELL;
generate
    for ( GCELL = 0; GCELL < ROB_SIZE; GCELL ++ )   begin:  ROB_drdy_blk
        always @( posedge clk )
            if ( ~rst_ )
                ROB_drdy[GCELL] <= 1'b0;
            else
                ROB_drdy[GCELL] <= mem_rsp_val & mem_rsp_ID == GCELL ? 1'b1 : ROB_get & ROB_get_ptr == GCELL ? 1'b0 : ROB_drdy[GCELL];
    
    end
endgenerate

assign  rd_to_rdy_val = ( ~ROB_rdy_st_val | rdy_to_rsp_val ) & ROB_rd_st_ptr != ROB_put_ptr;
assign  rdy_to_rsp_val = ROB_rdy_st_val & ( ~rsp_val | rsp_val & rsp_ready ) & ROB_rdy_st_drdy;

always @( posedge clk )
    if ( ~rst_ )
        ROB_rd_st_ptr <= {SWIDTH{1'b0}};
    else
        ROB_rd_st_ptr <= rd_to_rdy_val ? ROB_rd_st_ptr + 1'b1 : ROB_rd_st_ptr;
        

always @( posedge clk )
    if ( ~rst_ )
        ROB_rdy_st_val <= 1'b0;
    else
        ROB_rdy_st_val <= rd_to_rdy_val ? 1'b1 : rdy_to_rsp_val ? 1'b0 : ROB_rdy_st_val;

always @( posedge clk )
    if ( ~rst_ )
        ROB_rdy_st_ptr <= {SWIDTH{1'b0}};
    else
        ROB_rdy_st_ptr <= rdy_to_rsp_val ? ROB_rdy_st_ptr + 1'b1 : ROB_rdy_st_ptr;

always @( posedge clk )
    if ( ~rst_ )
        ROB_rdy_st_drdy <= 1'b0;
    else
        ROB_rdy_st_drdy <=  rd_to_rdy_val ? ROB_drdy[ROB_rd_st_ptr] : 
                            ROB_rdy_st_val & ~ROB_rdy_st_drdy ? ROB_drdy[ROB_rdy_st_ptr] : 
                            rdy_to_rsp_val ? 1'b0 : ROB_rdy_st_drdy;

assign  ROB_pmem_rd_val  = rd_to_rdy_val;
assign  ROB_pmem_rd_addr = ROB_rd_st_ptr;

assign  ROB_dmem_rd_val  = rd_to_rdy_val;
assign  ROB_dmem_rd_addr = ROB_rd_st_ptr;




always @( posedge clk )
    if ( ~rst_ )
        rsp_val <= 1'b0;
    else
        rsp_val <= rdy_to_rsp_val ? 1'b1 : ROB_get ? 1'b0 : rsp_val;

always @( posedge clk )
    if ( rdy_to_rsp_val ) begin
        rsp_data              <= ROB_dmem_rd_data;
        { rsp_ID, rsp_param } <= ROB_pmem_rd_data;
    end
    
    
rmem #( .depth(ROB_SIZE), .awidth(SWIDTH), .width (ROB_PMEM_WIDTH) )
ROB_pmem (
        .wclk                                   ( clk ),
        .rclk                                   ( clk ),

        .wren                                   ( ROB_pmem_wr_val  ),
        .waddress                               ( ROB_pmem_wr_addr ),
        .wdata                                  ( ROB_pmem_wr_data ),

        .rden                                   ( ROB_pmem_rd_val  ),
        .raddress                               ( ROB_pmem_rd_addr ),
        .rdata                                  ( ROB_pmem_rd_data )
);
    
rmem #( .depth(ROB_SIZE), .awidth(SWIDTH), .width (ROB_DMEM_WIDTH) )
ROB_dmem (
        .wclk                                   ( clk ),
        .rclk                                   ( clk ),

        .wren                                   ( ROB_dmem_wr_val  ),
        .waddress                               ( ROB_dmem_wr_addr ),
        .wdata                                  ( ROB_dmem_wr_data ),

        .rden                                   ( ROB_dmem_rd_val  ),
        .raddress                               ( ROB_dmem_rd_addr ),
        .rdata                                  ( ROB_dmem_rd_data )
);
    


endmodule 

`endif   // _ROB__SV_ 

