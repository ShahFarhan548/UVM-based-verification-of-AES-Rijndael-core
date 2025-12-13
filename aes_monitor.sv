
class aes_monitor extends uvm_monitor;

    `uvm_component_utils(aes_monitor)

    virtual aes_interface vif;
    aes_packet pkt;
    int num_pkt_col=0;

    function new(string name = "aes_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        if (!aes_vif_config::get(this, "", "vif", vif))
            `uvm_error("NOVIF", "Virtual interface (vif) not set for aes_monitor")
        else
            `uvm_info(get_type_name(), "Virtual interface successfully connected in AES monitor", UVM_HIGH)
    endfunction




// working
/*
task run_phase(uvm_phase phase);
    bit [31:0] collected_state [3:0];
    bit collected_cf;
    
    forever begin
        pkt = aes_packet::type_id::create("pkt", this);
        
        `uvm_info(get_type_name(), "Monitor waiting for DUT completion...", UVM_MEDIUM)
        
        // Start transaction recording
        void'(begin_tr(pkt, "Monitor_AES_Packet"));
        
        // Wait for collection with timeout
        fork
            begin
                vif.collect_output(collected_state, collected_cf);
                `uvm_info(get_type_name(), "Monitor collected output from DUT", UVM_MEDIUM)
            end
            begin
                repeat(50000) @(posedge vif.CLK);
                `uvm_error(get_type_name(), "TIMEOUT: DUT never asserted CF or took too long")
            end
        join_any
        disable fork;
        
        // Copy collected data to packet
        foreach(pkt.state_o[i])
            pkt.state_o[i] = collected_state[i];
        pkt.CF = collected_cf;
        
        // End transaction recording
        end_tr(pkt);
        
        `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH);
        num_pkt_col++;
    end
endtask
*/

// working

task run_phase(uvm_phase phase);
    bit [31:0] collected_state [3:0];
    bit collected_cf;
    
    // Wait for driver to be ready before starting
    wait(vif.driver_active == 1);
    `uvm_info(get_type_name(), "Monitor: Driver is active, starting collection", UVM_LOW)
  
    forever begin

        pkt = aes_packet::type_id::create("pkt", this);
        
        `uvm_info(get_type_name(), "Monitor waiting for DUT completion...", UVM_MEDIUM)

        void'(begin_tr(pkt, "Monitor_AES_Packet"));
                 
       // fork
      //      begin
               vif.collect_output(collected_state, collected_cf);
                
                `uvm_info(get_type_name(), "Monitor collected output from DUT", UVM_MEDIUM)
//          @(posedge vif.monstart) 
              void'(begin_tr(pkt, "Monitor_YAPP_Packet"));

         //   end

      //  join
        
        // Copy collected data to packet
        foreach(pkt.state_o[i])
            pkt.state_o[i] = collected_state[i];
        pkt.CF = collected_cf;
        
        end_tr(pkt);
        
        `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH);
        num_pkt_col++;
     
    end
endtask



/*
task run_phase(uvm_phase phase);
    bit [31:0] collected_out_state [3:0];
    bit [31:0] collected_in_state  [3:0];
    bit [31:0] collected_out_key   [7:0];
    bit [31:0] collected_in_key    [7:0];
    bit        collected_enc_dec;
    bit [1:0]  collected_KL;
    bit        collected_cf;
    
    // Wait for driver to be active
 //   wait(driver_active == 1);
    `uvm_info(get_type_name(), "Monitor: Driver is active, starting collection", UVM_LOW)
    
    forever begin
        pkt = aes_packet::type_id::create("pkt", this);

        `uvm_info(get_type_name(), "Monitor waiting for DUT completion...", UVM_MEDIUM)

        void'(begin_tr(pkt, "Monitor_AES_Packet"));

        // Collect all input/output signals
        vif.collect_output(
            collected_out_state,
            collected_in_state,
            collected_out_key,
            collected_in_key,
            collected_enc_dec,
            collected_KL,
            collected_cf
        );

        // Copy all signals to packet
        foreach(pkt.state_o[i]) pkt.state_o[i] = collected_out_state[i];
        foreach(pkt.state_i[i]) pkt.state_i[i] = collected_in_state[i];
        foreach(pkt.KEY[i])     pkt.KEY[i]     = collected_in_key[i]; // input key snapshot
        pkt.enc_dec = collected_enc_dec;
        pkt.KL      = collected_KL;
        pkt.CF      = collected_cf;

        end_tr(pkt);
        `uvm_info(get_type_name(), $sformatf("Packet Collected:\n%s", pkt.sprint()), UVM_HIGH);

        num_pkt_col++;
    end
endtask
*/





    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
    endfunction

endclass




