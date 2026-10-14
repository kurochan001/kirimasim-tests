/*
:name: test_if_else_2
:description: Test for if-else statements
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_2.expected
*/
// Test for if-else statements
// IEEE 1800-2023 §12.4

module test_if_else;
    int a, b, result;
    logic flag;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple if
        test_count++;
        a = 10;
        if (a > 5) begin
            result = 1;
        end else begin
            result = 0;
        end
        if (result == 1) begin
            $display("Test 1: Simple if PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: If-else chain
        test_count++;
        a = 50;
        if (a < 10) begin
            result = 1;
        end else if (a < 30) begin
            result = 2;
        end else if (a < 70) begin
            result = 3;
        end else begin
            result = 4;
        end
        if (result == 3) begin
            $display("Test 2: If-else chain PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Nested if
        test_count++;
        a = 15;
        b = 25;
        if (a > 10) begin
            if (b > 20) begin
                result = 100;
            end else begin
                result = 50;
            end
        end else begin
            result = 0;
        end
        if (result == 100) begin
            $display("Test 3: Nested if PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Logical operators in condition
        test_count++;
        a = 5;
        b = 10;
        if (a > 0 && b > 0) begin
            result = 1;
        end else begin
            result = 0;
        end
        if (result == 1) begin
            $display("Test 4: Logical operators PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Single statement if
        test_count++;
        flag = 1;
        if (flag) result = 999;
        if (result == 999) begin
            $display("Test 5: Single statement if PASS");
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
