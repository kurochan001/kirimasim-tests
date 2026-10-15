/*
:name: test_string_icompare
:description: Test: String icompare method (case-insensitive compare)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.7
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_icompare.expected
*/
// Test: String icompare method (case-insensitive compare)
// IEEE 1800-2023 Section 6.16.6 and 6.16.7 (only the sign of the result is defined, as for C strcmp)

module test_string_icompare;
    initial begin
        string s1, s2;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Equal strings (same case)
        s1 = "hello";
        s2 = "hello";
        result = s1.icompare(s2);
        if (result == 0) begin
            $display("PASS: icompare('hello', 'hello') == 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare('hello', 'hello') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 2: Equal strings (different case)
        s1 = "Hello";
        s2 = "hello";
        result = s1.icompare(s2);
        if (result == 0) begin
            $display("PASS: icompare('Hello', 'hello') == 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare('Hello', 'hello') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 3: Mixed case comparison
        s1 = "HELLO WORLD";
        s2 = "hello world";
        result = s1.icompare(s2);
        if (result == 0) begin
            $display("PASS: icompare('HELLO WORLD', 'hello world') == 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare expected 0, got %0d", result);
            fail_count++;
        end

        // Test 4: First string less than second (case insensitive)
        s1 = "ABC";
        s2 = "abd";
        result = s1.icompare(s2);
        if (result < 0) begin
            $display("PASS: icompare('ABC', 'abd') < 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare('ABC', 'abd') expected < 0, got %0d", result);
            fail_count++;
        end

        // Test 5: First string greater than second (case insensitive)
        s1 = "xyz";
        s2 = "ABC";
        result = s1.icompare(s2);
        if (result > 0) begin
            $display("PASS: icompare('xyz', 'ABC') > 0");
            pass_count++;
        end else begin
            $display("FAIL: icompare('xyz', 'ABC') expected > 0, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string icompare tests passed");
        else
            $display("FAIL: Some string icompare tests failed");

        $finish;
    end
endmodule
