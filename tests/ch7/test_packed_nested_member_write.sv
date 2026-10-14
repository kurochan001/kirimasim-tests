/*
:name: test_packed_nested_member_write
:description: 7.3 Packed Nested Member Write Test
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1 7.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_nested_member_write.expected
*/
// IEEE 1800-2023 §7.2-7.3 Packed Nested Member Write Test

module test_packed_nested_member_write;
    // Define a packed union with nested struct members
    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] high;
            logic [15:0] low;
        } halves;
        struct packed {
            logic [7:0] byte3;
            logic [7:0] byte2;
            logic [7:0] byte1;
            logic [7:0] byte0;
        } bytes;
    } packet_t;

    packet_t data;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Packed Nested Member Write Test (IEEE 1800-2023 §7.2-7.3) ===");

        // Test 1: Initialize via word member
        data.word = 32'hDEADBEEF;
        if (data.word == 32'hDEADBEEF) begin
            $display("PASS: data.word = 0x%h", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0xDEADBEEF", data.word);
            failed++;
        end

        // Test 2: Read nested members (should work as before)
        if (data.halves.high == 16'hDEAD && data.halves.low == 16'hBEEF) begin
            $display("PASS: data.halves = (0x%h, 0x%h)", data.halves.high, data.halves.low);
            passed++;
        end else begin
            $display("FAIL: data.halves = (0x%h, 0x%h), expected (0xDEAD, 0xBEEF)",
                     data.halves.high, data.halves.low);
            failed++;
        end

        // Test 3: Write to nested member (halves.low)
        data.halves.low = 16'h1234;
        if (data.word == 32'hDEAD1234) begin
            $display("PASS: data.word = 0x%h after halves.low write", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0xDEAD1234", data.word);
            failed++;
        end

        // Test 4: Write to nested member (halves.high)
        data.halves.high = 16'h5678;
        if (data.word == 32'h56781234) begin
            $display("PASS: data.word = 0x%h after halves.high write", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0x56781234", data.word);
            failed++;
        end

        // Test 5: Write to bytes nested member
        data.bytes.byte3 = 8'hAA;
        if (data.word == 32'hAA781234) begin
            $display("PASS: data.word = 0x%h after bytes.byte3 write", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0xAA781234", data.word);
            failed++;
        end

        // Test 6: Write all bytes
        data.bytes.byte3 = 8'h11;
        data.bytes.byte2 = 8'h22;
        data.bytes.byte1 = 8'h33;
        data.bytes.byte0 = 8'h44;
        if (data.word == 32'h11223344) begin
            $display("PASS: data.word = 0x%h after all bytes write", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0x11223344", data.word);
            failed++;
        end

        // Test 7: Verify halves view after bytes write
        if (data.halves.high == 16'h1122 && data.halves.low == 16'h3344) begin
            $display("PASS: data.halves = (0x%h, 0x%h) after bytes write",
                     data.halves.high, data.halves.low);
            passed++;
        end else begin
            $display("FAIL: data.halves = (0x%h, 0x%h), expected (0x1122, 0x3344)",
                     data.halves.high, data.halves.low);
            failed++;
        end

        $display("");
        $display("=== Results: %0d passed, %0d failed ===", passed, failed);

        if (failed == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
