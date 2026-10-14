/*
:name: test_packed_union_struct_member
:description: Packed union with a struct member: reading and writing through both views (IEEE 1800-2023 Section 7.3.1)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_union_struct_member.expected
*/
// IEEE 1800-2023 §7.3 Packed Union Basic Member Access Test

module test_packed_union_struct_member;
    // Define a simple packed union with scalar members
    typedef union packed {
        logic [31:0] word;
        struct packed {
            logic [15:0] high;
            logic [15:0] low;
        } halves;
    } packet_t;

    packet_t data;
    int passed = 0;
    int failed = 0;

    initial begin
        $display("=== Packed Union Basic Member Access Test (IEEE 1800-2023 §7.3) ===");

        // Test 1: Initialize via word member
        data.word = 32'hDEADBEEF;
        if (data.word == 32'hDEADBEEF) begin
            $display("PASS: data.word = 0x%h", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0xDEADBEEF", data.word);
            failed++;
        end

        // Test 2: Read via halves struct (nested member read)
        if (data.halves.high == 16'hDEAD) begin
            $display("PASS: data.halves.high = 0x%h", data.halves.high);
            passed++;
        end else begin
            $display("FAIL: data.halves.high = 0x%h, expected 0xDEAD", data.halves.high);
            failed++;
        end

        if (data.halves.low == 16'hBEEF) begin
            $display("PASS: data.halves.low = 0x%h", data.halves.low);
            passed++;
        end else begin
            $display("FAIL: data.halves.low = 0x%h, expected 0xBEEF", data.halves.low);
            failed++;
        end

        // Test 3: Write via word member again
        data.word = 32'h12345678;
        if (data.word == 32'h12345678) begin
            $display("PASS: data.word = 0x%h after second assignment", data.word);
            passed++;
        end else begin
            $display("FAIL: data.word = 0x%h, expected 0x12345678", data.word);
            failed++;
        end

        // Test 4: Verify halves view updated
        if (data.halves.high == 16'h1234 && data.halves.low == 16'h5678) begin
            $display("PASS: data.halves = (0x%h, 0x%h) after word update", data.halves.high, data.halves.low);
            passed++;
        end else begin
            $display("FAIL: data.halves = (0x%h, 0x%h), expected (0x1234, 0x5678)", data.halves.high, data.halves.low);
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
