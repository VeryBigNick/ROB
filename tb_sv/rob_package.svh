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



	task	automatic		pause_rand(
		ref				clk,
		output	logic	val
	);
		int			pause_n;
		pause_n = $urandom_range(0, 3);
		if ( pause_n != 0 )	begin
			repeat(pause_n)
			@(posedge clk)
			#1	val = 1'b0;
		end
	endtask

typedef	logic   [AWIDTH - 1:0]  addr_t    ;
typedef	logic	[DWIDTH - 1:0]	mem_t	[addr_t];

typedef	class	transaction_req;
typedef	class	driver_req;
typedef	class	generator;
typedef	class	mem_model;
typedef	class	monitor;

`include	"transaction_req.svh"
`include	"driver_req.svh"
`include	"generator.svh"
`include	"mem_model.svh"
`include	"monitor.svh"

endpackage