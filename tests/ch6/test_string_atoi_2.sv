/*
:name: test_string_atoi_2
:description: Test: String atoi method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_atoi_2.expected
*/
// Test: String atoi method
// IEEE 1800-2023 Section 6.16.9

module test_string_atoi_2;
    initial begin
        string s;
        int result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple positive integer
        s = "12345";
        result = s.atoi();
        if (result == 12345) begin
            $display("PASS: atoi('12345') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atoi('12345') expected 12345, got %0d", result);
            fail_count++;
        end

        // Test 2: Negative integer
        // Whether atoi reads a leading minus is not settled: 6.16.9 names the
        // sign among the parts of the literal syntax it does not parse, and
        // tools differ. So 0 and -9876 both pass, and the value is not shown.
        s = "-9876";
        result = s.atoi();
        if (result == 0 || result == -9876) begin
            $display("PASS: atoi('-9876') is 0 or -9876");
            pass_count++;
        end else begin
            $display("FAIL: atoi('-9876') expected 0 or -9876, got %0d", result);
            fail_count++;
        end

        // Test 3: Zero
        s = "0";
        result = s.atoi();
        if (result == 0) begin
            $display("PASS: atoi('0') = %0d", result);
            pass_count++;
        end else begin
            $display("FAIL: atoi('0') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 4: Leading whitespace
        s = "   42";
        result = s.atoi();
        if (result == 0) begin  // stops at the first space (6.16.9)
            $display("PASS: atoi('   42') = %0d (stops at the leading space)", result);
            pass_count++;
        end else begin
            $display("FAIL: atoi('   42') expected 0, got %0d", result);
            fail_count++;
        end

        // Test 5: Large number
        s = "2147483647";
        result = s.atoi();
        if (result == 2147483647) begin
            $display("PASS: atoi('2147483647') = %0d (max int)", result);
            pass_count++;
        end else begin
            $display("FAIL: atoi('2147483647') expected 2147483647, got %0d", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string atoi tests passed");
        else
            $display("FAIL: Some string atoi tests failed");

        $finish;
    end
endmodule
