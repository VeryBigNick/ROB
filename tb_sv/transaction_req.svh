class		transaction_req
/*
#(
	parameter	AWIDTH      = 32,
				DWIDTH      = 32,
				PWIDTH      = 10,
				IDWIDTH     = 16
				)
*/;
	addr_t  				addr    ;
	logic   [IDWIDTH - 1:0] ID      ;
	logic   [PWIDTH - 1:0]  param   ;
	logic	[DWIDTH - 1:0]	data	;

	virtual	function	int	rand_trn (
			addr_table			addr_table_h );
		static	int	temp = 0;
		static	int	seed = 10;

		if ( addr_table_h.size_f() == 2**AWIDTH )
			return	0;
			
		do 	begin
			this.addr 	= $random(seed);
//			$display("Array = %p, generated addr = %h", mem, addr);
		end
		while ( addr_table_h.exist_f(this.addr)/*mem.exists(this.addr)*/ );
		
		this.ID 	= $urandom_range(0, 2**IDWIDTH);
		this.param	= temp;
		this.data	= $urandom_range(0, 2**DWIDTH - 1);
//		mem[this.addr] = this.data;
		addr_table_h.add_f(this.addr, this.data);
		temp++;
		return 1;
	endfunction
	
	virtual	function	void	print_trn();
		$display("Request to ROB: adrress = %h, ID = %h, param = %h, data = %h",
					addr, ID, param, data);
	endfunction

endclass