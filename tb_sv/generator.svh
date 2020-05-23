class	generator	extends	component;

	driver_req			drv_h;
	transaction_req		trn_h;
	addr_table			addr_table_h;
//	mem_t			mem;
	
	function	new(
		driver_req 		drv_h,
		addr_table		mem//,
//		mem_t			mem	
	);
		this.drv_h 	= drv_h;
		this.trn_h 	= new();
		this.addr_table_h = new();
		this.addr_table_h = mem;
//		this.mem	= mem;
	endfunction

	virtual	task	run(int n);
		int		pause_n;
		this.pause(trn_h);
		repeat (n)	begin
			while ( trn_h.rand_trn(addr_table_h) == 0 )
				this.pause(trn_h);

			this.send(trn_h);
			trn_h.print_trn;
			this.pause(trn_h);
		end
	endtask

	virtual	task	send(transaction_req	trn_h);
		drv_h.send(trn_h);
	endtask
	
	virtual	task	pause(transaction_req	trn_h);
		int	n;
		n = $urandom_range(0, 3);
		drv_h.pause(trn_h, n);
	endtask

endclass