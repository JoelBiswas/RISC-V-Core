import cpu_pkg::*;

//TODO: Add S-Type functionality
module decoder (
    input logic [31:0] instruction,

    output logic [4:0] rs1_addr,
    output logic [4:0] rs2_addr,
    output logic [4:0] rd_addr,
    output instr_type_e operation,
    output logic [31:0] immediate,
    output logic use_immediate
);
    localparam [6:0] R_TYPE = 7'b0110011;
    localparam [6:0] I_ALU_TYPE = 7'b0010011;
    localparam [6:0] I_LOAD_TYPE = 7'b0000011;
    localparam [6:0] S_TYPE = 7'b0100011;
    localparam [6:0] B_TYPE = 7'b1100011;
    localparam [31:0] EBREAK_TYPE = 32'b00000000000100000000000001110011;

    logic [6:0] funct7, opcode;
    logic [2:0] funct3;
    logic [31:0] i_type_immediate, s_type_immediate, b_type_immediate;

    //0000000|00000|00000|000|00000|0110011 R-TYPE

    //000000000000 |00000|000|00000|0010011 I-TYPE

    assign funct7 = instruction[31:25];
    assign rs2_addr = instruction[24:20];
    assign rs1_addr = instruction[19:15];
    assign funct3 = instruction[14:12];
    assign rd_addr =  instruction[11:7];
    assign opcode = instruction[6:0];

    assign s_type_immediate = {{20{instruction[31]}} , {instruction[31:25], instruction[11:7]}};
    assign i_type_immediate = {{20{instruction[31]}}, instruction[31:20]};
    assign b_type_immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};

    assign immediate = (opcode == S_TYPE)
        ? s_type_immediate
        : (opcode == B_TYPE) 
            ? b_type_immediate
            : i_type_immediate;
    assign use_immediate = (opcode == I_ALU_TYPE) || (opcode == I_LOAD_TYPE) || (opcode == S_TYPE) || (opcode == B_TYPE);
    
    always_comb begin
        if (instruction == EBREAK_TYPE) operation = EBREAK;
        else if (opcode == I_LOAD_TYPE && funct3 == 3'b010) operation = LOAD;
        else if (opcode == S_TYPE && funct3 == 3'b010) operation = STORE;
        else if (opcode == B_TYPE && funct3 == 3'b000) operation = BEQ;
        else if (opcode == R_TYPE) begin
            case (funct3)
                3'b000: operation = (funct7 == 7'b0) ? ADD : SUB;
                3'b001: operation = SLL;
                3'b101: operation = SRL;
                default: operation = NOP;
            endcase
        end
        else if (opcode == I_ALU_TYPE && funct3 == 3'b000) operation = ADDI;
        else operation = NOP;
    end

endmodule