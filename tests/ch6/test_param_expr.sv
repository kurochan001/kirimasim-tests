/*
:name: test_param_expr
:description: Parameter Expression Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_param_expr.expected
*/
// IEEE 1800-2023 Section 6.20 - Parameter Expression Tests
module test_param_expr;
    int pass_count = 0;
    int fail_count = 0;
    
    parameter A = 5;
    parameter B = 3;
    parameter SUM = A + B;
    parameter PROD = A * B;
    parameter DIFF = A - B;
    parameter MAX = (A > B) ? A : B;
    parameter WIDTH = $clog2(256);

    initial begin
        $display("=== IEEE 1800-2023 Parameter Expression Tests ===");

        // Test 1: A value
        $display("Test 1: A value");
        if (A == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", A); fail_count++; end

        // Test 2: B value
        $display("Test 2: B value");
        if (B == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", B); fail_count++; end

        // Test 3: SUM
        $display("Test 3: SUM");
        if (SUM == 8) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", SUM); fail_count++; end

        // Test 4: PROD
        $display("Test 4: PROD");
        if (PROD == 15) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", PROD); fail_count++; end

        // Test 5: DIFF
        $display("Test 5: DIFF");
        if (DIFF == 2) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", DIFF); fail_count++; end

        // Test 6: MAX
        $display("Test 6: MAX");
        if (MAX == 5) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", MAX); fail_count++; end

        // Test 7: WIDTH (clog2)
        $display("Test 7: WIDTH");
        if (WIDTH == 8) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", WIDTH); fail_count++; end

        // Test 8: Expression
        $display("Test 8: Expression");
        if (A * B + 1 == 16) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", A * B + 1); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
