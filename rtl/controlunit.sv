module controlunit #(
    parameter DATA_WIDTH = 32
) (
    input logic [DATA_WIDTH-1:0] instr,   // Instruction input
    input logic                 stall,
    output logic [2:0]          ALUctrl,  // ALU control signal
    output logic                ALUsrc,   // ALU source (1 for immediate, 0 for register)
    output logic [2:0]          ImmSrc,   // Immediate source selection
    output logic                RegWrite,  // Register write enable 
    output logic [1:0]          branch,    //2 bit branch signal: MSB for branch confirmation, LSB for branch type
    output logic [1:0]          Jump,      //2 bit Jump signal: MSB for jump confirmation, LSB for Jump type
    output logic [2:0]          AddrMode,  // sets the instruction for data memory
    output logic                ResultSrc, // control signal for output mux
    output logic                WD3Src     // control unit signal for write port for register allowing Jump instruction implementation       
);

    // Extract instruction fields
    logic [6:0] op;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign op = instr[6:0];
    assign funct3 = instr[14:12];
    assign funct7 = instr[31:25];

    always_comb begin
        // Default values
        ALUctrl = 3'b000;
        ALUsrc = 1'b0;
        ImmSrc = 3'b000;
        RegWrite = 1'b0;
        AddrMode = 3'b000;
        ResultSrc = 1'b0;
        WD3Src = 1'b0;
        branch = 2'b00;
        Jump =  2'b00;

        case (op)
            // R-Type
            7'b0110011: begin 
                case (funct3)
                    3'b000: ALUctrl = (funct7 == 7'b0100000) ? 3'b001 : 3'b000; // SUB/ADD
                    3'b110: ALUctrl = 3'b011; // OR
                    3'b100: ALUctrl = 3'b100; //XOR
                    3'b111: ALUctrl = 3'b010; // AND
                    3'b010: ALUctrl = 3'b101; // SLT
                    default: ALUctrl = 3'b000;
                endcase
                RegWrite = 1'b1;
                ALUsrc = 1'b0;
            end

            // I-Type (Arithmetic)
            7'b0010011: begin 
                case (funct3)
                    3'b000: ALUctrl = 3'b000; // ADDI
                    3'b110: ALUctrl = 3'b011; // ORI
                    3'b111: ALUctrl = 3'b010; // ANDI
                    3'b010: ALUctrl = 3'b101; // SLTI
                    default: ALUctrl = 3'b000;
                endcase
                RegWrite = 1'b1;
                ALUsrc = 1'b1;
                ImmSrc = 3'b000;
            end

            // Load (I-Type)
            7'b0000011: begin 
                ALUctrl = 3'b000; // ADD for address calculation
                RegWrite = 1'b1;
                ALUsrc = 1'b1;
                ImmSrc = 3'b000;
                ResultSrc = 1'b1; //result is switched to dataMem read from ALUout

                //For data_mem
                case(funct3)
                3'b000: AddrMode = 3'b000;
                3'b001: AddrMode = 3'b001;
                3'b010: AddrMode = 3'b010;
                3'b100: AddrMode = 3'b011;
                3'b101: AddrMode = 3'b100;
                default: AddrMode = 3'b000;
                endcase
            end

            // Store (S-Type)
            7'b0100011: begin 
                ALUctrl = 3'b000; // ADD for address calculation
                ALUsrc = 1'b1; // Uses rd2
                ImmSrc = 3'b001; // S-Type immediate
                
                //For data_mem
                case(funct3)
                3'b000: AddrMode = 3'b101;
                3'b001: AddrMode = 3'b110;
                3'b010: AddrMode = 3'b111;
                default: AddrMode = 3'b101;
                endcase
            end

            // Branch (B-Type)
            7'b1100011: begin 
                ALUctrl = 3'b001; // SUB for comparison
                ImmSrc = 3'b010;  // B-Type immediate
                // branch signal used for PCsrc and flush
                case (funct3)
                    3'b000: begin // BEQ
                        branch = 2'b11; // BEQ branch = 1
                    end
                    3'b001: begin // BNE
                        branch = 2'b10; // BNE branch = 0
                    end
                    default: begin
                        branch = 2'b11; // Default branch = 0
                    end
                endcase
            end

            // J-Type (JAL)
            7'b1101111: begin 
                RegWrite = 1'b1;
                ALUsrc = 1'b1;
                ImmSrc = 3'b100;
                WD3Src = 1'b1;
                Jump = 2'b10;
            end

            // JALR (I-Type)
            7'b1100111: begin 
                ALUsrc = 1'b1;
                ImmSrc = 3'b000;
                ResultSrc = 1'b0;
                WD3Src = 1'b1;
                Jump = 2'b11;


                //for ret instructions Rd = 5'b00000 -> to prevent overwriting zero
                if(instr[11:7] == 5'b00000) begin
                    RegWrite = 1'b0;
                end
                else begin
                    RegWrite = 1'b1; // for normal JALR instructions allows writing to regfile
                end
                
            end

            // LUI (Load Upper Immediate)
            7'b0110111: begin 
                RegWrite = 1'b1;
                ALUsrc = 1'b1;
                ImmSrc = 3'b011;
            end

            //NOTE: NOT fully implemented/used here

            // AUIPC (Add Upper Immediate to PC)
            7'b0010111: begin 
                RegWrite = 1'b1;
                ALUsrc = 1'b1;
                ImmSrc = 3'b011;
            end

            // I-Type (ecall, ebreak)
            7'b1110011: begin 
                ALUsrc = 1'b1;
                if (funct3 == 3'b000) begin
                    RegWrite = 1'b0; // ecall/ebreak
                end else begin
                    RegWrite = 1'b1; // Other I-Type
                end
            end

            // Default case (unknown opcode)
            default: begin
                ALUctrl = 3'b000;
                ALUsrc = 1'b0;
                ImmSrc = 3'b000;
                RegWrite = 1'b0;
                AddrMode = 3'b000;
                ResultSrc = 1'b0;
                WD3Src = 1'b0;
                branch = 2'b00;
                Jump = 2'b00;
            end
        endcase

        if (stall) begin
            RegWrite = 0;
        end
    end
endmodule
