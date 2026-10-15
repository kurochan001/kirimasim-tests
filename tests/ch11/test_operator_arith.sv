/*
:name: test_operator_arith
:description: Arithmetic operators
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_operator_arith.expected
*/
// Arithmetic operators
module test_operator_arith;
    int a, b, result;
    logic [31:0] ua, ub, uresult;
    real ra, rb, rresult;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        // Test 1: Basic arithmetic (+, -, *, /)
        a = 20;
        b = 5;
        if ((a + b == 25) && (a - b == 15) && (a * b == 100) && (a / b == 4)) begin
            $display("PASS: Test 1 - Basic arithmetic");
            pass_count++;
        end else begin
            $display("FAIL: Test 1 - Basic arithmetic failed");
            fail_count++;
        end

        // Test 2: Modulo operator
        a = 17;
        b = 5;
        result = a % b;
        if (result == 2) begin
            $display("PASS: Test 2 - Modulo operator");
            pass_count++;
        end else begin
            $display("FAIL: Test 2 - Expected 2, got %0d", result);
            fail_count++;
        end

        // Test 3: Power operator
        a = 2;
        b = 10;
        result = a ** b;
        if (result == 1024) begin
            $display("PASS: Test 3 - Power operator");
            pass_count++;
        end else begin
            $display("FAIL: Test 3 - Expected 1024, got %0d", result);
            fail_count++;
        end

        // Test 4: Unary operators
        a = 10;
        if ((-a == -10) && (+a == 10)) begin
            $display("PASS: Test 4 - Unary operators");
            pass_count++;
        end else begin
            $display("FAIL: Test 4 - Unary operators failed");
            fail_count++;
        end

        // Test 5: Real arithmetic
        ra = 10.5;
        rb = 3.0;
        rresult = ra / rb;
        if (rresult == 3.5) begin
            $display("PASS: Test 5 - Real division");
            pass_count++;
        end else begin
            $display("FAIL: Test 5 - Expected 3.5, got %f", rresult);
            fail_count++;
        end

        // Summary
        $display("Operator Arith: %0d PASS, %0d FAIL", pass_count, fail_count);
        if (fail_count == 0) $display("PASS: All tests passed");
        else $display("FAIL: Some tests failed");
        $finish;
    end
endmodule
