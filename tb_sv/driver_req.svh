class	driver_req;

	virtual	tb_req_ifc	req;

	function	new	(virtual	tb_req_ifc	req);
		this.req = req;
	endfunction
	
	virtual	task	reset();
		req.val  <= 1'b0;
		req.rst_ <= 1'b0;
		repeat(10)	@(posedge req.clk);
		req.rst_ <= 1'b1;	
	endtask
	
	virtual	task	send(transaction_req trn_h);
//		@(posedge req.clk)
			req.val 	<= 1'b1;
			req.addr    <= trn_h.addr   ;
			req.ID      <= trn_h.ID     ;
			req.param   <= trn_h.param  ;
			req.data	<= trn_h.data	;
		do	
			@(posedge req.clk);
		while	(~req.ready);
			#1	req.val 	<= 1'b0;
	endtask
	
	virtual	task	pause(
		transaction_req trn_h,
		int				pause_n);
		if ( pause_n != 0 )	begin
			repeat(pause_n)
				@(posedge req.clk)
				#1	req.val 	<= 1'b0;
		end
	endtask
	
endclass
	