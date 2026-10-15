/*
:name: test_variables_and_subroutine_calls
:description: Module variables, block variables, and function and task calls (IEEE 1800-2023 Sections 6.21, 13.3 and 13.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.21 13.3 13.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variables_and_subroutine_calls.expected
*/
// Module variables, block variables, and function and task calls
// IEEE 1800-2023 §6.21, §13.3 and §13.4

module test_variables_and_subroutine_calls;
    int local_var = 10;
    int result;
    int pass_count = 0;
    int test_count = 0;

    function int add_values(int a, int b);
        return a + b;
    endfunction

    task set_value(output int out_val, input int in_val);
        out_val = in_val * 2;
    endtask

    initial begin
        // Test 1: Local variable context
        test_count++;
        result = local_var + 5;
        if (result == 15) begin
            $display("Test 1: Local variable PASS");
            pass_count++;
        end else begin
            $display("Test 1: FAIL");
        end

        // Test 2: Function context
        test_count++;
        result = add_values(3, 7);
        if (result == 10) begin
            $display("Test 2: Function PASS");
            pass_count++;
        end else begin
            $display("Test 2: FAIL");
        end

        // Test 3: Task context
        test_count++;
        set_value(result, 5);
        if (result == 10) begin
            $display("Test 3: Task PASS");
            pass_count++;
        end else begin
            $display("Test 3: FAIL");
        end

        // Test 4: Nested context
        test_count++;
        begin
            static int nested_var = 20;
            result = nested_var + local_var;
        end
        if (result == 30) begin
            $display("Test 4: Nested PASS");
            pass_count++;
        end else begin
            $display("Test 4: FAIL");
        end

        // Test 5: Expression context
        test_count++;
        result = (local_var > 5) ? local_var * 2 : local_var / 2;
        if (result == 20) begin
            $display("Test 5: Expression PASS");
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
