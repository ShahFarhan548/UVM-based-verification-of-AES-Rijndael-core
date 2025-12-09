class aes_seqs extends uvm_sequence#(aes_packet);
  `uvm_object_utils(aes_seqs)

  
  function new(string name="aes_seqs");
  super.new(name);
  endfunction

task pre_body();
uvm_phase phase;
  `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif

if (phase != null) begin
  phase.raise_objection(this, get_type_name);
  `uvm_info(get_type_name(), "Raise objection", UVM_MEDIUM);
end
endtask : pre_body


 task post_body();
    uvm_phase phase;
    `ifdef UVM_VERSION_1_2
      // in UVM1.2, get starting phase from method
      phase = get_starting_phase();
    `else
      phase = starting_phase;
    `endif
    if (phase != null) begin
      phase.drop_objection(this, get_type_name());
      `uvm_info(get_type_name(), "drop objection", UVM_MEDIUM)
    end
  endtask : post_body


endclass : aes_seqs



class rand_packet extends aes_seqs;
  `uvm_object_utils(rand_packet)
   
    function new(string name="rand_packet");
    super.new(name);
  endfunction

   task body();
    `uvm_info(get_type_name(), "Executing rand_packet sequence", UVM_LOW)
     repeat(5)
      `uvm_do(req)
  endtask

endclass : rand_packet
  



