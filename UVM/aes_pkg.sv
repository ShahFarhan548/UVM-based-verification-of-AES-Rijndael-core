
package aes_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"


typedef uvm_config_db#(virtual aes_interface) aes_vif_config;

 
  `include "aes_packet.sv"
  `include "aes_monitor.sv"
  `include "aes_sequencer.sv"
  `include "aes_seqs.sv"
  `include "aes_driver.sv"
  `include "aes_agent.sv"
  `include "aes_env.sv" 
 

endpackage
