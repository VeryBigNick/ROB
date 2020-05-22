class		transaction_rsp	;

logic    [DWIDTH - 1:0]  data    ;
logic    [IDWIDTH - 1:0] ID      ;
logic    [PWIDTH - 1:0]  param   ;

	
	virtual	function	void	print_trn();
		$display("Responce from ROB: ID = %h, param = %h, data = %h",
					ID, param, data);
	endfunction

endclass