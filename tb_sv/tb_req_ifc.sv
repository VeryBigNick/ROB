interface		tb_req_ifc 
	import	rob_package::*;
(
	input	clk );
	logic					rst_	;
	logic                   val     ;
	logic   [AWIDTH - 1:0]  addr    ;
	logic   [IDWIDTH - 1:0] ID      ;
	logic   [PWIDTH - 1:0]  param   ;
	logic                   ready   ;
	logic	[DWIDTH - 1:0]	data	;

modport		tb_port (
	input					clk		,
	output					rst_	,
	output                  val     ,
	output                  addr    ,
	output                  ID      ,
	output                  param   ,
	input                   ready   ,
	output	                data	
);


endinterface:	tb_req_ifc
				
