/*
:name: test_cast_real
:description: Real type casts
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.1 6.12.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cast_real.expected
*/
// IEEE 1800-2023 §6.24: Real type casts
module test_cast_real;
    int pass_count = 0;
    int fail_count = 0;
    int ival;
    real rval;

    initial begin
        // Test 1: Int to real
        ival = 42;
        rval = real'(ival);
        if (rval == 42.0) begin
            $display("Test 1 PASS: int to real = %0f", rval);
            pass_count++;
        end else begin
            $display("Test 1 FAIL: got %0f", rval);
            fail_count++;
        end

        // Test 2: Negative int to real
        ival = -100;
        rval = real'(ival);
        if (rval == -100.0) begin
            $display("Test 2 PASS: neg int to real = %0f", rval);
            pass_count++;
        end else begin
            $display("Test 2 FAIL: got %0f", rval);
            fail_count++;
        end

        // Test 3: Zero to real
        ival = 0;
        rval = real'(ival);
        if (rval == 0.0) begin
            $display("Test 3 PASS: zero to real = %0f", rval);
            pass_count++;
        end else begin
            $display("Test 3 FAIL: got %0f", rval);
            fail_count++;
        end

        $display("Passed: %0d/3", pass_count);
        if (fail_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end
endmodule
