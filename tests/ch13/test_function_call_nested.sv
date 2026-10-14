/*
:name: test_function_call_nested
:description: Function calls, nested and chained (IEEE 1800-2023 Sections 13.4 and 13.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_call_nested.expected
*/
// IEEE 1800-2023 Sections 13.4 and 13.5 - Function calls, nested and chained
module test_task_call;
    int pass_count = 0;
    int fail_count = 0;
    
    function int add_func(int a, int b);
        return a + b;
    endfunction
    
    function int mult_func(int a, int b);
        return a * b;
    endfunction
    
    function int diff_func(int a, int b);
        return a - b;
    endfunction
    
    function int abs_func(int a);
        if (a < 0) return -a;
        else return a;
    endfunction
    
    initial begin
        int result;
        
        $display("=== IEEE 1800-2023 Task/Function Call Tests ===");
        
        // Test 1: Add function
        $display("Test 1: Add");
        result = add_func(10, 20);
        if (result == 30) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end
        
        // Test 2: Multiply
        $display("Test 2: Mult");
        result = mult_func(6, 7);
        if (result == 42) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end
        
        // Test 3: Diff
        $display("Test 3: Diff");
        result = diff_func(100, 30);
        if (result == 70) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end
        
        // Test 4: Abs positive
        $display("Test 4: Abs pos");
        result = abs_func(50);
        if (result == 50) begin $display("Test 4 PASS: %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end
        
        // Test 5: Abs negative
        $display("Test 5: Abs neg");
        result = abs_func(-30);
        if (result == 30) begin $display("Test 5 PASS: %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end
        
        // Test 6: Nested calls
        $display("Test 6: Nested");
        result = add_func(mult_func(2, 3), mult_func(4, 5));
        if (result == 26) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end
        
        // Test 7: Chain
        $display("Test 7: Chain");
        result = diff_func(mult_func(10, 10), add_func(20, 30));
        if (result == 50) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end
        
        // Test 8: Zero
        $display("Test 8: Zero");
        result = mult_func(add_func(5, -5), 100);
        if (result == 0) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
