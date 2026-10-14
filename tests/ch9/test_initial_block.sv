/*
:name: test_initial_block
:description: Initial Block Tests
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.1
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_initial_block.expected
*/
// IEEE 1800-2023 Section 9.2.1 - Initial Block Tests
module test_initial_block;
    int pass_count = 0;
    int fail_count = 0;
    int v1 = 0, v2 = 0, v3 = 0;
    
    initial begin
        v1 = 100;
    end
    
    initial begin
        #2;
        v2 = 200;
    end
    
    initial begin
        #3;
        v3 = 300;
    end
    
    initial begin
        $display("=== IEEE 1800-2023 Initial Block Tests ===");
        
        // Read only at times when no other initial block writes: v1 is
        // written at time 0, v2 at time 2 and v3 at time 3.
        #1;

        // Test 1: v1 set
        $display("Test 1: v1");
        if (v1 == 100) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: v1=%0d", v1); fail_count++; end
        
        // Test 2: v2 not yet
        $display("Test 2: v2 before");
        if (v2 == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: v2=%0d", v2); fail_count++; end
        
        // Test 3: Wait for v2
        $display("Test 3: v2 after");
        #3;
        if (v2 == 200) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: v2=%0d", v2); fail_count++; end
        
        // Test 4: v3 set
        $display("Test 4: v3");
        if (v3 == 300) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: v3=%0d", v3); fail_count++; end
        
        // Test 5: All set
        $display("Test 5: All set");
        if (v1 + v2 + v3 == 600) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Modify v1
        $display("Test 6: Modify");
        v1 = 111;
        if (v1 == 111) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Modify v2
        $display("Test 7: Modify v2");
        v2 = 222;
        if (v2 == 222) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Final sum
        $display("Test 8: Final");
        if (v1 + v2 + v3 == 633) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: sum=%0d", v1+v2+v3); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
