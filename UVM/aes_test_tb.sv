import uvm_pkg::*;
`include "uvm_macros.svh"
import aes_pkg::*;


class aes_test_tb extends uvm_test;
`uvm_component_utils(aes_test_tb)

aes_tb tb1;

function new(string name = "base_test", uvm_component parent = null);
super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);

// uvm_config_int::set(this, "*", "recording_detail", 1);

// // Default sequence for previous base_test (can be left or removed)
// uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", 
//                         "default_sequence", yapp_5_packets::get_type());

`uvm_info(get_type_name(), "base_test build_phase executing", UVM_HIGH)
tb1 = aes_tb::type_id::create("tb1", this);
  // Pass the interface to driver and monitor
    // aes_vif_config::set(this, "tb1.env1.agent.driver",  "vif", aes_if_inst);
    // aes_vif_config::set(this, "tb1.env1.agent.monitor","vif", aes_if_inst);

endfunction


function void end_of_elaboration_phase(uvm_phase phase);
super.end_of_elaboration_phase(phase);
uvm_top.print_topology();
endfunction


function void check_phase(uvm_phase phase);
super.check_phase(phase);
check_config_usage();
endfunction


virtual task run_phase(uvm_phase phase);
uvm_objection obj;

obj = phase.get_objection();
obj.set_drain_time(this, 200ns);
endtask

endclass : aes_test_tb


class simple_test extends aes_test_tb;
`uvm_component_utils(simple_test)

function new(string name = "simple_test", uvm_component parent = null);
super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
// 1. YAPP UVC: create short YAPP packets
// yapp_packet::type_id::set_type_override(short_yapp_packet::get_type());


// 2. Call base build_phase to create TB and UVCs
super.build_phase(phase);

// 3. YAPP default sequence
uvm_config_wrapper::set(this, "tb1.env1.agent.sequencer.run_phase", "default_sequence", rand_packet::get_type()); // 4) Set default sequence for all Channel UVCs at once (wildcard 'chan*') // Ensure channel_rx_resp_seq is compiled and visible via channel_pkg. 
// uvm_config_wrapper::set(this, "tb.chan*.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type()); // 5) Clock & Reset default sequence 
// uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());

// 6. HBUS UVC: no default sequence needed


endfunction

endclass : simple_test