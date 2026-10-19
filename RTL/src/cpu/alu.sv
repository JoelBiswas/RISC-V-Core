import cpu_pkg::*;

module alu (
    input logic [31:0] in1,
    input logic [31:0] in2,
    input instr_type_e operation,

    output logic [31:0] result
);

    always_comb begin
        case (operation)
            ADD: result = in1 + in2;
            ADDI: result = in1 + in2;
            SUB: result = in1 - in2;
            SRL: result = in1 >> in2[4:0]; //Only last 5 bits are used
            SLL: result = in1 << in2[4:0];
            LOAD: result = in1 + in2;
            STORE: result = in1 + in2;
            BEQ: result = in1 + in2;
            default: result = 0;
        endcase
    end

endmodule

// have alu calculate next_pc (current pc + decoder immediate)
//Set next pc to alu output