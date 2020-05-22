class	mem_model;

	virtual	tb_req_ifc	wr_data;
	virtual	tb_mem_ifc	rd_data;

	mem_t				mem;
	
	
	req_buf_t	req_buf	[$];
	
	function	new(
		virtual	tb_req_ifc	wr_data,
		virtual	tb_mem_ifc	rd_data
	);
		this.wr_data = wr_data;
		this.rd_data = rd_data;
	endfunction
	
	virtual	task	reset();
		rd_data.rsp_val = 1'b0;
	endtask
	
	virtual	task	write(
//		transaction_req trn_h	
	);
		forever	begin
			@(posedge wr_data.clk);
			if ( wr_data.val & wr_data.ready )
				mem[wr_data.addr] = wr_data.data;
		end
	endtask
	
	virtual	task	req();
		forever	begin
			@(posedge rd_data.clk);
			if ( rd_data.req_val )
				req_buf.push_back('{
					addr 	: rd_data.req_addr,
					ID 		: rd_data.req_ID	});
		end
	endtask
	
	virtual	task	rsp();
		req_buf_t	rsp_out;
		int			pause_n;

		forever	begin
//			@(posedge rd_data.clk);
			
			if( this.req_buf.size() != 0 )	begin
				pause_n = $urandom_range(0, 3);
				if ( pause_n != 0 )	begin
					repeat(pause_n)
						@(posedge rd_data.clk)
						#1	rd_data.rsp_val = 1'b0;
				end
//				pause_rand(rd_data.clk, rd_data.rsp_val);
				req_buf.shuffle();
				rsp_out = req_buf.pop_front();
				
				rd_data.rsp_val 	= 1'b1;
				rd_data.rsp_ID		= rsp_out.ID;
				rd_data.rsp_data	= mem[rsp_out.addr];
			end
			@(posedge rd_data.clk);
			#1	rd_data.rsp_val = 1'b0;
		end
	endtask
	
	virtual	task	run();
		fork
			this.write();
			this.rsp();
			this.req();
		join
	endtask
	
	virtual	function	logic   [DWIDTH - 1:0]	check(
		logic	[AWIDTH - 1:0]  addr
	);
		return	mem[addr];
	endfunction

endclass