class	mem_model	extends	component;

	virtual	tb_req_ifc	wr_data;
	virtual	tb_mem_ifc	rd_data;

	mem_t				mem;
	
	
	req_buf_t	req_buf	[$];
	
	virtual	task	build ();
		this.wr_data = rob_package::tb_req;
		this.rd_data = rob_package::tb_mem;
	endtask
	
	virtual	task	reset();
		rd_data.rsp_val = 1'b0;
	endtask
	
	virtual	task	write();
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
		logic	[DWIDTH - 1:0]	rsp_data;

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
				
				if ( mem.exists(rsp_out.addr) == 1 )	begin
					rd_data.rsp_val 	= 1'b1;
					rd_data.rsp_ID		= rsp_out.ID;
					rsp_data = mem[rsp_out.addr];
					if ($test$plusargs("MEMORY_ERRORS"))	begin
						int		rand_addr = $urandom_range(0, 3);
						if ( rand_addr == 0 )
							rsp_data = 'x;
					end
					
					rd_data.rsp_data	= rsp_data;
				end
				else	begin
					$error("Memory model error: reading of nonexisting element: address = %h",
							rsp_out.addr);
					$stop;
				end
			end
			@(posedge rd_data.clk);
			#1	rd_data.rsp_val = 1'b0;
		end
	endtask
	
	virtual	task	run(int n);
		fork
			this.write();
			this.rsp();
			this.req();
		join
	endtask

endclass