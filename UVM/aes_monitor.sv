


class aes_monitor extends uvm_monitor;

	aes_packet pkt;

  // Count packets collected
  int num_pkt_col;
	// virtual interface aes_if vif;
	
	// TLM ports used to connect the monitor to the scoreboard
  	// uvm_analysis_port #(aes_packet) item_collected_port;
	
	`uvm_component_utils(aes_monitor)
	
	
	function new(string name = "aes_monitor", uvm_component parent);
    super.new(name, parent);		
		 // Create the TLM port
    // item_collected_port = new("item_collected_port", this);
	endfunction
	
// 	virtual function void connect_phase(uvm_phase phase);
//     		if (!uvm_config_db#(virtual aes_if)::get(this, "", "vif", vif))
//       			`uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor")
//     		else
//       			`uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor", UVM_HIGH)
//   endfunction	
	
  task run_phase(uvm_phase phase);
    		
    		// if (vif == null) begin
      		// 	`uvm_fatal("NOVIF", "Virtual interface not found in aes_monitor; cannot proceed")
    		// end

		// Wait until reset is released (active low)
		// wait (vif.rst_i == 1);
		// `uvm_info(get_type_name(), "Detected Reset Released (monitor)", UVM_MEDIUM);
    	// 	 forever begin
      	// 		pkt = aes_packet::type_id::create("pkt", this);
		// 	   void'(begin_tr(pkt,"Monitor_AES_pkt"));
      	// 		vif.collect_packet(pkt);			    
        //   end_tr(pkt);
      	// 		`uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW)
      	// 		//item_collected_port.write(pkt.clone());
      	// 	num_pkt_col++;
    	// 	end
    		
  	endtask
  	
  	// UVM report_phase
  	function void report_phase(uvm_phase phase);
    		`uvm_info(get_type_name(), $sformatf("Report: AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
  	endfunction

	function void start_of_simulation_phase (uvm_phase phase);
		`uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
	endfunction

endclass
