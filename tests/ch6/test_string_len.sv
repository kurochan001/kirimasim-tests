/*
:name: test_string_len
:description: String Length Tests
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_len.expected
*/
// IEEE 1800-2023 Section 6.16 - String Length Tests
module test_string_len;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        static string s1 = "hello";
        static string s2 = "";
        static string s3 = "a";
        static string s4 = "test string";

        $display("=== IEEE 1800-2023 String Length Tests ===");

        $display("Test 1: Hello len");
        if (s1.len() == 5) begin $display("Test 1 PASS"); pass_count++; end
        else begin $display("Test 1 FAIL: %0d", s1.len()); fail_count++; end

        $display("Test 2: Empty len");
        if (s2.len() == 0) begin $display("Test 2 PASS"); pass_count++; end
        else begin $display("Test 2 FAIL: %0d", s2.len()); fail_count++; end

        $display("Test 3: Single char");
        if (s3.len() == 1) begin $display("Test 3 PASS"); pass_count++; end
        else begin $display("Test 3 FAIL: %0d", s3.len()); fail_count++; end

        $display("Test 4: With space");
        if (s4.len() == 11) begin $display("Test 4 PASS"); pass_count++; end
        else begin $display("Test 4 FAIL: %0d", s4.len()); fail_count++; end

        $display("Test 5: After concat");
        s1 = {s1, " world"};
        if (s1.len() == 11) begin $display("Test 5 PASS"); pass_count++; end
        else begin $display("Test 5 FAIL: %0d", s1.len()); fail_count++; end

        $display("Test 6: Length compare");
        if (s1.len() == s4.len()) begin $display("Test 6 PASS"); pass_count++; end
        else begin $display("Test 6 FAIL"); fail_count++; end

        $display("Test 7: Non-zero check");
        if (s3.len() != 0) begin $display("Test 7 PASS"); pass_count++; end
        else begin $display("Test 7 FAIL"); fail_count++; end

        $display("Test 8: Zero check");
        if (s2.len() == 0) begin $display("Test 8 PASS"); pass_count++; end
        else begin $display("Test 8 FAIL"); fail_count++; end

        $display("\n=== Summary: %0d/%0d tests passed ===", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("TEST PASSED"); else $display("TEST FAILED");
        $finish;
    end
endmodule
