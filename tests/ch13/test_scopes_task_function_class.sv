/*
:name: test_scopes_task_function_class
:description: Variables in module, task, function, named block and class scopes
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3 13.4 9.3.4 8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scopes_task_function_class.expected
*/
// Variables in module, task, function, named block and class scopes
// IEEE 1800-2023 §6-12

module test_scopes_task_function_class;
    int global_var = 100;
    int arr[4] = '{1, 2, 3, 4};
    int pass_count = 0;
    int test_count = 0;

    // Task with local scope
    task automatic test_scope;
        int local_var;
        local_var = 50;
        if (local_var == 50) begin
            $display("Local scope var = %0d PASS", local_var);
        end
    endtask

    // Function with nested scope
    function int nested_scope(int x);
        int inner;
        inner = x * 2;
        begin : named_block
            int block_var;
            block_var = inner + 1;
            return block_var;
        end
    endfunction

    // Class for object context
    class Container;
        int value;
        
        function new(int v);
            value = v;
        endfunction
        
        function int getValue();
            return value;
        endfunction
    endclass

    Container c;

    initial begin
        // Test 1: Global variable access
        test_count++;
        if (global_var == 100) begin
            $display("Test 1: Global var = %0d PASS", global_var);
            pass_count++;
        end else begin
            $display("Test 1: Global var = %0d FAIL", global_var);
        end

        // Test 2: Array element access
        test_count++;
        if (arr[2] == 3) begin
            $display("Test 2: Array element = %0d PASS", arr[2]);
            pass_count++;
        end else begin
            $display("Test 2: Array element = %0d FAIL", arr[2]);
        end

        // Test 3: Task scope
        test_count++;
        test_scope();
        $display("Test 3: Task scope PASS");
        pass_count++;

        // Test 4: Nested function scope
        test_count++;
        if (nested_scope(5) == 11) begin  // 5*2+1 = 11
            $display("Test 4: Nested scope = %0d PASS", nested_scope(5));
            pass_count++;
        end else begin
            $display("Test 4: Nested scope = %0d FAIL", nested_scope(5));
        end

        // Test 5: Class object context
        test_count++;
        c = new(42);
        if (c.getValue() == 42) begin
            $display("Test 5: Object context = %0d PASS", c.getValue());
            pass_count++;
        end else begin
            $display("Test 5: Object context = %0d FAIL", c.getValue());
        end

        // Test 6: Variable modification
        test_count++;
        global_var = 200;
        if (global_var == 200) begin
            $display("Test 6: Modified global = %0d PASS", global_var);
            pass_count++;
        end else begin
            $display("Test 6: Modified global = %0d FAIL", global_var);
        end

        // Test 7: Array modification
        test_count++;
        arr[0] = 10;
        if (arr[0] == 10) begin
            $display("Test 7: Modified array = %0d PASS", arr[0]);
            pass_count++;
        end else begin
            $display("Test 7: Modified array = %0d FAIL", arr[0]);
        end

        // Test 8: Object modification
        test_count++;
        c.value = 100;
        if (c.value == 100) begin
            $display("Test 8: Modified object = %0d PASS", c.value);
            pass_count++;
        end else begin
            $display("Test 8: Modified object = %0d FAIL", c.value);
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
