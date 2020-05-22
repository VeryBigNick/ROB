interface		tb_rsp_ifc 
	import	rob_package::*;
(
	input	clk );
	logic                   val     ;
	logic   [IDWIDTH - 1:0] ID      ;
	logic   [PWIDTH - 1:0]  param   ;
	logic                   ready   ;
	logic	[DWIDTH - 1:0]	data	;



endinterface:	tb_rsp_ifc
