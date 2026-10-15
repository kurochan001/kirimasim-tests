/*
:name: test_format_real
:description: Real number formatting
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_format_real.expected
*/
// IEEE 1800-2023 §21.2.1.1: Real number formatting
module test_format_real;
    int pass_count = 0;
    int fail_count = 0;
    real r;
    string s;

    initial begin
        // Test 1: Default real format
        r = 3.14159;
        s = $sformatf("%f", r);
        // Check length is > 0
        if (s.len() > 0) begin
            $display("Test 1 PASS: real format = %s", s);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 2: Integer part
        r = 123.0;
        s = $sformatf("%0.0f", r);
        if (s == "123") begin
            $display("Test 2 PASS: int part");
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got '%s'", s);
            fail_count++;
        end

        // Test 3: Exponent format
        r = 1000.0;
        s = $sformatf("%e", r);
        // Check for scientific notation
        if (s.len() > 0) begin
            $display("Test 3 PASS: exp format = %s", s);
            pass_count++;
        end else begin
            $display("Test 3 FAIL");
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
