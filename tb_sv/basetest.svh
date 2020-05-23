class	basetest	extends 	component;

	driver_req	drv_h;
	monitor		mon_h;
	generator	gen_h;
	addr_table		addr_table_h;

	virtual	task	build	();
		addr_table_h = new();
		drv_h = new(rob_package::tb_req);
		mon_h = new( 	//.req(rob_package::tb_req), 
						//.rsp(rob_package::tb_rsp),
						.mem(addr_table_h) );
		gen_h = new(.drv_h(drv_h), .mem(addr_table_h));
		addr_table_h.build();
		drv_h.build();
		mon_h.build();
		gen_h.build();    
	endtask

	
	virtual	task	reset();
		addr_table_h.reset();
		drv_h.reset();
		mon_h.reset();
		gen_h.reset();    
	endtask

	virtual	task	run(int n);
	fork	
		addr_table_h.run(n);
		drv_h.run(n);
		mon_h.run(n);
		gen_h.run(n);    
	join
	endtask

	virtual	task	check(int n);
		addr_table_h.check(n);
		drv_h.check(n);
		mon_h.check(n);
		gen_h.check(n);    
	endtask

	virtual	task	report();
		addr_table_h.report();
		drv_h.report();
		mon_h.report();
		gen_h.report();    
	endtask


endclass