



class aes_driver extends uvm_driver #(aes_packet);

	  aes_packet pkt;
    int num_sent;
  virtual aes_interface vif;

	`uvm_component_utils(aes_driver)
	
	function new(string name = "aes_driver", uvm_component parent);
		super.new(name, parent);
    num_sent = 0;
	endfunction
	
  	
	virtual function void connect_phase(uvm_phase phase);
    		if (!aes_vif_config::get(this, " ", "vif", vif))
      			`uvm_error("NOVIF", "Virtual interface (vif) not set for aes_driver")
    		else
      			`uvm_info(get_type_name(), "Virtual interface successfully connected in AES driver", UVM_HIGH)
  	endfunction
	
  	task run_phase(uvm_phase phase);
    		fork
      			get_and_drive();
      			 reset_signals();
    		join
  	endtask
 
    // task get_and_drive();
  	// @(posedge vif.CLK);
	// 	@(negedge vif.CLK);
    		
    // 		forever begin
    //   			seq_item_port.get_next_item(pkt);

    //   			`uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", pkt.sprint()), UVM_HIGH)
       
    //   			vif.send_to_dut(pkt);
      		
    //   			num_sent++;
    //   			// Communicate item done to the sequencer
    //   			seq_item_port.item_done();
    // 		end
  	// endtask
	
	task get_and_drive();
	@(posedge vif.CLR);
	@(negedge vif.CLR);
    forever begin
        seq_item_port.get_next_item(pkt);

        `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", pkt.sprint()), UVM_HIGH)

        // Correctly call the interface task with all arguments
        vif.send_to_dut(
            pkt.enc_dec,
            pkt.KL,
            pkt.KEY,
            pkt.state_i
        );

        num_sent++;
        seq_item_port.item_done();
    end
endtask


	
	 
  	task reset_signals();
    		forever 
     			vif.cipher_reset();
        end
  	endtask
  

  	// UVM report_phase
  	function void report_phase(uvm_phase phase);
    		`uvm_info(get_type_name(), $sformatf("Report: AES driver sent %0d packets", num_sent), UVM_LOW)
  	endfunction
	
	  function void start_of_simulation_phase (uvm_phase phase);
		  `uvm_info(get_type_name(), "Running Simulation Driver", UVM_HIGH)
	  endfunction

endclass




	
	
	


	
	
	
