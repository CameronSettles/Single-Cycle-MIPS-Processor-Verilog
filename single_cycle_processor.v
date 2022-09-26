// Top module connects the datapath to the control unit
module single_cycle_processor(  input CLK,
                                input RFRST,
                                input DMRST,
                                input PCRRST );
    
    wire RFWE, DMWE;
    wire [3:0] ALU_sel;
    wire [5:0] opcode, funct;
    wire zero, M_to_RF_sel, ALU_in_sel1, ALU_in_sel2, RFD_sel, PC_sel, jump;
    
    control_unit CU(.opcode(opcode),
                    .funct(funct),
                    .zero(zero),
                    .RFWE(RFWE),
                    .DMWE(DMWE),
                    .ALU_sel(ALU_sel),
                    .M_to_RF_sel(M_to_RF_sel),
                    .ALU_in_sel1(ALU_in_sel1),
                    .ALU_in_sel2(ALU_in_sel2),
                    .PC_sel(PC_sel),
                    .jump(jump),
                    .RFD_sel(RFD_sel)           );
                
    datapath DP(.CLK(CLK),
                .DMRST(DMRST),
                .DMWE(DMWE),
                .RFRST(RFRST),
                .RFWE(RFWE),
                .PCRRST(PCRRST),
                .ALU_sel(ALU_sel),
                .M_to_RF_sel(M_to_RF_sel),
                .ALU_in_sel1(ALU_in_sel1),
                .ALU_in_sel2(ALU_in_sel2),
                .PC_sel(PC_sel),
                .RFD_sel(RFD_sel),
                .jump(jump),
                .opcode_out(opcode),
                .funct_out(funct),
                .zero_out(zero)             );
    
endmodule
