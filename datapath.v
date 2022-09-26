module datapath( input CLK,
                 input DMRST,
                 input DMWE,
                 input RFRST,
                 input RFWE,
                 input PCRRST,
                 input [3:0] ALU_sel,
                 input M_to_RF_sel,
                 input ALU_in_sel1,
                 input ALU_in_sel2,
                 input PC_sel,
                 input RFD_sel,
                 input jump,
                 output wire [5:0] opcode_out,
                 output wire [5:0] funct_out,
                 output wire zero_out            );
    
    // Instructions are 32 bits
    wire [31:0] inst;
    // Disecting the instruction into its constituent parts:
    // -----------------------------------------------------
    // First 6 bits are the opcode
    wire [5:0] opcode = inst[31:26];
    // The next three 5-bit sections could be rs and rt 
    // respectively if the instruction is R-type or I-type.
    wire [4:0] rs = inst[25:21];
    wire [4:0] rt = inst[20:16];
    // If the instruction is R-type:
    // the next two 5-bit sections are rd and shamt
    // and the last 6-bit section is funct
    wire [4:0] rd = inst[15:11];
    wire [4:0] shamt = inst[10:6];
    wire [5:0] funct = inst[5:0];
    // If the instruction is I-type:
    // the last 16-bit section is an immediate (imm) 
    wire [15:0] imm = inst[15:0];
    // If the instruction is J-type:
    // the 26-bit section after the opcode is a jump target (jaddr)
    wire [25:0] jaddr = inst[25:0];
    
    // Output the instruction opcode and funct fields for the control unit
    assign opcode_out = opcode;
    assign funct_out = funct;
    
    // Supporting lw instruction
    // Construct Sign-Extended Immediate (Simm)
    wire [31:0] Simm;
    assign Simm[31:0] = { {16{inst[15]}}, imm[15:0] };
    
    wire [31:0] RFRD1;
    wire [31:0] DM_din;
    wire [31:0] DM_out;
    wire [31:0] ALU_out;
    
    DM data_mem(.CLK(CLK),
                .RST(DMRST),
                .DMWE(DMWE),
                .DMA(ALU_out),
                .DMWD(DM_din),
                .DMRD(DM_out) );
                
    // ALUDM MUX
    reg [31:0] ALUDM;
    always @ (M_to_RF_sel or ALU_out or DM_out) begin
        if (M_to_RF_sel == 0)
            ALUDM = ALU_out;
        else
            ALUDM = DM_out;
    end
    
    // RFD MUX
    reg [31:0] rtd;
    always @ (RFD_sel or rt or rd) begin
        if (RFD_sel == 0)
            rtd = rt;
        else
            rtd = rd;
    end
    
    RF reg_file(.CLK(CLK),
                .RST(RFRST),
                .RFWE(RFWE),
                .RFRA1(rs),
                .RFRA2(rt),
                .RFWA(rtd),
                .RFWD(ALUDM),
                .RFRD1(RFRD1),
                .RFRD2(DM_din)  );
    
    // Sign extend shamt
    wire [31:0] Sshamt;
    assign Sshamt[31:0] = { {26{inst[10]}}, shamt[4:0]};
    
    // ALU_in1 MUX
    // select Sshamt for immediate shift operations
    reg [31:0] ALU_in1;
    always @ (ALU_in_sel1 or RFRD1 or Sshamt) begin
        if (ALU_in_sel1 == 0)
            ALU_in1 = RFRD1;
        else
            ALU_in1 = Sshamt;
    end
    
    // ALU_in2 MUX
    reg [31:0] ALU_in2;
    always @ (ALU_in_sel2 or DM_din or Simm) begin
        if (ALU_in_sel2 == 0)
            ALU_in2 = DM_din;
        else
            ALU_in2 = Simm;
    end
    
    ALU alu(.ALU_sel(ALU_sel),
            .ALU_in1(ALU_in1),
            .ALU_in2(ALU_in2),
            .zero(zero_out),
            .ALU_out(ALU_out) );
            
    // PC holds the address of the current instuction in IM
    wire [31:0] PC;
    // Program Counter Prime (PCP)(PC') is the address of the next instruction in IM
    reg [31:0] PCP;
    //   1.   PCP becomes PC_branch if there is a branch instruction
    //   2.   PCP becomes PC_jump if there is a jump instruction
    //   3.   Otherwise PCP becomse PC_p1
    wire [31:0] PC_p1, PC_branch, PC_jump;
      
    // PC_p1 is PC + 1
    assign PC_p1 = PC + 1;
    
    // PC_branch is PC + 1 + Simm
    assign PC_branch = PC_p1 + Simm;
    
    // PC_jump keeps the 6 MSBs of PC + 1 and replaces the rest with jaddr
    assign PC_jump = {PC_p1[31:26], jaddr[25:0]};
    
    always @ (PC_sel or jump or PC_branch or PC_p1 or PC_jump) begin
        if (jump == 0) begin
            if (PC_sel == 0)
                PCP = PC_p1;
            else
                PCP = PC_branch;
        end else
            PCP = PC_jump;
    end
        
    IM inst_mem(.IMA(PC),
                .IMRD(inst) );
                
                
    PCR PC_reg( .CLK(CLK),
                .RST(PCRRST),
                .PCP(PCP),
                .PC(PC)       );            
endmodule