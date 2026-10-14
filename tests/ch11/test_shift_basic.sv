/*
:name: test_shift_basic
:description: Shift Operators Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.10
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_shift_basic.expected
*/
// IEEE 1800-2023 Section 11.4.10 - Shift Operators Tests
module test_shift_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [7:0] val;
        int sval;
        
        $display("=== IEEE 1800-2023 Shift Operators Tests ===");
        
        // Test 1: Left shift
        $display("Test 1: Left shift");
        val = 8'h01;
        val = val << 4;
        if (val == 8'h10) begin $display("Test 1 PASS: %h", val); pass_count++; end
        else begin $display("Test 1 FAIL: got %h", val); fail_count++; end
        
        // Test 2: Right shift
        $display("Test 2: Right shift");
        val = 8'h80;
        val = val >> 4;
        if (val == 8'h08) begin $display("Test 2 PASS: %h", val); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", val); fail_count++; end
        
        // Test 3: Left by 1
        $display("Test 3: Left by 1");
        val = 8'h55;
        val = val << 1;
        if (val == 8'hAA) begin $display("Test 3 PASS: %h", val); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", val); fail_count++; end
        
        // Test 4: Right by 1
        $display("Test 4: Right by 1");
        val = 8'hAA;
        val = val >> 1;
        if (val == 8'h55) begin $display("Test 4 PASS: %h", val); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", val); fail_count++; end
        
        // Test 5: Left by 0
        $display("Test 5: Left by 0");
        val = 8'hAB;
        val = val << 0;
        if (val == 8'hAB) begin $display("Test 5 PASS: %h", val); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", val); fail_count++; end
        
        // Test 6: Right by 0
        $display("Test 6: Right by 0");
        val = val >> 0;
        if (val == 8'hAB) begin $display("Test 6 PASS: %h", val); pass_count++; end
        else begin $display("Test 6 FAIL: got %h", val); fail_count++; end
        
        // Test 7: Shift all out
        $display("Test 7: All out");
        val = 8'hFF;
        val = val << 8;
        if (val == 8'h00) begin $display("Test 7 PASS: %h", val); pass_count++; end
        else begin $display("Test 7 FAIL: got %h", val); fail_count++; end
        
        // Test 8: Shift 2 bits
        $display("Test 8: Shift 2");
        val = 8'h0F;
        val = val << 2;
        if (val == 8'h3C) begin $display("Test 8 PASS: %h", val); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", val); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
