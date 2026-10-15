/*
:name: test_function_side_effects
:description: Function Side Effects
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5.2 11.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_side_effects.expected
*/
// IEEE 1800-2023 Section 13.4: Function Side Effects
// Tests functions with side effects and their evaluation

module test_function_side_effects;
    int pass_count = 0;
    int fail_count = 0;

    // Global state for side effect tracking
    int call_count = 0;
    int last_value = 0;
    int accumulator = 0;
    string log_messages[$];

    // Function with counter side effect
    function automatic int counted_double(int val);
        call_count++;
        return val * 2;
    endfunction

    // Function that logs
    function automatic int logged_add(int a, int b);
        log_messages.push_back($sformatf("add(%0d, %0d)", a, b));
        return a + b;
    endfunction

    // Function that updates state
    function automatic int stateful_compute(int val);
        last_value = val;
        accumulator += val;
        return val * val;
    endfunction

    // Function with multiple side effects
    function automatic int multi_effect(int val);
        call_count++;
        log_messages.push_back($sformatf("multi(%0d)", val));
        accumulator += val;
        return val;
    endfunction

    // Pure function (no side effects) for comparison
    function automatic int pure_add(int a, int b);
        return a + b;
    endfunction

    // Function modifying passed reference
    function automatic int modify_and_return(ref int val);
        val *= 2;
        return val;
    endfunction

    initial begin
        int result;
        int x, y;

        // Test 1: Count function calls
        call_count = 0;
        result = counted_double(5) + counted_double(10);
        if (call_count == 2 && result == 30) pass_count++;
        else begin fail_count++; $display("FAIL: counted double"); end

        // Test 2: Logging side effect
        log_messages.delete();
        result = logged_add(1, 2) + logged_add(3, 4);
        if (log_messages.size() == 2 && result == 10) pass_count++;
        else begin fail_count++; $display("FAIL: logged add"); end

        // Test 3: Stateful computation
        last_value = 0;
        accumulator = 0;
        result = stateful_compute(5);  // returns 25, sets last_value=5, accumulator=5
        if (result == 25 && last_value == 5 && accumulator == 5) pass_count++;
        else begin fail_count++; $display("FAIL: stateful compute"); end

        result = stateful_compute(3);  // returns 9, sets last_value=3, accumulator=8
        if (result == 9 && last_value == 3 && accumulator == 8) pass_count++;
        else begin fail_count++; $display("FAIL: stateful compute chain"); end

        // Test 4: Multiple side effects
        call_count = 0;
        log_messages.delete();
        accumulator = 0;
        result = multi_effect(10) + multi_effect(20);
        if (call_count == 2 && log_messages.size() == 2 && accumulator == 30 && result == 30)
            pass_count++;
        else begin fail_count++; $display("FAIL: multi effect"); end

        // Test 5: Side effects in conditional
        call_count = 0;
        result = (1 == 1) ? counted_double(5) : counted_double(10);
        if (call_count == 1 && result == 10) pass_count++;
        else begin fail_count++; $display("FAIL: conditional side effect"); end

        // Test 6: Side effects in loop
        call_count = 0;
        result = 0;
        for (int i = 0; i < 5; i++) begin
            result += counted_double(i);
        end
        if (call_count == 5 && result == 20) pass_count++;  // 0+2+4+6+8 = 20
        else begin fail_count++; $display("FAIL: loop side effect"); end

        // Test 7: Reference modification
        x = 10;
        result = modify_and_return(x);
        if (x == 20 && result == 20) pass_count++;
        else begin fail_count++; $display("FAIL: ref modification"); end

        // Test 8: Nested function calls with side effects
        call_count = 0;
        accumulator = 0;
        result = multi_effect(multi_effect(5));  // inner returns 5, outer returns 5
        // call_count should be 2, accumulator should be 10 (5+5)
        if (call_count == 2 && accumulator == 10) pass_count++;
        else begin fail_count++; $display("FAIL: nested side effects cc=%0d acc=%0d", call_count, accumulator); end

        // Test 9: Order of evaluation
        call_count = 0;
        log_messages.delete();
        result = logged_add(logged_add(1, 2), logged_add(3, 4));
        // Should log: add(1,2), add(3,4), add(3,7) in some order, result = 10
        if (log_messages.size() == 3 && result == 10) pass_count++;
        else begin fail_count++; $display("FAIL: eval order size=%0d", log_messages.size()); end

        // Test 10: Pure function comparison
        x = 5; y = 10;
        result = pure_add(x, y);
        if (result == 15 && x == 5 && y == 10) pass_count++;  // no side effects
        else begin fail_count++; $display("FAIL: pure function"); end

        if (fail_count == 0)
            $display("TEST PASSED (%0d/11)", pass_count);
        else
            $display("TEST FAILED (pass=%0d, fail=%0d)", pass_count, fail_count);
        $finish;
    end
endmodule
