/*
:name: test_if_else_chain
:description: If-Else Chain Tests
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_chain.expected
*/
// IEEE 1800-2023 Section 12.4 - If-Else Chain Tests
module test_if_else_chain;
    int pass_count = 0;
    int fail_count = 0;

    function automatic int grade(int score);
        if (score >= 90) return 4;
        else if (score >= 80) return 3;
        else if (score >= 70) return 2;
        else if (score >= 60) return 1;
        else return 0;
    endfunction

    initial begin
        int result;

        $display("=== IEEE 1800-2023 If-Else Chain Tests ===");

        $display("Test 1: Grade A");
        result = grade(95);
        if (result == 4) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: Grade B");
        result = grade(85);
        if (result == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Grade C");
        result = grade(75);
        if (result == 2) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Grade D");
        result = grade(65);
        if (result == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Grade F");
        result = grade(50);
        if (result == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Boundary 90");
        result = grade(90);
        if (result == 4) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Boundary 80");
        result = grade(80);
        if (result == 3) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Max score");
        result = grade(100);
        if (result == 4) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
