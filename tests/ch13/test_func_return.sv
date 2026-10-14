/*
:name: test_func_return
:description: Function Return Tests
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_func_return.expected
*/
// IEEE 1800-2023 Section 13.4 - Function Return Tests
module test_func_return;
    int pass_count = 0;
    int fail_count = 0;
    
    function int double_val(int x);
        return x * 2;
    endfunction
    
    function int max_val(int a, int b);
        return (a > b) ? a : b;
    endfunction
    
    function int abs_val(int x);
        return (x < 0) ? -x : x;
    endfunction
    
    function int square(int x);
        return x * x;
    endfunction
    
    initial begin
        int result;
        
        $display("=== IEEE 1800-2023 Function Return Tests ===");
        
        // Test 1: Double
        $display("Test 1: Double");
        result = double_val(5);
        if (result == 10) begin $display("Test 1 PASS: %0d", result); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", result); fail_count++; end
        
        // Test 2: Max a > b
        $display("Test 2: Max a>b");
        result = max_val(10, 5);
        if (result == 10) begin $display("Test 2 PASS: %0d", result); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", result); fail_count++; end
        
        // Test 3: Max b > a
        $display("Test 3: Max b>a");
        result = max_val(3, 8);
        if (result == 8) begin $display("Test 3 PASS: %0d", result); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", result); fail_count++; end
        
        // Test 4: Abs positive
        $display("Test 4: Abs pos");
        result = abs_val(42);
        if (result == 42) begin $display("Test 4 PASS: %0d", result); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", result); fail_count++; end
        
        // Test 5: Abs negative
        $display("Test 5: Abs neg");
        result = abs_val(-25);
        if (result == 25) begin $display("Test 5 PASS: %0d", result); pass_count++; end
        else begin $display("Test 5 FAIL: got %0d", result); fail_count++; end
        
        // Test 6: Square
        $display("Test 6: Square");
        result = square(7);
        if (result == 49) begin $display("Test 6 PASS: %0d", result); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", result); fail_count++; end
        
        // Test 7: Nested
        $display("Test 7: Nested");
        result = double_val(max_val(3, 5));
        if (result == 10) begin $display("Test 7 PASS: %0d", result); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", result); fail_count++; end
        
        // Test 8: Complex
        $display("Test 8: Complex");
        result = abs_val(-square(4));
        if (result == 16) begin $display("Test 8 PASS: %0d", result); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", result); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
