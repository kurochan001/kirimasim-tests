/*
:name: test_string_itoa
:description: Test: String itoa method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_itoa.expected
*/
// Test: String itoa method
// IEEE 1800-2023 Section 6.16.1

module test_string_itoa;
    initial begin
        string s;
        int value;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Positive integer to string
        value = 12345;
        s.itoa(value);
        if (s == "12345") begin
            $display("PASS: itoa(12345) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(12345) expected '12345', got '%s'", s);
            fail_count++;
        end

        // Test 2: Zero
        value = 0;
        s.itoa(value);
        if (s == "0") begin
            $display("PASS: itoa(0) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(0) expected '0', got '%s'", s);
            fail_count++;
        end

        // Test 3: Negative integer
        value = -9876;
        s.itoa(value);
        if (s == "-9876") begin
            $display("PASS: itoa(-9876) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(-9876) expected '-9876', got '%s'", s);
            fail_count++;
        end

        // Test 4: Single digit
        value = 7;
        s.itoa(value);
        if (s == "7") begin
            $display("PASS: itoa(7) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(7) expected '7', got '%s'", s);
            fail_count++;
        end

        // Test 5: Large positive integer
        value = 2147483647;
        s.itoa(value);
        if (s == "2147483647") begin
            $display("PASS: itoa(2147483647) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: itoa(2147483647) expected '2147483647', got '%s'", s);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string itoa tests passed");
        else
            $display("FAIL: Some string itoa tests failed");

        $finish;
    end
endmodule
