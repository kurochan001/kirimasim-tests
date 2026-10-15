/*
:name: test_string_octtoa
:description: Test: String octtoa method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_octtoa.expected
*/
// Test: String octtoa method
// IEEE 1800-2023 Section 6.16.1

module test_string_octtoa;
    initial begin
        string s;
        int value;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple octal conversion
        value = 8'o17;
        s.octtoa(value);
        if (s == "17") begin
            $display("PASS: octtoa(0o17) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(0o17) expected '17', got '%s'", s);
            fail_count++;
        end

        // Test 2: Zero
        value = 0;
        s.octtoa(value);
        if (s == "0") begin
            $display("PASS: octtoa(0) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(0) expected '0', got '%s'", s);
            fail_count++;
        end

        // Test 3: Octal 777
        value = 12'o777;
        s.octtoa(value);
        if (s == "777") begin
            $display("PASS: octtoa(0o777) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(0o777) expected '777', got '%s'", s);
            fail_count++;
        end

        // Test 4: Single digit
        value = 7;
        s.octtoa(value);
        if (s == "7") begin
            $display("PASS: octtoa(7) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(7) expected '7', got '%s'", s);
            fail_count++;
        end

        // Test 5: Larger value
        value = 'o12345;
        s.octtoa(value);
        if (s == "12345") begin
            $display("PASS: octtoa(0o12345) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: octtoa(0o12345) expected '12345', got '%s'", s);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string octtoa tests passed");
        else
            $display("FAIL: Some string octtoa tests failed");

        $finish;
    end
endmodule
