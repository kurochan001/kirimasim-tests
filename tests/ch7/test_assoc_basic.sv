/*
:name: test_assoc_basic
:description: Associative Array Basic Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_basic.expected
*/
// IEEE 1800-2023 Section 7.8 - Associative Array Basic Tests
module test_assoc_basic;
    int pass_count = 0;
    int fail_count = 0;
    
    int aa[string];
    int nums[int];
    
    initial begin
        $display("=== IEEE 1800-2023 Assoc Array Basic Tests ===");
        
        // Test 1: String key assign
        $display("Test 1: String key");
        aa["one"] = 1;
        if (aa["one"] == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end
        
        // Test 2: Multiple entries
        $display("Test 2: Multiple");
        aa["two"] = 2;
        aa["three"] = 3;
        if (aa["two"] == 2 && aa["three"] == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end
        
        // Test 3: Num returns count
        $display("Test 3: Num");
        if (aa.num() == 3) begin $display("Test 3 PASS: num=%0d", aa.num()); pass_count++; end
        else begin $display("Test 3 FAIL: num=%0d", aa.num()); fail_count++; end
        
        // Test 4: Int key
        $display("Test 4: Int key");
        nums[100] = 1000;
        nums[200] = 2000;
        if (nums[100] == 1000) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end
        
        // Test 5: Exists
        $display("Test 5: Exists");
        if (aa.exists("one")) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL"); fail_count++; end
        
        // Test 6: Delete entry
        $display("Test 6: Delete");
        aa.delete("one");
        if (aa.num() == 2) begin $display("Test 6 PASS: num=%0d", aa.num()); pass_count++; end
        else begin $display("Test 6 FAIL: num=%0d", aa.num()); fail_count++; end
        
        // Test 7: Update
        $display("Test 7: Update");
        aa["two"] = 22;
        if (aa["two"] == 22) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end
        
        // Test 8: Clear
        $display("Test 8: Clear");
        aa.delete();
        if (aa.num() == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: num=%0d", aa.num()); fail_count++; end
        
        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
