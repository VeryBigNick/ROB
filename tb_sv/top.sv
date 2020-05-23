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

	basetest		test_h;
	mem_model		mem_h;

	initial	begin
		rob_package::tb_req = tb_req;
		rob_package::tb_mem = tb_mem;
		rob_package::tb_rsp = tb_rsp;

		test_h = new();
		mem_h = new();
		
		$display("Build---------------");
		test_h.build();
		mem_h.build();
		
		$display("Reset---------------");
		test_h.reset();
		mem_h.reset();

		$display("Run-----------------");
		fork	
			mem_h.run(0);
		join_none
		test_h.run(10000);

		$display("Check-----------------");		
		test_h.check(10000);
		mem_h.check(0);

		$display("Finish--------------");
		$finish;		
	end


	
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