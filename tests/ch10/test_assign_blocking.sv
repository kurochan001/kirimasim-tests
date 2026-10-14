/*
:name: test_assign_blocking
:description: Blocking Assignment Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_assign_blocking.expected
*/
// IEEE 1800-2023 Section 10.4.1 - Blocking Assignment Tests
module test_assign_blocking;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        int a, b, c, d;
        
        $display("=== IEEE 1800-2023 Blocking Assignment Tests ===");
        
        // Test 1: Simple assign
        $display("Test 1: Simple");
        a = 10;
        if (a == 10) begin $display("Test 1 PASS: %0d", a); pass_count++; end
        else begin $display("Test 1 FAIL: got %0d", a); fail_count++; end
        
        // Test 2: Chain assign
        $display("Test 2: Chain");
        a = 5; b = a; c = b;
        if (c == 5) begin $display("Test 2 PASS: %0d", c); pass_count++; end
        else begin $display("Test 2 FAIL: got %0d", c); fail_count++; end
        
        // Test 3: Expression assign
        $display("Test 3: Expression");
        a = 10; b = 20;
        c = a + b;
        if (c == 30) begin $display("Test 3 PASS: %0d", c); pass_count++; end
        else begin $display("Test 3 FAIL: got %0d", c); fail_count++; end
        
        // Test 4: Self assign
        $display("Test 4: Self assign");
        a = 5;
        a = a + 10;
        if (a == 15) begin $display("Test 4 PASS: %0d", a); pass_count++; end
        else begin $display("Test 4 FAIL: got %0d", a); fail_count++; end
        
        // Test 5: Multiple assign
        $display("Test 5: Multiple");
        a = 1; b = 2; c = 3; d = 4;
        if (a + b + c + d == 10) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Negative assign
        $display("Test 6: Negative");
        a = -50;
        if (a == -50) begin $display("Test 6 PASS: %0d", a); pass_count++; end
        else begin $display("Test 6 FAIL: got %0d", a); fail_count++; end
        
        // Test 7: Zero assign
        $display("Test 7: Zero");
        a = 100;
        a = 0;
        if (a == 0) begin $display("Test 7 PASS: %0d", a); pass_count++; end
        else begin $display("Test 7 FAIL: got %0d", a); fail_count++; end
        
        // Test 8: Complex expr
        $display("Test 8: Complex");
        a = 10; b = 3;
        c = a * b - a / b;
        if (c == 27) begin $display("Test 8 PASS: %0d", c); pass_count++; end
        else begin $display("Test 8 FAIL: got %0d", c); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
