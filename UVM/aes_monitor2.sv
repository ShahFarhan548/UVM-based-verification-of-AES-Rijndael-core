


// class aes_monitor2 extends uvm_monitor;
//     `uvm_component_utils(aes_monitor2)
    
//     virtual aes_interface vif;
//     aes_packet pkt;
//     int num_pkt_col = 0;
    
//     uvm_analysis_port#(aes_packet) item_collected_port;
    
//     function new(string name = "aes_monitor2", uvm_component parent);
//         super.new(name, parent);
//         item_collected_port = new("item_collected_port", this);
//     endfunction
    
//     virtual function void connect_phase(uvm_phase phase);
//         if (!aes_vif_config::get(this, "", "vif", vif))
//             `uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor2")
//         else
//             `uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor", UVM_HIGH)
//     endfunction
    
//     task run_phase(uvm_phase phase);
//         bit [31:0] collected_state [3:0];
//         bit collected_cf;
        
//         // Input snapshot variables
//         bit enc_mode;
//         bit [1:0] key_len;
//         bit [31:0] key_array [7:0];
//         bit [31:0] state_in [3:0];
        
//         // Wait for reset to complete
//         @(posedge vif.CLK iff vif.CLR == 1'b0);
        
//         // Wait for driver to be ready
//         wait(vif.driver_active == 1);
//         repeat(5) @(posedge vif.CLK);  // Reduced from 10 to 5
        
//         `uvm_info(get_type_name(), "Monitor: Driver is active, starting collection", UVM_LOW)
        
//         forever begin
//             pkt = aes_packet::type_id::create("pkt", this);
            
//                        @(posedge vif.CLK iff vif.drvstart == 1);
            
//             // Snapshot input values
//             enc_mode = vif.enc_dec;
//             key_len  = vif.KL;
//             foreach(key_array[i])
//                 key_array[i] = vif.KEY[i];
//             foreach(state_in[i])
//                 state_in[i] = vif.state_i[i];
            
//             `uvm_info(get_type_name(), 
//                       $sformatf("Monitor captured inputs: enc_dec=%0b, KL=%0d", enc_mode, key_len), 
//                       UVM_MEDIUM)
            
//             // Wait for DUT to complete and collect outputs
//             vif.collect_output(collected_state, collected_cf);
            
//             // Fill packet with captured data
//             pkt.enc_dec = enc_mode;
//             pkt.KL      = key_len;
//             pkt.CK      = 1'b1;
            
//             foreach(pkt.KEY[i])
//                 pkt.KEY[i] = key_array[i];
//             foreach(pkt.state_i[i])
//                 pkt.state_i[i] = state_in[i];
//             foreach(pkt.state_o[i])
//                 pkt.state_o[i] = collected_state[i];
//             pkt.CF = collected_cf;
            
//             // Send to scoreboard
//             item_collected_port.write(pkt);
            
//             `uvm_info(get_type_name(), 
//                       $sformatf("Packet Collected #%0d:\n%s", num_pkt_col, pkt.sprint()), UVM_HIGH)
            
//             num_pkt_col++;
//         end
//     endtask
    
//     function void report_phase(uvm_phase phase);
//         `uvm_info(get_type_name(), 
//                   $sformatf("AES Monitor Collected %0d Packets", num_pkt_col), 
//                   UVM_LOW)
//     endfunction
    
//     function void start_of_simulation_phase(uvm_phase phase);
//         `uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
//     endfunction
// endclass



class aes_monitor2 extends uvm_monitor;

    `uvm_component_utils(aes_monitor2)

    virtual aes_interface vif;
    aes_packet pkt;
    int num_pkt_col=0;

    uvm_analysis_port#(aes_packet) item_collected_port;

    function new(string name = "aes_monitor2", uvm_component parent);
        super.new(name, parent);
          item_collected_port = new("item_collected_port", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if (!aes_vif_config::get(this, "", "vif", vif))
            `uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor2")
        else
            `uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor 2", UVM_HIGH)
    endfunction


// working
task run_phase(uvm_phase phase);
    bit [31:0] collected_state [3:0];
    bit collected_cf;
     bit enc_mode;
        bit [1:0] key_len;
        bit [31:0] key_array [7:0];
        bit [31:0] state_in [3:0];
    
    // Wait for driver to be ready before starting
    wait(vif.driver_active == 1);
    `uvm_info(get_type_name(), "Monitor: Driver is active, starting collection", UVM_LOW)
  
    forever begin

        pkt = aes_packet::type_id::create("pkt", this);
        
        `uvm_info(get_type_name(), "Monitor waiting for DUT completion...", UVM_MEDIUM)

        void'(begin_tr(pkt, "Monitor_AES_Packet"));
                 
        enc_mode = vif.enc_dec;
            key_len  = vif.KL;
            foreach(key_array[i])
                key_array[i] = vif.KEY[i];
            foreach(state_in[i])
                state_in[i] = vif.state_i[i];
            
            `uvm_info(get_type_name(), 
                      $sformatf("Monitor captured inputs: enc_dec=%0b, KL=%0d", enc_mode, key_len), 
                      UVM_MEDIUM)
            
            // Wait for DUT to complete and collect outputs
            vif.collect_output(collected_state, collected_cf);
            
            // Fill packet with captured data
            pkt.enc_dec = enc_mode;
            pkt.KL      = key_len;
            pkt.CK      = 1'b1;
            
            foreach(pkt.KEY[i])
                pkt.KEY[i] = key_array[i];
            foreach(pkt.state_i[i])
                pkt.state_i[i] = state_in[i];
            foreach(pkt.state_o[i])
                pkt.state_o[i] = collected_state[i];
            pkt.CF = collected_cf;
            
            // Send to scoreboard
            item_collected_port.write(pkt);
        
        end_tr(pkt);
       `uvm_info(get_type_name(),       $sformatf("Packet Collected #%0d:\n%s", num_pkt_col, pkt.sprint()), UVM_HIGH)
            
            num_pkt_col++;
     end
     
    // end
endtask






    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
    endfunction

endclass



