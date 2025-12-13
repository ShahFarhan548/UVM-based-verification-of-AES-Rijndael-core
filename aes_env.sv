
class aes_env extends uvm_env;
`uvm_component_utils (aes_env)
  aes_agent agent;
  aes_agent2 agent2;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = aes_agent::type_id::create("agent", this);
    agent2 = aes_agent2::type_id::create("agent2", this);
  endfunction
	
	function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "Running Simulation ...", UVM_HIGH)
  endfunction

endclass



