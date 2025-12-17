interface aes_interface (input logic CLK, input logic CLR);
timeunit 1ns;
timeprecision 100ps;

import uvm_pkg::*;
 `include "uvm_macros.svh"

  logic CK;                         // Secondary clock/control
  logic enc_dec;                    // 1 = encrypt, 0 = decrypt
  logic [1:0] KL;                   // Key length control

  logic [31:0] KEY [7:0];           // Key array (8 x 32-bit)
  logic [31:0] state_i [3:0];       // Input state

  logic [31:0] state_o [3:0];       // Output state from DUT
  logic CF;                         // Finish/Completion flag

// working

  bit drvstart, monstart;
    bit driver_active = 0;  // ADD THIS
    int packets_sent = 0;   // ADD THIS

/*
     bit drvstart, monstart;
    bit driver_active = 0;
    int packets_sent = 0;
  
    // Add these events
    event driver_sent_packet;    // Driver triggers when packet is sent
    event dut_completed_packet;  // Triggered when CF goes high
*/

  // Local buffer (internal storage for stimulus)
  logic [31:0] key_mem [8];
  logic [31:0] state_mem [4];

  // ----------------------------
  // Reset Task
  // ----------------------------

task cipher_reset();
    @(posedge CLR);  // This waits for reset DEASSERTION
    enc_dec   <= '0;
    KL        <= '0;
    CK        <= 1'b0;
    foreach(KEY[i])   KEY[i]   <= '0;  // Use '0 instead of 'hz
    foreach(state_i[i]) state_i[i] <= '0;
    drvstart <= 0;
    monstart <= 0;
endtask

  // ----------------------------
  // DRIVER TASK — Apply Inputs recent working
  // ----------------------------
  task send_to_dut(
        input bit enc_mode,                 // encrypt/decrypt
         bit [1:0] key_length,         // KL value
         bit [31:0] key_array [7:0],     // key
         bit [31:0] state_array [3:0]   // input state
                );
      @(posedge CLK);
          drvstart = 1;

    // Latch values into interface
            enc_dec <= enc_mode;
            KL      <= key_length;
            CK      <= 1'b1;

    // Drive KEY
            foreach (KEY[i]) begin
              KEY[i] <= key_array[i];
            end

    // Drive State
            foreach (state_i[i]) begin
              state_i[i] <= state_array[i];
            end

        @(posedge CLK);

   
            CK <= 1'b0; // pulse complete

            drvstart = 0;
  endtask : send_to_dut


  // ----------------------------
  // MONITOR TASK — Collect Output
  // ----------------------------
//working

task collect_output(
      
    output bit [31:0] out_state [3:0],
    output bit comp_flag
);
    // Wait for CF to go high
   @(posedge CLK iff (CF == 1'b1));
   //  @(negedge CLK iff (CF == 1'b1));
  // wait (CF == 1'b0);
   // repeat (20) @(posedge CLK); 
    monstart = 1;
    
    // Collect all outputs immediately (no clock waits inside loop!)
    foreach(out_state[i]) begin
        out_state[i] = state_o[i];
    end
    
    comp_flag = CF;
    monstart = 0;

    
    
    // Wait for CF to go low before returning (ready for next packet)
    @(posedge CLK iff (CF == 1'b0));
endtask

/*
task collect_output(
    output bit [31:0] out_state [3:0],
    output bit [31:0] in_state  [3:0],
    output bit [31:0] out_key   [7:0],
    output bit [31:0] in_key    [7:0],
    output bit        out_enc_dec,
    output bit [1:0]  out_KL,
    output bit        comp_flag
);
    // Wait for CF to go high (DUT done)
    @(posedge CLK iff (CF == 1'b1));
    monstart = 1;

    // Capture DUT outputs
    foreach(out_state[i]) begin
        out_state[i] = state_o[i];
    end

    // Capture DUT inputs
    foreach(in_state[i]) begin
        in_state[i] = state_i[i];
    end
    foreach(in_key[i]) begin
        in_key[i] = KEY[i];
    end

    // Capture control signals
    out_enc_dec = enc_dec;
    out_KL      = KL;

    // Completion flag
    comp_flag = CF;
    monstart = 0;

    // Wait for CF to go low (ready for next packet)
    @(posedge CLK iff (CF == 1'b0));
endtask
*/

  // ----------------------------
  // ASSERTIONS
  // ----------------------------

  // // CF should not stay asserted forever (protocol deadlock indicator)
  // property complete_flag_clears;
  //   @(posedge CLK) CF |-> ##[5:20] !CF;
  // endproperty

  // COMPLETE_CLEAR_CHECK : assert property(complete_flag_clears)
  //   else begin
  //     $display("** Cipher IF Assertion Error: CF stuck HIGH! Possible protocol error.");
  //     $finish;
  //   end

endinterface : aes_interface
