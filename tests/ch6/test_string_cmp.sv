/*
:name: test_string_cmp
:description: String Compare Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_cmp.expected
*/
// IEEE 1800-2023 Section 6.16 - String Compare Tests
module test_string_cmp;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        string s1, s2;

        $display("=== IEEE 1800-2023 String Compare Tests ===");

        $display("Test 1: Equal");
        s1 = "hello";
        s2 = "hello";
        if (s1 == s2) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL"); fail_count++; end

        $display("Test 2: Not equal");
        s2 = "world";
        if (s1 != s2) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL"); fail_count++; end

        $display("Test 3: Empty");
        s1 = "";
        s2 = "";
        if (s1 == s2) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL"); fail_count++; end

        $display("Test 4: Concat");
        s1 = "hello";
        s2 = " world";
        s1 = {s1, s2};
        if (s1 == "hello world") begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %s", s1); fail_count++; end

        $display("Test 5: Length");
        s1 = "test";
        if (s1.len() == 4) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", s1.len()); fail_count++; end

        $display("Test 6: Empty len");
        s1 = "";
        if (s1.len() == 0) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL: %0d", s1.len()); fail_count++; end

        $display("Test 7: Assign");
        s1 = "abc";
        s2 = s1;
        if (s2 == "abc") begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Case diff");
        s1 = "ABC";
        s2 = "abc";
        if (s1 != s2) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
