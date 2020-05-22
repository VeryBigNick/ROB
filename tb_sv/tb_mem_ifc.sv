interface		tb_mem_ifc
	import	rob_package::*;
 (
	input	clk );
	
logic                   req_val     ;
logic   [AWIDTH - 1:0]  req_addr    ;
logic   [SWIDTH - 1:0]  req_ID      ;

logic                   rsp_val     ;
logic   [SWIDTH - 1:0]  rsp_ID      ;
logic   [DWIDTH - 1:0]  rsp_data    ;

modport		mem_port (
	input	clk,
    input	req_val   ,
    input	req_addr  ,
    input	req_ID    ,
    output	rsp_val   ,
    output	rsp_ID    ,
    output	rsp_data  
);
	
endinterface:	tb_mem_ifc