/*
:name: test_logic_basic
:description: Logic Basic Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.3.1 6.11
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_logic_basic.expected
*/
// IEEE 1800-2023 Section 6.3 - Logic Basic Tests
module test_logic_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic a, b, result;
        logic [3:0] vec;
        
        $display("=== IEEE 1800-2023 Logic Basic Tests ===");
        
        // Test 1: Logic 0
        $display("Test 1: Logic 0");
        a = 1'b0;
        if (a == 0) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Logic 1
        $display("Test 2: Logic 1");
        a = 1'b1;
        if (a == 1) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: AND operation
        $display("Test 3: AND");
        a = 1; b = 1;
        result = a & b;
        if (result == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: OR operation
        $display("Test 4: OR");
        a = 0; b = 1;
        result = a | b;
        if (result == 1) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: NOT operation
        $display("Test 5: NOT");
        a = 0;
        result = ~a;
        if (result == 1) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: XOR operation
        $display("Test 6: XOR");
        a = 1; b = 1;
        result = a ^ b;
        if (result == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Vector assign
        $display("Test 7: Vector");
        vec = 4'b1010;
        if (vec == 10) begin $display("Test 7 PASS: %b", vec); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Vector ops
        $display("Test 8: Vector ops");
        vec = 4'b1111 & 4'b0101;
        if (vec == 4'b0101) begin $display("Test 8 PASS: %b", vec); pass_count++; end
        else begin $display("Test 8 FAIL: got %b", vec); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
