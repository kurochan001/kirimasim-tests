/*
:name: test_assoc_ops
:description: Associative Array Operations Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_ops.expected
*/
// IEEE 1800-2023 Section 7.8 - Associative Array Operations Tests
module test_assoc_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int aa[string];
        int ai[int];
        string key;
        int val;

        $display("=== IEEE 1800-2023 Associative Array Operations Tests ===");

        // Test 1: String key insert
        $display("Test 1: String insert");
        aa["one"] = 1;
        aa["two"] = 2;
        if (aa["one"] == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", aa["one"]); fail_count++; end

        // Test 2: Num method
        $display("Test 2: Num");
        if (aa.num() == 2) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", aa.num()); fail_count++; end

        // Test 3: Exists
        $display("Test 3: Exists");
        if (aa.exists("two")) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Not exists
        $display("Test 4: Not exists");
        if (!aa.exists("three")) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Int key
        $display("Test 5: Int key");
        ai[100] = 1000;
        ai[200] = 2000;
        if (ai[100] == 1000) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", ai[100]); fail_count++; end

        // Test 6: Delete key
        $display("Test 6: Delete");
        aa.delete("one");
        if (aa.num() == 1) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", aa.num()); fail_count++; end

        // Test 7: Update value
        $display("Test 7: Update");
        aa["two"] = 22;
        if (aa["two"] == 22) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", aa["two"]); fail_count++; end

        // Test 8: Size
        $display("Test 8: Size");
        if (aa.size() == 1) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", aa.size()); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
