
// class aes_env extends uvm_env;
// `uvm_component_utils (aes_env)
//   aes_agent agent;
//   aes_agent2 agent2;

//   function new(string name, uvm_component parent);
//     super.new(name, parent);
//   endfunction

//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     agent = aes_agent::type_id::create("agent", this);
//     agent2 = aes_agent2::type_id::create("agent2", this);
//   endfunction
	
// 	function void start_of_simulation_phase(uvm_phase phase);
//     super.start_of_simulation_phase(phase);
//     `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH)
//   endfunction

// endclass




class aes_env extends uvm_env;
  `uvm_component_utils(aes_env)

  aes_agent  agent;
  aes_agent2 agent2;
  aes_fifo_scoreboard sb;
  aes_subscriber sub;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent  = aes_agent::type_id::create("agent", this);
    agent2 = aes_agent2::type_id::create("agent2", this);
    sb  = aes_fifo_scoreboard::type_id::create("sb", this); // correct
     sub = aes_subscriber::type_id::create("sub", this);  
  endfunction

    function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);

  agent2.monitor_2.item_collected_port.connect(sb.out_imp);

    // Connect monitors to scoreboard
    // env.agent.monitor.ap.connect(sb.in_imp);

    `uvm_info(get_type_name(), "AES TB: Monitors connected to scoreboard", UVM_HIGH);

    agent2.monitor_2.item_collected_port.connect(sub.analysis_export);
   // agent2.monitor2.ap1.connect(sub.analysis_export);  


  endfunction
	

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "AES ENV: Simulation started", UVM_HIGH)
  endfunction

endclass








