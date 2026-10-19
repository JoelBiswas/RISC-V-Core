  # Final Test Plan

  ## Document information

  | Field | Value |
  | --- | --- |
  | Verification engineer | Joel Biswas |
  | Plan revision | Final |
  | Date | 2026-10-02 |

  ### Revision history

  | Revision | Date | Changes |
  | --- | --- | --- |
  | Initial | 2026-09-21 | Added functional tests 1.1-1.19, constrained random test information, and two assertions |
  | Final | 2026-10-02 | Implemented all tests, constraints, assertions, ran coverage analysis |

  ## 1. Functional tests


  ### Functional-test summary

  | Test ID | Test name | Functionality being tested | Expected result | Status |
  | --- | --- | --- | --- | --- |
  | 1.1 | `ebreak` | Program termination | The program correctly terminates | Completed |
  | 1.2 | `addi_pos` | Addition with positive immediate | Destination registers contain correct sums | Completed |
  | 1.3 |`addi_neg`  |Subtraction with an immediate  | Destination registers contain correct differences | Completed |
  | 1.4 | `add` | Register-to-register addition | Destination registers contain correct sums | Completed |
  | 1.5 | `sub` | Register-to-register subtraction | Destination registers contain correct differences | Completed |
  | 1.6 | `lw` | Load word from data memory | Destination register contains the correct word | Completed |
  | 1.7 | `lw_seq` | Load multiple words from data memory | Destination registers contain the correct words | Completed |
  | 1.8 | `sw` | Write word to data memory | dmem destination contains the correct word | Completed |
  | 1.9 | `sw_seq` | Write multiple words to data memory | dmem destinations contain the correct words | Completed |
  | 1.10 | `beq_taken` | Branch when source registers are equal | Instructions after branch and before branch target are skipped | Completed |
  | 1.11 | `beq_not_taken` | Branch when source registers are not equal | Instructions execute sequentially | Completed |
  | 1.12 | `sll` | Logical shift left | Destination register contains the correctly shifted value | Completed |
  | 1.13 | `srl` | Logical shift right | Destination register contains the correctly shifted value | Completed |
  | 1.14 | `x0_write` | Writing to `x0` | `x0` must remain `0` | Completed |
  | 1.15 | `addi_limits` | Adds maximum and minimum immediate values | Destination registers contain the correct sums | Completed |
  | 1.16 | `shift_zero` | Logical shift with a shift value of `0` | Destination registers contain the correctly un-shifted values | Completed |
  | 1.17 | `shift_large` | Logical shift with values over `31` | Destination registers contain the correctly shifted values | Completed |
  | 1.18 | `store_load` | Store word in data memory and immediately load it into a register | Destination register contains the correctly stored and loaded value | Completed |
  | 1.19 | `arithmetic_chain` | Computes various arithmetic operations in a sequence | Destination registers contain the correct values | Completed |
  | 1.20 | `dsram_write_read` | Writes to dsram through xbar and reads the result | Correct values are written and read in dsram. | Completed |
  | 1.21 | `dsram_write_seq` | Writes to dsram twice through xbar | Correct values are written to dsram. | Completed |
  | 1.22 | `dsram_read_seq` | Reads from dsram twice through xbar | Correct values are read from dsram. | Completed |

  ### Functional-test details

  ### 1.1 — `ebreak`

  **Functionality:** Tests the CPU's ability to terminate a program using the `EBREAK` command

  **Initial state:**

  - Registers: Reset State (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. Place instruction after `EBREAK` to check termination. 

  **Program:**

  ```systemverilog
  prog = '{
    EBREAK_WORD,
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(5))
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0`|
  | `x1` | `32'h00000000` |The add instruction should not run 

  **Pass criteria:** After `EBREAK`, the program ends. `x0` and `x1` must remain `0`.

  **Final result:** PASS: The CPU halted after reaching 'EBREAK', and the following instruction was not executed.

  ### 1.2 — `addi_pos`

  **Functionality:** Tests the CPU's ability to add a positive immediate to a register value and store the result in a register using the `ADDI` command.

  **Initial state:**

  - Registers: Reset State (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`

  **Program:**

  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(5)),
    asm_instr(.op(ADDI), .rd(2), .rs1(1), .imm(4)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0`|
  | `x1` | `32'h00000005` |0 + 5 = 5 |
  | `x2` | `32'h00000009` | 5 + 4 = 9|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `5`, and `x2` contains `9`. `x0` must remain `0`.

  **Final result:** PASS. The CPU produced the expected positive-immediate results.

  ### 1.3 — `addi_neg`

  **Functionality:** Tests the CPU's ability to add a negative immediate to a register value and store the result in a register using the `ADDI` command. This essentially tests subtraction with an immediate.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**

  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(-5)),
    asm_instr(.op(ADDI), .rd(2), .rs1(1), .imm(-4)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'hFFFFFFFB` |0 - 5 = -5 |
  | `x2` | `32'hFFFFFFF7` | -5 - 4 = -9|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `-5`, and `x2` contains `-9`. `x0` must remain `0`.

  **Final result:** PASS. The CPU correctly sign-extended and added negative immediates.

  ### 1.4 — `add`

  **Functionality:** Tests the CPU's ability to perform register-to-register addition and store the result using the `ADD` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(10)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(20)),
    asm_instr(.op(ADD), .rd(3), .rs1(1), .rs2(2)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h0000000A` | 0 + 10 = 10|
  | `x2` | `32'h00000014` | 0 + 20 = 20|
  | `x3` | `32'h0000001E` | 10 + 20 = 30|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `10`, and `x2` contains `20`, and `x3` contains `30`. `x0` must remain `0`.

  **Final result:** PASS. Register-to-register addition produced the expected result.

  ### 1.5 — `sub`

  **Functionality:** Tests the CPU's ability to perform register-to-register subtraction and store the result using the `SUB` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(5)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(4)),
    asm_instr(.op(SUB), .rd(3), .rs1(1), .rs2(2)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000005` | 0 + 5 = 5|
  | `x2` | `32'h00000004` | 0 + 4 = 4|
  | `x3` | `32'h00000001` | 5 - 4 = 1|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `5`, and `x2` contains `4`, and `x3` contains `1`. `x0` must remain `0`.

  **Final result:** PASS. Register-to-register subtraction produced the expected result.

  ### 1.6 — `lw`

  **Functionality:** Tests the CPU's ability to load a word from data memory and store the result in a register using the `LW` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: Memory word at address `0x08` initialized to `0xABCDEF11`
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(LW), .rd(1), .rs1(0), .imm(8)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'hABCDEF11` | `x1` should obtain the value of `dmem[0x08]`|
  | `dmem[0x08]` | `32'hABCDEF11` | `dmem[0x08]` should remain unchanged|

  **Pass criteria:** After `EBREAK`, the program ends and `x1` contains `0xABCDEF11`. `x0` and `dmem[0x08]` must remain unchanged.

  **Final result:** PASS. The CPU loaded the correct word into the register file without modifying memory.
  ### 1.7 — `lw_seq`

  **Functionality:** Tests the CPU's ability to load multiple words from data memory and store the results in multiple registers using the `LW` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: Memory word at address `0x08` initialized to `0xABCDEF11`, `0x0C` initialized to `0x83AB900B`, and `0x10` initialized to `0xBFF739A6`.
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(LW), .rd(1), .rs1(0), .imm(8)),
    asm_instr(.op(LW), .rd(2), .rs1(0), .imm(12)),
    asm_instr(.op(LW), .rd(3), .rs1(0), .imm(16)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'hABCDEF11` | `x1` should obtain the value of `dmem[0x08]`|
  | `x2` | `32'h83AB900B` | `x2` should obtain the value of `dmem[0x0C]`|
  | `x3` | `32'hBFF739A6` | `x3` should obtain the value of `dmem[0x10]`|
  | `dmem[0x08]` | `32'hABCDEF11` | `dmem[0x08]` should remain unchanged|
  | `dmem[0x0C]` | `32'h83AB900B` | `dmem[0x0C]` should remain unchanged|
  | `dmem[0x10]` | `32'hBFF739A6` | `dmem[0x10]` should remain unchanged|

  **Pass criteria:** After `EBREAK`, the program ends and `x1` contains `0xABCDEF11`, `x2` contains `0x83AB900B`, and `x3` contains `0xBFF739A6`. `x0`, `dmem[0x08]`, `dmem[0x0C]`, and `dmem[0x10]` must remain unchanged.

  **Final result:** PASS. All three sequential loads returned the expected memory values.

  ### 1.8 — `sw`

  **Functionality:** Tests the CPU's ability to store a word from a register into data memory using the `SW` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(9)),
    asm_instr(.op(SW), .rs1(0), .rs2(1), .imm(8)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000009` | 0 + 9 = 9|
  | `dmem[0x08]` | `32'h00000009` | `dmem[0x08]` should contain the value of `x1`|

  **Pass criteria:** After `EBREAK`, the program ends and `x1`and `dmem[0x08]` contain `9`. `x0` must remain unchanged.

  **Final result:** PASS. The CPU stored the correct value into memory at the correct address.

  ### 1.9 — `sw_seq`

  **Functionality:** Tests the CPU's ability to store multiple words from registers into data memory using the `SW` command.

  **Initial state:**

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(9)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(25)),
    asm_instr(.op(ADDI), .rd(3), .rs1(0), .imm(14)),
    asm_instr(.op(SW), .rs1(0), .rs2(1), .imm(8)),
    asm_instr(.op(SW), .rs1(0), .rs2(2), .imm(12)),
    asm_instr(.op(SW), .rs1(0), .rs2(3), .imm(16)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000009` | 0 + 9 = 9|
  | `x2` | `32'h00000019` | 0 + 25 = 25|
  | `x3` | `32'h0000000E` | 0 + 14 = 14|
  | `dmem[0x08]` | `32'h00000009` | `dmem[0x08]` should contain the value of `x1`|
  | `dmem[0x0C]` | `32'h00000019` | `dmem[0x0C]` should contain the value of `x2`|
  | `dmem[0x10]` | `32'h0000000E` | `dmem[0x10]` should contain the value of `x3`|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` and `dmem[0x08]` contain `9`, `x2` and `dmem[0x0C]` contain `25`, and `x3` and `dmem[0x10]` contain `14`. `x0` must remain unchanged.

  **Final result:** PASS. All three sequential stores wrote the expected values to their corresponding data-memory locations.

  ### 1.10 — `beq_taken`

  **Functionality:** Tests the CPU's ability to execute instructions at a branch target and skip instructions between the branch and branch target when two registers are equal using the `BEQ` command.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(9)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(9)),
    asm_instr(.op(BEQ), .rs1(1), .rs2(2), .imm(8)),
    asm_instr(.op(ADDI), .rd(3), .rs1(0), .imm(1)),
    asm_instr(.op(ADDI), .rd(4), .rs1(0), .imm(4)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000009` | 0 + 9 = 9|
  | `x2` | `32'h00000009` | 0 + 9 = 9|
  | `x3` | `32'h00000000` | The instruction to change`x3` is skipped|
  | `x4` | `32'h00000004` | 0 + 4 = 4|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` and `x2` contain `9`, and `x4` contains `4`. `x0` and `x3` must remain unchanged.

  **Final result:** PASS. The equal-register branch was taken.
  ### 1.11 — `beq_not_taken`

  **Functionality:** Tests the CPU's ability to execute instructions to not skip instructions when two registers are not equal using the `BEQ` command.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(9)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(5)),
    asm_instr(.op(BEQ), .rs1(1), .rs2(2), .imm(8)),
    asm_instr(.op(ADDI), .rd(3), .rs1(0), .imm(4)),
    asm_instr(.op(ADDI), .rd(4), .rs1(0), .imm(4)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000009` | 0 + 9 = 9|
  | `x2` | `32'h00000005` | 0 + 5 = 5|
  | `x3` | `32'h00000004` | 0 + 4 = 4|
  | `x4` | `32'h00000004` | 0 + 4 = 4|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `9`, `x2` contains `5`, and `x3`and `x4` contain `4`. `x0` must remain unchanged.

  **Final result:** PASS. The unequal-register branch was not taken.
  ### 1.12 — `sll`

  **Functionality:** Tests the CPU's ability to perform a logical left shift with a register value as the shift amount using the `SLL` command.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(17)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(3)),
    asm_instr(.op(SLL), .rd(3), .rs1(1), .rs2(2)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000011` | 0 + 17 = 17|
  | `x2` | `32'h00000003` | 0 + 3 = 3|
  | `x3` | `32'h00000088` | 17 << 3 = 136|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `17`, `x2` contains `3`, and `x3` contains `136`. `x0` must remain unchanged.

  **Final result:** PASS. Logical left shift produced the expected result.
  ### 1.13 — `srl`

  **Functionality:** Tests the CPU's ability to perform a logical right shift with a register value as the shift amount using the `SRL` command.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(132)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(3)),
    asm_instr(.op(SRL), .rd(3), .rs1(1), .rs2(2)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000084` | 0 + 132 = 132|
  | `x2` | `32'h00000003` | 0 + 3 = 3|
  | `x3` | `32'h00000010` | 132 >> 3 = 16|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `132`, `x2` contains `3`, and `x3` contains `16`. `x0` must remain unchanged.

  **Final result:** PASS. Logical right shift produced the expected result.

  ### 1.14 — `x0_write`

  **Functionality:** Tests the CPU's ability to prevent a write to the `x0` register.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(0), .rs1(0), .imm(8)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |

  **Pass criteria:** After `EBREAK`, the program ends. `x0` must remain unchanged.

  **Final result:** PASS. The attempted write to `x0` was ignored.

  ### 1.15 — `addi_limits`

  **Functionality:** Tests the CPU's ability to correctly execute `ADDI` using the maximum and minimum signed 12-bit immediate values, `2047` and `-2048`.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(2047)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(-2048)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h000007FF` | 0 + 2047 = 2047|
  | `x2` | `32'hFFFFF800` | 0 + -2048 = -2048|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `2047`, and `x2` contains `-2048`. `x0` must remain unchanged.

  **Final result:** PASS. The CPU correctly handled the maximum and minimum signed 12-bit immediates.

  ### 1.16 — `shift_zero`

  **Functionality:** Tests the CPU's ability to perform logical left and right shifts with a shift value of `0`.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(10)),
    asm_instr(.op(SLL), .rd(2), .rs1(1), .rs2(0)),
    asm_instr(.op(SRL), .rd(3), .rs1(1), .rs2(0)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h0000000A` | 0 + 10 = 10|
  | `x2` | `32'h0000000A` | 10 << 0 = 10|
  | `x3` | `32'h0000000A` | 10 >> 0 = 10|

  **Pass criteria:** After `EBREAK`, the program ends and `x1`, `x2`, and `x3` all contain `10`. `x0` must remain unchanged.

  **Final result:** PASS. Both zero-amount shifts left the operand unchanged.

  ### 1.17 — `shift_large`

  **Functionality:** Tests the CPU's ability to perform logical left and right shifts with a shift value over `31`. In RISC-V, the lower five bits of the shift value should be used.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(10)),
    asm_instr(.op(ADDI), .rd(2), .rs1(0), .imm(35)),
    asm_instr(.op(SLL), .rd(3), .rs1(1), .rs2(2)),
    asm_instr(.op(SRL), .rd(4), .rs1(1), .rs2(2)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h0000000A` | 0 + 10 = 10|
  | `x2` | `32'h00000023` | 0 + 35 = 35|
  | `x3` | `32'h00000050` | Lower 5 bits of `35` are`0b00011` or `3`; 10 << 3 = 80 |
  | `x4` | `32'h00000001` | Lower 5 bits of `35` are`0b00011` or `3`; 10 >> 3 = 1|

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `10`, `x2` contains `35`, `x3` contains `80`, and `x4` contains `1`. `x0` must remain unchanged.

  **Final result:** PASS. The CPU correctly used the lower five bits of the shift amount.

  ### 1.18 — `store_load`

  **Functionality:** Tests the CPU's ability to store a value to data memory, and then load it.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(10)),
    asm_instr(.op(SW), .rs1(0), .rs2(1), .imm(8)),
    asm_instr(.op(LW), .rd(2), .rs1(0), .imm(8)),
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h0000000A` | 0 + 10 = 10|
  | `x2` | `32'h0000000A` | `x2` loads the value of `dmem[0x08]` |
  | `dmem[0x08]` | `32'h0000000A` | `dmem[0x08]` stores the value in `x1`|

  **Pass criteria:** After `EBREAK`, the program ends and`x1`, `x2`, and `dmem[0x08]` all contain `10`. `x0` must remain unchanged.

  **Final result:** PASS. The CPU stored the correct value to memory and immediately loaded the same value into the register file.

  ### 1.19 — `arithmetic_chain`

  **Functionality:** Tests the CPU's ability to perform a sequence of arithmetic with various registers.

  - Registers: Reset state (all registers initialized to 0)
  - Data memory: none
  - Other setup: Reset CPU before program. End program with `EBREAK`.

  **Program:**


  ```systemverilog
  prog = '{
    asm_instr(.op(ADDI), .rd(1), .rs1(0), .imm(3)), //x1 = 3
    asm_instr(.op(ADDI), .rd(2), .rs1(1), .imm(174)), //x2 = 177
    asm_instr(.op(SLL), .rd(1), .rs1(2), .rs2(1)), //x1 = 1416
    asm_instr(.op(SUB), .rd(2), .rs1(2), .rs2(1)), //x2 = -1,239
    asm_instr(.op(ADDI), .rd(1), .rs1(1), .imm(-1400)), //x1 = 16
    asm_instr(.op(ADDI), .rd(3), .rs1(1), .imm(-14)), //x3 = 2
    asm_instr(.op(SRL), .rd(1), .rs1(1), .rs2(3)), //x1 = 4
    EBREAK_WORD
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `x0` | `32'h00000000` |`x0` must remain `0` |
  | `x1` | `32'h00000004` | 16 >> 2 = 4|
  | `x2` | `32'hFFFFFB29` | 177 - 1416 = -1239 |
  | `x3` | `32'h00000002` | 16 - 14 = 2 |

  **Pass criteria:** After `EBREAK`, the program ends, `x1` contains `4`, `x2` contains `-1239`, and `x3` contains `2`. `x0` must remain unchanged.

  **Final result:** PASS. The complete arithmetic dependency chain produced the expected final values.

  ### 1.20 — `dsram_write_read`

  **Functionality:** Tests writing to and reading from data SRAM (dsram) through the external crossbar interface..

  **Initial state:**

  - Registers: Reset State (all registers initialized to 0)
  - Data memory: No required initial value at the tested address.
  - Other setup: Reset CPU before performing the external crossbar transactions. 

  **Program:**

  ```systemverilog
  prog = '{
    seqr.send_write_trans(14'h1000, 32'hDEADBEEF);
    seqr.send_read_trans (14'h1000);
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `dmem[0x000]` | `32'hDEADBEEF` |Crossbar address 14'h1000 accesses the first word of data SRAM. The write transaction stores 32'hDEADBEEF, and the following read should return the same value.|

  **Pass criteria:** The write transaction successfully writes 32'hDEADBEEF to data SRAM at crossbar address 14'h1000. A subsequent read from the same address must return 32'hDEADBEEF.

  **Final result:** PASS: 32'hDEADBEEF was successfully written to data SRAM through the crossbar and the subsequent read from the same address returned 32'hDEADBEEF.

  ### 1.21 — `dsram_write_seq`

  **Functionality:** Tests back-to-back writes to different data SRAM (dsram) addresses through the external crossbar interface.

  **Initial state:**

  - Registers: Reset State (all registers initialized to 0)
  - Data memory: No required initial values at the tested addresses
  - Other setup: Reset CPU before performing the external crossbar transactions

  **Program:**

  ```systemverilog
  prog = '{
    seqr.send_write_trans(14'h1004, 32'h12345678);
    seqr.send_write_trans(14'h1008, 32'hABCDEF01);
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `dmem[0x001]` | `32'h12345678` | Crossbar address 14'h1004 accesses the second word of data SRAM. |
  | `dmem[0x002]` | `32'hABCDEF01` | Crossbar address 14'h1008 accesses the third word of data SRAM. |

  **Pass criteria:** Both back-to-back write transactions complete successfully. `dmem[0x001]` must contain `32'h12345678`, and `dmem[0x002]` must contain `32'hABCDEF01`.

  **Final result:** PASS: Both back-to-back writes completed successfully, with `32'h12345678` written to `dmem[0x001]` and `32'hABCDEF01` written to `dmem[0x002]`.

  ### 1.22 — `dsram_read_seq`

  **Functionality:** Tests back-to-back reads from different data SRAM (dsram) addresses through the external crossbar interface.

  **Initial state:**

  - Registers: Reset State (all registers initialized to 0)
  - Data memory: 'dmem[0x001]' = `32'h12345678` and `dmem[0x002]` = `32'hABCDEF01`
  - Other setup: The data memory values are initialized by the preceding write transactions.

  **Program:**

  ```systemverilog
  prog = '{
    seqr.send_read_trans(14'h1004);
    seqr.send_read_trans(14'h1008);
  };
  ```

  **Expected result:**

  | Register or memory word | Expected value | Calculation or explanation |
  | --- | --- | --- |
  | `dmem[0x001]` | `32'h12345678` | Reading crossbar address 14'h1004 should return the value previously written to the second word of data SRAM. |
  | `dmem[0x002]` | `32'hABCDEF01` | Reading crossbar address 14'h1008 should return the value previously written to the third word of data SRAM. |

  **Pass criteria:** Both back-to-back read transactions complete successfully. The read from `14'h1004` must return `32'h12345678`, and the read from `14'h1008` must return `32'hABCDEF01`.

  **Final result:** PASS: Both back-to-back reads completed successfully and returned the expected values, `32'h12345678` and `32'hABCDEF01`.

  ## 2. Constrained-random tests  

  ### Instruction constraints


  | Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
  | --- | --- | --- | --- |
  | `c_opcode` | Provided | Restricts generated instructions to valid opcodes | No member change |
  | `c_reg_bias` | Provided | Makes the generated program more likely to use registers `x0-x7` | No member change |
  | `c_imm_range` | Partial | Restricts immediate values to a legal range | Checked if the immediate is between `-4096` and `4094` for the `OP_BEQ` opcode or between `-2048` and `2047` for other immediate based opcodes. |
  | `c_mem_align` | Open | Ensures that memory addresses are word aligned and are a valid location in memory. | Checks if the memory address is divisible by four and that it is between `0` and `(DSRAM_WORDS * 4) - 4`. |
  | `c_imm_unused` | Provided | Restricts immediate generation for commands that don't use immediates | No member change |
  | `c_branch_target` | Partial | Restricts the target of `BEQ` to a valid instruction address | Checks that the immediate value is divisible by `4`, greater than or equal to `4`, and that the branch doesn't point to a target outside of the program. |
  | `c_no_branch_at_end` | Provided | Restricts a branch command from being generated at the end of a program | No member change |
  | `c_branch_taken_bias` | Open | Makes generated program equally likely to take a branch versus not take a branch | Makes it equally likely for  `(reg_snapshot[rs1] == reg_snapshot[rs2]` to be `1` or `0` using `dist`.|

  ### External-port constraints

  | Constraint | Provided, partial, or open | Behavior and purpose | Final implementation summary |
  | --- | --- | --- | --- |
  | `c_align` | Provided | Restricts external memory addresses to be word-aligned | No member change |
  | `c_valid_window` | Partial | Restricts external addresses to only valid windows and valid address locations. | Checks that the address is between `0` and `(ISRAM_WORDS * 4) - 1` for instruction memory transactions, `0` and `(DSRAM_WORDS * 4) - 1)` for memory transactions, and `0` and `(REG_COUNT * 4) - 1)` for register file transactions.|
  | `c_reg_read_only` | Provided | Prevents writing to the register file | No member change |
  | `c_data_corners` | Open | Biases generated data toward corner-case values without eliminating ordinary random 32-bit values. | Increases the chances to generate all zeroes, all ones, and alternating zeroes and ones using `dist`., |

  ### Random-program test

  | Item | Plan |
  | --- | --- |
  | Number of programs per seed | 100 program tests and `30` `xbar` tests |
  | Program-length range | 10-30 |
  | Information logged for reproduction | Numeric `SVSEED`, iteration, and complete generated program |

  **Implementation outline:**

  ```systemverilog
  for (int i = 0; i < NUM_RANDOM_PROGRAMS; i++) begin
      $display(" RANDOM CPU PROGRAM %0d   SEED=%s", i, requested_seed);
      sb.set_test($sformatf("random_cpu_%0d", i));

      drv.reset_task();
      init_memories();  

      seqr.gen_program($urandom_range(10, 30));
      seqr.wait_for_empty();
      repeat (2) @(cpu_if.cb);

      drv.run_program(2000);

      if (drv.last_run_completed) begin
          readback(2, REG_COUNT);
          readback(1, DSRAM_WORDS);
      end else begin
          $display($stime,
                  " TB: Skipping random program %0d readback after timeout\n", i);
          drv.reset_task();
      end
  end

  drv.reset_task();

  for (int i = 0; i < NUM_RANDOM_XBAR; i++) begin
    cpu_xbar_item #(DataSize, AddrSize) trans;
    trans = new();

    trans.randomize();
    
    $display("RANDOM XBAR %0d: addr=0x%04x data=0x%08x write=%0b", i, trans.addr, trans.data, trans.is_write);

    seqr.xbar_box.put(trans);
  end

  seqr.wait_for_empty();
  repeat (4) @(cpu_if.cb);
    ```

  ## 3. Assertions

  ### Assertion summary

  | Assertion ID/name | Behavior checked | When it is sampled/disabled | Activating test |
  | --- | --- | --- | --- |
  | 3.1 / `X0_IS_ZERO` | Checks if register `x0` always contains `0`. | Checked on each rising clock edge. Disabled on reset | All |
  | 3.2 / `PC_WORD_ALIGNED` | Checks if the PC is always a multiple of 4 | Checked on each rising clock edge. Disable on reset | All |

  ### 3.1 — `X0_IS_ZERO`

  **Timing requirement in words:** On every rising edge of the clock, register `x0` must contain `0`. This is disabled when reset is high.

  ```systemverilog
  X0_IS_ZERO:
      assert property (@(posedge clk) disable iff (rst)
          dut.register_crossbar[0] == 32'h00000000)
      else assertion_fail("Register x0 does not contain zero");
  ```

  **Evidence that it detects a violation:** Temporarily modified the register file to allow writes to `x0`. The assertion caight this error with: `ASSERT: Register x0 does not contain zero`.

  ### 3.2 — `PC_WORD_ALIGNED`

  **Timing requirement in words:** On every rising clock edge, the PC must be a multiple of 4. This is disabled when reset is high.

  ```systemverilog
  PC_WORD_ALIGNED:
      assert property (@(posedge clk) disable iff (rst)
          dut.cpu.current_pc[1:0] == 2'b00)
      else assertion_fail("The current PC is not word-aligned");
  ```

  **Evidence that it detects a violation:** Temporarily modified `fetch.sv` to increment the program counter by `2` instead of `4`. The assertion caught this error with: `ASSERT: The current PC is not word-aligned`.