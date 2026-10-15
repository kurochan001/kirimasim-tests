/*
:name: test_concat_repl_2
:description: Concatenation and Replication Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 11.4.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_concat_repl_2.expected
*/
// IEEE 1800-2023 Section 11.4.12 - Concatenation and Replication Tests
module test_concat_repl;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [7:0] a, b;
        logic [15:0] wide;
        
        $display("=== IEEE 1800-2023 Concat/Replication Tests ===");
        
        // Test 1: Simple concat
        $display("Test 1: Simple concat");
        a = 8'hAB; b = 8'hCD;
        wide = {a, b};
        if (wide == 16'hABCD) begin $display("Test 1 PASS: %h", wide); pass_count++; end
        else begin $display("Test 1 FAIL: got %h", wide); fail_count++; end
        
        // Test 2: Reverse order
        $display("Test 2: Reverse");
        wide = {b, a};
        if (wide == 16'hCDAB) begin $display("Test 2 PASS: %h", wide); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", wide); fail_count++; end
        
        // Test 3: Replication x2
        $display("Test 3: Repl x2");
        a = 8'hAA;
        wide = {2{a}};
        if (wide == 16'hAAAA) begin $display("Test 3 PASS: %h", wide); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", wide); fail_count++; end
        
        // Test 4: Zero pattern
        $display("Test 4: Zero");
        a = 8'h00;
        wide = {2{a}};
        if (wide == 16'h0000) begin $display("Test 4 PASS: %h", wide); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", wide); fail_count++; end
        
        // Test 5: FF pattern
        $display("Test 5: FF pattern");
        a = 8'hFF;
        wide = {2{a}};
        if (wide == 16'hFFFF) begin $display("Test 5 PASS: %h", wide); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", wide); fail_count++; end
        
        // Test 6: 55 pattern
        $display("Test 6: 55 pattern");
        a = 8'h55;
        wide = {2{a}};
        if (wide == 16'h5555) begin $display("Test 6 PASS: %h", wide); pass_count++; end
        else begin $display("Test 6 FAIL: got %h", wide); fail_count++; end
        
        // Test 7: Concat self
        $display("Test 7: Self concat");
        a = 8'h12;
        wide = {a, a};
        if (wide == 16'h1212) begin $display("Test 7 PASS: %h", wide); pass_count++; end
        else begin $display("Test 7 FAIL: got %h", wide); fail_count++; end
        
        // Test 8: Different values
        $display("Test 8: Different");
        a = 8'h11; b = 8'h22;
        wide = {a, b};
        if (wide == 16'h1122) begin $display("Test 8 PASS: %h", wide); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", wide); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
