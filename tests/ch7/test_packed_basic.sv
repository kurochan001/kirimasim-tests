/*
:name: test_packed_basic
:description: Packed Array Basic Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_packed_basic.expected
*/
// IEEE 1800-2023 Section 7.4.1 - Packed Array Basic Tests
module test_packed_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [31:0] packed_val;
        logic [7:0] bytes [4];
        
        $display("=== IEEE 1800-2023 Packed Array Basic Tests ===");
        
        // Test 1: Assign packed
        $display("Test 1: Assign");
        packed_val = 32'h12345678;
        if (packed_val == 32'h12345678) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Slice low
        $display("Test 2: Slice low");
        if (packed_val[7:0] == 8'h78) begin $display("Test 2 PASS: %h", packed_val[7:0]); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", packed_val[7:0]); fail_count++; end
        
        // Test 3: Slice mid
        $display("Test 3: Slice mid");
        if (packed_val[15:8] == 8'h56) begin $display("Test 3 PASS: %h", packed_val[15:8]); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", packed_val[15:8]); fail_count++; end
        
        // Test 4: Slice high
        $display("Test 4: Slice high");
        if (packed_val[31:24] == 8'h12) begin $display("Test 4 PASS: %h", packed_val[31:24]); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", packed_val[31:24]); fail_count++; end
        
        // Test 5: Modify slice
        $display("Test 5: Modify");
        packed_val[7:0] = 8'hAA;
        if (packed_val == 32'h123456AA) begin $display("Test 5 PASS: %h", packed_val); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", packed_val); fail_count++; end
        
        // Test 6: Zero value
        $display("Test 6: Zero");
        packed_val = 0;
        if (packed_val == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: All ones
        $display("Test 7: All ones");
        packed_val = 32'hFFFFFFFF;
        if (packed_val == 32'hFFFFFFFF) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Single bit
        $display("Test 8: Single bit");
        packed_val = 0;
        packed_val[15] = 1;
        if (packed_val == 32'h00008000) begin $display("Test 8 PASS: %h", packed_val); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", packed_val); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
