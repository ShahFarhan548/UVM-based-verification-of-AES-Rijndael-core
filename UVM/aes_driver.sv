



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
    get_and_drive();
endtask


// working
/*
task get_and_drive();
    wait(vif.CLR == 1'b1);
    @(posedge vif.CLK);
    
    forever begin
        seq_item_port.get_next_item(pkt);
        
        `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", pkt.sprint()), UVM_HIGH)
        
        void'(begin_tr(pkt, "Driver_AES_Packet"));
        
        vif.send_to_dut(
            pkt.enc_dec,
            pkt.KL,
            pkt.KEY,
            pkt.state_i
        );
        
        // CRITICAL: Wait for DUT to complete this packet
        @(posedge vif.CLK iff vif.CF == 1'b1);
        `uvm_info(get_type_name(), "DUT completed processing packet", UVM_MEDIUM)
        
        // Wait for CF to go low before next packet
        @(posedge vif.CLK iff vif.CF == 1'b0);
        
        end_tr(pkt);
        
        num_sent++;
        seq_item_port.item_done();
    end
endtask	 
*/

// working  recent

task get_and_drive();
  //  wait(vif.CLR == 1'b1);
    
    @(posedge vif.CLK);
    
    vif.driver_active = 1;  // Signal that driver is ready
    
    forever begin
        seq_item_port.get_next_item(pkt);

        `uvm_info(get_type_name(), $sformatf("Sending Packet :\n%s", pkt.sprint()), UVM_HIGH)
        
        void'(begin_tr(pkt, "Driver_AES_Packet"));
      @(posedge vif.CLK);
        vif.send_to_dut(
            pkt.enc_dec,
            pkt.KL,
            pkt.KEY,
            pkt.state_i
        );
        
        vif.packets_sent++;  // Increment counter
        
        // Wait for DUT to complete this packet
        @(posedge vif.CLK iff vif.CF == 1'b1);
        
        `uvm_info(get_type_name(), "DUT completed processing packet", UVM_MEDIUM)
        
        // Wait for CF to go low before next packet
        @(posedge vif.CLK iff vif.CF == 1'b0);
        
        end_tr(pkt);
        
        num_sent++;
        seq_item_port.item_done();
    end
endtask




/*
task get_and_drive();
    wait(vif.CLR == 1'b1);
    @(posedge vif.CLK);
    
    vif.driver_active = 1;
    
    forever begin
        seq_item_port.get_next_item(pkt);
        
        `uvm_info(get_type_name(), $sformatf("Driver: Sending Packet %0d", num_sent+1), UVM_LOW)
        
        void'(begin_tr(pkt, "Driver_AES_Packet"));
        
        vif.send_to_dut(
            pkt.enc_dec,
            pkt.KL,
            pkt.KEY,
            pkt.state_i
        );
        
        // Trigger event that packet was sent
        -> vif.driver_sent_packet;
        
        vif.packets_sent++;
        
        // Wait for DUT to complete this packet
        @(posedge vif.CLK iff vif.CF == 1'b1);
        `uvm_info(get_type_name(), $sformatf("Driver: Packet %0d completed by DUT", num_sent+1), UVM_MEDIUM)
        
        // Wait for CF to go low before next packet
        @(posedge vif.CLK iff vif.CF == 1'b0);
        
        end_tr(pkt);
        
        num_sent++;
        seq_item_port.item_done();
    end
endtask
*/


  	task reset_signals();
    		forever begin
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




	
	
	


	
	
	
