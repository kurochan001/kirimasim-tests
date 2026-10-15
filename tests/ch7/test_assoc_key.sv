/*
:name: test_assoc_key
:description: Associative Array Key Tests
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assoc_key.expected
*/
// IEEE 1800-2023 Section 7.8 - Associative Array Key Tests
module test_assoc_key;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        int aa_int[string];
        string aa_str[int];
        int val;

        $display("=== IEEE 1800-2023 Associative Array Key Tests ===");

        $display("Test 1: String key set");
        aa_int["one"] = 1;
        aa_int["two"] = 2;
        if (aa_int["one"] == 1) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", aa_int["one"]); fail_count++; end

        $display("Test 2: String key get");
        if (aa_int["two"] == 2) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", aa_int["two"]); fail_count++; end

        $display("Test 3: Int key set");
        aa_str[10] = "ten";
        aa_str[20] = "twenty";
        if (aa_str[10] == "ten") begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Int key get");
        if (aa_str[20] == "twenty") begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL"); fail_count++; end

        $display("Test 5: Modify value");
        aa_int["one"] = 100;
        if (aa_int["one"] == 100) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", aa_int["one"]); fail_count++; end

        $display("Test 6: Add new key");
        aa_int["three"] = 3;
        if (aa_int["three"] == 3) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", aa_int["three"]); fail_count++; end

        $display("Test 7: Size check");
        if (aa_int.num() == 3) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL: %0d", aa_int.num()); fail_count++; end

        $display("Test 8: Delete key");
        aa_int.delete("two");
        if (aa_int.num() == 2) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL: %0d", aa_int.num()); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
