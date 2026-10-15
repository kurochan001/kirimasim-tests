/*
:name: test_cast_shortint
:description: Shortint type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_shortint.expected
*/
// IEEE 1800-2023 §6.24: Shortint type casts
module test_cast_shortint;
    int pass_count = 0;
    int fail_count = 0;
    shortint sival;
    int ival;

    initial begin
        // Test 1: Int to shortint
        ival = 1000;
        sival = shortint'(ival);
        if (sival == 1000) begin
            $display("Test 1 PASS: int to shortint = %0d", sival);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0d", sival);
            fail_count++;
        end

        // Test 2: Truncation
        ival = 32'h12345678;
        sival = shortint'(ival);
        if (sival == 16'h5678) begin
            $display("Test 2 PASS: truncate = %04h", sival);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %04h", sival);
            fail_count++;
        end

        // Test 3: Negative value
        ival = -100;
        sival = shortint'(ival);
        if (sival == -100) begin
            $display("Test 3 PASS: negative = %0d", sival);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0d", sival);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
