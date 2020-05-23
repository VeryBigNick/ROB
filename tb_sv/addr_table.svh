class	addr_table	extends 	component;

	mem_t				addr_table_mem;

	virtual		function	void	add_f	(
		addr_t  				addr    ,
		logic	[DWIDTH - 1:0]	data	);
		
		this.addr_table_mem[addr] = data;		
	endfunction
	
	virtual		function	int		exist_f	(
		addr_t  				addr
	);
		return	this.addr_table_mem.exists(addr);
	endfunction
	
	virtual		function	int		size_f ();
		return	this.addr_table_mem.size();
	endfunction
	
	virtual		function	void	delete_f	(
		addr_t  				addr
	);
		this.addr_table_mem.delete(addr);
	endfunction

	virtual	task	check(int n);
		if ( this.addr_table_mem.size() != 0 )	begin
			$error("Requests buffer is not empty: %p", this.addr_table_mem);
			$stop();
		end
		else
			$display("Address table is OK!");
endtask

endclass