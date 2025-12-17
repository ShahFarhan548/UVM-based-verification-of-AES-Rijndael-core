class aes_seqs extends uvm_sequence#(aes_packet);
  `uvm_object_utils(aes_seqs)

  function new(string name="aes_seqs");
    super.new(name);
  endfunction

  task pre_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif

    if (phase != null) begin
      // call get_type_name() with parentheses
      phase.raise_objection(this, get_type_name());
      `uvm_info(get_type_name(), "Raise objection", UVM_MEDIUM);
    end
  endtask : pre_body


  task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif

    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "Drop objection", UVM_MEDIUM);
    end
  endtask : post_body

endclass : aes_seqs


class rand_packet extends aes_seqs;
  `uvm_object_utils(rand_packet)

  function new(string name="rand_packet");
    super.new(name);
  endfunction

 task body();
    aes_packet req;
    `uvm_info(get_type_name(), "Executing rand_packet sequence", UVM_LOW)
    
    repeat (10) begin  // ← Changed from 1 to 10
      `uvm_do_with(req, {KL != 0;})
      //`uvm_do(req)
    end
  
    // #1700; 
endtask

endclass : rand_packet


class packet_encryption extends aes_seqs;

  `uvm_object_utils(packet_encryption)

  function new(string name="packet_encryption");
    super.new(name);
  endfunction


  task body();
    aes_packet req;

    // Create a new AES packet
  //  req = aes_packet::type_id::create("req");

    `uvm_info(get_type_name(), "Executing packet_encryption sequence", UVM_LOW)

    // repeat (3) begin
//    `uvm_do_with(req, { enc_dec == 1; })

// working encry and decrypt

  //   `uvm_do_with(req, {
  //   state_i[0] == 32'h122f90b6;
  //   state_i[1] == 32'h7660bfc7;
  //   state_i[2] == 32'hbb3e1111;
  //   state_i[3] == 32'hd82df7f2;
    
  //   foreach(KEY[i]) KEY[i] == 5;

  //   enc_dec == 0;

  //   KL == 2; 
  //   })


  //    `uvm_do_with(req, {
  //   state_i[0] == 32'h3d90d0df;
  //   state_i[1] == 32'hcfd0f631;
  //   state_i[2] == 32'h2115e12e;
  //   state_i[3] == 32'ha28709dc;
    
  //   foreach(KEY[i]) KEY[i] == 5;

  //   enc_dec == 0;

  //   KL == 2;    })


  //    `uvm_do_with(req, {
  //   state_i[0] == 32'h651c2495;
  //   state_i[1] == 32'h5e72eeda;
  //   state_i[2] == 32'h9a132569;
  //   state_i[3] == 32'hf270d032;
    
  //   foreach(KEY[i]) KEY[i] == 5;

  //   enc_dec == 0;

  //   KL == 2;    })

    

  // endtask

// decryption 
//  outputs 
/*
ab825f23 d1ff6cf9 920eaeed c1d9d07b
651c2406 4072eeda 9a132569 f270d032
   

*/

// testing with golden model 


    `uvm_do_with(req, {
    state_i[0] == 32'h6bc1bee2;
    state_i[1] == 32'h2e409f96;
    state_i[2] == 32'he93d7e11;
    state_i[3] == 32'h7393172a;
    
    KEY[0] == 32'h603deb10;
    KEY[1] == 32'h15ca71be;
    KEY[2] == 32'h2b73aef0;
    KEY[3] == 32'h857d7781;
    KEY[4] == 32'h1f352c07;
    KEY[5] == 32'h3b6108d7;
    KEY[6] == 32'h2d9810a3;
    KEY[7] == 32'h0914dff4;

    enc_dec == 0;

    KL == 2; 
    })


     `uvm_do_with(req, {
    state_i[0] == 32'h3d90d0df;
    state_i[1] == 32'hcfd0f631;
    state_i[2] == 32'h2115e12e;
    state_i[3] == 32'ha28709dc;
    
    foreach(KEY[i]) KEY[i] == 5;

    enc_dec == 0;

    KL == 2;    })

endtask



endclass



class packet_decryption extends aes_seqs;

  `uvm_object_utils(packet_decryption)

  function new(string name="packet_decryption");
    super.new(name);
  endfunction

  task body();
     aes_packet req;
    `uvm_info(get_type_name(), "Executing packet_decryption sequence", UVM_LOW)

    repeat (2) begin
    //`uvm_do_with(req, { enc_dec == 0; KL != 0; })
      
    `uvm_do_with(req, {
    state_i[0] == 32'ha8b92c3c;
    state_i[1] == 32'he230e353;
    state_i[2] == 32'h36814fe6;
    state_i[3] == 32'hf1c6b71d;

    foreach(KEY[i]) KEY[i] == 5;

    enc_dec == 0;

    KL == 2;
    })

    end

  endtask



endclass


class zero_key extends aes_seqs;
  `uvm_object_utils(zero_key)

  function new(string name="zero_key");
    super.new(name);
  endfunction

  task body();
    aes_packet req;

    // Create packet object
    req = aes_packet::type_id::create("req");

    `uvm_info(get_type_name(), "Executing zero_key sequence", UVM_LOW)

    // Repeat 50 times
    repeat (50) begin
      `uvm_do_with(req, { foreach (KEY[i]) KEY[i] == 0; })
    end
  endtask
endclass



class zero_input extends aes_seqs;
  `uvm_object_utils(zero_input)

  function new(string name="zero_input");
    super.new(name);
  endfunction

  task body();
    aes_packet req;

    // Create packet object
    req = aes_packet::type_id::create("req");

    `uvm_info(get_type_name(), "Executing zero_input sequence", UVM_LOW)

    // Repeat 50 times
    repeat (30) begin
      `uvm_do_with(req, { foreach (state_i[i]) state_i[i] == 0; enc_dec == 1; })
    end
  endtask
endclass


/*
class reset_packet extends aes_seqs;

  `uvm_object_utils(reset_packet)

  function new(string name="reset_packet");
    super.new(name);
  endfunction

  task body()
     aes_packet req;
     req = aes_packet::type_id::create("req");

    `uvm_info(get_type_name(), "Executing reset sequence", UVM_LOW)

     repeat (20) begin
      `uvm_do_with(req, { CLR == 1; enc_dec == 1; })
    end

  endtask

endclass
*/