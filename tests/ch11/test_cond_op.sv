/*
:name: test_cond_op
:description: Conditional Operator Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cond_op.expected
*/
// IEEE 1800-2023 Section 11.4.11 - Conditional Operator Tests
module test_cond_op;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int a, b, result;
        logic flag;

        $display("=== IEEE 1800-2023 Conditional Operator Tests ===");

        $display("Test 1: True cond");
        a = 10;
        b = 20;
        result = (a < b) ? a : b;
        if (result == 10) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", result); fail_count++; end

        $display("Test 2: False cond");
        result = (a > b) ? a : b;
        if (result == 20) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", result); fail_count++; end

        $display("Test 3: Equal cond");
        a = 5;
        b = 5;
        result = (a == b) ? 100 : 200;
        if (result == 100) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", result); fail_count++; end

        $display("Test 4: Not equal cond");
        result = (a != b) ? 100 : 200;
        if (result == 200) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", result); fail_count++; end

        $display("Test 5: Nested cond");
        a = 15;
        result = (a < 10) ? 1 : (a < 20) ? 2 : 3;
        if (result == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", result); fail_count++; end

        $display("Test 6: Logic flag");
        flag = 1'b1;
        result = flag ? 50 : 60;
        if (result == 50) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", result); fail_count++; end

        $display("Test 7: Zero flag");
        flag = 1'b0;
        result = flag ? 50 : 60;
        if (result == 60) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", result); fail_count++; end

        $display("Test 8: Expression cond");
        a = 8;
        result = ((a % 2) == 0) ? 1 : 0;
        if (result == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", result); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
