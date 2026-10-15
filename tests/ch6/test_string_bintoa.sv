/*
:name: test_string_bintoa
:description: Test: String bintoa method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_bintoa.expected
*/
// Test: String bintoa method
// IEEE 1800-2023 Section 6.16.1

module test_string_bintoa;
    initial begin
        string s;
        int value;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple binary conversion
        value = 4'b1010;
        s.bintoa(value);
        if (s == "1010") begin
            $display("PASS: bintoa(0b1010) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(0b1010) expected '1010', got '%s'", s);
            fail_count++;
        end

        // Test 2: Zero
        value = 0;
        s.bintoa(value);
        if (s == "0") begin
            $display("PASS: bintoa(0) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(0) expected '0', got '%s'", s);
            fail_count++;
        end

        // Test 3: All ones (8-bit)
        value = 8'b11111111;
        s.bintoa(value);
        if (s == "11111111") begin
            $display("PASS: bintoa(0b11111111) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(0b11111111) expected '11111111', got '%s'", s);
            fail_count++;
        end

        // Test 4: Single bit
        value = 1;
        s.bintoa(value);
        if (s == "1") begin
            $display("PASS: bintoa(1) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(1) expected '1', got '%s'", s);
            fail_count++;
        end

        // Test 5: Mixed pattern
        value = 8'b10110101;
        s.bintoa(value);
        if (s == "10110101") begin
            $display("PASS: bintoa(0b10110101) = '%s'", s);
            pass_count++;
        end else begin
            $display("FAIL: bintoa(0b10110101) expected '10110101', got '%s'", s);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string bintoa tests passed");
        else
            $display("FAIL: Some string bintoa tests failed");

        $finish;
    end
endmodule
