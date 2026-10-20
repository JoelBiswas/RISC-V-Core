/*
 * Top-level testbench
 */
module cpu_tb_top;

    import cpu_tb_pkg::*;

    parameter int DataSize = DATA_W;
    parameter int AddrSize = XBAR_AW;

    string requested_seed = "default";

    int assertion_errors = 0;

    logic clk = 0;
    always #5 clk = ~clk;

    // IF instantiation
    cpu_if #(.DataSize(DataSize), .AddrSize(AddrSize)) cpu_if(.clk(clk));

    // DUT instantiation
    chip_top dut (
        .clk_i(clk),
        .rst_i(cpu_if.cpu.reset),
        .en_cpu_i(cpu_if.cpu.en_cpu),
        .halt_cpu_i(cpu_if.cpu.halt_cpu),
        .cpu_halted_o(cpu_if.cpu.cpu_halted),
        .addr_i(cpu_if.cpu.addr),
        .wdata_i(cpu_if.cpu.wdata),
        .w_en_i(cpu_if.cpu.w_en),
        .r_en_i(cpu_if.cpu.r_en),
        .rdata_o(cpu_if.cpu.rdata),
        .rready_o(cpu_if.cpu.rready)
    );

    // Observation signals from the DUT memory path
    assign cpu_if.cpu_active     = dut.cpu_enable_q;
    assign cpu_if.dsram_en       = dut.dsram_en;
    assign cpu_if.dsram_write_en = dut.dsram_write_en;
    assign cpu_if.dsram_addr     = dut.dsram_addr;
    assign cpu_if.dsram_wdata    = dut.dsram_wdata;
    assign cpu_if.dsram_rdata    = dut.dsram_rdata;
    assign cpu_if.dsram_rready   = dut.dsram_rready;

    cpu_tb_pkg::cpu_sequencer #(.DataSize(DataSize), .AddrSize(AddrSize)) seqr;
    cpu_tb_pkg::cpu_driver #(.DataSize(DataSize), .AddrSize(AddrSize))    drv;
    cpu_tb_pkg::cpu_monitor #(.DataSize(DataSize), .AddrSize(AddrSize))   mon;
    cpu_tb_pkg::cpu_sb #(.DataSize(DataSize), .AddrSize(AddrSize))        sb;

    // Reference model registers exposed to SimVision
    logic [31:0] ref_regs_wave [REG_COUNT];

    always @(negedge clk) begin
        if (sb != null && sb.ref_model != null) begin
            for (int i = 0; i < REG_COUNT; i++) begin
                ref_regs_wave[i] = sb.ref_model.regs[i];
            end
        end
    end

    // Record failed assertion
    function void assertion_fail(input string message);
        assertion_errors++;
        $error($stime, " ASSERT: %s\n", message);
    endfunction: assertion_fail

    // Initialize both memories through the DUT's external memory port
    task automatic init_memories();
        $display($stime, " TB: Initializing instruction and data memories\n");
        mon.log_transactions = 1'b0;
        sb.log_transactions = 1'b0;
        for (int i = 0; i < ISRAM_WORDS; i++) begin
            seqr.send_write_trans(word_addr(ISRAM_BASE, i), EBREAK_WORD);
        end
        for (int i = 0; i < DSRAM_WORDS; i++) begin
            seqr.send_write_trans(word_addr(DSRAM_BASE, i), $urandom());
        end
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        mon.log_transactions = 1'b1;
        sb.log_transactions = 1'b1;
        $display($stime, " TB: Memory initialization complete\n");
    endtask: init_memories

    // Queue external reads on a memory window
    task automatic readback(input int window, input int num_words, input int start_word=0);
        logic [AddrSize-1:0] base;

        case (window)
            0: base = ISRAM_BASE;
            1: base = DSRAM_BASE;
            2: base = REG_BASE;
            default: base = REG_BASE;
        endcase

        for (int i = 0; i < num_words; i++) begin
            seqr.send_read_trans(word_addr(base, start_word + i));
        end
        seqr.wait_for_empty();
        repeat (4) @(cpu_if.cb);
    endtask: readback

    task automatic preload_dmem(input logic [31:0] values [$], input int start_word=0);
        foreach (values[i]) begin
            seqr.send_write_trans(word_addr(DSRAM_BASE, start_word + i), values[i]);
        end
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
    endtask: preload_dmem

    // Run a directed test
    task automatic run_directed(input string name, const ref logic [31:0] program_words [$],
            input int max_cycles=2000, input int dmem_words=16);
        $display("");
        $display("=================================================================");
        $display(" TEST: %s", name);
        $display("=================================================================");
        sb.set_test(name);

        drv.reset_task();
        seqr.load_program(program_words);
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        drv.run_program(max_cycles);

        if (drv.last_run_completed) begin
            readback(2, REG_COUNT);
            readback(1, dmem_words);
        end else begin
            $display($stime, " TB: Skipping %s readback after CPU timeout\n", name);
            drv.reset_task();
        end
    endtask: run_directed

    // Basic smoke test for loading, running, and observing a program that halts
    task automatic run_smoke_test();
        logic [31:0] smoke_prog [$];
        smoke_prog = '{ EBREAK_WORD };
        run_directed("smoke_ebreak", smoke_prog, 100, 1);
    endtask: run_smoke_test

    // Smoke test for stopping the CPU from outside the program
    // Readback is skipped because the CPU stops before the program completes
    task automatic run_external_halt_smoke();
        logic [31:0] long_prog [$];

        for (int i = 0; i < 32; i++) begin
            long_prog.push_back(asm_instr(.op(OP_ADDI), .rd(1), .rs1(1), .imm(1)));
        end
        long_prog.push_back(EBREAK_WORD);

        $display("");
        $display("=================================================================");
        $display(" TEST: smoke_external_halt");
        $display("=================================================================");
        sb.set_test("smoke_external_halt");

        drv.reset_task();
        seqr.load_program(long_prog);
        seqr.wait_for_empty();
        repeat (2) @(cpu_if.cb);
        drv.start_cpu();
        repeat (12) @(cpu_if.cb);
        drv.halt_cpu_now();
        drv.reset_task();
    endtask: run_external_halt_smoke

    

    // TEST PROGRAM
    logic [31:0] prog [$];
    logic [31:0] data [$];

    int NUM_RANDOM_PROGRAMS = 100;
    int NUM_RANDOM_XBAR = 30;

    initial begin
        int total_errors;

        mon = new(cpu_if);
        sb = new(mon.mon_box);
        seqr = new();
        drv = new(cpu_if, seqr.xbar_box);

        void'($value$plusargs("NUM_RANDOM_PROGRAMS=%d", NUM_RANDOM_PROGRAMS));
        void'($value$plusargs("NUM_RANDOM_XBAR=%d", NUM_RANDOM_XBAR));
        if ($test$plusargs("REF_TRACE")) begin
            sb.ref_model.trace = 1'b1;
        end

        fork
            mon.run();
            sb.run();
            drv.run();
        join_none



        drv.reset_task();
        init_memories();

        run_smoke_test();
        run_external_halt_smoke();


        // DIRECTED TESTS
        drv.reset_task();
        init_memories();

        
        // Example Test: addi with a positive immediate
        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(100)),
            EBREAK_WORD
        };
        run_directed("addi_positive", prog);

        prog = '{
            EBREAK_WORD,
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5))
        };
        run_directed("ebreak", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(4)),
            EBREAK_WORD
        };
        run_directed("addi_pos", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(-5)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(-4)),
            EBREAK_WORD
        };
        run_directed("addi_neg", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(20)),
            asm_instr(.op(OP_ADD), .rd(3), .rs1(1), .rs2(2)),
            EBREAK_WORD
        };
        run_directed("add", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(5)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(4)),
            asm_instr(.op(OP_SUB), .rd(3), .rs1(1), .rs2(2)),
            EBREAK_WORD
        };
        run_directed("sub", prog);

        prog = '{
            asm_instr(.op(OP_LW), .rd(1), .rs1(0), .imm(8)),
            EBREAK_WORD
        };
        run_directed("lw", prog);

        prog = '{
            asm_instr(.op(OP_LW), .rd(1), .rs1(0), .imm(8)),
            asm_instr(.op(OP_LW), .rd(2), .rs1(0), .imm(12)),
            asm_instr(.op(OP_LW), .rd(3), .rs1(0), .imm(16)),
            EBREAK_WORD
        };
        run_directed("lw_seq", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(9)),
            asm_instr(.op(OP_SW), .rs1(0), .rs2(1), .imm(8)),
            EBREAK_WORD
        };
        run_directed("sw", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(9)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(25)),
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(14)),
            asm_instr(.op(OP_SW), .rs1(0), .rs2(1), .imm(8)),
            asm_instr(.op(OP_SW), .rs1(0), .rs2(2), .imm(12)),
            asm_instr(.op(OP_SW), .rs1(0), .rs2(3), .imm(16)),
            EBREAK_WORD
        };
        run_directed("sw_seq", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(9)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(9)),
            asm_instr(.op(OP_BEQ), .rs1(1), .rs2(2), .imm(8)),
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(1)),
            asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(4)),
            EBREAK_WORD
        };
        run_directed("beq_taken", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(9)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(5)),
            asm_instr(.op(OP_BEQ), .rs1(1), .rs2(2), .imm(8)),
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(0), .imm(4)),
            asm_instr(.op(OP_ADDI), .rd(4), .rs1(0), .imm(4)),
            EBREAK_WORD
        };
        run_directed("beq_not_taken", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(17)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(3)),
            asm_instr(.op(OP_SLL), .rd(3), .rs1(1), .rs2(2)),
            EBREAK_WORD
        };
        run_directed("sll", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(132)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(3)),
            asm_instr(.op(OP_SRL), .rd(3), .rs1(1), .rs2(2)),
            EBREAK_WORD
        };
        run_directed("srl", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(0), .rs1(0), .imm(8)),
            EBREAK_WORD
        };
        run_directed("x0_write", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(2047)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(-2048)),
            EBREAK_WORD
        };
        run_directed("addi_limits", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
            asm_instr(.op(OP_SLL), .rd(2), .rs1(1), .rs2(0)),
            asm_instr(.op(OP_SRL), .rd(3), .rs1(1), .rs2(0)),
            EBREAK_WORD
        };
        run_directed("shift_zero", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(0), .imm(35)),
            asm_instr(.op(OP_SLL), .rd(3), .rs1(1), .rs2(2)),
            asm_instr(.op(OP_SRL), .rd(4), .rs1(1), .rs2(2)),
            EBREAK_WORD
        };
        run_directed("shift_large", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(10)),
            asm_instr(.op(OP_SW), .rs1(0), .rs2(1), .imm(8)),
            asm_instr(.op(OP_LW), .rd(2), .rs1(0), .imm(8)),
            EBREAK_WORD
        };
        run_directed("store_load", prog);

        prog = '{
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(0), .imm(3)), //x1 = 3
            asm_instr(.op(OP_ADDI), .rd(2), .rs1(1), .imm(174)), //x2 = 177
            asm_instr(.op(OP_SLL), .rd(1), .rs1(2), .rs2(1)), //x1 = 1416
            asm_instr(.op(OP_SUB), .rd(2), .rs1(2), .rs2(1)), //x2 = -1,239
            asm_instr(.op(OP_ADDI), .rd(1), .rs1(1), .imm(-1400)), //x1 = 16
            asm_instr(.op(OP_ADDI), .rd(3), .rs1(1), .imm(-14)), //x3 = 2
            asm_instr(.op(OP_SRL), .rd(1), .rs1(1), .rs2(3)), //x1 = 4
            EBREAK_WORD
        };
        run_directed("arithmetic_chain", prog);

        // Directed Xbar tests
        sb.set_test("directed_xbar");

        // Test 1: DSRAM write -> read same address
        seqr.send_write_trans(14'h1000, 32'hDEADBEEF);
        seqr.send_read_trans (14'h1000);

        // Test 2: Back-to-back writes
        seqr.send_write_trans(14'h1004, 32'h12345678);
        seqr.send_write_trans(14'h1008, 32'hABCDEF01);

        // Test 3: Back-to-back reads
        seqr.send_read_trans(14'h1004);
        seqr.send_read_trans(14'h1008);

        // Wait until driver processes everything
        seqr.wait_for_empty();
        repeat (4) @(cpu_if.cb);

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

        // TEST FINISH
        repeat (20) @(cpu_if.cb);
        total_errors = sb.errors + drv.timeouts + mon.errors + assertion_errors;
        if (sb.checks == 0) begin
            $error("Testbench performed zero checks; no results were verified");
        end

        $display("=================================================================");
        $display("  Scoreboard mismatches : %0d", sb.errors);
        $display("  Driver timeouts       : %0d", drv.timeouts);
        $display("  Monitor protocol errs : %0d", mon.errors);
        $display("  Assertion failures    : %0d", assertion_errors);
        $display("=================================================================");
        $display();

        if (total_errors == 0) begin
            $display("=================================================================");
            $display(" TEST PASSED!");
            $display("=================================================================");
        end else begin
            $display("=================================================================");
            $display(" TEST FAILED: %0d error(s)", total_errors);
            $display("=================================================================");
        end
        $finish;
    end

    // Stop a broken DUT or testbench instead of letting the simulation run forever
    initial begin
        #10ms;
        $display(" TEST FAILED - global timeout");
        $fatal(1, "global timeout");
    end

    initial begin
        void'($value$plusargs("SEED_LABEL=%s", requested_seed));
        $shm_open("waves.shm");
        $shm_probe("ASM");
    end

    wire rst = cpu_if.reset;

    X0_IS_ZERO:
        assert property (@(posedge clk) disable iff (rst)
            dut.register_crossbar[0] == 32'h00000000)
        else assertion_fail("Register x0 does not contain zero");

    PC_WORD_ALIGNED:
        assert property (@(posedge clk) disable iff (rst)
            dut.cpu.current_pc[1:0] == 2'b00)
        else assertion_fail("The current PC is not word-aligned");

    // Example assertion
    // It checks one interface rule and sends failures through the testbench counter
    NO_SIMULTANEOUS_READ_WRITE:
        assert property (@(posedge clk) disable iff (rst)
            !(cpu_if.w_en && cpu_if.r_en))
        else assertion_fail("w_en_i and r_en_i were asserted together");



endmodule: cpu_tb_top
