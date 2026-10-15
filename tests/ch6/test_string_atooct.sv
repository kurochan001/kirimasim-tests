/*
:name: test_string_atooct
:description: Test: String atooct method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atooct.expected
*/
// Test: String atooct method
// IEEE 1800-2023 Section 6.16.9

module test_string_atooct;
    initial begin
        string s;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple octal value
        s = "17";
        result = s.atooct();
        if (result == 8'o17) begin
            $display("PASS: atooct('17') = %0d (octal %o)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atooct('17') expected 15, got %0d", result);
            fail_count++;
        end

        // Test 2: Octal 777
        s = "777";
        result = s.atooct();
        if (result == 12'o777) begin
            $display("PASS: atooct('777') = %0d (0x%0h)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atooct('777') expected 511, got %0d", result);
            fail_count++;
        end

        // Test 3: Zero
        s = "0";
        result = s.atooct();
        if (result == 0) begin
            $display("PASS: atooct('0') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atooct('0') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 4: Single digit
        s = "7";
        result = s.atooct();
        if (result == 7) begin
            $display("PASS: atooct('7') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atooct('7') expected 7, got %0d", result);
            fail_count++;
        end

        // Test 5: Larger octal value
        s = "12345";
        result = s.atooct();
        if (result == 'o12345) begin
            $display("PASS: atooct('12345') = %0d (0x%0h)", result, result);
            pass_count++;
        end else begin
            $display("FAIL: atooct('12345') expected 5349, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string atooct tests passed");
        else
            $display("FAIL: Some string atooct tests failed");

        $finish;
    end
endmodule
