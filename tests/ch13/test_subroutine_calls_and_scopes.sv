/*
:name: test_subroutine_calls_and_scopes
:description: Subroutine calls in expressions and variables of nested blocks (IEEE 1800-2023 Sections 13.3, 13.4 and 6.21)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.3 6.21
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_calls_and_scopes.expected
*/
// Test for subroutine calls in expressions and variables of nested blocks
// IEEE 1800-2023 §13.3, §13.4 and §6.21

module test_subroutine_calls_and_scopes;
    int a, b, result;
    logic [31:0] lval;
    int pass_count = 0;
    int test_count = 0;

    function int add(int x, int y);
        return x + y;
    endfunction

    function int multiply(int x, int y);
        return x * y;
    endfunction

    task set_value(output int v, input int val);
        v = val;
    endtask

    initial begin
        // Test 1: Function call
        test_count++;
        result = add(10, 20);
        if (result == 30) begin
            $display("Test 1: Function call PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: Nested function call
        test_count++;
        result = add(multiply(2, 3), multiply(4, 5));
        if (result == 26) begin
            $display("Test 2: Nested function PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", result);
        end

        // Test 3: Task call with output
        test_count++;
        set_value(a, 42);
        if (a == 42) begin
            $display("Test 3: Task output PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL a=%0d", a);
        end

        // Test 4: Local variable scope
        test_count++;
        begin
            int local_var;
            local_var = 100;
            a = local_var;
        end
        if (a == 100) begin
            $display("Test 4: Local scope PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL a=%0d", a);
        end

        // Test 5: Multiple scopes
        test_count++;
        a = 0;
        begin
            static int x = 1;
            begin
                static int y = 2;
                a = x + y;
            end
        end
        if (a == 3) begin
            $display("Test 5: Multiple scopes PASS");
            pass_count++;
        end else begin
            $display("Test 5: FAIL a=%0d", a);
        end

        // Test 6: Expression in function arg
        test_count++;
        a = 5;
        b = 10;
        result = add(a * 2, b / 2);
        if (result == 15) begin
            $display("Test 6: Expr in arg PASS");
            pass_count++;
        end else begin
            $display("Test 6: FAIL result=%0d", result);
        end

        // Test 7: Conditional in expression
        test_count++;
        a = 10;
        b = 20;
        result = add((a > b) ? a : b, 5);
        if (result == 25) begin
            $display("Test 7: Cond in expr PASS");
            pass_count++;
        end else begin
            $display("Test 7: FAIL result=%0d", result);
        end

        // Test 8: Chained function calls
        test_count++;
        result = multiply(add(1, 2), add(3, 4));
        if (result == 21) begin
            $display("Test 8: Chained calls PASS");
            pass_count++;
        end else begin
            $display("Test 8: FAIL result=%0d", result);
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
