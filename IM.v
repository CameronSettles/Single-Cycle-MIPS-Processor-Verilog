module IM( input [31:0] IMA,
           output wire [31:0] IMRD
    );
    
reg [31:0] mem [0: 2048];

// Load instructions into IM
initial $readmemb("part_e.mem", mem);

// Asynchronously drive read output signal
assign IMRD = mem[IMA];

endmodule
