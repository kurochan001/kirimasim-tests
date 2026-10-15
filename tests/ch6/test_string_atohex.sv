/*
:name: test_string_atohex
:description: Test: String atohex method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atohex.expected
*/
// Test: String atohex method
// IEEE 1800-2023 Section 6.16.1

module test_string_atohex;
    initial begin
        string s;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple hex value
        s = "1A";
        result = s.atohex();
        if (result == 32'h1A) begin
            $display("PASS: atohex('1A') = 0x%0h", result);
            pass_count++;
        end else begin
            $display("FAIL: atohex('1A') expected 0x1A, got 0x%0h", result);
            fail_count++;
        end

        // Test 2: Lowercase hex
        s = "ff";
        result = s.atohex();
        if (result == 32'hFF) begin
            $display("PASS: atohex('ff') = 0x%0h", result);
            pass_count++;
        end else begin
            $display("FAIL: atohex('ff') expected 0xFF, got 0x%0h", result);
            fail_count++;
        end

        // Test 3: Mixed case hex
        s = "AbCd";
        result = s.atohex();
        if (result == 32'hABCD) begin
            $display("PASS: atohex('AbCd') = 0x%0h", result);
            pass_count++;
        end else begin
            $display("FAIL: atohex('AbCd') expected 0xABCD, got 0x%0h", result);
            fail_count++;
        end

        // Test 4: Zero
        s = "0";
        result = s.atohex();
        if (result == 0) begin
            $display("PASS: atohex('0') = 0x%0h", result);
            pass_count++;
        end else begin
            $display("FAIL: atohex('0') expected 0x0, got 0x%0h", result);
            fail_count++;
        end

        // Test 5: Larger hex value
        s = "DEADBEEF";
        result = s.atohex();
        if (result == 32'hDEADBEEF) begin
            $display("PASS: atohex('DEADBEEF') = 0x%0h", result);
            pass_count++;
        end else begin
            $display("FAIL: atohex('DEADBEEF') expected 0xDEADBEEF, got 0x%0h", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string atohex tests passed");
        else
            $display("FAIL: Some string atohex tests failed");

        $finish;
    end
endmodule
