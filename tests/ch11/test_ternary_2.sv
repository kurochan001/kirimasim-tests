/*
:name: test_ternary_2
:description: Test for ternary operator
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ternary_2.expected
*/
// Test for ternary operator
// IEEE 1800-2023 §11.4.11

module test_ternary;
    int a, b, result;
    logic flag;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple ternary true
        test_count++;
        flag = 1;
        result = flag ? 10 : 20;
        if (result == 10) begin
            $display("Test 1: Ternary true PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Simple ternary false
        test_count++;
        flag = 0;
        result = flag ? 10 : 20;
        if (result == 20) begin
            $display("Test 2: Ternary false PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Ternary with expression
        test_count++;
        a = 5;
        b = 10;
        result = (a > b) ? a : b;
        if (result == 10) begin
            $display("Test 3: Ternary expression PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Nested ternary
        test_count++;
        a = 5;
        result = (a < 3) ? 1 : (a < 7) ? 2 : 3;
        if (result == 2) begin
            $display("Test 4: Nested ternary PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Ternary in assignment
        test_count++;
        a = 100;
        b = (a > 50) ? a * 2 : a / 2;
        if (b == 200) begin
            $display("Test 5: Ternary in assignment PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL");
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
