/*-----------------------------------------------------------------
File name     : aes_hw_top.sv
Developer     : Your Name
Created       : 2025/12/09
Description   : Hardware top module for AES DUT
                Instantiates AES DUT, AES interface, clock/reset
-----------------------------------------------------------------*/

module aes_hw_top;

  // Clock and reset signals
  logic [31:0] clock_period;
  logic        run_clock;
  logic        CLK;    // main simulation clock
  logic        CLR;    // reset

  // Clock generator instance
//   clkgen clkgen_inst (
//       .clock(CLK),
//       .run_clock(run_clock),
//       .clock_period(clock_period)
//   );
// simple clock generator (10 ns period => 100 MHz)
initial begin
  CLK = 0;
  forever #5 CLK = ~CLK;
end

// simple reset pulse on CLR (assert high for 50 ns)
initial begin
  CLR = 1;
  #50;
  CLR = 0;
end

  // AES Interface instantiation
  aes_interface aes_if_inst (
      .CLK(CLK),
      .CLR(CLR)
  );

  // DUT instantiation
  cipher_unit dut (
      .CLK(CLK),
      .CLR(CLR),
      .CK(aes_if_inst.CK),
      .KEY(aes_if_inst.KEY),
      .KL(aes_if_inst.KL),
      .enc_dec(aes_if_inst.enc_dec),
      .state_i(aes_if_inst.state_i),
      .state_o(aes_if_inst.state_o),
      .CF(aes_if_inst.CF)
  );

endmodule
