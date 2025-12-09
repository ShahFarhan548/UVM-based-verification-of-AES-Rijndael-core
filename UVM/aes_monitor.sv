


// class aes_monitor extends uvm_monitor;

// 	aes_packet pkt;

//   // Count packets collected
//   int num_pkt_col;
// 	virtual aes_interface vif;
	
// 	// TLM ports used to connect the monitor to the scoreboard
//   	// uvm_analysis_port #(aes_packet) item_collected_port;
	
// 	`uvm_component_utils(aes_monitor)
	
	
// 	function new(string name = "aes_monitor", uvm_component parent);
//     super.new(name, parent);		
// 		 // Create the TLM port
//     // item_collected_port = new("item_collected_port", this);
// 	endfunction
	
// 	virtual function void connect_phase(uvm_phase phase);
//     		if (!aes_vif_config::get(this, " ", "vif", vif))
//       			`uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor")
//     		else
//       			`uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor", UVM_HIGH)
//   endfunction	
	
// //   task run_phase(uvm_phase phase);
// //     forever begin
// //         pkt = aes_packet::type_id::create("pkt", this);

// //         // Collect output from interface
// //         vif.collect_output(pkt.state_o, pkt.CF);

// //         `uvm_info(get_type_name(), $sformatf("Packet Collected :\n%s", pkt.sprint()), UVM_LOW);

// //         // Write to TLM analysis port if you have one
// //         // item_collected_port.write(pkt.clone());
// //         num_pkt_col++;
// //     end
// // endtask


// // 	task run_phase(uvm_phase phase);
// //     forever begin
// //         // Create a new packet object
// //         pkt = aes_packet::type_id::create("pkt", this);

// //         // Collect DUT output into packet
// //         vif.collect_output(pkt.state_i, pkt.state_o, pkt.CF );

// //         `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH)

// //         // Increment count
// //         num_pkt_col++;

// //         // Optionally, send to scoreboard through TLM
// //         // item_collected_port.write(pkt.clone());
// //     end
// // endtask

// task run_phase(uvm_phase phase);
//     //wait (vif.cipher_reset());
//     forever begin
//         // Create a new packet for DUT output
//         pkt = aes_packet::type_id::create("pkt", this);

//         // Collect DUT output only
//         vif.collect_output(pkt.state_o, pkt.CF);

//         `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH);

//         num_pkt_col++;

//         // Optionally, send to scoreboard via TLM
//         // item_collected_port.write(pkt.clone());
//     end
// endtask




  	
//   	// UVM report_phase
//   	function void report_phase(uvm_phase phase);
//     		`uvm_info(get_type_name(), $sformatf("Report: AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
//   	endfunction

// 	function void start_of_simulation_phase (uvm_phase phase);
// 		`uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
// 	endfunction

// endclass




class aes_monitor extends uvm_monitor;

    `uvm_component_utils(aes_monitor)

    virtual aes_interface vif;
    aes_packet pkt;
    int num_pkt_col;

    function new(string name = "aes_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if (!aes_vif_config::get(this, " ", "vif", vif))
            `uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor")
        else
            `uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor", UVM_HIGH)
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            // Wait until driver starts sending a packet
            @(posedge vif.drvstart);

            // Create new packet
            pkt = aes_packet::type_id::create("pkt", this);

            // Wait for completion flag from DUT
            @(posedge vif.CF);

            // Capture DUT outputs
            foreach(pkt.state_o[i])
                pkt.state_o[i] = vif.state_o[i];

            // Capture CF
            pkt.CF = vif.CF;

            `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH);

            num_pkt_col++;
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
    endfunction

endclass
