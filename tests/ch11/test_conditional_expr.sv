/*
:name: test_conditional_expr
:description: Test for conditional expressions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_expr.expected
*/
// Test for conditional expressions
// IEEE 1800-2023 §11.4.11

module test_conditional_expr;
    int a, b, c;
    logic cond;
    int result;
    logic [7:0] vec;
    int pass_count = 0;
    int test_count = 0;

    initial begin
        // Test 1: Simple ternary - true condition
        test_count++;
        cond = 1;
        result = cond ? 10 : 20;
        if (result == 10) begin
            $display("Test 1: true ? 10 : 20 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 1: true ? 10 : 20 = %0d FAIL", result);
        end

        // Test 2: Simple ternary - false condition
        test_count++;
        cond = 0;
        result = cond ? 10 : 20;
        if (result == 20) begin
            $display("Test 2: false ? 10 : 20 = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 2: false ? 10 : 20 = %0d FAIL", result);
        end

        // Test 3: Nested ternary
        test_count++;
        a = 1;
        b = 2;
        result = (a > b) ? 100 : ((a < b) ? 50 : 0);
        if (result == 50) begin
            $display("Test 3: nested ternary = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 3: nested ternary = %0d FAIL", result);
        end

        // Test 4: Ternary with expressions
        test_count++;
        a = 5;
        b = 3;
        result = (a + b > 5) ? a * b : a + b;
        if (result == 15) begin  // 5*3 = 15
            $display("Test 4: expr ternary = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 4: expr ternary = %0d FAIL", result);
        end

        // Test 5: Vector ternary
        test_count++;
        cond = 1;
        vec = cond ? 8'hAA : 8'h55;
        if (vec == 8'hAA) begin
            $display("Test 5: vector ternary = 0x%h PASS", vec);
            pass_count++;
        end else begin
            $display("Test 5: vector ternary = 0x%h FAIL", vec);
        end

        // Test 6: Ternary in assignment
        test_count++;
        a = 10;
        b = 20;
        c = (a < b) ? a : b;  // Min function
        if (c == 10) begin
            $display("Test 6: min(10,20) = %0d PASS", c);
            pass_count++;
        end else begin
            $display("Test 6: min(10,20) = %0d FAIL", c);
        end

        // Test 7: Chained ternary (like switch)
        test_count++;
        a = 2;
        result = (a == 0) ? 100 :
                 (a == 1) ? 200 :
                 (a == 2) ? 300 : 400;
        if (result == 300) begin
            $display("Test 7: chained ternary = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 7: chained ternary = %0d FAIL", result);
        end

        // Test 8: Ternary with expression
        test_count++;
        a = 5;
        result = (a > 3) ? a * 2 : a;  // Inline calculation
        if (result == 10) begin
            $display("Test 8: ternary with expr = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 8: ternary with expr = %0d FAIL", result);
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
