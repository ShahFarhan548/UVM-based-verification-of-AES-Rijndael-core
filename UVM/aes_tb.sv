import uvm_pkg::*;
`include "uvm_macros.svh"
import aes_pkg::*;

class aes_tb extends uvm_env;
`uvm_component_utils(aes_tb)

aes_env env1;

  function new(string name = "aes_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env1 = aes_env::type_id::create("env1", this);
    endfunction

endclass

