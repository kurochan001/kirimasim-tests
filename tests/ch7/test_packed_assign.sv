/*
:name: test_packed_assign
:description: Test: Packed array/struct assignment
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1 7.2.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_assign.expected
*/
// Test: Packed array/struct assignment

module test_packed_assign;
    int pass_count = 0;
    int total_tests = 15;

    // Packed arrays
    logic [3:0][7:0] packed_arr;  // 32-bit packed array of 4 bytes
    logic [1:0][15:0] word_arr;   // 32-bit packed array of 2 words
    logic [7:0][3:0] nibble_arr;  // 32-bit packed array of 8 nibbles

    // Packed structs
    typedef struct packed {
        logic [7:0] opcode;
        logic [7:0] src;
        logic [7:0] dst;
        logic [7:0] data;
    } instruction_t;

    typedef struct packed {
        logic valid;
        logic [6:0] tag;
        logic [23:0] payload;
    } packet_t;

    // Nested packed struct
    typedef struct packed {
        logic [3:0] flags;
        logic [11:0] addr;
    } header_t;

    typedef struct packed {
        header_t hdr;
        logic [15:0] data;
    } frame_t;

    instruction_t instr;
    packet_t pkt;
    frame_t frame;
    logic [31:0] raw32;
    logic [15:0] raw16;

    initial begin
        // Test 1: Packed array whole assignment
        packed_arr = 32'hDEADBEEF;
        if (packed_arr == 32'hDEADBEEF) begin
            pass_count++;
            $display("PASS: Packed array whole assignment");
        end else $display("FAIL: Packed array whole assignment");

        // Test 2: Packed array element access
        if (packed_arr[0] == 8'hEF && packed_arr[3] == 8'hDE) begin
            pass_count++;
            $display("PASS: Packed array element read");
        end else $display("FAIL: Packed array element read, [0]=%h [3]=%h", packed_arr[0], packed_arr[3]);

        // Test 3: Packed array element assignment
        packed_arr[1] = 8'hAA;
        if (packed_arr[1] == 8'hAA) begin
            pass_count++;
            $display("PASS: Packed array element assignment");
        end else $display("FAIL: Packed array element assignment");

        // Test 4: Packed struct whole assignment
        instr = 32'h12345678;
        if (instr == 32'h12345678) begin
            pass_count++;
            $display("PASS: Packed struct whole assignment");
        end else $display("FAIL: Packed struct whole assignment");

        // Test 5: Packed struct field read
        if (instr.opcode == 8'h12 && instr.data == 8'h78) begin
            pass_count++;
            $display("PASS: Packed struct field read");
        end else $display("FAIL: Packed struct field read, opcode=%h data=%h", instr.opcode, instr.data);

        // Test 6: Packed struct field assignment
        instr.opcode = 8'hAB;
        instr.dst = 8'hCD;
        if (instr.opcode == 8'hAB && instr.dst == 8'hCD) begin
            pass_count++;
            $display("PASS: Packed struct field assignment");
        end else $display("FAIL: Packed struct field assignment");

        // Test 7: Packed struct aggregate
        instr = '{opcode: 8'h01, src: 8'h02, dst: 8'h03, data: 8'h04};
        if (instr.opcode == 8'h01 && instr.src == 8'h02) begin
            pass_count++;
            $display("PASS: Packed struct aggregate");
        end else $display("FAIL: Packed struct aggregate");

        // Test 8: Packed struct with single-bit field
        pkt.valid = 1;
        pkt.tag = 7'h5A;
        pkt.payload = 24'hCAFE00;
        if (pkt.valid == 1 && pkt.tag == 7'h5A) begin
            pass_count++;
            $display("PASS: Packed struct single-bit field");
        end else $display("FAIL: Packed struct single-bit field");

        // Test 9: Nested packed struct
        frame.hdr.flags = 4'hA;
        frame.hdr.addr = 12'h123;
        frame.data = 16'hBEEF;
        if (frame.hdr.flags == 4'hA && frame.data == 16'hBEEF) begin
            pass_count++;
            $display("PASS: Nested packed struct field");
        end else $display("FAIL: Nested packed struct field");

        // Test 10: Nested packed struct whole sub-struct
        frame.hdr = 16'hF000;
        if (frame.hdr.flags == 4'hF && frame.hdr.addr == 12'h000) begin
            pass_count++;
            $display("PASS: Nested packed sub-struct whole");
        end else $display("FAIL: Nested packed sub-struct whole");

        // Test 11: Packed to unpacked conversion
        raw32 = packed_arr;
        if (raw32[7:0] == packed_arr[0]) begin
            pass_count++;
            $display("PASS: Packed to unpacked conversion");
        end else $display("FAIL: Packed to unpacked conversion");

        // Test 12: Word packed array
        word_arr = 32'hABCD1234;
        if (word_arr[0] == 16'h1234 && word_arr[1] == 16'hABCD) begin
            pass_count++;
            $display("PASS: Word packed array");
        end else $display("FAIL: Word packed array, [0]=%h [1]=%h", word_arr[0], word_arr[1]);

        // Test 13: Nibble packed array
        nibble_arr = 32'h12345678;
        if (nibble_arr[0] == 4'h8 && nibble_arr[7] == 4'h1) begin
            pass_count++;
            $display("PASS: Nibble packed array");
        end else $display("FAIL: Nibble packed array, [0]=%h [7]=%h", nibble_arr[0], nibble_arr[7]);

        // Test 14: Packed array slice
        raw16 = packed_arr[1:0];  // Lower 16 bits (2 bytes)
        if (raw16 == {packed_arr[1], packed_arr[0]}) begin
            pass_count++;
            $display("PASS: Packed array slice");
        end else $display("FAIL: Packed array slice");

        // Test 15: Packed struct to raw
        raw32 = instr;
        if (raw32 == {instr.opcode, instr.src, instr.dst, instr.data}) begin
            pass_count++;
            $display("PASS: Packed struct to raw");
        end else $display("FAIL: Packed struct to raw");

        if (pass_count == total_tests) $display("PASS: packed_assign (%0d/%0d)", pass_count, total_tests);

        else $display("FAIL: packed_assign (%0d/%0d)", pass_count, total_tests);
        $finish;
    end
endmodule
