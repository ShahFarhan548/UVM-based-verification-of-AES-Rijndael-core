class aes_input_monitor extends uvm_monitor;
  `uvm_component_utils(aes_input_monitor)

  // Virtual interface
  virtual aes_interface vif;

  // Analysis port to broadcast input transactions
  uvm_analysis_port #(aes_packet) ap;

  int num_inputs_collected = 0;

  function new(string name = "aes_input_monitor", uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    if (!aes_vif_config::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", "Virtual interface not set for aes_input_monitor")
  endfunction

  task run_phase(uvm_phase phase);
    aes_packet pkt;

    forever begin
      // Trigger exactly when driver drives inputs
      @(posedge vif.CLK iff vif.drvstart == 1'b1);

      pkt = aes_packet::type_id::create("pkt", this);

      // Sample DUT inputs
      pkt.enc_dec = vif.enc_dec;
      pkt.KL      = vif.KL;

      foreach (pkt.KEY[i])
        pkt.KEY[i] = vif.KEY[i];

      foreach (pkt.state_i[i])
        pkt.state_i[i] = vif.state_i[i];

  `uvm_info(get_type_name(),  $sformatf("Packet Collected #%0d:\n%s", num_inputs_collected, pkt.sprint()),  UVM_HIGH)

   
      // Broadcast to scoreboard / reference model
      ap.write(pkt);

      num_inputs_collected++;
    end
  endtask

  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("AES INPUT MONITOR collected %0d input packets",
                num_inputs_collected),
      UVM_LOW)
  endfunction

endclass
