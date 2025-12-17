
// package aes_pkg;

//   import uvm_pkg::*;
//   typedef uvm_config_db#(virtual aes_interface) aes_vif_config;

//   `include "uvm_macros.svh" 
//   `include "aes_packet.sv"
//   `include "aes_input_monitor.sv"
//   `include "aes_monitor2.sv"
//   `include "aes_sequencer.sv"
//   `include "aes_seqs.sv"
//   `include "aes_driver.sv"
//   `include "aes_agent.sv"
//   `include "aes_agent2.sv"
//   `include "aes_env.sv" 
//   // `include "aes_fifo_scoreboard.sv"
 
// endpackage


package aes_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef uvm_config_db#(virtual aes_interface) aes_vif_config;

  // -----------------------------
  // Include all components
  // -----------------------------
  `include "aes_packet.sv"
  `include "aes_sequencer.sv"
  `include "aes_seqs.sv"
  `include "aes_driver.sv"
  `include "aes_input_monitor.sv"
  `include "aes_monitor2.sv"
  // `include "aes_coverage.sv"
  `include "aes_fifo_scoreboard.sv"
  
  `include "aes_agent.sv"
  `include "aes_agent2.sv"
  `include "aes_subscriber.sv"
  `include "aes_env.sv"

endpackage
