/*
:name: test_clocked_value_timing
:description: A variable updated by a clocked always procedure, read one time unit after each edge
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2 10.4.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocked_value_timing.expected
*/
// IEEE 1800-2023 §24: Program block timing
// A clocked always procedure and a reader that waits one time unit after each edge

`timescale 1ns/1ps

module test_clocked_value_timing_top;
    int pass_count = 0;
    int test_count = 0;

    logic clk = 0;
    logic [7:0] value = 0;

    // Clock generation with limited cycles
    initial begin
        repeat(20) begin
            #5 clk = ~clk;
        end
    end

    // DUT-like always block
    always @(posedge clk) begin
        value <= value + 1;
    end

    initial begin
        // Test 1: Initial block executes
        test_count++;
        pass_count++;
        $display("Test 1 PASS: initial block executes");

        // Test 2: Wait for clock edge
        test_count++;
        @(posedge clk);
        #1;
        if (value >= 1) begin
            pass_count++;
            $display("Test 2 PASS: value increments on clock (value=%0d)", value);
        end else begin
            $display("Test 2 FAIL: value=%0d", value);
        end

        // Test 3: Multiple clock edges
        test_count++;
        begin
            static logic [7:0] start_val;
            // Assigned here so the result does not depend on the order of static initializers.
            start_val = value;
            repeat(3) @(posedge clk);
            #1;
            if (value > start_val) begin
                pass_count++;
                $display("Test 3 PASS: multiple edges (start=%0d, end=%0d)", start_val, value);
            end else begin
                $display("Test 3 FAIL: value not increasing");
            end
        end

        // Test 4: Time progresses
        test_count++;
        begin
            time t1, t2;
            t1 = $time;
            @(posedge clk);
            t2 = $time;
            if (t2 > t1) begin
                pass_count++;
                $display("Test 4 PASS: time progresses (%0d -> %0d)", t1, t2);
            end else begin
                $display("Test 4 FAIL: time did not progress");
            end
        end

        $display("=== Program Timing Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        $finish;
    end
endmodule
