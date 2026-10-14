/*
:name: test_string_atoreal
:description: Test: String atoreal method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.1 6.16.9
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_string_atoreal.expected
*/
// Test: String atoreal method
// IEEE 1800-2023 Section 6.16.1

module test_string_atoreal;
    initial begin
        string s;
        real result;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple real value
        s = "3.14";
        result = s.atoreal();
        if (result > 3.13 && result < 3.15) begin
            $display("PASS: atoreal('3.14') = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: atoreal('3.14') expected ~3.14, got %f", result);
            fail_count++;
        end

        // Test 2: Integer as real
        s = "42";
        result = s.atoreal();
        if (result == 42.0) begin
            $display("PASS: atoreal('42') = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: atoreal('42') expected 42.0, got %f", result);
            fail_count++;
        end

        // Test 3: Negative real
        s = "-123.456";
        result = s.atoreal();
        if (result > -123.46 && result < -123.45) begin
            $display("PASS: atoreal('-123.456') = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: atoreal('-123.456') expected ~-123.456, got %f", result);
            fail_count++;
        end

        // Test 4: Zero
        s = "0.0";
        result = s.atoreal();
        if (result == 0.0) begin
            $display("PASS: atoreal('0.0') = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: atoreal('0.0') expected 0.0, got %f", result);
            fail_count++;
        end

        // Test 5: Scientific notation
        s = "1.5e3";
        result = s.atoreal();
        if (result > 1499.0 && result < 1501.0) begin
            $display("PASS: atoreal('1.5e3') = %f", result);
            pass_count++;
        end else begin
            $display("FAIL: atoreal('1.5e3') expected ~1500.0, got %f", result);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string atoreal tests passed");
        else
            $display("FAIL: Some string atoreal tests failed");

        $finish;
    end
endmodule
