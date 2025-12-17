module CU_S(
input CLK,
input CLR,
input enc_dec,
input [1:0]KL,
input KF,
output logic mux0,
output logic mux1,
output logic [1:0]mux2,
output logic mux3,
output logic mux4,
output logic mux5,
output logic mux6,
output logic SE,
output logic SCLR,
output logic CF,
output logic [3:0]R
    );

logic [3:0]STATE;
logic [3:0]NXT_STATE;


//Round counter --- variables
reg [3:0]R_reg;
wire [3:0]Rt;
logic cond1;//to check if R = Rt
logic cond2;//to check if R = 0
logic cond3;//to choose R
logic cond4;//to check if R = Rt - 1
logic cond5;//to reset R_reg based off of state

//Round counter --- body
assign Rt = KL[1]?(14):(KL[0]?(10):(12));// to choose rt 0 (4) = 10 ; 1 (6) = 11 ; 2 (8) = 14

always_comb
begin
    if(R_reg == Rt)
        begin
            cond1 = 1;
        end
    else
        begin
            cond1 = 0; 
        end
     //to change state input
     if(R_reg == 0)
        begin
            cond2 = 1;
        end
     else
        begin
            cond2 = 0;      
        end
        
    if(R_reg == (Rt-1))
            begin
                cond4 = 1;
            end
        else
            begin
                cond4 = 0; 
            end   

    case(STATE)// STATE MACHINE
        0://RESET
            begin
                NXT_STATE = KF?2:1;// INPUT IF KF is HIGH OR STALL IF KF is LOW
                
                cond5 = 0;//resetinng R to zero
                CF = 0;
                SCLR = 1;   //state RESET
                SE = 0;     //state DISABLED                
                mux0 = 0;   // MUX VALUES UPDATED TO PREVENT A FEEDBACK LOOP
                mux1 = 1;   
                mux2 = 1;   
                mux3 = 1;   
                mux4 = 0;    
                mux5 = 1;   
                mux6 = 0;                                
            end
        1://STALL
            begin
                NXT_STATE = cond1?0:1;//stays in STALL till R = Rt then goes to reset
                    
                cond5 = 1;// allowing R to be updated
                cond3 = 1;  //R
                CF = 0;
                SCLR = 1;   //state RESET
                SE = 0;     //state DISABLED                
                mux0 = 0; //state
                mux1 = 1;    //changed from zero
                mux2 = 1;   //changed from zero
                mux3 = 1;    //changed from zero, used to take in state 4
                mux4 = 0;   //takes in state 3
                mux5 = 1; //Also state   (changed from zero)
                mux6 = 0;                    
            end
        2://INPUT
            begin
                NXT_STATE = KF?(enc_dec?3:6):0;// 1 -> encryption  0 -> decryption, if KF is 0 then it resets again                                
                
                cond5 = 0;// pausing R
                CF = 1;     //Ready to take input
                SCLR = 0;   //state not RESET
                SE = 1;     //state enabled                
                mux0 = 1;   // 1 means that state takes input from the outside
                //mux1 = 0;   //BS
                //mux2 = 0;   //RS
                //mux3 = 0;   //MC
                //mux4 = 0;   //ARK
                //mux5 = 1;   // can be either 1 or zero, we dont care
                //mux6 = 0;   //Swapping between EN/EX and DN/DX                             
                 
            end
        3://E0
            begin
                NXT_STATE = 4;// the next state HAS to be EX
                    
                cond3 = 1;  //R
                cond5 = 1;// allowing R to be updated
                
                CF = 0;
                SCLR = 0;   //state not RESET
                SE = 1;     //state enabled                
                mux0 = 0;   // 1 means that state takes input from the outside
                mux1 = 0;
                mux2 = 0;
                mux3 = 0;
                mux4 = 1;
                mux5 = 1;   // needs to be 1 for ARK input into state
                mux6 = 0;   //No outside inputs                                         
            end
        4://EX
            begin
                NXT_STATE = cond4?5:4;// Stay in this state till R = Rt - 1  
                    
                CF = 0;    
                SCLR = 0;   //state not RESET
                SE = 1;     //state enabled                
                mux0 = 0;   // 1 means that state takes input from the outside
                mux1 = 1;   //state into BS
                mux2 = 1;   //BS into RS
                mux3 = 1;   //RS into MC
                mux4 = 0;   //MC into ARK 
                mux5 = 1;   // needs to be 1 for ARK input into state
                mux6 = 0;   //MC into ARK                             
            end 
        5://EN
            begin
                    NXT_STATE = 2;//into INPUT
                    
                    CF = 0;     //input to be taken in the next cycle    
                    SCLR = 0;   //state not RESET
                    SE = 1;     //state enabled                
                    mux0 = 0;   // 1 means that state takes input from the outside
                    mux1 = 1;   //state into BS
                    mux2 = 1;   //BS into RS
                    mux3 = 1;   //dont care since its not being used
                    mux4 = 0;   //RS into ARK 
                    mux5 = 1;   // needs to be 1 for ARK input into state
                    mux6 = 1;   //RS into ARK                                    
            end
        6://D0 
            begin
                    NXT_STATE = 7;//into DX

                    cond5 = 1;// allowing R to be updated
                    cond3 = 0;  //R
                    
                    CF = 0;       
                    SCLR = 0;   //state not RESET
                    SE = 1;     //state enabled                
                    mux0 = 0;   // 1 means that state takes input from the outside
                    mux1 = 0;   //RS into BS
                    mux2 = 0;   //ARK into RS
                    mux3 = 0;   //dont care since MC is being skipped
                    mux4 = 1;   //state into ARK 
                    mux5 = 0;   // BS into state
                    mux6 = 0;   // no user input                                      
            end
        7://DX
            begin
                    NXT_STATE = cond4?8:7;// Stay in this state till R = Rt - 1
                    
                    CF = 0;        
                    SCLR = 0;   //state not RESET
                    SE = 1;     //state enabled                
                    mux0 = 0;   // 1 means that state takes input from the outside
                    mux1 = 0;   //RS into BS
                    mux2 = 2;   //MC into RS
                    mux3 = 0;   //ARK into MC
                    mux4 = 1;   //state into ARK 
                    mux5 = 0;   // BS into state
                    mux6 = 0;   // no user input                        
            end
        8://DN
            begin

                    NXT_STATE = 2;//into INPUT

                    CF = 0;         
                    SCLR = 0;   //state not RESET
                    SE = 1;     //state enabled                
                    mux0 = 0;   //1 means that state takes input from the outside
                    mux1 = 0;   //We dont care
                    mux2 = 2;   //We dont care
                    mux3 = 0;   //We dont care
                    mux4 = 1;   //state into ARK 
                    mux5 = 1;   //ARK into state
                    mux6 = 0;   //no user input                              
            end                                                                                                                                            
    endcase

end

always_ff@(posedge CLK)
begin
    //for round incrementing
    if(R_reg == Rt)
        begin
            R_reg <= 0;
        end
    else
        begin
            R_reg <= cond5?(R_reg + 1):(0);    
        end


    if(CLR)
        begin
            STATE <= 0;
        end
    else
        begin
            STATE <= NXT_STATE;// into next state
        end                   
end


assign R = cond3?(R_reg):(Rt - R_reg);// to swap between round counts for round key

endmodule
