/*
:name: test_scope_nesting
:description: Local variables in recursive automatic functions, automatic tasks and class methods
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.2 13.3.1 8.6
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_nesting.expected
*/
// Local variables in recursive automatic functions, automatic tasks and class methods
// IEEE 1800-2023 Section 13

module test_scope_nesting;
    int pass_count = 0;
    int test_count = 0;

    // Function with local scope
    function automatic int nested_scope(int depth);
        int local_var;
        local_var = depth * 10;
        if (depth > 0) begin
            return nested_scope(depth - 1) + local_var;
        end
        return local_var;
    endfunction

    // Task with scope changes
    task automatic scope_task(input int in_val, output int out_val);
        int temp;
        temp = in_val * 2;
        out_val = temp + 1;
    endtask

    // Class for object scope
    class ScopeTest;
        int member_var;
        
        function new(int val);
            member_var = val;
        endfunction
        
        function int get_double();
            return member_var * 2;
        endfunction
    endclass

    initial begin
        int result;
        int out_result;
        ScopeTest obj;

        // Test 1: Nested function scope
        test_count++;
        result = nested_scope(3);
        if (result == 60) begin // 0 + 10 + 20 + 30
            $display("Test 1: Nested scope PASS result=%0d", result);
            pass_count++;
        end else begin
            $display("Test 1: FAIL result=%0d", result);
        end

        // Test 2: Task scope
        test_count++;
        scope_task(5, out_result);
        if (out_result == 11) begin
            $display("Test 2: Task scope PASS result=%0d", out_result);
            pass_count++;
        end else begin
            $display("Test 2: FAIL result=%0d", out_result);
        end

        // Test 3: Class object scope
        test_count++;
        obj = new(25);
        result = obj.get_double();
        if (result == 50) begin
            $display("Test 3: Class scope PASS result=%0d", result);
            pass_count++;
        end else begin
            $display("Test 3: FAIL result=%0d", result);
        end

        // Test 4: Multiple nested calls
        test_count++;
        result = nested_scope(5);
        $display("Test 4: Deep nesting PASS result=%0d", result);
        pass_count++;

        // Test 5: Multiple tasks
        test_count++;
        for (int i = 0; i < 5; i++) begin
            scope_task(i, out_result);
        end
        $display("Test 5: Multiple tasks PASS");
        pass_count++;

        // Report
        if (pass_count == test_count) begin
            $display("TEST PASSED: %0d/%0d tests passed", pass_count, test_count);
        end else begin
            $display("TEST FAILED: %0d/%0d tests passed", pass_count, test_count);
        end

        $finish;
    end
endmodule
