module PCR( input CLK,
            input RST,
            input [31:0] PCP,
            output wire [31:0] PC
    );
    
    reg [31:0] mem;
    
    // Asynchronous reset
    always @ (posedge RST)
        mem = 32'b00000000000000000000000000000000;
        
    // Synchronous read
    always @ (posedge CLK)
        mem = PCP;
    
    // Asynchronously drive PC output signal
    assign PC = mem;
        
endmodule
