
module aes_top;
  import uvm_pkg::*; 
  `include "uvm_macros.svh" 
  import aes_pkg::*;

  	`include "aes_tb.sv"
  	`include "aes_test_tb.sv"

  // Instantiate the DUT / hw_top
  aes_hw_top hw();

  // Set virtual interfaces for UVCs
  initial begin
    // Only set the virtual interface from hw
    aes_vif_config::set(null, "uvm_test_top.tb.env.*", "vif", hw.aes_if_inst);

    // Run the UVM test
    run_test();
  end
endmodule


