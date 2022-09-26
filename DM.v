module DM( input CLK,
           input RST,
           input DMWE,
           input [31:0] DMA,
           input [31:0] DMWD,
           output wire [31:0] DMRD
    );
    
    parameter DEPTH = 2048;
    reg [31:0] mem [0:DEPTH];
    
    // On reset: set all register to 0
    integer i;
    always @ (posedge RST) begin
        for (i = 0; i < DEPTH+1; i = i + 1) begin
            mem[i]= 0;
        end
        // Load DM with 17, 31, -5, -2, 250
        mem[0] = 17;
        mem[1] = 31;
        mem[2] = -5;
        mem[3] = -2;
        mem[4] = 250;
    end
    
    // Asynchronously read
    assign DMRD = mem[DMA];

    // The DM is in read-first mode
    always @ (posedge CLK) begin
        
        // Synchronously write DMWD into DM at DMA if write enable (DMWE) is active
        if (DMWE)
            mem[DMA] = DMWD;
    end
endmodule
