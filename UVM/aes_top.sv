
module aes_top;
 import uvm_pkg::*; 
  `include "uvm_macros.svh" 
  import aes_pkg::*;
 
`include "aes_tb.sv"
 `include "aes_test_tb.sv"


aes_interface aes_if_inst(CLK, CLR);


  // Instantiate the DUT / hw_top
   aes_hw_top hw();

  // Set virtual interfaces for UVCs
  initial begin

 aes_vif_config::set(null, "*", "vif", aes_if_inst);
    aes_vif_config::set(null, "*", "vif", hw.aes_if_inst);
    // channel_vif_config::set(null, "*.chan0.*", "vif", hw.chan_if0);
    // channel_vif_config::set(null, "*.chan1.*", "vif", hw.chan_if1);
    // channel_vif_config::set(null, "*.chan2.*", "vif", hw.chan_if2);
    // clock_and_reset_vif_config::set(null, "*", "vif", hw.clk_rst_if);
    // hbus_vif_config::set(null, "*", "vif", hw.hbus_if1);

    // Run the UVM test
    run_test();
  end

endmodule

