
`define   TOP_ROB_SIZE    16
`define   TOP_SWIDTH      4 
`define   TOP_AWIDTH      10
`define   TOP_DWIDTH      32
`define   TOP_PWIDTH      5
`define   TOP_IDWIDTH     8


module  ROB_top (
input   wire    pin_clk,
input   wire    rst_,

input   wire                    req_val     ,
input   wire    [`TOP_AWIDTH - 1:0]  req_addr    ,
input   wire    [`TOP_IDWIDTH - 1:0] req_ID      ,
input   wire    [`TOP_PWIDTH - 1:0]  req_param   ,
output  reg                     req_ready   ,

output  reg                     rsp_val     ,
output  reg     [`TOP_DWIDTH - 1:0]  rsp_data    ,
output  reg     [`TOP_IDWIDTH - 1:0] rsp_ID      ,
output  reg     [`TOP_PWIDTH - 1:0]  rsp_param   ,
input   wire                    rsp_ready   ,

output  reg                     mem_req_val     ,
output  reg     [`TOP_AWIDTH - 1:0]  mem_req_addr    ,
output  reg     [`TOP_SWIDTH - 1:0]  mem_req_ID      ,

input   wire                    mem_rsp_val     ,
input   wire    [`TOP_SWIDTH - 1:0]  mem_rsp_ID      ,
input   wire    [`TOP_DWIDTH - 1:0]  mem_rsp_data    

  
);

localparam   ROB_SIZE    = `TOP_ROB_SIZE;
localparam   SWIDTH      = `TOP_SWIDTH  ;
localparam   AWIDTH      = `TOP_AWIDTH  ;
localparam   DWIDTH      = `TOP_DWIDTH  ;
localparam   PWIDTH      = `TOP_PWIDTH  ;
localparam   IDWIDTH     = `TOP_IDWIDTH ;

my_pll u0 (
    .rst      (rst_),      //   input,  width = 1,   reset.reset
    .refclk   (pin_clk),   //   input,  width = 1,  refclk.clk
    .outclk_0 (clk)  //  output,  width = 1, outclk0.clk
);
    
ROB #(
        .ROB_SIZE                               ( ROB_SIZE     ),
        .SWIDTH                                 ( SWIDTH       ),
        .AWIDTH                                 ( AWIDTH       ),
        .DWIDTH                                 ( DWIDTH       ),
        .PWIDTH                                 ( PWIDTH       ),
        .IDWIDTH                                ( IDWIDTH      )
)
    ROB (
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


endmodule 



