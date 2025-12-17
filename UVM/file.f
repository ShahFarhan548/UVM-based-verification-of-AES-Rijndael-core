

-64
-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d
-sv
-uvm
-timescale 1ns/1ns

// Include directories

-incdir "/home/cc/Fahad_DV/Final_Project/practice_github/fahad_shah/UVM"
-incdir "/home/cc/Fahad_DV/Final_Project/practice_github/fahad_shah/CIPHER_UNIT/sv"

// Compile UVC package & interface files

// YAPP UVC
../UVM/aes_pkg.sv
../UVM/aes_interface.sv


	  
      aes_hw_top.sv
	aes_top.sv
	
 ../CIPHER_UNIT/sv/S_Box.sv
 ../CIPHER_UNIT/sv/Inv_S_Box.sv
 ../CIPHER_UNIT/sv/Xtime.sv

 ../CIPHER_UNIT/sv/GFunc.sv
 ../CIPHER_UNIT/sv/HFunc.sv

 ../CIPHER_UNIT/sv/MixColumn.sv
../CIPHER_UNIT/sv/ARK.sv
../CIPHER_UNIT/sv/BS.sv
../CIPHER_UNIT/sv/MC.sv
 ../CIPHER_UNIT/sv/KEXP.sv
 ../CIPHER_UNIT/sv/ByteSub.sv
 ../CIPHER_UNIT/sv/State.sv
 ../CIPHER_UNIT/sv/Register.sv
 ../CIPHER_UNIT/sv/dem1_8.sv
 ../CIPHER_UNIT/sv/dem1_9.sv
 ../CIPHER_UNIT/sv/dem1_11.sv
 ../CIPHER_UNIT/sv/demux1_11.sv
 ../CIPHER_UNIT/sv/mux3_1.sv
 ../CIPHER_UNIT/sv/mux15_1.sv
../CIPHER_UNIT/sv/RS.sv
../CIPHER_UNIT/sv/CU_S.sv
 ../CIPHER_UNIT/sv/aes.sv
 
	
/// Simulation options
+UVM_TESTNAME=encryption_test
+UVM_VERBOSITY=UVM_FULL
+SVSEED=random

// Enable functional + code coverage
-coverage all
-covoverwrite

// Instrument RTL DUT (NOT UVM class!)
-covdut aes_top

// Access for UVM & coverage
-access +rwc

// Optional GUI
//-gui


















