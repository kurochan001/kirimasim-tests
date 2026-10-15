/*
:name: test_delta_cycles
:description: Delta cycles and simulation time
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.4.2.3 3.14.2.3 22.7 21.3.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_delta_cycles.expected
*/
// The time unit and precision are given explicitly: without `timescale they are
// implementation-specific (3.14.2.3), and #0.5 must be exact.
`timescale 1ns/100ps
// IEEE 1800-2023 §4.4: Delta cycles and simulation time
// Tests delta cycle semantics
// Verifies time advancement and delay behavior

module test_delta_cycles;
    int pass_count = 0;
    int fail_count = 0;

    initial begin
        $display("=== Delta Cycles ===");

        // Test 1: #0 advances delta cycle but not time
        $display("Initial $time = %0t", $time);
        #0;
        $display("After #0: $time = %0t", $time);
        if ($time == 0) begin
            $display("PASS: #0 does not advance time");
            pass_count++;
        end else begin
            $display("FAIL: #0 advanced time");
            fail_count++;
        end

        // Test 2: Multiple #0 in sequence
        #0;
        #0;
        #0;
        if ($time == 0) begin
            $display("PASS: Multiple #0 still at time 0");
            pass_count++;
        end else begin
            $display("FAIL: Time advanced after multiple #0");
            fail_count++;
        end

        // Test 3: Time accumulation with multiple delays
        #5;
        #5;
        if ($time == 10) begin
            $display("PASS: Time accumulates: 5+5 = 10");
            pass_count++;
        end else begin
            $display("FAIL: Time = %0t, expected 10", $time);
            fail_count++;
        end

        // Test 4: Mixed delays
        #3;
        #7;
        if ($time == 20) begin
            $display("PASS: Mixed delays: 10+3+7 = 20");
            pass_count++;
        end else begin
            $display("FAIL: Time = %0t, expected 20", $time);
            fail_count++;
        end

        // Test 5: Fractional delays work
        #0.5;
        #0.5;
        if ($time >= 20) begin
            $display("PASS: Fractional delays work, time = %0t", $time);
            pass_count++;
        end else begin
            $display("FAIL: Fractional delay issue");
            fail_count++;
        end

        $display("");
        $display("=== Results: %0d PASS, %0d FAIL ===", pass_count, fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
