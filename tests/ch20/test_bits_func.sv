/*
:name: test_bits_func
:description: $bits Function Tests
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bits_func.expected
*/
// IEEE 1800-2023 Section 20.6 - $bits Function Tests
module test_bits_func;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        logic [7:0] byte_val;
        logic [15:0] word_val;
        logic [31:0] dword_val;
        int int_val;

        $display("=== IEEE 1800-2023 $bits Function Tests ===");

        $display("Test 1: Byte");
        if ($bits(byte_val) == 8) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", $bits(byte_val)); fail_count++; end

        $display("Test 2: Word");
        if ($bits(word_val) == 16) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", $bits(word_val)); fail_count++; end

        $display("Test 3: DWord");
        if ($bits(dword_val) == 32) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", $bits(dword_val)); fail_count++; end

        $display("Test 4: Int");
        if ($bits(int_val) == 32) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", $bits(int_val)); fail_count++; end

        $display("Test 5: Logic 1");
        begin
            logic single;
            if ($bits(single) == 1) begin $display("Test 5 PASS"); pass_count++; end
            else begin $display("Test 5 FAIL"); fail_count++; end
        end

        $display("Test 6: Logic 4");
        begin
            logic [3:0] nibble;
            if ($bits(nibble) == 4) begin $display("Test 6 PASS"); pass_count++; end
            else begin $display("Test 6 FAIL"); fail_count++; end
        end

        $display("Test 7: Type check");
        if ($bits(logic[3:0]) == 4) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Int type");
        if ($bits(int) == 32) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
