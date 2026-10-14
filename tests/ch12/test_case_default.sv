/*
:name: test_case_default
:description: Case Default Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_default.expected
*/
// IEEE 1800-2023 Section 12.5 - Case Default Tests
module test_case_default;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int decode(int sel);
        case (sel)
            0: return 100;
            1: return 200;
            2: return 300;
            default: return -1;
        endcase
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 Case Default Tests ===");

        // Test 1: Case 0
        $display("Test 1: Case 0");
        result = decode(0);
        if (result == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        // Test 2: Case 1
        $display("Test 2: Case 1");
        result = decode(1);
        if (result == 200) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        // Test 3: Case 2
        $display("Test 3: Case 2");
        result = decode(2);
        if (result == 300) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        // Test 4: Default 3
        $display("Test 4: Default 3");
        result = decode(3);
        if (result == -1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        // Test 5: Default neg
        $display("Test 5: Default neg");
        result = decode(-1);
        if (result == -1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        // Test 6: Default large
        $display("Test 6: Default large");
        result = decode(100);
        if (result == -1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        // Test 7: Sequential
        $display("Test 7: Sequential");
        result = decode(0) + decode(1);
        if (result == 300) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        // Test 8: All valid
        $display("Test 8: All valid");
        result = decode(0) + decode(1) + decode(2);
        if (result == 600) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
