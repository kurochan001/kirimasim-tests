/*
:name: test_string_toupper
:description: Test: String toupper method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_toupper.expected
*/
// Test: String toupper method
// IEEE 1800-2023 Section 6.16.4

module test_string_toupper;
    initial begin
        string s, result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Convert lowercase to uppercase
        s = "hello";
        result = s.toupper();
        if (result == "HELLO") begin
            $display("PASS: toupper('hello') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: toupper('hello') expected 'HELLO', got '%s'", result);
            fail_count++;
        end

        // Test 2: Mixed case conversion
        s = "HeLLo WoRLd";
        result = s.toupper();
        if (result == "HELLO WORLD") begin
            $display("PASS: toupper('HeLLo WoRLd') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: toupper expected 'HELLO WORLD', got '%s'", result);
            fail_count++;
        end

        // Test 3: Already uppercase
        s = "UPPERCASE";
        result = s.toupper();
        if (result == "UPPERCASE") begin
            $display("PASS: toupper('UPPERCASE') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: toupper expected 'UPPERCASE', got '%s'", result);
            fail_count++;
        end

        // Test 4: With numbers and special characters
        s = "abc123!@#";
        result = s.toupper();
        if (result == "ABC123!@#") begin
            $display("PASS: toupper('abc123!@#') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: toupper expected 'ABC123!@#', got '%s'", result);
            fail_count++;
        end

        // Test 5: Empty string
        s = "";
        result = s.toupper();
        if (result == "") begin
            $display("PASS: toupper('') = '' (empty string)");
            pass_count++;
        end else begin
            $display("FAIL: toupper('') expected '', got '%s'", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string toupper tests passed");
        else
            $display("FAIL: Some string toupper tests failed");

        $finish;
    end
endmodule
