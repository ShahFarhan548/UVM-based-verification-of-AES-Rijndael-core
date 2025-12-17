// class aes_fifo_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(aes_fifo_scoreboard)

//   // ------------------------------------------------------------
//   // Analysis imports (from monitors)
//   // ------------------------------------------------------------
//   `uvm_analysis_imp_decl(_in)
//   `uvm_analysis_imp_decl(_out)

//   uvm_analysis_imp_in  #(aes_packet, aes_fifo_scoreboard) in_imp;
//   uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard) out_imp;

//   // ------------------------------------------------------------
//   // FIFOs (Queues)
//   // ------------------------------------------------------------
//   aes_packet exp_fifo[$];   // Expected packets (from input monitor)
//   aes_packet dut_fifo[$];   // DUT output packets (from output monitor)

//   // ------------------------------------------------------------
//   // Control knobs
//   // ------------------------------------------------------------
//   bit compare_enable = 1;
//   int max_fifo_depth = 100;

//   // ------------------------------------------------------------
//   // Counters
//   // ------------------------------------------------------------
//   int num_exp_rcvd;
//   int num_dut_rcvd;
//   int num_compared;
//   int num_pass;
//   int num_fail;

//   // ------------------------------------------------------------
//   // Constructor
//   // ------------------------------------------------------------
//   function new(string name="aes_fifo_scoreboard",
//                uvm_component parent=null);
//     super.new(name, parent);
//     in_imp  = new("in_imp",  this);
//     out_imp = new("out_imp", this);
//   endfunction

//   // ------------------------------------------------------------
//   // INPUT MONITOR CALLBACK
//   // ------------------------------------------------------------
//   // Called when aes_input_monitor broadcasts a packet
//   function void write_in(aes_packet pkt);
//     aes_packet exp_pkt;

//     exp_pkt = aes_packet::type_id::create("exp_pkt");

//     // Copy inputs only
//     exp_pkt.enc_dec = pkt.enc_dec;
//     exp_pkt.KL      = pkt.KL;

//     foreach (exp_pkt.KEY[i])
//       exp_pkt.KEY[i] = pkt.KEY[i];

//     foreach (exp_pkt.state_i[i])
//       exp_pkt.state_i[i] = pkt.state_i[i];

//     // Call reference model (INTENTIONALLY EMPTY)
//     aes_reference_model(exp_pkt);

//     // Push into expected FIFO
//     exp_fifo.push_back(exp_pkt);
//     num_exp_rcvd++;

//     if (exp_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(),
//         "Expected FIFO exceeded depth limit")

//     `uvm_info(get_type_name(),
//       $sformatf("SB: Expected packet stored (exp_fifo=%0d)",
//                 exp_fifo.size()),
//       UVM_MEDIUM)
//   endfunction

//   // ------------------------------------------------------------
//   // OUTPUT MONITOR CALLBACK
//   // ------------------------------------------------------------
//   // Called when aes_monitor2 broadcasts a packet
//   function void write_out(aes_packet pkt);
//     aes_packet dut_pkt;

//     dut_pkt = aes_packet::type_id::create("dut_pkt");

//     // Copy DUT outputs only
//     foreach (dut_pkt.state_o[i])
//       dut_pkt.state_o[i] = pkt.state_o[i];

//     dut_pkt.CF = pkt.CF;

//     dut_fifo.push_back(dut_pkt);
//     num_dut_rcvd++;

//     if (dut_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(),
//         "DUT FIFO exceeded depth limit")

//     `uvm_info(get_type_name(),
//       $sformatf("SB: DUT packet stored (dut_fifo=%0d)",
//                 dut_fifo.size()),
//       UVM_MEDIUM)
//   endfunction

//   // ------------------------------------------------------------
//   // RUN PHASE — FIFO MATCH & COMPARE
//   // ------------------------------------------------------------
//   task run_phase(uvm_phase phase);
//     aes_packet exp_pkt;
//     aes_packet dut_pkt;

//     forever begin
//       // Wait until both FIFOs have data
//       wait (compare_enable &&
//             exp_fifo.size() > 0 &&
//             dut_fifo.size() > 0);

//       exp_pkt = exp_fifo.pop_front();
//       dut_pkt = dut_fifo.pop_front();
//       num_compared++;

//       if (compare_state(dut_pkt, exp_pkt)) begin
//         num_pass++;
//         `uvm_info(get_type_name(),
//           "AES COMPARE PASS",
//           UVM_LOW)
//       end
//       else begin
//         num_fail++;
//         `uvm_error(get_type_name(),
//           $sformatf(
//             "AES COMPARE FAIL\nDUT=%s\nEXP=%s",
//             dut_pkt.sprint(),
//             exp_pkt.sprint()))
//       end
//     end
//   endtask

//   // ------------------------------------------------------------
//   // STATE COMPARISON
//   // ------------------------------------------------------------
//   function bit compare_state(aes_packet dut,
//                              aes_packet exp);
//     foreach (dut.state_o[i]) begin
//       if (dut.state_o[i] !== exp.state_o[i])
//         return 0;
//     end
//     return 1;
//   endfunction

//   // ------------------------------------------------------------
//   // REFERENCE MODEL STUB (EMPTY BY DESIGN)
//   // ------------------------------------------------------------
//   function void aes_reference_model(ref aes_packet pkt);
//     // DO NOT IMPLEMENT NOW
//     // Placeholder for:
//     // - SystemVerilog model
//     // - DPI-C
//     // - Python golden model
//   endfunction

//   // ------------------------------------------------------------
//   // CHECK PHASE — NO LEFTOVER DATA
//   // ------------------------------------------------------------
//   function void check_phase(uvm_phase phase);
//     super.check_phase(phase);

//     if (exp_fifo.size() != 0 || dut_fifo.size() != 0) begin
//       `uvm_error(get_type_name(),
//         $sformatf(
//           "SB CHECK FAIL: exp_fifo=%0d dut_fifo=%0d",
//           exp_fifo.size(), dut_fifo.size()))
//     end
//     else begin
//       `uvm_info(get_type_name(),
//         "SB CHECK PASS: All FIFOs empty",
//         UVM_MEDIUM)
//     end
//   endfunction

//   // ------------------------------------------------------------
//   // REPORT
//   // ------------------------------------------------------------
//   function void report_phase(uvm_phase phase);
//     `uvm_info(get_type_name(),
//       $sformatf(
//         "\n====== AES SCOREBOARD REPORT ======\n" \
//         "Expected Received : %0d\n"            \
//         "DUT Received      : %0d\n"            \
//         "Compared          : %0d\n"            \
//         "PASS              : %0d\n"            \
//         "FAIL              : %0d\n",
//         num_exp_rcvd,
//         num_dut_rcvd,
//         num_compared,
//         num_pass,
//         num_fail),
//       UVM_NONE)

//     if (num_fail > 0)
//       `uvm_error("AES_SB", "TEST FAILED")
//     else
//       `uvm_info("AES_SB", "TEST PASSED", UVM_LOW)
//   endfunction

// endclass



// class aes_fifo_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(aes_fifo_scoreboard)

//   // ------------------------
//   // Analysis imports (from monitors)
//   // ------------------------
//   `uvm_analysis_imp_decl(_in)
//   `uvm_analysis_imp_decl(_out)

//   uvm_analysis_imp_in  #(aes_packet, aes_fifo_scoreboard) in_imp;
//   uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard) out_imp;

//   // ------------------------
//   // FIFOs
//   // ------------------------
//   aes_packet exp_fifo[$];
//   aes_packet dut_fifo[$];

//   // ------------------------
//   // Control
//   // ------------------------
//   bit compare_enable = 1;
//   int max_fifo_depth = 100;

//   // ------------------------
//   // Counters
//   // ------------------------
//   int num_exp_rcvd = 0;
//   int num_dut_rcvd = 0;
//   int num_compared = 0;
//   int num_pass = 0;
//   int num_fail = 0;

//   // ------------------------
//   // Constructor
//   // ------------------------
//   function new(string name="aes_fifo_scoreboard", uvm_component parent=null);
//     super.new(name, parent);
//     in_imp  = new("in_imp", this);
//     out_imp = new("out_imp", this);
//   endfunction

//   // ------------------------
//   // Input monitor callback
//   // ------------------------
//   function void write_in(aes_packet pkt);
//     aes_packet exp_pkt = aes_packet::type_id::create("exp_pkt");

//     // Copy input values
//     exp_pkt.enc_dec = pkt.enc_dec;
//     exp_pkt.KL      = pkt.KL;
//     foreach(exp_pkt.KEY[i])     exp_pkt.KEY[i]     = pkt.KEY[i];
//     foreach(exp_pkt.state_i[i]) exp_pkt.state_i[i] = pkt.state_i[i];

//     // Reference model stub
//     aes_reference_model(exp_pkt);

//     // Store in expected FIFO
//     exp_fifo.push_back(exp_pkt);
//     num_exp_rcvd++;

//     if (exp_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(), "Expected FIFO exceeded depth limit");

//     `uvm_info(get_type_name(),
//       $sformatf("SB: Expected packet stored (exp_fifo=%0d)", exp_fifo.size()),
//       UVM_MEDIUM);
//   endfunction

//   // ------------------------
//   // Output monitor callback
//   // ------------------------
//   function void write_out(aes_packet pkt);
//     aes_packet dut_pkt = aes_packet::type_id::create("dut_pkt");

//     foreach(dut_pkt.state_o[i])
//       dut_pkt.state_o[i] = pkt.state_o[i];
//     dut_pkt.CF = pkt.CF;

//     // Store in DUT FIFO
//     dut_fifo.push_back(dut_pkt);
//     num_dut_rcvd++;

//     if (dut_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(), "DUT FIFO exceeded depth limit");

//     `uvm_info(get_type_name(),
//       $sformatf("SB: DUT packet stored (dut_fifo=%0d)", dut_fifo.size()),
//       UVM_MEDIUM);
//   endfunction

//   // ------------------------
//   // Run phase – FIFO compare
//   // ------------------------
//   task run_phase(uvm_phase phase);
//     aes_packet exp_pkt;
//     aes_packet dut_pkt;

//     forever begin
//       // Wait until both FIFOs have data
//       wait (compare_enable && exp_fifo.size() > 0 && dut_fifo.size() > 0);

//       exp_pkt = exp_fifo.pop_front();
//       dut_pkt = dut_fifo.pop_front();
//       num_compared++;

//       if (compare_state(dut_pkt, exp_pkt)) begin
//         num_pass++;
//         `uvm_info(get_type_name(), "AES COMPARE PASS", UVM_LOW);
//       end
//       else begin
//         num_fail++;
//         `uvm_error(get_type_name(),
//           $sformatf("AES COMPARE FAIL\nDUT=%s\nEXP=%s", dut_pkt.sprint(), exp_pkt.sprint()));
//       end
//     end
//   endtask

//   // ------------------------
//   // Compare state
//   // ------------------------
//   function bit compare_state(aes_packet dut, aes_packet exp);
//     foreach(dut.state_o[i])
//       if (dut.state_o[i] !== exp.state_o[i])
//         return 0;
//     return 1;
//   endfunction

//   // ------------------------
//   // Reference model stub
//   // ------------------------
//   function void aes_reference_model(ref aes_packet pkt);
//     // empty
//   endfunction

//   // ------------------------
//   // Check phase
//   // ------------------------
//   function void check_phase(uvm_phase phase);
//     super.check_phase(phase);
//     if (exp_fifo.size() != 0 || dut_fifo.size() != 0) begin
//       `uvm_error(get_type_name(),
//         $sformatf("SB CHECK FAIL: exp_fifo=%0d dut_fifo=%0d", exp_fifo.size(), dut_fifo.size()));
//     end
//     else begin
//       `uvm_info(get_type_name(), "SB CHECK PASS: All FIFOs empty", UVM_MEDIUM);
//     end
//   endfunction

//   // ------------------------
//   // Report phase
//   // ------------------------
//   function void report_phase(uvm_phase phase);
//   // Proper string ID
//   `uvm_info("AES_SB",
//     $sformatf(
//       {
//         "\n====== AES SCOREBOARD REPORT ======\n",
//         "Expected Received : %0d\n",
//         "DUT Received      : %0d\n",
//         "Compared          : %0d\n",
//         "PASS              : %0d\n",
//         "FAIL              : %0d\n"
//       },
//       num_exp_rcvd,
//       num_dut_rcvd,
//       num_compared,
//       num_pass,
//       num_fail),
//     UVM_NONE);
//   if (num_fail > 0) begin 
//     `uvm_error("AES_SB", "TEST FAILED");
//   end else begin 
//     `uvm_info("AES_SB", "TEST PASSED", UVM_LOW);
//   end
// endfunction


// endclass



// working for both fifo

// class aes_fifo_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(aes_fifo_scoreboard)

//   // ------------------------
//   // Analysis ports (from monitors)
//   // ------------------------
//   `uvm_analysis_imp_decl(_in)
//   `uvm_analysis_imp_decl(_out)

//   uvm_analysis_imp_in  #(aes_packet, aes_fifo_scoreboard)  in_imp;
//   uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard)  out_imp;

//   // ------------------------
//   // FIFOs
//   // ------------------------
//   aes_packet exp_fifo[$];  // Original plaintext
//   aes_packet dut_fifo[$];  // Decrypted output

//   // ------------------------
//   // Control
//   // ------------------------
//   bit compare_enable = 1;
//   int max_fifo_depth = 100;
//   bit discard_first_output = 1; 

//   // ------------------------
//   // Counters
//   // ------------------------
//   int num_exp_rcvd  = 0;
//   int num_dut_rcvd  = 0;
//   int num_compared  = 0;
//   int num_pass      = 0;
//   int num_fail      = 0;

//   // ------------------------
//   // Constructor
//   // ------------------------
//   function new(string name="aes_fifo_scoreboard", uvm_component parent=null);
//     super.new(name, parent);
//     in_imp  = new("in_imp", this);
//     out_imp = new("out_imp", this);
//   endfunction

//   // ------------------------
//   // Input monitor callback
//   // Store original plaintext
//   // ------------------------
//   // function void write_in(aes_packet pkt);
//   //   aes_packet exp_pkt = aes_packet::type_id::create("exp_pkt");

//   //   foreach(exp_pkt.state_i[i])
//   //     exp_pkt.state_i[i] = pkt.state_i[i];

//   //   exp_fifo.push_back(exp_pkt);
//   //   num_exp_rcvd++;

//   //   if (exp_fifo.size() > max_fifo_depth)
//   //     `uvm_warning(get_type_name(), "Expected FIFO exceeded depth limit");

//   //   `uvm_info(get_type_name(),
//   //     $sformatf("SB: Plaintext packet stored (exp_fifo=%0d)", exp_fifo.size()),
//   //     UVM_MEDIUM);
//   // endfunction


//     function void write_in(aes_packet pkt);
//     aes_packet exp_pkt = aes_packet::type_id::create("exp_pkt");
//   // If we know the total number of packets, we can skip the last one
//   // For demonstration, let's assume `total_packets` is known/configured
//   static int packet_count = 0;
//   int total_packets = 3; // <-- Set this to the total number of input packets expected

//   packet_count++;

//   if (packet_count == total_packets) begin
//     `uvm_info(get_type_name(), "SB: Last input packet skipped", UVM_LOW)
//     return; // Skip storing the last packet
//   end

  

//   foreach(exp_pkt.state_i[i])
//     exp_pkt.state_i[i] = pkt.state_i[i];

//   exp_fifo.push_back(exp_pkt);
//   num_exp_rcvd++;

//   if (exp_fifo.size() > max_fifo_depth)
//     `uvm_warning(get_type_name(), "Expected FIFO exceeded depth limit");

//   `uvm_info(get_type_name(),
//     $sformatf("SB: Plaintext packet stored (exp_fifo=%0d)", exp_fifo.size()),
//     UVM_MEDIUM);
// endfunction

//   // ------------------------
//   // Output monitor callback
//   // Store decrypted output
//   // ------------------------
//   function void write_out(aes_packet pkt);

//      aes_packet dut_pkt = aes_packet::type_id::create("dut_pkt");

//      if (discard_first_output) begin
//       `uvm_info(get_type_name(), "SB: First output packet discarded", UVM_LOW)
//       discard_first_output = 0; // Only discard the first packet
//       return;
//     end

   

//     foreach(dut_pkt.state_i[i])
//       dut_pkt.state_i[i] = pkt.state_i[i];

//     dut_fifo.push_back(dut_pkt);
//     num_dut_rcvd++;

//     if (dut_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(), "DUT FIFO exceeded depth limit");

//     `uvm_info(get_type_name(),
//       $sformatf("SB: Decrypted packet stored (dut_fifo=%0d)", dut_fifo.size()),
//       UVM_MEDIUM);
//   endfunction

//   // ------------------------
//   // Run phase – Compare original plaintext vs decrypted output
//   // ------------------------
//   task run_phase(uvm_phase phase);
//     aes_packet exp_pkt;
//     aes_packet dut_pkt;

//     forever begin
//       // Wait until both FIFOs have data
//       wait (compare_enable && exp_fifo.size() > 0 && dut_fifo.size() > 0);

//       exp_pkt = exp_fifo.pop_front();
//       dut_pkt = dut_fifo.pop_front();
//       num_compared++;

//       if (compare_state(dut_pkt, exp_pkt)) begin
//         num_pass++;
//         `uvm_info(get_type_name(), "ROUND-TRIP AES PASS", UVM_LOW);
//       end else begin
//         num_fail++;
//         `uvm_error(get_type_name(),
//           $sformatf("ROUND-TRIP AES FAIL\nORIG=%s\nDECRY=%s", exp_pkt.sprint(), dut_pkt.sprint()));
//       end
//     end
//   endtask

//   // ------------------------
//   // Compare state
//   // ------------------------
//   function bit compare_state(aes_packet dut, aes_packet exp);
//     foreach(dut.state_i[i])
//       if (dut.state_i[i] !== exp.state_i[i])
//         return 0;
//     return 1;
//   endfunction

//   // ------------------------
//   // Check phase
//   // ------------------------
//   function void check_phase(uvm_phase phase);
//     super.check_phase(phase);

//     if (exp_fifo.size() != 0 || dut_fifo.size() != 0) begin
//       `uvm_error(get_type_name(),
//         $sformatf("SB CHECK FAIL: exp_fifo=%0d dut_fifo=%0d", exp_fifo.size(), dut_fifo.size()));
//     end else begin
//       `uvm_info(get_type_name(), "SB CHECK PASS: All FIFOs empty", UVM_MEDIUM);
//     end
//   endfunction

//   // ------------------------
//   // Report phase
//   // ------------------------
//     function void report_phase(uvm_phase phase);
// //   // Proper string ID
//   `uvm_info("AES_SB",
//     $sformatf(
//       {
//         "\n====== AES SCOREBOARD REPORT ======\n",
//         "Expected Received : %0d\n",
//         "DUT Received      : %0d\n",
//         "Compared          : %0d\n",
//         "PASS              : %0d\n",
//         "FAIL              : %0d\n"
//       },
//       num_exp_rcvd,
//       num_dut_rcvd,
//       num_compared,
//       num_pass,
//       num_fail),
//     UVM_NONE);
//   if (num_fail > 0) begin 
//     `uvm_error("AES_SB", "TEST FAILED");
//   end else begin 
//     `uvm_info("AES_SB", "TEST PASSED", UVM_LOW);
//   end
// endfunction

// endclass




// class aes_fifo_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(aes_fifo_scoreboard)

//   // ------------------------
//   // Analysis port for DUT output
//   // ------------------------
//   `uvm_analysis_imp_decl(_out)
//   uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard) out_imp;

//   // ------------------------
//   // FIFOs
//   // ------------------------
//   aes_packet dut_fifo[$];       // DUT output FIFO
//   aes_packet golden_model[$];   // Packets from TXT file

//   // ------------------------
//   // Control
//   // ------------------------
//   bit compare_enable = 1;
//   int max_fifo_depth = 100;
//   bit discard_first_output = 1; 

//   // ------------------------
//   // Counters
//   // ------------------------
//   int num_dut_rcvd  = 0;
//   int num_compared  = 0;
//   int num_pass      = 0;
//   int num_fail      = 0;

//   // ------------------------
//   // Constructor
//   // ------------------------
//   function new(string name="aes_fifo_scoreboard", uvm_component parent=null);
//     super.new(name, parent);
//     out_imp = new("out_imp", this);
//   endfunction

//   // ------------------------
//   // Build phase – Load golden model from TXT
//   // ------------------------
//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
//      aes_packet pkt = aes_packet::type_id::create($sformatf("golden_pkt_%0d", golden_model.size()));
//     string filename = "aes_golden.txt"; // Your TXT file
//     int fd;
//     string line;

//     fd = $fopen(filename, "r");
//     if (fd == 0) begin
//       `uvm_error(get_type_name(), $sformatf("Cannot open golden file: %s", filename))
//       return;
//     end

//     while (!$feof(fd)) begin
//       line = "";
//       void'($fgets(line, fd));
//       line = line.tolower().trim(); // remove spaces/tabs/newlines

//       if (line.len() == 0) continue; // Skip empty lines

     

//       string word;
//       int unsigned val;
//       int idx = 0;

//       // Split line by spaces, parse 4 hex words
//       string temp_line = line;
//       while (temp_line.len() > 0 && idx < 4) begin
//         int space_pos = temp_line.find(" ");
//         if (space_pos >= 0) begin
//           word = temp_line.substr(0, space_pos-1);
//           temp_line = temp_line.substr(space_pos+1, temp_line.len()-1);
//         end else begin
//           word = temp_line;
//           temp_line = "";
//         end

//         if ($sscanf(word, "%h", val) == 1)
//           pkt.state_i[idx] = val;
//         else
//           pkt.state_i[idx] = 32'h0;

//         idx++;
//       end

//       golden_model.push_back(pkt);
//     end

//     $fclose(fd);

//     `uvm_info(get_type_name(), $sformatf("Golden model loaded: %0d packets", golden_model.size()), UVM_LOW);
//   endfunction

//   // ------------------------
//   // Output monitor callback
//   // ------------------------
//   function void write_out(aes_packet pkt);
//   aes_packet dut_pkt = aes_packet::type_id::create("dut_pkt");
//     if (discard_first_output) begin
//       `uvm_info(get_type_name(), "SB: First output packet discarded", UVM_LOW)
//       discard_first_output = 0;
//       return;
//     end

    

//     foreach(dut_pkt.state_i[i])
//       dut_pkt.state_i[i] = pkt.state_i[i];

//     dut_fifo.push_back(dut_pkt);
//     num_dut_rcvd++;

//     if (dut_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(), "DUT FIFO exceeded depth limit");

//     `uvm_info(get_type_name(),
//       $sformatf("SB: Decrypted packet stored (dut_fifo=%0d)", dut_fifo.size()),
//       UVM_MEDIUM);
//   endfunction

//   // ------------------------
//   // Run phase – Compare DUT output with golden model
//   // ------------------------
//   task run_phase(uvm_phase phase);
//     aes_packet dut_pkt;
//     int golden_index = 0;

//     forever begin
//       wait (compare_enable && dut_fifo.size() > 0);

//       dut_pkt = dut_fifo.pop_front();
//       num_compared++;

//       if (golden_index >= golden_model.size()) begin
//         `uvm_warning(get_type_name(), "No more golden packets, skipping comparison")
//         continue;
//       end

//       aes_packet golden_pkt = golden_model[golden_index];
//       golden_index++;

//       if (compare_state(dut_pkt, golden_pkt)) begin
//         num_pass++;
//         `uvm_info(get_type_name(), $sformatf("AES COMPARE PASS for packet %0d", num_compared), UVM_LOW);
//       end else begin
//         num_fail++;
//         `uvm_error(get_type_name(),
//           $sformatf("AES COMPARE FAIL for packet %0d\nDUT=%s\nGOLDEN=%s", 
//                      num_compared, dut_pkt.sprint(), golden_pkt.sprint()));
//       end
//     end
//   endtask

//   // ------------------------
//   // Compare 32x4 state
//   // ------------------------
//   function bit compare_state(aes_packet dut, aes_packet golden);
//     foreach(dut.state_i[i])
//       if (dut.state_i[i] !== golden.state_i[i])
//         return 0;
//     return 1;
//   endfunction

//   // ------------------------
//   // Check phase
//   // ------------------------
//   function void check_phase(uvm_phase phase);
//     super.check_phase(phase);

//     if (dut_fifo.size() != 0) begin
//       `uvm_error(get_type_name(),
//         $sformatf("SB CHECK FAIL: dut_fifo=%0d", dut_fifo.size()));
//     end else begin
//       `uvm_info(get_type_name(), "SB CHECK PASS: DUT FIFO empty", UVM_MEDIUM);
//     end
//   endfunction

//   // ------------------------
//   // Report phase
//   // ------------------------
//   // function void report_phase(uvm_phase phase);
//   //   `uvm_info("AES_SB",
//   //     $sformatf(
//   //       "\n====== AES SCOREBOARD REPORT ======\n"
//   //       "DUT Received  : %0d\n"
//   //       "Compared      : %0d\n"
//   //       "PASS          : %0d\n"
//   //       "FAIL          : %0d\n",
//   //       num_dut_rcvd,
//   //       num_compared,
//   //       num_pass,
//   //       num_fail
//   //     ),
//   //     UVM_NONE  );

//   //   if (num_fail > 0)
//   //     `uvm_error("AES_SB", "TEST FAILED");
//   //   else
//   //     `uvm_info("AES_SB", "TEST PASSED", UVM_LOW);
//   // endfunction

// endclass





// class aes_fifo_scoreboard extends uvm_scoreboard;
//   `uvm_component_utils(aes_fifo_scoreboard)

//   // ------------------------
//   // Analysis port for DUT output
//   // ------------------------
//   `uvm_analysis_imp_decl(_out)
//   uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard) out_imp;

//   // ------------------------
//   // FIFOs
//   // ------------------------
//   aes_packet dut_fifo[$];       // DUT output FIFO
//   aes_packet golden_model[$];   // Packets from TXT file

//   // ------------------------
//   // Control
//   // ------------------------
//   bit compare_enable = 1;
//   int max_fifo_depth = 100;
//   bit discard_first_output = 1; 

//   // ------------------------
//   // Counters
//   // ------------------------
//   int num_dut_rcvd  = 0;
//   int num_compared  = 0;
//   int num_pass      = 0;
//   int num_fail      = 0;

//   // ------------------------
//   // Constructor
//   // ------------------------
//   function new(string name="aes_fifo_scoreboard", uvm_component parent=null);
//     super.new(name, parent);
//     out_imp = new("out_imp", this);
//   endfunction

//   // ------------------------
//   // Build phase – Load golden model from TXT
//   // ------------------------
//   virtual function void build_phase(uvm_phase phase);
//     super.build_phase(phase);
    
//     // DECLARE ALL VARIABLES AT THE TOP OF THE FUNCTION
//     // string filename = "aes_golden.txt";
//     int fd;
//     string line;
//     aes_packet pkt;
//     string word;
//     int unsigned val;
//     int idx;
//     string temp_line;
//     int space_pos;

//     fd = $fopen(aes_golden.txt, "r");
//     if (fd == 0) begin
//       `uvm_error(get_type_name(), $sformatf("Cannot open golden file: %s", aes_golden.txt))
//       return;
//     end

//     while (!$feof(fd)) begin
//       line = "";
//       void'($fgets(line, fd));
//       line = line.tolower().trim(); // remove spaces/tabs/newlines

//       if (line.len() == 0) continue; // Skip empty lines

//       // Create new packet for each line
//       pkt = aes_packet::type_id::create($sformatf("golden_pkt_%0d", golden_model.size()));
//       idx = 0;

//       // Split line by spaces, parse 4 hex words
//       temp_line = line;
//       while (temp_line.len() > 0 && idx < 4) begin
//         space_pos = temp_line.find(" ");
//         if (space_pos >= 0) begin
//           word = temp_line.substr(0, space_pos-1);
//           temp_line = temp_line.substr(space_pos+1, temp_line.len()-1);
//         end else begin
//           word = temp_line;
//           temp_line = "";
//         end

//         if ($sscanf(word, "%h", val) == 1)
//           pkt.state_i[idx] = val;
//         else
//           pkt.state_i[idx] = 32'h0;

//         idx++;
//       end

//       golden_model.push_back(pkt);
//     end

//     $fclose(fd);

//     `uvm_info(get_type_name(), $sformatf("Golden model loaded: %0d packets", golden_model.size()), UVM_LOW);
//   endfunction

//   // ------------------------
//   // Output monitor callback
//   // ------------------------
//   function void write_out(aes_packet pkt);
//     aes_packet dut_pkt;
    
//     if (discard_first_output) begin
//       `uvm_info(get_type_name(), "SB: First output packet discarded", UVM_LOW)
//       discard_first_output = 0;
//       return;
//     end

//     dut_pkt = aes_packet::type_id::create("dut_pkt");

//     foreach(dut_pkt.state_i[i])
//       dut_pkt.state_i[i] = pkt.state_i[i];

//     dut_fifo.push_back(dut_pkt);
//     num_dut_rcvd++;

//     if (dut_fifo.size() > max_fifo_depth)
//       `uvm_warning(get_type_name(), "DUT FIFO exceeded depth limit");

//     `uvm_info(get_type_name(),
//       $sformatf("SB: Decrypted packet stored (dut_fifo=%0d)", dut_fifo.size()),
//       UVM_MEDIUM);
//   endfunction

//   // ------------------------
//   // Run phase – Compare DUT output with golden model
//   // ------------------------
//   task run_phase(uvm_phase phase);
//     aes_packet dut_pkt;
//     aes_packet golden_pkt;  // DECLARE AT TOP OF TASK
//     int golden_index = 0;

//     forever begin
//       wait (compare_enable && dut_fifo.size() > 0);

//       dut_pkt = dut_fifo.pop_front();
//       num_compared++;

//       if (golden_index >= golden_model.size()) begin
//         `uvm_warning(get_type_name(), "No more golden packets, skipping comparison")
//         continue;
//       end

//       golden_pkt = golden_model[golden_index];
//       golden_index++;

//       if (compare_state(dut_pkt, golden_pkt)) begin
//         num_pass++;
//         `uvm_info(get_type_name(), $sformatf("AES COMPARE PASS for packet %0d", num_compared), UVM_LOW);
//       end else begin
//         num_fail++;
//         `uvm_error(get_type_name(),
//           $sformatf("AES COMPARE FAIL for packet %0d\nDUT=%s\nGOLDEN=%s", 
//                      num_compared, dut_pkt.sprint(), golden_pkt.sprint()));
//       end
//     end
//   endtask

//   // ------------------------
//   // Compare 32x4 state
//   // ------------------------
//   function bit compare_state(aes_packet dut, aes_packet golden);
//     foreach(dut.state_i[i])
//       if (dut.state_i[i] !== golden.state_i[i])
//         return 0;
//     return 1;
//   endfunction

//   // ------------------------
//   // Check phase
//   // ------------------------
//   function void check_phase(uvm_phase phase);
//     super.check_phase(phase);

//     if (dut_fifo.size() != 0) begin
//       `uvm_error(get_type_name(),
//         $sformatf("SB CHECK FAIL: dut_fifo=%0d", dut_fifo.size()));
//     end else begin
//       `uvm_info(get_type_name(), "SB CHECK PASS: DUT FIFO empty", UVM_MEDIUM);
//     end
//   endfunction

//   // ------------------------
//   // Report phase
//   // ------------------------
//   function void report_phase(uvm_phase phase);
//     `uvm_info("AES_SB",
//       $sformatf(
//         "\n====== AES SCOREBOARD REPORT ======\n"
//         "DUT Received  : %0d\n"
//         "Compared      : %0d\n"
//         "PASS          : %0d\n"
//         "FAIL          : %0d\n",
//         num_dut_rcvd,
//         num_compared,
//         num_pass,
//         num_fail
//       ),
//       UVM_NONE
//     );

//     if (num_fail > 0) begin
//       `uvm_error("AES_SB", "TEST FAILED");
//     end else begin 
//       `uvm_info("AES_SB", "TEST PASSED", UVM_LOW);
//     end
//   endfunction

// endclass


class aes_fifo_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(aes_fifo_scoreboard)

  // ------------------------
  // Analysis port for DUT output
  // ------------------------
  `uvm_analysis_imp_decl(_out)
  uvm_analysis_imp_out #(aes_packet, aes_fifo_scoreboard) out_imp;

  // ------------------------
  // FIFOs
  // ------------------------
  aes_packet dut_fifo[$];       // DUT output FIFO
  aes_packet golden_model[$];   // Packets from TXT file

  // ------------------------
  // Control
  // ------------------------
  bit compare_enable = 1;
  int max_fifo_depth = 100;
  bit discard_first_output = 1; 

  // ------------------------
  // Counters
  // ------------------------
  int num_dut_rcvd  = 0;
  int num_compared  = 0;
  int num_pass      = 0;
  int num_fail      = 0;

  // ------------------------
  // Constructor
  // ------------------------
  function new(string name="aes_fifo_scoreboard", uvm_component parent=null);
    super.new(name, parent);
    out_imp = new("out_imp", this);
  endfunction


  virtual function void build_phase(uvm_phase phase);
   
    
    string filename;
    int fd;
    string line;
    aes_packet pkt;
    int num_read;
     super.build_phase(phase);

    filename = "aes_golden.txt";
    
    fd = $fopen(filename, "r");
    if (fd == 0) begin
      `uvm_error(get_type_name(), $sformatf("Cannot open golden file: %s", filename))
      return;
    end

    while (!$feof(fd)) begin
      line = "";
      void'($fgets(line, fd));
      
      if (line.len() == 0) continue;

      // Create new packet
      pkt = aes_packet::type_id::create($sformatf("golden_pkt_%0d", golden_model.size()));
      
      // Parse 4 hex values directly
      num_read = $sscanf(line, "%h %h %h %h", 
                         pkt.state_i[0], 
                         pkt.state_i[1], 
                         pkt.state_i[2], 
                         pkt.state_i[3]);
      
      if (num_read == 4) begin
        golden_model.push_back(pkt);
      end else if (num_read > 0) begin
        `uvm_warning(get_type_name(), 
          $sformatf("Incomplete line (read %0d values): %s", num_read, line))
      end
    end

    $fclose(fd);

    `uvm_info(get_type_name(), 
      $sformatf("Golden model loaded: %0d packets", golden_model.size()), 
      UVM_LOW)
  endfunction

  // ------------------------
  // Output monitor callback
  // ------------------------
  function void write_out(aes_packet pkt);
    aes_packet dut_pkt;
    
    if (discard_first_output) begin
      `uvm_info(get_type_name(), "SB: First output packet discarded", UVM_LOW)
      discard_first_output = 0;
      return;
    end

    dut_pkt = aes_packet::type_id::create("dut_pkt");

    foreach(dut_pkt.state_o[i])
      dut_pkt.state_o[i] = pkt.state_o[i];

    dut_fifo.push_back(dut_pkt);
    num_dut_rcvd++;

    if (dut_fifo.size() > max_fifo_depth)
      `uvm_warning(get_type_name(), "DUT FIFO exceeded depth limit")

    `uvm_info(get_type_name(),
      $sformatf("SB: Decrypted packet stored (dut_fifo=%0d)", dut_fifo.size()),
      UVM_MEDIUM)
  endfunction

  // ------------------------
  // Run phase – Compare DUT output with golden model
  // ------------------------
  // task run_phase(uvm_phase phase);
  //   aes_packet dut_pkt;
  //   aes_packet golden_pkt;
  //   int golden_index;
    
  //   golden_index = 0;

  //   forever begin
  //     wait (compare_enable && dut_fifo.size() > 0);

  //     dut_pkt = dut_fifo.pop_front();
  //     num_compared++;

  //     if (golden_index >= golden_model.size()) begin
  //       `uvm_warning(get_type_name(), "No more golden packets, skipping comparison")
  //       continue;
  //     end

  //     golden_pkt = golden_model[golden_index];
  //     golden_index++;

  //     if (compare_state(dut_pkt, golden_pkt)) begin
  //       num_pass++;
  //       `uvm_info(get_type_name(), $sformatf("AES COMPARE PASS for packet %0d", num_compared), UVM_LOW)
  //     end else begin
  //       num_fail++;
  //       `uvm_error(get_type_name(),
  //         $sformatf("AES COMPARE FAIL for packet %0d\nDUT=%s\nGOLDEN=%s", 
  //                    num_compared, dut_pkt.sprint(), golden_pkt.sprint()))
  //     end
  //   end
  // endtask


   task run_phase(uvm_phase phase);
    aes_packet dut_pkt;
    aes_packet golden_pkt;
    int golden_index;
    
    golden_index = 0;

    forever begin
      wait (compare_enable && dut_fifo.size() > 0);

      dut_pkt = dut_fifo.pop_front();
      num_compared++;

      if (golden_index >= golden_model.size()) begin
        `uvm_warning(get_type_name(), "No more golden packets, skipping comparison")
        continue;
      end

      golden_pkt = golden_model[golden_index];
      golden_index++;

      if (compare_state(dut_pkt, golden_pkt)) begin
        num_pass++;
        `uvm_info(get_type_name(), 
          $sformatf("AES COMPARE PASS for packet %0d\n  DUT    : %08h %08h %08h %08h\n  GOLDEN : %08h %08h %08h %08h", 
                    num_compared,
                    dut_pkt.state_o[0], dut_pkt.state_o[1], dut_pkt.state_o[2], dut_pkt.state_o[3],
                    golden_pkt.state_i[0], golden_pkt.state_i[1], golden_pkt.state_i[2], golden_pkt.state_i[3]),
          UVM_LOW)
      end else begin
        num_fail++;
        `uvm_error(get_type_name(),
          $sformatf("AES COMPARE FAIL for packet %0d\n  DUT    : %08h %08h %08h %08h\n  GOLDEN : %08h %08h %08h %08h", 
                    num_compared,
                    dut_pkt.state_o[0], dut_pkt.state_o[1], dut_pkt.state_o[2], dut_pkt.state_o[3],
                    golden_pkt.state_i[0], golden_pkt.state_i[1], golden_pkt.state_i[2], golden_pkt.state_i[3]))
      end
    end
  endtask

  // ------------------------
  // Compare 32x4 state
  // ------------------------
  function bit compare_state(aes_packet dut, aes_packet golden);
    foreach(dut.state_o[i])
      if (dut.state_o[i] !== golden.state_i[i])
        return 0;
    return 1;
  endfunction

  // ------------------------
  // Check phase
  // ------------------------
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (dut_fifo.size() != 0) begin
      `uvm_error(get_type_name(),
        $sformatf("SB CHECK FAIL: dut_fifo=%0d", dut_fifo.size()))
    end else begin
      `uvm_info(get_type_name(), "SB CHECK PASS: DUT FIFO empty", UVM_MEDIUM)
    end
  endfunction

  // ------------------------
  // Report phase
  // ------------------------
   function void report_phase(uvm_phase phase);
    `uvm_info("AES_SB", 
  $sformatf("\n====== AES SCOREBOARD REPORT ======\n DUT Received  : %0d\n Compared      : %0d\n PASS          : %0d\n FAIL          : %0d\n", 
    num_dut_rcvd, num_compared, num_pass, num_fail), 
  UVM_NONE)
endfunction

endclass

