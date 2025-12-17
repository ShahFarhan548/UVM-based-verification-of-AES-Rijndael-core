
// import uvm_pkg::*;
// `include "uvm_macros.svh"
// // import aes_fifo_scoreboard::*;

// class aes_tb extends uvm_env;
// `uvm_component_utils(aes_tb)

// aes_env env;
// aes_fifo_scoreboard sb; 

//   function new(string name = "aes_tb", uvm_component parent);
//     super.new(name, parent);
//   endfunction

// function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//     env = aes_env::type_id::create("env", this);
//     sb = aes_fifo_scoreboard::type_id::create("sb", this);
//   endfunction


//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);

//     agent.mon.ap.connect(sb.in_imp);

//     agent2.mon.item_collected_port.connect(sb.out_imp);

//     `uvm_info(get_type_name(), "AES ENV: Monitors connected to scoreboard", UVM_HIGH)
     
     
//   endfunction
// endclass


class aes_tb extends uvm_env;
  `uvm_component_utils(aes_tb)

  aes_env env;
  

  function new(string name = "aes_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = aes_env::type_id::create("env", this);
    
  endfunction

  
endclass


