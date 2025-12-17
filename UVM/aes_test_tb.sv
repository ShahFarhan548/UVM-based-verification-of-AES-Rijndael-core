
/*
class aes_test_tb extends uvm_test;
`uvm_component_utils(aes_test_tb)

aes_tb tb;

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
tb = aes_tb::type_id::create("tb", this);
  // Pass the interface to driver and monitor
    // aes_vif_config::set(this, "tb.env1.agent.driver",  "vif", aes_if_inst);
    // aes_vif_config::set(this, "tb.env1.agent.monitor","vif", aes_if_inst);

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
uvm_config_wrapper::set(this, "tb.env1.agent.sequencer.run_phase", "default_sequence", rand_packet::get_type()); // 4) Set default sequence for all Channel UVCs at once (wildcard 'chan*') // Ensure channel_rx_resp_seq is compiled and visible via channel_pkg. 
// uvm_config_wrapper::set(this, "tb.chan*.rx_agent.sequencer.run_phase", "default_sequence", channel_rx_resp_seq::get_type()); // 5) Clock & Reset default sequence 
// uvm_config_wrapper::set(this, "tb.clk_rst.agent.sequencer.run_phase", "default_sequence", clk10_rst5_seq::get_type());

// 6. HBUS UVC: no default sequence needed


endfunction

endclass : simple_test
*/


import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------
// Base Test Class
//------------------------------------------------------
class aes_test_tb extends uvm_test;
  `uvm_component_utils(aes_test_tb)

  aes_tb tb;  // top-level testbench handle
  virtual aes_interface vif; // virtual interface handle

  // Constructor
  function new(string name = "aes_test_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  // Build Phase
  virtual function void build_phase(uvm_phase phase);

    uvm_config_int::set( this, "*", "recording_detail", 1);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Build Phase Started for AES Base Test", UVM_HIGH)

    tb = aes_tb::type_id::create("tb", this);

  endfunction


  // End of Elaboration Phase
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction


  // Check Phase
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    check_config_usage();
  endfunction


// rand_packet

virtual task run_phase(uvm_phase phase);
  rand_packet seq;
 
  // NO objections here - let sequence handle it
  `uvm_info(get_type_name(), "AES Base Test Run Phase Started", UVM_HIGH)
  
  seq = rand_packet::type_id::create("seq");
  seq.starting_phase = phase;  // ← CRITICAL: Tell sequence which phase to use
  seq.start(tb.env.agent.sequencer);
  
  `uvm_info(get_type_name(), "AES Base Test Run Phase Completed", UVM_LOW)
  // NO drop objection here
endtask




endclass : aes_test_tb



//------------------------------------------------------
// Simple Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class simple_test extends aes_test_tb;
  `uvm_component_utils(simple_test)
  function new(string name = "simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    `uvm_info(get_type_name(), "Building simple_test - setting default sequences", UVM_HIGH)

  endfunction

endclass : simple_test




//------------------------------------------------------
// Encryption Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class encryption_test extends aes_test_tb;
  `uvm_component_utils(encryption_test)
  
  function new(string name = "encryption_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building encryption_test", UVM_HIGH)
  endfunction
  
  // Override run_phase to use packet_encryption sequence
  virtual task run_phase(uvm_phase phase);
    packet_encryption seq;
    
    `uvm_info(get_type_name(), "Encryption Test Run Phase Started", UVM_HIGH)
    
    seq = packet_encryption::type_id::create("seq");
    seq.starting_phase = phase;
    seq.start(tb.env.agent.sequencer);
    
    `uvm_info(get_type_name(), "Encryption Test Run Phase Completed", UVM_LOW)
  endtask
endclass : encryption_test





//------------------------------------------------------
// Decryption Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class decryption_test extends aes_test_tb;
  `uvm_component_utils(decryption_test)
  
  function new(string name = "decryption_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building Decryption_test", UVM_HIGH)
  endfunction
  
  // Override run_phase to use packet_decryption sequence
  virtual task run_phase(uvm_phase phase);
    packet_decryption seq;
    
    `uvm_info(get_type_name(), "Decryption Test Run Phase Started", UVM_HIGH)
    
    seq = packet_decryption::type_id::create("seq");
    seq.starting_phase = phase;
    seq.start(tb.env.agent.sequencer);
    
    `uvm_info(get_type_name(), "Decryption Test Run Phase Completed", UVM_LOW)
  endtask
endclass : decryption_test




//------------------------------------------------------
// Zero Key Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class zero_key_test extends aes_test_tb;
  `uvm_component_utils(zero_key_test)
  
  function new(string name = "zero_key_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building zero_key_test", UVM_HIGH)
  endfunction
  
  // Override run_phase to use zero_key sequence
  virtual task run_phase(uvm_phase phase);
    zero_key seq;
    
    `uvm_info(get_type_name(), "Zero Key Test Run Phase Started", UVM_HIGH)
    
    seq = zero_key::type_id::create("seq");
    seq.starting_phase = phase;
    seq.start(tb.env.agent.sequencer);
    
    `uvm_info(get_type_name(), "Zero Key Test Run Phase Completed", UVM_LOW)
  endtask
endclass



//------------------------------------------------------
// Zero Input Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class zero_input_test extends aes_test_tb;
  `uvm_component_utils(zero_input_test)
  
  function new(string name = "zero_input_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building zero_input_test", UVM_HIGH)
  endfunction
  
  // Override run_phase to use zero_input sequence
  virtual task run_phase(uvm_phase phase);
    zero_input seq;
    
    `uvm_info(get_type_name(), "Zero Input Test Run Phase Started", UVM_HIGH)
    
    seq = zero_input::type_id::create("seq");
    seq.starting_phase = phase;
    seq.start(tb.env.agent.sequencer);
    
    `uvm_info(get_type_name(), "Zero Input Test Run Phase Completed", UVM_LOW)
  endtask
endclass

/*
//------------------------------------------------------
// Reset Test Class (Derives from aes_test_tb)
//------------------------------------------------------
class reset_test extends aes_test_tb;
  `uvm_component_utils(reset_test)
  
  function new(string name = "reset_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info(get_type_name(), "Building reset_test", UVM_HIGH)
  endfunction
  
  // Override run_phase to use reset sequence
  virtual task run_phase(uvm_phase phase);
    zero_input seq;
    
    `uvm_info(get_type_name(), "Reset Test Run Phase Started", UVM_HIGH)
    
    seq = reset_packet::type_id::create("seq");
    seq.starting_phase = phase;
    seq.start(tb.env.agent.sequencer);
    
    `uvm_info(get_type_name(), "Reset Test Run Phase Completed", UVM_LOW)
  endtask
endclass
*/

