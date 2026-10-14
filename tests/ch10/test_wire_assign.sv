/*
:name: test_wire_assign
:description: Continuous Assignment Tests
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wire_assign.expected
*/
// IEEE 1800-2023 Section 10.3 - Continuous Assignment Tests
module test_wire_assign;
    int pass_count = 0;
    int fail_count = 0;
    
    logic [7:0] a, b;
    wire [7:0] sum, diff, prod;
    
    assign sum = a + b;
    assign diff = a - b;
    
    initial begin
        $display("=== IEEE 1800-2023 Wire Assign Tests ===");
        
        // Test 1: Initial sum
        $display("Test 1: Initial");
        a = 10; b = 5;
        #1;
        if (sum == 15) begin $display("Test 1 PASS: sum=%0d", sum); pass_count++; end
        else begin $display("Test 1 FAIL: sum=%0d", sum); fail_count++; end
        
        // Test 2: Diff
        $display("Test 2: Diff");
        if (diff == 5) begin $display("Test 2 PASS: diff=%0d", diff); pass_count++; end
        else begin $display("Test 2 FAIL: diff=%0d", diff); fail_count++; end
        
        // Test 3: Update a
        $display("Test 3: Update a");
        a = 20;
        #1;
        if (sum == 25) begin $display("Test 3 PASS: sum=%0d", sum); pass_count++; end
        else begin $display("Test 3 FAIL: sum=%0d", sum); fail_count++; end
        
        // Test 4: Update b
        $display("Test 4: Update b");
        b = 15;
        #1;
        if (sum == 35) begin $display("Test 4 PASS: sum=%0d", sum); pass_count++; end
        else begin $display("Test 4 FAIL: sum=%0d", sum); fail_count++; end
        
        // Test 5: Zero sum
        $display("Test 5: Zero");
        a = 0; b = 0;
        #1;
        if (sum == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Max values
        $display("Test 6: Max");
        a = 100; b = 100;
        #1;
        if (sum == 200) begin $display("Test 6 PASS: sum=%0d", sum); pass_count++; end
        else begin $display("Test 6 FAIL: sum=%0d", sum); fail_count++; end
        
        // Test 7: Diff check
        $display("Test 7: Diff");
        a = 50; b = 20;
        #1;
        if (diff == 30) begin $display("Test 7 PASS: diff=%0d", diff); pass_count++; end
        else begin $display("Test 7 FAIL: diff=%0d", diff); fail_count++; end
        
        // Test 8: Same values
        $display("Test 8: Same");
        a = 42; b = 42;
        #1;
        if (diff == 0) begin $display("Test 8 PASS: diff=%0d", diff); pass_count++; end
        else begin $display("Test 8 FAIL: diff=%0d", diff); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
