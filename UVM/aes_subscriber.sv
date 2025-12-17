
/*
class aes_subscriber extends uvm_subscriber#(aes_packet);

  `uvm_component_utils(aes_subscriber)
  aes_packet item;
  uvm_analysis_imp#(aes_packet, aes_subscriber) input_aexp;
  real cov;


  covergroup aes_cov;

//    reset: coverpoint item.reset_n
//    {
//      bins low = {0};
//      bins high = {1};
//      bins hi_lw = (1=>0);
//      bins lw_hi = (0=>1);
//    }



//    valid_input: coverpoint item.valid_in
//    {
//      bins low = {0};
//      bins high = {1};
//      bins hi_lw = (1=>0);
//      bins lw_hi = (0=>1);
//    }


    input_text: coverpoint item.state_i
    {
      option.auto_bin_max = 1000;
    }

    input_key: coverpoint item.KEY
    {
      option.auto_bin_max = 1000;
    }

    output_text: coverpoint item.state_o
    {
      option.auto_bin_max = 1000;
    }


//    valid_output: coverpoint item.valid_out
//    {
//      bins low = {0};
//      bins high = {1};
//      bins hi_lw = (1=>0);
//      bins lw_hi = (0=>1);
//    }


  endgroup

  function new(string name = "aes_subscriber", uvm_component parent = null);
    super.new(name, parent);
    aes_cov = new();
  endfunction

  virtual function void write(aes_packet t);
    item = t;
    aes_cov.sample();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item = aes_packet :: type_id :: create("item");
    input_aexp = new("input_aexp", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    cov = aes_cov.get_coverage();
  endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Coverage is %f", cov), UVM_LOW)
  endfunction
endclass
*/







class aes_subscriber extends uvm_subscriber#(aes_packet);

  `uvm_component_utils(aes_subscriber)

  // Packet handle
  aes_packet item;

  // Analysis port
 //uvm_analysis_imp#(aes_packet, aes_subscriber) input_aexp;

  // Coverage metric
  real cov;

  // ----------------------------
  // Covergroup for AES packets
  // ----------------------------
/*
  covergroup aes_cov;
    // Coverpoint for enc_dec
    input_enc_dec: coverpoint item.enc_dec { option.auto_bin_max = 2; }

    // Coverpoints for KL
    input_KL: coverpoint item.KL { option.auto_bin_max = 4; }    

    // Coverpoints for input state
    input_text_0: coverpoint item.state_i[0] { option.auto_bin_max = 32; }
    input_text_1: coverpoint item.state_i[1] { option.auto_bin_max = 32; }
    input_text_2: coverpoint item.state_i[2] { option.auto_bin_max = 32; }
    input_text_3: coverpoint item.state_i[3] { option.auto_bin_max = 32; }
   
    // Coverpoints for KEY array
    input_key_0: coverpoint item.KEY[0] { option.auto_bin_max = 32; }
    input_key_1: coverpoint item.KEY[1] { option.auto_bin_max = 32; }
    input_key_2: coverpoint item.KEY[2] { option.auto_bin_max = 32; }
    input_key_3: coverpoint item.KEY[3] { option.auto_bin_max = 32; }
    input_key_4: coverpoint item.KEY[4] { option.auto_bin_max = 32; }
    input_key_5: coverpoint item.KEY[5] { option.auto_bin_max = 32; }
    input_key_6: coverpoint item.KEY[6] { option.auto_bin_max = 32; }
    input_key_7: coverpoint item.KEY[7] { option.auto_bin_max = 32; }

    // Coverpoints for output state
    output_text_0: coverpoint item.state_o[0] { option.auto_bin_max = 32; }
    output_text_1: coverpoint item.state_o[1] { option.auto_bin_max = 32; }
    output_text_2: coverpoint item.state_o[2] { option.auto_bin_max = 32; }
    output_text_3: coverpoint item.state_o[3] { option.auto_bin_max = 32; }

    // Coverpoint for CF
    output_CF:    coverpoint item.CF { option.auto_bin_max = 1; }

  endgroup
*/

covergroup aes_cov;
    option.per_instance = 1;
    
    // ===== BASIC CONTROL SIGNALS =====
    
    // Encrypt/Decrypt mode (2 bins: 0=decrypt, 1=encrypt)
    cp_enc_dec: coverpoint item.enc_dec {
        bins decrypt = {0};
        bins encrypt = {1};
    }
    
    // Key Length (4 possible values based on AES standard)
    cp_key_length: coverpoint item.KL {
        bins KL_128 = {2'b00};  // 128-bit key
        bins KL_256 = {2'b01};  // 256-bit key
        bins KL_192 = {2'b10};  // 192-bit key
        bins KL_reserved = {2'b11};  // Reserved/invalid
    }
    
    // Completion Flag
    cp_completion: coverpoint item.CF {
     //   bins not_complete = {0};
        bins complete = {1};
    }
    
    // ===== INPUT DATA PATTERNS =====
    
    // Check for all-zeros input (edge case)
    cp_input_all_zero: coverpoint (item.state_i[0] | item.state_i[1] | 
                                    item.state_i[2] | item.state_i[3]) {
        bins all_zero = {0};
        bins not_all_zero = {[1:$]};
    }
    
    // Check for all-ones input (edge case)
    cp_input_all_ones: coverpoint (item.state_i[0] & item.state_i[1] & 
                                    item.state_i[2] & item.state_i[3]) {
        bins all_ones = {32'hFFFFFFFF};
        bins not_all_ones = default;
    }
    
    // Sample individual input words for variety
    cp_state_i_0: coverpoint item.state_i[0] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_i_1: coverpoint item.state_i[1] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_i_2: coverpoint item.state_i[2] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_i_3: coverpoint item.state_i[3] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    // ===== KEY PATTERNS =====
    
    // Check for weak keys (all zeros)
    cp_key_all_zero: coverpoint (item.KEY[0] | item.KEY[1] | item.KEY[2] | 
                                  item.KEY[3] | item.KEY[4] | item.KEY[5] | 
                                  item.KEY[6] | item.KEY[7]) {
        bins all_zero = {0};
        bins not_all_zero = {[1:$]};
    }
    
    // Sample key words
    cp_key_0: coverpoint item.KEY[0] {
        bins zero = {0};
        bins non_zero = {[1:$]};
    }
    
    cp_key_1: coverpoint item.KEY[1] {
        bins zero = {0};
        bins non_zero = {[1:$]};
    }
    
    // ===== OUTPUT DATA PATTERNS =====
    
    // Check for all-zeros output (potential error)
    cp_output_all_zero: coverpoint (item.state_o[0] | item.state_o[1] | 
                                     item.state_o[2] | item.state_o[3]) {
        bins all_zero = {0};
        bins not_all_zero = {[1:$]};
    }
    
    // Sample output values
    cp_state_o_0: coverpoint item.state_o[0] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_o_1: coverpoint item.state_o[1] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_o_2: coverpoint item.state_o[2] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    cp_state_o_3: coverpoint item.state_o[3] {
        bins zero = {0};
        bins low = {[1:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFE]};
        bins max = {32'hFFFFFFFF};
    }
    
    // ===== CROSS COVERAGE =====
    
    // Cover all combinations of encrypt/decrypt with key lengths
    cross_enc_kl: cross cp_enc_dec, cp_key_length;
    
    // Cover completion flag with operation mode
    cross_cf_enc: cross cp_completion, cp_enc_dec;
    
    // Cover edge case: all zero input with different modes
    cross_zero_input: cross cp_input_all_zero, cp_enc_dec, cp_key_length {
        ignore_bins not_zero = binsof(cp_input_all_zero.not_all_zero);
    }
    
    // Cover edge case: all zero key (weak key)
    cross_zero_key: cross cp_key_all_zero, cp_enc_dec {
        ignore_bins not_zero = binsof(cp_key_all_zero.not_all_zero);
    }
    
endgroup


  // ----------------------------
  // Constructor
  // ----------------------------
  function new(string name = "aes_subscriber", uvm_component parent = null);
    super.new(name, parent);
    aes_cov = new();
  endfunction

  // ----------------------------
  // Analysis write method
  // ----------------------------
  virtual function void write(aes_packet t);
    item = t;
    aes_cov.sample();
  endfunction

  // ----------------------------
  // Build phase
  // ----------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item = aes_packet::type_id::create("item");
  //  input_aexp = new("input_aexp", this);
  endfunction

  // ----------------------------
  // Connect phase
  // ----------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
  endfunction

  // ----------------------------
  // Extract phase (coverage)
  // ----------------------------
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    cov = aes_cov.get_coverage();
  endfunction

  // ----------------------------
  // Report phase
  // ----------------------------
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name(), $sformatf("Coverage is %0f", cov), UVM_LOW)
  endfunction

endclass : aes_subscriber

