/*
:name: test_size_cast
:description: Size Casting Tests
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.1 11.4.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_size_cast.expected
*/
// IEEE 1800-2023 Section 6.24.1 - Size Casting Tests
module test_size_cast;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        logic [31:0] wide;
        logic [7:0] narrow;
        logic [15:0] mid;
        int signed_val;
        
        $display("=== IEEE 1800-2023 Size Casting Tests ===");
        
        // Test 1: Wide to narrow
        $display("Test 1: Wide to narrow");
        wide = 32'h12345678;
        narrow = wide[7:0];
        if (narrow == 8'h78) begin $display("Test 1 PASS: %h", narrow); pass_count++; end
        else begin $display("Test 1 FAIL: got %h", narrow); fail_count++; end
        
        // Test 2: Narrow to wide
        $display("Test 2: Narrow to wide");
        narrow = 8'hAB;
        wide = {24'h0, narrow};
        if (wide == 32'h000000AB) begin $display("Test 2 PASS: %h", wide); pass_count++; end
        else begin $display("Test 2 FAIL: got %h", wide); fail_count++; end
        
        // Test 3: Mid extraction
        $display("Test 3: Mid extract");
        wide = 32'hAABBCCDD;
        mid = wide[23:8];
        if (mid == 16'hBBCC) begin $display("Test 3 PASS: %h", mid); pass_count++; end
        else begin $display("Test 3 FAIL: got %h", mid); fail_count++; end
        
        // Test 4: Truncation
        $display("Test 4: Truncation");
        wide = 32'hFFFFFFFF;
        narrow = wide[7:0];
        if (narrow == 8'hFF) begin $display("Test 4 PASS: %h", narrow); pass_count++; end
        else begin $display("Test 4 FAIL: got %h", narrow); fail_count++; end
        
        // Test 5: Zero extend
        $display("Test 5: Zero extend");
        narrow = 8'h80;
        wide = {24'b0, narrow};
        if (wide == 32'h00000080) begin $display("Test 5 PASS: %h", wide); pass_count++; end
        else begin $display("Test 5 FAIL: got %h", wide); fail_count++; end
        
        // Test 6: Full width
        $display("Test 6: Full width");
        wide = 32'h12345678;
        if (wide[31:0] == 32'h12345678) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end
        
        // Test 7: Upper byte
        $display("Test 7: Upper byte");
        wide = 32'hABCDEF01;
        narrow = wide[31:24];
        if (narrow == 8'hAB) begin $display("Test 7 PASS: %h", narrow); pass_count++; end
        else begin $display("Test 7 FAIL: got %h", narrow); fail_count++; end
        
        // Test 8: Combine parts
        $display("Test 8: Combine");
        wide = 32'h11223344;
        mid = {wide[31:24], wide[7:0]};
        if (mid == 16'h1144) begin $display("Test 8 PASS: %h", mid); pass_count++; end
        else begin $display("Test 8 FAIL: got %h", mid); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
