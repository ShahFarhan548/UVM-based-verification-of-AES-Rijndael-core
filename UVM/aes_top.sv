
module aes_top;
 import uvm_pkg::*; 
  `include "uvm_macros.svh" 
  import aes_pkg::*;
 
`include "aes_tb.sv"
 `include "aes_test_tb.sv"



  // Instantiate the DUT / hw_top
//   hw_top hw();

  // Set virtual interfaces for UVCs
  initial begin


    // yapp_vif_config::set(null, "*", "vif", hw.in0);
    // channel_vif_config::set(null, "*.chan0.*", "vif", hw.chan_if0);
    // channel_vif_config::set(null, "*.chan1.*", "vif", hw.chan_if1);
    // channel_vif_config::set(null, "*.chan2.*", "vif", hw.chan_if2);
    // clock_and_reset_vif_config::set(null, "*", "vif", hw.clk_rst_if);
    // hbus_vif_config::set(null, "*", "vif", hw.hbus_if1);

    // Run the UVM test
    run_test();
  end

endmodule

