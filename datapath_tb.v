`timescale 1ns / 1ps

module datapath_tb;

    reg CLK;
    reg DMRST, DMWE, RFRST, RFWE, PCRRST;
    reg [3:0] ALUsel;
    
    datapath DUT(.CLK(CLK),
                 .DMRST(DMRST),
                 .DMWE(DMWE),
                 .RFRST(RFRST),
                 .RFWE(RFWE),
                 .ALUsel(ALUsel),
                 .PCRRST(PCRRST) );
                 
    initial CLK = 0;
    always #50 CLK = ~CLK;
    
    initial begin
        // Part a
        ALUsel = 4'b0010;
        RFWE = 1;
        DMWE = 0;
        
        // Resets
        DMRST = 1;
        RFRST = 1;
        PCRRST = 1;
        #100;
        DMRST = 0;
        RFRST = 0;
        PCRRST = 0;

        
    end

endmodule
