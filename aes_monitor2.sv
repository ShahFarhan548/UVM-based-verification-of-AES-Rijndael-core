
class aes_monitor2 extends uvm_monitor;

    `uvm_component_utils(aes_monitor2)

    virtual aes_interface vif;
    aes_packet pkt;
    int num_pkt_col=0;

    function new(string name = "aes_monitor2", uvm_component parent);
        super.new(name, parent);
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






    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(), $sformatf("AES Monitor Collected %0d Packets", num_pkt_col), UVM_LOW)
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running AES Monitor", UVM_HIGH)
    endfunction

endclass




