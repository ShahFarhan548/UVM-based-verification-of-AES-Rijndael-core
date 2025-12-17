// class aes_coverage extends uvm_subscriber#(aes_packet);
//   `uvm_component_utils(aes_coverage)

//   // ----------------------------------
//   // Analysis IMP declarations
//   // ----------------------------------
//   `uvm_analysis_imp_decl(_in)
//   `uvm_analysis_imp_decl(_out)

//   uvm_analysis_imp_in  #(aes_packet, aes_coverage) in_imp;
//   uvm_analysis_imp_out #(aes_packet, aes_coverage) out_imp;

//   // ----------------------------------
//   // Packet handles
//   // ----------------------------------
//   aes_packet in_pkt;
//   aes_packet out_pkt;

//   // ----------------------------------
//   // INPUT COVERGROUP
//   // ----------------------------------
//   covergroup aes_input_cg;
//     option.per_instance = 1;

//     cp_enc_dec : coverpoint in_pkt.enc_dec {
//       bins encrypt = {1'b1};
//       bins decrypt = {1'b0};
//     }

//     cp_key_len : coverpoint in_pkt.KL {
//       bins kl_128 = {2'b00};
//       bins kl_192 = {2'b01};
//       bins kl_256 = {2'b10};
//     }

//     cross_enc_kl : cross cp_enc_dec, cp_key_len;
//   endgroup

//   // ----------------------------------
//   // OUTPUT COVERGROUP
//   // ----------------------------------
//   covergroup aes_output_cg;
//     option.per_instance = 1;

//     cp_cf : coverpoint out_pkt.CF {
//       bins done = {1'b1};
//     }

//     cp_state0 : coverpoint out_pkt.state_o[0];
//   endgroup

//   // ----------------------------------
//   // Constructor
//   // ----------------------------------
//   function new(string name="aes_coverage", uvm_component parent=null);
//     super.new(name, parent);

//     in_imp  = new("in_imp",  this);
//     out_imp = new("out_imp", this);

//     aes_input_cg  = new();
//     aes_output_cg = new();
//   endfunction

//   // ----------------------------------
//   // INPUT MONITOR CALLBACK
//   // ----------------------------------
//   function void write_in(aes_packet pkt);
//     in_pkt = pkt;
//     aes_input_cg.sample();

//     `uvm_info("AES_COV_IN",
//       $sformatf("Input coverage sampled: enc_dec=%0b KL=%0b",
//                 pkt.enc_dec, pkt.KL),
//       UVM_LOW)
//   endfunction

//   // ----------------------------------
//   // OUTPUT MONITOR CALLBACK
//   // ----------------------------------
//   function void write_out(aes_packet pkt);
//     out_pkt = pkt;
//     aes_output_cg.sample();

//     `uvm_info("AES_COV_OUT",
//       $sformatf("Output coverage sampled: CF=%0b", pkt.CF),
//       UVM_LOW)
//   endfunction

// endclass

class aes_coverage extends uvm_subscriber#(aes_packet);
  `uvm_component_utils(aes_coverage)

  // --------------------------------------------------
  // Analysis imports (two independent streams)
  // --------------------------------------------------
  `uvm_analysis_imp_decl(_in)
  `uvm_analysis_imp_decl(_out)

  uvm_analysis_imp_in  #(aes_packet, aes_coverage) in_imp;
  uvm_analysis_imp_out #(aes_packet, aes_coverage) out_imp;

  // --------------------------------------------------
  // Packet handles (sampling references)
  // --------------------------------------------------
  aes_packet in_pkt;
  aes_packet out_pkt;

  // --------------------------------------------------
  // INPUT COVERGROUP
  // --------------------------------------------------
  covergroup aes_input_cg;
    option.per_instance = 1;

    // Encrypt / Decrypt
    cp_enc_dec : coverpoint in_pkt.enc_dec {
      bins encrypt = {1'b1};
      bins decrypt = {1'b0};
    }

    // Key length
    cp_key_len : coverpoint in_pkt.KL {
      bins kl_128 = {2'b00};
      bins kl_192 = {2'b01};
      bins kl_256 = {2'b10};
    }

    // Cross
    cross_enc_kl : cross cp_enc_dec, cp_key_len;
  endgroup

  // --------------------------------------------------
  // OUTPUT COVERGROUP
  // --------------------------------------------------
  covergroup aes_output_cg;
    option.per_instance = 1;

    // Completion flag
    cp_cf : coverpoint out_pkt.CF {
      bins done = {1'b1};
    }

    // Sample one state word (enough for sanity)
    cp_state0 : coverpoint out_pkt.state_o[0] {
      option.auto_bin_max = 32;
    }
  endgroup

  // --------------------------------------------------
  // Constructor
  // --------------------------------------------------
  function new(string name="aes_coverage", uvm_component parent=null);
    super.new(name, parent);

    in_imp  = new("in_imp",  this);
    out_imp = new("out_imp", this);

    aes_input_cg  = new();
    aes_output_cg = new();
  endfunction

  // --------------------------------------------------
  // INPUT MONITOR CALLBACK
  // --------------------------------------------------
  virtual function void write_in(aes_packet pkt);
    in_pkt = pkt;
    aes_input_cg.sample();

    `uvm_info("AES_COV_IN",
      $sformatf("Input coverage sampled: enc_dec=%0b KL=%0d",
                pkt.enc_dec, pkt.KL),
      UVM_LOW)
  endfunction

  // --------------------------------------------------
  // OUTPUT MONITOR CALLBACK
  // --------------------------------------------------
  virtual function void write_out(aes_packet pkt);

    // Only sample when DUT signals completion
    if (pkt.CF) begin
      out_pkt = pkt;
      aes_output_cg.sample();

      `uvm_info("AES_COV_OUT",
        "Output coverage sampled (CF=1)",
        UVM_LOW)
    end
  endfunction

  // --------------------------------------------------
  // REPORT
  // --------------------------------------------------
  function void report_phase(uvm_phase phase);
    real in_cov, out_cov;

    in_cov  = aes_input_cg.get_coverage();
    out_cov = aes_output_cg.get_coverage();

    // `uvm_info(get_type_name(),
    //   $sformatf(
    //     "\n====== AES COVERAGE REPORT ======\n" \
    //     "Input  Coverage : %0.2f %%\n"       \
    //     "Output Coverage : %0.2f %%\n",
    //     in_cov, out_cov),
    //   UVM_NONE)
  endfunction

endclass
