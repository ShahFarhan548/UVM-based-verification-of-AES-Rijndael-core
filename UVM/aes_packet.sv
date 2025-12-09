
class aes_packet extends uvm_sequence_item;

   bit enc_dec;                
  rand bit [1:0] KL;  
  rand bit [31:0] KEY[7:0];        // 256-bit key
  rand bit [31:0] state_i[3:0];   // 128-bit plaintext/ciphertext

       bit CF;
       bit [31:0] state_o[3:0];

  `uvm_object_utils_begin(aes_packet)
   `uvm_field_sarray_int(state_i, UVM_ALL_ON)
    `uvm_field_sarray_int(state_o, UVM_ALL_ON)
    `uvm_field_sarray_int(KEY,     UVM_ALL_ON)
    `uvm_field_int(enc_dec, UVM_ALL_ON)
    `uvm_field_int(KL, UVM_ALL_ON)
    `uvm_field_int(CF, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name="aes_packet");
    super.new(name);
  endfunction

  constraint key_constraint {
    foreach (KEY[i]) KEY[i] != 32'h0;
  }

endclass


  
