

class aes_sequencer extends uvm_sequencer #(aes_packet);

	`uvm_component_utils(aes_sequencer)
	
	function new(string name="aes_sequencer", uvm_component parent=null);
		super.new(name, parent);
	endfunction
	
	function void start_of_simulation_phase (uvm_phase phase);
		`uvm_info(get_type_name(), "Running Simulation Sequencer", UVM_HIGH)
	endfunction

endclass



