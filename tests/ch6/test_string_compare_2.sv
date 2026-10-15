/*
:name: test_string_compare_2
:description: Test: String compare method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.6
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_compare_2.expected
*/
// Test: String compare method
// IEEE 1800-2023 Section 6.16.6 and 6.16.7 (only the sign of the result is defined, as for C strcmp)

module test_string_compare_2;
    initial begin
        string s1, s2;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Equal strings
        s1 = "hello";
        s2 = "hello";
        result = s1.compare(s2);
        if (result == 0) begin
            $display("PASS: compare('hello', 'hello') == 0");
            pass_count++;
        end else begin
            $display("FAIL: compare('hello', 'hello') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 2: First string less than second (lexicographic)
        s1 = "abc";
        s2 = "abd";
        result = s1.compare(s2);
        if (result < 0) begin
            $display("PASS: compare('abc', 'abd') < 0");
            pass_count++;
        end else begin
            $display("FAIL: compare('abc', 'abd') expected < 0, got %0d", result);
            fail_count++;
        end

        // Test 3: First string greater than second
        s1 = "xyz";
        s2 = "abc";
        result = s1.compare(s2);
        if (result > 0) begin
            $display("PASS: compare('xyz', 'abc') > 0");
            pass_count++;
        end else begin
            $display("FAIL: compare('xyz', 'abc') expected > 0, got %0d", result);
            fail_count++;
        end

        // Test 4: Case sensitive comparison
        s1 = "Hello";
        s2 = "hello";
        result = s1.compare(s2);
        if (result != 0) begin
            $display("PASS: compare('Hello', 'hello') != 0");
            pass_count++;
        end else begin
            $display("FAIL: compare('Hello', 'hello') expected != 0, got %0d", result);
            fail_count++;
        end

        // Test 5: Different length strings
        s1 = "hello";
        s2 = "hello world";
        result = s1.compare(s2);
        if (result < 0) begin
            $display("PASS: compare('hello', 'hello world') < 0");
            pass_count++;
        end else begin
            $display("FAIL: compare('hello', 'hello world') expected < 0, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string compare tests passed");
        else
            $display("FAIL: Some string compare tests failed");

        $finish;
    end
endmodule
