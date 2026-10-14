/*
:name: test_string_substr
:description: Test: String substr method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.8
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_string_substr.expected
*/
// Test: String substr method
// IEEE 1800-2023 Section 6.16.1

module test_string_substr;
    initial begin
        string s, result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Extract substring from beginning
        s = "Hello World";
        result = s.substr(0, 4);
        if (result == "Hello") begin
            $display("PASS: substr(0, 4) = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: substr(0, 4) expected 'Hello', got '%s'", result);
            fail_count++;
        end

        // Test 2: Extract substring from middle
        s = "Hello World";
        result = s.substr(6, 10);
        if (result == "World") begin
            $display("PASS: substr(6, 10) = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: substr(6, 10) expected 'World', got '%s'", result);
            fail_count++;
        end

        // Test 3: Extract single character
        s = "ABCDE";
        result = s.substr(2, 2);
        if (result == "C") begin
            $display("PASS: substr(2, 2) = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: substr(2, 2) expected 'C', got '%s'", result);
            fail_count++;
        end

        // Test 4: Extract with numbers
        s = "abc123xyz";
        result = s.substr(3, 5);
        if (result == "123") begin
            $display("PASS: substr(3, 5) = '%s'", result);
            pass_count++;
        end else begin
            $display("FAIL: substr(3, 5) expected '123', got '%s'", result);
            fail_count++;
        end

        // Test 5: Extract entire string
        s = "test";
        result = s.substr(0, 3);
        if (result == "test") begin
            $display("PASS: substr(0, 3) = '%s' (entire string)", result);
            pass_count++;
        end else begin
            $display("FAIL: substr(0, 3) expected 'test', got '%s'", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string substr tests passed");
        else
            $display("FAIL: Some string substr tests failed");

        $finish;
    end
endmodule
