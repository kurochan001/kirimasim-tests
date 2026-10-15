/*
:name: test_assoc_array_ops
:description: Associative Array Operations Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8 7.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_array_ops.expected
*/
// IEEE 1800-2023 Section 7.8 - Associative Array Operations Tests
module test_assoc_array_ops;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int aa[string];
        int ia[int];
        string key;
        int ikey;

        $display("=== IEEE 1800-2023 Associative Array Operations Tests ===");

        // Test 1: String key set
        $display("Test 1: String key set");
        aa["one"] = 1;
        aa["two"] = 2;
        aa["three"] = 3;
        if (aa["two"] == 2) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", aa["two"]); fail_count++; end

        // Test 2: Num
        $display("Test 2: Num");
        if (aa.num() == 3) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", aa.num()); fail_count++; end

        // Test 3: Exists
        $display("Test 3: Exists");
        if (aa.exists("one") && !aa.exists("four")) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        // Test 4: Delete key
        $display("Test 4: Delete key");
        aa.delete("one");
        if (aa.num() == 2 && !aa.exists("one")) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        // Test 5: Int key
        $display("Test 5: Int key");
        ia[100] = 10;
        ia[200] = 20;
        ia[300] = 30;
        if (ia[200] == 20) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", ia[200]); fail_count++; end

        // Test 6: Modify value
        $display("Test 6: Modify value");
        ia[100] = 99;
        if (ia[100] == 99) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", ia[100]); fail_count++; end

        // Test 7: Delete all
        $display("Test 7: Delete all");
        aa.delete();
        if (aa.num() == 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", aa.num()); fail_count++; end

        // Test 8: Rebuild
        $display("Test 8: Rebuild");
        aa["x"] = 10;
        aa["y"] = 20;
        if (aa["x"] + aa["y"] == 30) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
