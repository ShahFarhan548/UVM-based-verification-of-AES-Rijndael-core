class aes_test_top extends uvm_test;
    `uvm_component_utils(aes_test_top)
    aes_test tb;
    function new(string name , uvm_component parent);
        super.new(name, parent);
    endfunction //new()

    function build_phase (uvm_phase phase);
        super.build_phase(phase);
        
        tb = aes_test_top::type_id::create("tb", this);
    endfunction

    function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_type_name(), "Running Simulation AES_TEST_TOP ", UVM_HIGH)
    endfunction

endclass //aes_test_top 