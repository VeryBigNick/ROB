package	rob_package;

	parameter	ROB_SIZE    = 128;
    parameter	SWIDTH      = 4 ;
	parameter	AWIDTH      = 4;
	parameter	DWIDTH      = 32;
	parameter	PWIDTH      = 10;
	parameter	IDWIDTH     = 16;
	parameter	TIMEOUT		= 200;

	typedef	struct	{
		logic	[AWIDTH - 1:0]  addr   	;
		logic	[SWIDTH - 1:0]	ID 		;
	}	req_buf_t;

	virtual	tb_req_ifc	tb_req;
	virtual	tb_mem_ifc	tb_mem;
	virtual	tb_rsp_ifc	tb_rsp;

	

typedef	logic   [AWIDTH - 1:0]  addr_t    ;
typedef	logic	[DWIDTH - 1:0]	mem_t	[addr_t];

typedef	class	component;
typedef	class	transaction_req;
typedef	class	driver_req;
typedef	class	generator;
typedef	class	mem_model;
typedef	class	monitor;
typedef class	addr_table;
typedef class	basetest;

`include	"component.svh"
`include	"transaction_req.svh"
`include	"driver_req.svh"
`include	"generator.svh"
`include	"mem_model.svh"
`include	"monitor.svh"
`include	"addr_table.svh"
`include	"basetest.svh"

endpackage