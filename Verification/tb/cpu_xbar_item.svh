/*
 * Transaction for the DUT's external memory port.
 * The driver and monitor use to interact with the DUT.
 */
class cpu_xbar_item #(int DataSize=32, int AddrSize=14);

    // The monitor creates CPU events while the sequencer creates external requests
    trans_kind_e kind;                 // Type of observed or requested transaction

    // Fields randomized for external memory access
    rand logic [AddrSize-1:0] addr;          // External memory address
    rand logic [DataSize-1:0] data;          // Write data or captured read data
    rand logic                is_write;      // Selects a write instead of a read

    // Keep requests aligned to whole words
    constraint c_align {
        addr[1:0] == 2'b00;
    }

    //Makes sure that the address points to a valid window, and a valid location inside that window.
    constraint c_valid_window {
        addr[13:12] inside {2'b00, 2'b01, 2'b10};
        (addr[13:12] == 2'b00) -> addr[11:0] inside {[12'h0 : (ISRAM_WORDS * 4) - 1]};
        (addr[13:12] == 2'b01) -> addr[11:0] inside {[12'h0 : (DSRAM_WORDS * 4) - 1]};
        (addr[13:12] == 2'b10) -> addr[11:0] inside {[12'h0 : (REG_COUNT * 4) - 1]};
    }

    // The register file can be read but not written through this port
    constraint c_reg_read_only {
        (addr[13:12] == 2'b10) -> is_write == 1'b0;
    }

    //Biases random generation towards corner-cases, such as all zeroes and all ones
    constraint c_data_corners {
        data dist {
            32'h00000000 := 5,  // all zeros
            32'hFFFFFFFF := 5,  // all ones
            32'hAAAAAAAA := 3,  // alternating 1010...
            32'h55555555 := 3,  // alternating 0101...
            [32'h00000000 : 32'hFFFFFFFF] :/ 84
        };
    }

    // Constructor
    function new();
        kind = XBAR_WRITE;
        addr = '0;
        data = '0;
        is_write = 1'b0;
    endfunction: new

    function void post_randomize();
        kind = is_write ? XBAR_WRITE : XBAR_READ;
    endfunction: post_randomize

    // Word index inside the selected memory window
    function logic [9:0] word_index();
        return addr[11:2];
    endfunction: word_index

    function xbar_win_e get_window();
        return window_of(addr);
    endfunction: get_window

    function void display();
        $display($stime, " Xbar: %s %s Addr: 0x%0x, Data: 0x%08x\n",
            kind.name(), get_window().name(), addr, data);
    endfunction: display

endclass: cpu_xbar_item