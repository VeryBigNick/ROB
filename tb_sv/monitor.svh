class	monitor	extends	component;

	virtual		tb_req_ifc	req;
	virtual		tb_rsp_ifc	rsp;
	addr_table				addr_table_h;
	int						rsp_cnt;

	typedef	struct	{
		logic	[AWIDTH - 1:0]  addr   	;
		logic	[IDWIDTH - 1:0]	ID 		;
		logic	[DWIDTH - 1:0]  data   	;
		logic	[PWIDTH - 1:0]  param  	;
	}	req_buf_t;
	
	req_buf_t	req_buf[$];

	function new		(
		addr_table			mem
		);
		this.req = rob_package::tb_req;
		this.rsp = rob_package::tb_rsp;	
		this.addr_table_h = new();
		this.addr_table_h = mem;
		rsp_cnt = 0;
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

	virtual	task	verif();
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
						addr_table_h.delete_f(rsp_next.addr);
						rsp_cnt++;
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
	
	virtual	task	run(int n);
		fork
			this.add();
			this.ready_rand();
		join_none
		
		this.verif();
	endtask
	
	virtual	task	check	(int n);
		if ( req_buf.size() != 0 )	begin
			$error("Requests buffer is not empty: %p", req_buf);
			$stop();
		end
		else if ( rsp_cnt !== n )	begin
			$error("Responces lost: expected = %d, done = %d", n, rsp_cnt);
			$stop();
		end
		else
			$display("Monitor is OK!");
	endtask

endclass