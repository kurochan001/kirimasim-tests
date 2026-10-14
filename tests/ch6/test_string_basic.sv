/*
:name: test_string_basic
:description: String Basic Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_basic.expected
*/
// IEEE 1800-2023 Section 6.16 - String Basic Tests
module test_string_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    initial begin
        string s1, s2, s3;
        
        $display("=== IEEE 1800-2023 String Basic Tests ===");
        
        // Test 1: String assign
        $display("Test 1: Assign");
        s1 = "Hello";
        if (s1 == "Hello") begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: String compare
        $display("Test 2: Compare");
        s2 = "Hello";
        if (s1 == s2) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Different strings
        $display("Test 3: Different");
        s3 = "World";
        if (s1 != s3) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end
        
        // Test 4: Length
        $display("Test 4: Length");
        if (s1.len() == 5) begin $display("Test 4 PASS: len=%0d", s1.len()); pass_count++; end
        else begin $display("Test 4 FAIL: len=%0d", s1.len()); fail_count++; end
        
        // Test 5: Empty string
        $display("Test 5: Empty");
        s2 = "";
        if (s2.len() == 0) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Concat
        $display("Test 6: Concat");
        s3 = {s1, " ", "World"};
        if (s3 == "Hello World") begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: got %s", s3); fail_count++; end
        
        // Test 7: Reassign
        $display("Test 7: Reassign");
        s1 = "New";
        if (s1 == "New" && s1.len() == 3) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Single char
        $display("Test 8: Single char");
        s1 = "X";
        if (s1.len() == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
