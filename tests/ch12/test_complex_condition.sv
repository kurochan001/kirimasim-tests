/*
:name: test_complex_condition
:description: Complex conditions
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4 11.4.7 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_complex_condition.expected
*/
// Complex conditions
// IEEE 1800-2023 §12

module test_complex_condition;
    int a, b, c;
    logic x, y, z;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple AND condition
        test_count++;
        a = 5; b = 10;
        if (a > 0 && b > 0) begin
            $display("Test 1: Simple AND PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Simple OR condition
        test_count++;
        a = 0; b = 10;
        if (a > 0 || b > 0) begin
            $display("Test 2: Simple OR PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Nested condition
        test_count++;
        a = 5; b = 10; c = 15;
        if ((a > 0 && b > 0) || c > 10) begin
            $display("Test 3: Nested condition PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Negation
        test_count++;
        x = 0;
        if (!x) begin
            $display("Test 4: Negation PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Complex expression
        test_count++;
        a = 1; b = 2; c = 3;
        if ((a < b) && (b < c) && (c > a)) begin
            $display("Test 5: Complex expression PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
        end

        // Test 6: Ternary in condition
        test_count++;
        x = 1; y = 0;
        if ((x ? 1 : 0) > 0) begin
            $display("Test 6: Ternary in condition PASS");
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
