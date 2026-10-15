/*
:name: test_local_variable_scope
:description: Local Variable Scope
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 13.4.2 6.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_local_variable_scope.expected
*/
// IEEE 1800-2023 Section 13.3: Local Variable Scope
// Tests static/automatic lifetime and nested scope behavior

module test_local_variable_scope;
    int pass_count = 0;
    int fail_count = 0;

    // Test 1: Mixed static and automatic in automatic function
    function automatic int test_mixed_lifetime();
        static int static_var = 0;
        int automatic_var = 0;
        static_var++;
        automatic_var++;
        return static_var * 100 + automatic_var;
    endfunction

    // Test 2: Nested scope with same variable names
    function automatic int test_nested_scope(int n);
        int outer = 10;
        begin : block1
            int inner = 20;
            if (n > 0) begin : block2
                int innermost = 30;
                return outer + inner + innermost;
            end
        end
        return outer;
    endfunction

    // Test 3: For loop scope
    function automatic int test_for_loop_scope();
        int total = 0;
        for (int i = 0; i < 3; i++) begin
            int temp = i * 10;
            total += temp;
        end
        return total;
    endfunction

    // Test 4: Static function with static local
    function static int test_static_function();
        static int call_count = 0;
        call_count++;
        return call_count;
    endfunction

    // Test 5: Variable shadowing in nested blocks
    function automatic int test_shadowing();
        int x = 100;
        begin
            int x = 200;  // shadows outer x
            begin
                int x = 300;  // shadows middle x
                if (x != 300) return -1;
            end
            if (x != 200) return -2;
        end
        if (x != 100) return -3;
        return 0;  // all correct
    endfunction

    // Test 6: Foreach loop scope
    function automatic int test_foreach_scope();
        int arr[] = '{1, 2, 3, 4, 5};
        int sum = 0;
        foreach (arr[i]) begin
            int doubled = arr[i] * 2;
            sum += doubled;
        end
        return sum;
    endfunction

    // Test 7: While loop with local declaration
    function automatic int test_while_scope();
        int count = 0;
        int i = 0;
        while (i < 5) begin
            int local_val = i * i;
            count += local_val;
            i++;
        end
        return count;  // 0+1+4+9+16 = 30
    endfunction

    initial begin
        int r1, r2, r3;

        // Test 1: Mixed lifetime - static persists, automatic resets
        r1 = test_mixed_lifetime();  // static=1, auto=1 -> 101
        r2 = test_mixed_lifetime();  // static=2, auto=1 -> 201
        r3 = test_mixed_lifetime();  // static=3, auto=1 -> 301
        if (r1 == 101 && r2 == 201 && r3 == 301) pass_count++;
        else begin fail_count++; $display("FAIL: mixed lifetime %0d,%0d,%0d", r1, r2, r3); end

        // Test 2: Nested scope
        if (test_nested_scope(1) == 60) pass_count++;
        else begin fail_count++; $display("FAIL: nested scope(1)"); end
        if (test_nested_scope(0) == 10) pass_count++;
        else begin fail_count++; $display("FAIL: nested scope(0)"); end

        // Test 3: For loop scope
        if (test_for_loop_scope() == 30) pass_count++;  // 0+10+20
        else begin fail_count++; $display("FAIL: for loop scope"); end

        // Test 4: Static function
        r1 = test_static_function();
        r2 = test_static_function();
        r3 = test_static_function();
        if (r1 == 1 && r2 == 2 && r3 == 3) pass_count++;
        else begin fail_count++; $display("FAIL: static function"); end

        // Test 5: Variable shadowing
        if (test_shadowing() == 0) pass_count++;
        else begin fail_count++; $display("FAIL: shadowing"); end

        // Test 6: Foreach scope
        if (test_foreach_scope() == 30) pass_count++;  // 2+4+6+8+10
        else begin fail_count++; $display("FAIL: foreach scope"); end

        // Test 7: While scope
        if (test_while_scope() == 30) pass_count++;  // 0+1+4+9+16
        else begin fail_count++; $display("FAIL: while scope"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/8)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
