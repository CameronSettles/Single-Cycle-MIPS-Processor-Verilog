module control_unit( input [5:0] opcode,
                     input [5:0] funct,
                     input zero,
                     output reg RFWE,
                     output reg DMWE,
                     output reg [3:0] ALU_sel,
                     output reg M_to_RF_sel,
                     output reg ALU_in_sel1,
                     output reg ALU_in_sel2,
                     output wire PC_sel,
                     output reg jump,
                     output reg RFD_sel          );
    
    reg branch;
    assign PC_sel = branch && zero;
    
    reg [1:0] ALU_op;
    
    // Opcode translations
    parameter LW = 6'b100011, SW = 6'b101011, r_type = 6'b000000, addi = 6'b001000;
    parameter BEQ = 6'b000100, J = 6'b000010;
    // Main Decoder
    // Update control signals when opcode changes
    always @ (opcode) begin
        case (opcode)
            
            LW: begin
                ALU_op =            2'b00;
                RFWE =              1'b1;
                RFD_sel =           1'b0;
                ALU_in_sel1 =       1'b0;
                ALU_in_sel2 =       1'b1;
                branch =            1'b0;
                DMWE =              1'b0;
                M_to_RF_sel =       1'b1;
                jump =              1'b0;
            end
            
            SW: begin 
                ALU_op =            2'b00;
                RFWE =              1'b0;
                RFD_sel =           1'b0; // X
                ALU_in_sel1 =       1'b0;
                ALU_in_sel2 =       1'b1;
                branch =            1'b0;
                DMWE =              1'b1;
                M_to_RF_sel =       1'b1; // X
                jump =              1'b0;
            end
            
            r_type: begin
                ALU_op =            2'b10;
                RFWE =              1'b1;
                RFD_sel =           1'b1;
                ALU_in_sel1 =       1'b0;
                ALU_in_sel2 =       1'b0;
                branch =            1'b0;
                DMWE =              1'b0;
                M_to_RF_sel =       1'b0;
                jump =              1'b0;
            end
                
            addi: begin
                ALU_op =            2'b00;
                RFWE =              1'b1;
                RFD_sel =           1'b0;
                ALU_in_sel1 =       1'b0;
                ALU_in_sel2 =       1'b1;
                branch =            1'b0;
                DMWE =              1'b0;
                M_to_RF_sel =       1'b0;
                jump =              1'b0;
            end
            
            BEQ: begin
                ALU_op =            2'b01;
                RFWE =              1'b0;
                RFD_sel =           1'b0; // X
                ALU_in_sel1 =       1'b0; 
                ALU_in_sel2 =       1'b0;
                branch =            1'b1;
                DMWE =              1'b0;
                M_to_RF_sel =       1'b0; // X
                jump =              1'b0;
            end
                
            J: begin
                ALU_op =            2'b01;// XX
                RFWE =              1'b0; 
                RFD_sel =           1'b0; // X
                ALU_in_sel1 =       1'b0; 
                ALU_in_sel2 =       1'b0; // X
                branch =            1'b1; // X
                DMWE =              1'b0; 
                M_to_RF_sel =       1'b0; // X
                jump =              1'b1;
            end
            
            // Default all control signals to 0
            default: begin 
                ALU_op =            0;
                RFWE =              0;
                RFD_sel =           0;
                ALU_in_sel1 =       0;
                ALU_in_sel2 =       0;
                branch =            0;
                DMWE =              0;
                M_to_RF_sel =       0;
            end
        endcase
    end
    
    // ALU_sel values
    parameter ADD=4'b0010, SUB=4'b0000, SLL=4'b0011, LRS=4'b0100, LVLS=4'b0101, LVRS=4'b0110;
    parameter SRA=4'b0111, AND=4'b1000, OR=4'b1001, XOR=4'b1010, XNOR=4'b1011;
    
    // ALU Decoder
    always @ (opcode or funct or ALU_op) begin
    
        // Funct is irrelevant. The operation is either ADD or SUB 
        if (ALU_op[1] == 0) begin
            if (ALU_op[0] == 0)
                ALU_sel = ADD;
            else 
                ALU_sel = SUB;
        
        // ALU_op[1] is 1 so we need to look at funct for the operation
        end else begin 
            case (funct)
                
                // Only immediate shift operations should have ALU_in_sel1 = 1
                6'b000000: begin
                    ALU_sel = SLL;
                    ALU_in_sel1 = 1'b1;
                end
                
                6'b100000: ALU_sel = ADD;
                6'b100010: ALU_sel = SUB;
                6'b100100: ALU_sel = AND;
                6'b100101: ALU_sel = OR;
                6'b000100: ALU_sel = SLL;
                6'b000111: ALU_sel = SRA;
                //6'b101010: ALU_sel = SLT;
            endcase
        end
    end
endmodule
