

class aes_agent extends uvm_agent;

	uvm_active_passive_enum is_active = UVM_ACTIVE;	
	
	aes_driver driver;
	aes_sequencer sequencer;
	aes_input_monitor monitor;




	`uvm_component_utils_begin(aes_agent)
  		`uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
	`uvm_component_utils_end
	

	function new(string name = "aes_agent", uvm_component parent);
		super.new(name, parent);
	endfunction
	
	function void build_phase (uvm_phase phase);
		super.build_phase(phase);


		monitor = aes_input_monitor::type_id::create("monitor", this);
		
		
		if (is_active == UVM_ACTIVE) begin
  			sequencer = aes_sequencer::type_id::create("sequencer", this);
  			driver    = aes_driver::type_id::create("driver", this);
		end
	
	endfunction
	
	function void connect_phase(uvm_phase phase);
		if (is_active == UVM_ACTIVE)
			driver.seq_item_port.connect(sequencer.seq_item_export);
	endfunction
	
	function void start_of_simulation_phase (uvm_phase phase);
		`uvm_info(get_type_name(), "Running Simulation Agent", UVM_HIGH)
	endfunction

endclass



