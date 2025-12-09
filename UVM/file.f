

-64
-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d
-sv
-uvm
-timescale 1ns/1ns

// Include directories

-incdir "/home/cc/Fahad_DV/Final_Project/proj/UVM_RANJDEIL_CORE"
// -incdir "/home/cc/Fahad_DV/UVM/lab6/task1/clock_and_reset/sv"
// -incdir "/home/cc/Fahad_DV/UVM/lab6/task1/hbus/sv"

// Compile UVC package & interface files

// YAPP UVC
../UVM_RANJDEIL_CORE/aes_pkg.sv
// router_module_pkg.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/clock_and_reset/sv/clock_and_reset_pkg.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/channel/sv/channel_pkg.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/hbus/sv/hbus_pkg.sv

// yapp_if.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/clock_and_reset/sv/clock_and_reset_if.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/channel/sv/channel_if.sv
// /home/cc/Fahad_DV/UVM/lab6/task1/hbus/sv/hbus_if.sv

	// clkgen.sv
    //     hw_top.sv
	aes_top.sv
	// yapp_router.sv
	

// Simulation options
+UVM_TESTNAME=simple_test
+UVM_VERBOSITY=UVM_FULL
+SVSEED=random

//-gui -access +rwc










