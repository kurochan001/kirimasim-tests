/*
:name: test_arith_ops
:description: Test for arithmetic operations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_arith_ops.expected
*/
// Test for arithmetic operations
// IEEE 1800-2023 §11.4

module test_arith_ops;
    int a, b, result;
    real r1, r2, r_result;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Addition
        test_count++;
        a = 10;
        b = 20;
        result = a + b;
        if (result == 30) begin
            $display("Test 1: Addition PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Subtraction
        test_count++;
        result = b - a;
        if (result == 10) begin
            $display("Test 2: Subtraction PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Multiplication
        test_count++;
        result = a * b;
        if (result == 200) begin
            $display("Test 3: Multiplication PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Division
        test_count++;
        result = b / a;
        if (result == 2) begin
            $display("Test 4: Division PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Modulo
        test_count++;
        a = 17;
        b = 5;
        result = a % b;
        if (result == 2) begin
            $display("Test 5: Modulo PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: Real arithmetic
        test_count++;
        r1 = 3.5;
        r2 = 2.5;
        r_result = r1 + r2;
        if (r_result == 6.0) begin
            $display("Test 6: Real arithmetic PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL");
        end

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
