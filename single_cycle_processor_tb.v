`timescale 1ns / 1ps
module single_cycle_processor_tb;

    reg CLK;
    reg RFRST, DMRST, PCRRST;
    
    single_cycle_processor DUT( .CLK(CLK),
                                .RFRST(RFRST),
                                .DMRST(DMRST),
                                .PCRRST(PCRRST) );
    
    // Initialize and start the clock                      
    initial CLK = 0;
    always #100 CLK = ~CLK;
    
    // Activate reset signals 
    // before first clock cycle ends
    initial begin
        PCRRST = 1; RFRST = 1; DMRST = 1; #50
        PCRRST = 0; RFRST = 0; DMRST = 0;
    end 
endmodule
