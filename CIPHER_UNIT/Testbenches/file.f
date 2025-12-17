// 64 bit option for AWS labs
-64

-uvmhome /home/cc/mnt/XCELIUM2309/tools/methodology/UVM/CDNS-1.1d

// include directories
//*** add incdir include directories here
-timescale 1ns/1ns
// compile files
//*** add compile files here

// ============ 1. Include directories ============
-incdir /home/cc/Fahad_DV/Final_Project/practice_github/fahad_shah/CIPHER_UNIT/sv
-incdir .

//-gui
-access
+rwc

// ============ 4. DUT + helper modules ============
../sv/aes.sv
../sv/CU_S.sv
../sv/demux1_11.sv
../sv/KEXP.sv
../sv/mux3_1.sv
../sv/State.sv
../sv/ARK.sv
../sv/dem1_11.sv
../sv/GFunc.sv
../sv/MC.sv
../sv/Register.sv
../sv/BS.sv
../sv/dem1_8.sv
../sv/HFunc.sv
../sv/MixColumn.sv
../sv/RS.sv
../sv/Xtime.sv
../sv/ByteSub.sv
../sv/dem1_9.sv
../sv/Inv_S_Box.sv
../sv/mux15_1.sv
../sv/S_Box.sv





aes_tb.sv




