/*
:name: test_string_realtoa
:description: Test: String realtoa method
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.15 6.16.10
:oracle: spec iverilog@13.0 verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_realtoa.expected
*/
// Test: String realtoa method
// IEEE 1800-2023 Section 6.16.15 and 6.16.10

module test_string_realtoa;
    initial begin
        string s;
        real value;
        static int pass_count = 0;
        static int fail_count = 0;

        // Test 1: Simple real to string
        value = 3.14;
        s.realtoa(value);
        // The text form is not specified; realtoa is the inverse of atoreal (6.16.15)
        if (s.atoreal() == value) begin
            $display("PASS: realtoa(3.14) reads back with atoreal");
            pass_count++;
        end else begin
            $display("FAIL: realtoa(3.14) expected '3.14...', got '%s'", s);
            fail_count++;
        end

        // Test 2: Integer value as real
        value = 42.0;
        s.realtoa(value);
        if (s.atoreal() == value) begin
            $display("PASS: realtoa(42.0) reads back with atoreal");
            pass_count++;
        end else begin
            $display("FAIL: realtoa(42.0) expected '42...', got '%s'", s);
            fail_count++;
        end

        // Test 3: Zero
        value = 0.0;
        s.realtoa(value);
        if (s.atoreal() == value) begin
            $display("PASS: realtoa(0.0) reads back with atoreal");
            pass_count++;
        end else begin
            $display("FAIL: realtoa(0.0) expected '0...', got '%s'", s);
            fail_count++;
        end

        // Test 4: Negative real
        value = -123.456;
        s.realtoa(value);
        if (s.atoreal() == value) begin
            $display("PASS: realtoa(-123.456) reads back with atoreal");
            pass_count++;
        end else begin
            $display("FAIL: realtoa(-123.456) expected '-123...', got '%s'", s);
            fail_count++;
        end

        // Test 5: Small decimal
        value = 0.001;
        s.realtoa(value);
        if (s.atoreal() == value) begin
            $display("PASS: realtoa(0.001) reads back with atoreal");
            pass_count++;
        end else begin
            $display("FAIL: realtoa(0.001) expected '0.001...', got '%s'", s);
            fail_count++;
        end

        // Summary
        $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
        if (fail_count == 0)
            $display("PASS: All string realtoa tests passed");
        else
            $display("FAIL: Some string realtoa tests failed");

        $finish;
    end
endmodule
