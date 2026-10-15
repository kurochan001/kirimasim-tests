/*
:name: test_string_hextoa
:description: Test: String hextoa method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.12
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_hextoa.expected
*/
// Test: String hextoa method
// IEEE 1800-2023 Section 6.16.12 (the case of the letters a-f is not specified)

module test_string_hextoa;
    initial begin
        string s;
        int value;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple hex conversion
        value = 32'h1A;
        s.hextoa(value);
        if (s == "1a" || s == "1A") begin
            $display("PASS: hextoa(0x1A)");
            pass_count++;
        end else begin
            $display("FAIL: hextoa(0x1A) expected '1a' or '1A', got '%s'", s);
            fail_count++;
        end

        // Test 2: Zero
        value = 0;
        s.hextoa(value);
        if (s == "0") begin
            $display("PASS: hextoa(0)");
            pass_count++;
        end else begin
            $display("FAIL: hextoa(0) expected '0', got '%s'", s);
            fail_count++;
        end

        // Test 3: All hex digits
        value = 32'hABCDEF;
        s.hextoa(value);
        if (s == "abcdef" || s == "ABCDEF") begin
            $display("PASS: hextoa(0xABCDEF)");
            pass_count++;
        end else begin
            $display("FAIL: hextoa(0xABCDEF) expected 'abcdef' or 'ABCDEF', got '%s'", s);
            fail_count++;
        end

        // Test 4: Power of 2
        value = 32'h100;
        s.hextoa(value);
        if (s == "100") begin
            $display("PASS: hextoa(0x100)");
            pass_count++;
        end else begin
            $display("FAIL: hextoa(0x100) expected '100', got '%s'", s);
            fail_count++;
        end

        // Test 5: DEADBEEF pattern
        value = 32'hDEADBEEF;
        s.hextoa(value);
        if (s == "deadbeef" || s == "DEADBEEF") begin
            $display("PASS: hextoa(0xDEADBEEF)");
            pass_count++;
        end else begin
            $display("FAIL: hextoa(0xDEADBEEF) expected 'deadbeef' or 'DEADBEEF', got '%s'", s);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string hextoa tests passed");
        else
            $display("FAIL: Some string hextoa tests failed");

        $finish;
    end
endmodule
