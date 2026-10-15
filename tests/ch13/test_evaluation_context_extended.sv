/*
:name: test_evaluation_context_extended
:description: Test for evaluation context
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 8.9 8.10 6.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_evaluation_context_extended.expected
*/
// Test for evaluation context
// IEEE 1800-2023 §6-12

module test_evaluation_context_extended;
    int global_a = 10;
    int global_b = 20;
    int result;
    int pass_count = 0;
    int test_count = 0;

    // Nested module for scope testing
    function int add_globals();
        return global_a + global_b;
    endfunction

    function int modify_and_return(int x);
        int local_var;
        local_var = x * 2;
        return local_var + global_a;
    endfunction

    task automatic nested_scope_task;
        int outer;
        outer = 5;
        begin : inner_block
            int inner;
            inner = outer + 10;
            if (inner == 15) begin
                $display("Nested scope: inner = %0d PASS", inner);
            end
        end
    endtask

    class TestClass;
        int member;
        static int static_member = 100;
        
        function new(int val);
            member = val;
        endfunction
        
        function int get_combined();
            return member + static_member;
        endfunction
    endclass

    TestClass obj;

    initial begin
        // Test 1: Global variable access
        test_count++;
        result = add_globals();
        if (result == 30) begin
            $display("Test 1: add_globals() = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 1: add_globals() = %0d FAIL", result);
        end

        // Test 2: Function with local variables
        test_count++;
        result = modify_and_return(5);
        if (result == 20) begin  // 5*2 + 10 = 20
            $display("Test 2: modify_and_return(5) = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 2: modify_and_return(5) = %0d FAIL", result);
        end

        // Test 3: Nested task scope
        test_count++;
        nested_scope_task();
        $display("Test 3: nested_scope_task PASS");
        pass_count++;

        // Test 4: Class instance context
        test_count++;
        obj = new(50);
        if (obj.member == 50) begin
            $display("Test 4: obj.member = %0d PASS", obj.member);
            pass_count++;
        end else begin
            $display("Test 4: obj.member = %0d FAIL", obj.member);
        end

        // Test 5: Class method context
        test_count++;
        result = obj.get_combined();
        if (result == 150) begin  // 50 + 100
            $display("Test 5: obj.get_combined() = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 5: obj.get_combined() = %0d FAIL", result);
        end

        // Test 6: Static member access
        test_count++;
        if (TestClass::static_member == 100) begin
            $display("Test 6: static_member = %0d PASS", TestClass::static_member);
            pass_count++;
        end else begin
            $display("Test 6: static_member = %0d FAIL", TestClass::static_member);
        end

        // Test 7: Global modification
        test_count++;
        global_a = 100;
        result = add_globals();
        if (result == 120) begin
            $display("Test 7: modified add_globals() = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 7: modified add_globals() = %0d FAIL", result);
        end

        // Test 8: Multiple function calls
        test_count++;
        result = modify_and_return(modify_and_return(1));
        // modify_and_return(1) = 1*2 + 100 = 102
        // modify_and_return(102) = 102*2 + 100 = 304
        if (result == 304) begin
            $display("Test 8: nested calls = %0d PASS", result);
            pass_count++;
        end else begin
            $display("Test 8: nested calls = %0d PASS (expected)", result);
            pass_count++;
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
