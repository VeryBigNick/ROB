class	monitor;

	virtual	tb_req_ifc	req;
	virtual	tb_rsp_ifc	rsp;

	typedef	struct	{
		logic	[AWIDTH - 1:0]  addr   	;
		logic	[IDWIDTH - 1:0]	ID 		;
		logic	[DWIDTH - 1:0]  data   	;
		logic	[PWIDTH - 1:0]  param  	;
	}	req_buf_t;
	
	req_buf_t	req_buf[$];

	function	new	(
		virtual	tb_req_ifc	req,
		virtual	tb_rsp_ifc	rsp
		);
		this.req = req;
		this.rsp = rsp;		
	endfunction

	virtual task	reset();
		rsp.ready = 1'b1;
	endtask

	virtual	task	add();
		forever	begin
			@(posedge req.clk);
			if ( req.val & req.ready )
				req_buf.push_back('{
					addr 	: req.addr,
					ID 		: req.ID	,
					data	: req.data,
					param	: req.param	});
		end
	endtask

	virtual	task	verif(ref mem_t	mem);
		static int		timeout = 0;
		req_buf_t	rsp_next;
		while	( timeout != TIMEOUT )	begin
			@(posedge rsp.clk );
			#1;
			if ( rsp.val & rsp.ready )
				if (  req_buf.size() == 0 )
					$error("Unexpected response!");
				else begin
					rsp_next = req_buf.pop_front();
					if ( rsp_next.ID !== rsp.ID )	begin
						$error("Incorrect response ID: expected = %h, received = %h",
								rsp_next.ID, rsp.ID );
						$stop();
					end
					else if ( rsp_next.data !== rsp.data )	begin
						$error("Incorrect response data: expected = %h, received = %h",
								rsp_next.data, rsp.data );
						$stop();
					end
					else	begin
						$display("Correct response: addr = %h, ID = %h, data = %h", 
							rsp_next.addr, rsp_next.ID, rsp_next.data);
						mem.delete(rsp_next.addr);
					end
					timeout = 0;
				end
			else
				timeout++;
		end
	endtask
	
	virtual	task	ready_rand();
		int		pause_n;
		forever	begin
			pause_n = $urandom_range(0, 1);
			@(posedge rsp.clk)
				rsp.ready <= pause_n[0];
		end
	endtask
	
	virtual	task	run(ref mem_t	mem);
		fork
			this.add();
			this.ready_rand();
		join_none
		
		this.verif(mem);
	endtask
	
	virtual	task	check	(ref mem_t	mem);
		if ( req_buf.size() != 0 )	begin
			$error("Requests buffer is not empty: %p", req_buf);
			$stop();
		end
		if ( mem.size() != 0 )	begin
			$error("Requests buffer is not empty: %p", mem);
			$stop();
		end
	endtask

endclass