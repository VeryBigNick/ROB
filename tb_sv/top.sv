module	top;
	timeunit	1ns/1ns;
	
	initial	$timeformat(-9, 0, "ns", 3);
	
	import	rob_package::*;
	
	logic	clk;
	initial	begin
		clk <= 1'b0;
		forever #5	clk = ~clk;
	end
	
	tb_req_ifc	tb_req(clk);
	tb_mem_ifc	tb_mem(clk);
	tb_rsp_ifc	tb_rsp(clk);
	
	mem_t			mem;
	driver_req		drv_h;
	generator		gen_h;
	monitor			mon_h;
	mem_model		mem_h;

	initial	begin
		drv_h = new(tb_req);
		gen_h = new(.drv_h(drv_h));
		mon_h = new( .req(tb_req), .rsp(tb_rsp) );
		mem_h = new(.wr_data(tb_req), .rd_data(tb_mem));
		
		$display("Reset---------------");
		drv_h.reset();
		mon_h.reset();
		mem_h.reset();
		$display("Run-----------------");
		fork	
			mem_h.run();
		join_none
		fork
			gen_h.run(1000, mem);
			mon_h.run(mem);
		join
		$display("Check-----------------");		
		mon_h.check(mem);
		$display("Finish--------------");
		$finish;		
	end


	
// daemon for random responces from mem
/*
initial	begin
		forever	begin
			if ( mem_h.req_buf.size() != 0 )
				mem_h.rsp();
			else
				@(posedge clk);
		end
	end
*/

	
// daemon for requests to mem
/*
	always @(posedge clk)
		if ( tb_mem.req_val )	begin
			mem_h.req();
		end
*/
// daemon for writes to mem
/*
	always @(posedge clk)
		if ( tb_req.val )	begin
			mem_h.write();
			mon_h.add();
		end
*/	
ROB #(
        .ROB_SIZE     ( ROB_SIZE     ),
        .SWIDTH       ( SWIDTH       ),
        .AWIDTH       ( AWIDTH       ),
        .DWIDTH       ( DWIDTH       ),
        .PWIDTH       ( PWIDTH       ),
        .IDWIDTH      ( IDWIDTH      )
)
	dut (
        .clk          ( clk             ),
        .rst_         ( tb_req.rst_     ),

        .req_val      ( tb_req.val      ),
        .req_addr     ( tb_req.addr     ),
        .req_ID       ( tb_req.ID       ),
        .req_param    ( tb_req.param    ),
        .req_ready    ( tb_req.ready    ),

        .rsp_val      ( tb_rsp.val      ),
        .rsp_data     ( tb_rsp.data     ),
        .rsp_ID       ( tb_rsp.ID       ),
        .rsp_param    ( tb_rsp.param    ),
        .rsp_ready    ( tb_rsp.ready    ),

        .mem_req_val  ( tb_mem.req_val  ),
        .mem_req_addr ( tb_mem.req_addr ),
        .mem_req_ID   ( tb_mem.req_ID   ),

        .mem_rsp_val  ( tb_mem.rsp_val  ),
        .mem_rsp_ID   ( tb_mem.rsp_ID   ),
        .mem_rsp_data ( tb_mem.rsp_data )

);	




endmodule