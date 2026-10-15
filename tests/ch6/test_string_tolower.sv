/*
:name: test_string_tolower
:description: Test: String tolower method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.5
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_tolower.expected
*/
// Test: String tolower method
// IEEE 1800-2023 Section 6.16.5

module test_string_tolower;
    initial begin
        string s, result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Convert uppercase to lowercase
        s = "HELLO";
        result = s.tolower();
        if (result == "hello") begin
            $display("PASS: tolower('HELLO') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: tolower('HELLO') expected 'hello', got '%s'", result);
            fail_count++;
        end

        // Test 2: Mixed case conversion
        s = "HeLLo WoRLd";
        result = s.tolower();
        if (result == "hello world") begin
            $display("PASS: tolower('HeLLo WoRLd') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: tolower expected 'hello world', got '%s'", result);
            fail_count++;
        end

        // Test 3: Already lowercase
        s = "lowercase";
        result = s.tolower();
        if (result == "lowercase") begin
            $display("PASS: tolower('lowercase') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: tolower expected 'lowercase', got '%s'", result);
            fail_count++;
        end

        // Test 4: With numbers and special characters
        s = "ABC123!@#";
        result = s.tolower();
        if (result == "abc123!@#") begin
            $display("PASS: tolower('ABC123!@#') = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: tolower expected 'abc123!@#', got '%s'", result);
            fail_count++;
        end

        // Test 5: Empty string
        s = "";
        result = s.tolower();
        if (result == "") begin
            $display("PASS: tolower('') = '' (empty string)");
            pass_count++;
        end else begin
            $display("FAIL: tolower('') expected '', got '%s'", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string tolower tests passed");
        else
            $display("FAIL: Some string tolower tests failed");

        $finish;
    end
endmodule
