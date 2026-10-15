/*
:name: test_blocking_in_clocked_always
:description: Test: blocking assignment intermediate value used by NBA in always @(posedge clk)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_blocking_in_clocked_always.expected
*/
// Test: blocking assignment intermediate value used by NBA in always @(posedge clk)
// This is a common Verilog pattern: use blocking assigns for intermediate
// combinational values within a clocked always block, then use those values
// as RHS of non-blocking assignments.
// IEEE 1800-2023 §10.4.1: blocking assignments execute in sequence

`timescale 1ns/1ps

module testbench;
    reg clk;
    reg resetn;

    initial begin
        clk = 0;
        resetn = 0;
    end

    always #5 clk = ~clk;

    // Intermediate variable (blocking assign target)
    reg [31:0] temp_val;

    // Registered outputs (NBA targets)
    reg [31:0] reg_a;
    reg [31:0] reg_b;

    integer cycle;
    initial cycle = 0;

    // A blocking assignment sets an intermediate value, then nonblocking
    // assignments use it
    always @(posedge clk) begin
        // Step 1: blocking assign to intermediate
        temp_val = reg_a + 1;

        if (!resetn) begin
            reg_a <= 0;
            reg_b <= 0;
        end else begin
            // Step 2: NBA uses the blocking-assigned intermediate
            reg_a <= temp_val;      // should be old reg_a + 1
            reg_b <= temp_val * 2;  // should be (old reg_a + 1) * 2
        end

        // Step 3: clear the intermediate value
        temp_val = 32'hxxxxxxxx;
    end

    integer test_pass, test_fail;
    initial begin
        test_pass = 0;
        test_fail = 0;
    end

    reg test_done;
    initial test_done = 0;

    always @(posedge clk) begin
        cycle = cycle + 1;

        if (cycle == 3) resetn <= 1;

        if (cycle > 3 && cycle <= 8) begin
            // temp_val is not printed: it is written by the other always
            // procedure at the same clock edge (4.7).
            $display("CYC[%0d] reg_a=%0d reg_b=%0d", cycle, reg_a, reg_b);
        end

        if (!test_done && cycle == 10) begin
            test_done <= 1;

            // After reset at cycle 3, reg_a should increment each cycle
            // cycle 4: reg_a=0 (just released reset)
            // cycle 5: reg_a=1 (0+1)
            // cycle 6: reg_a=2 (1+1)
            // ...
            // By cycle 10, reg_a should be >= 5
            if (reg_a >= 5) begin
                $display("PASS: A1 - reg_a incremented to %0d", reg_a);
                test_pass = test_pass + 1;
            end else begin
                $display("FAIL: A1 - reg_a = %0d (expected >= 5)", reg_a);
                test_fail = test_fail + 1;
            end

            // reg_b should be 2 * reg_a
            if (reg_b == reg_a * 2) begin
                $display("PASS: A2 - reg_b = %0d (= 2 * reg_a)", reg_b);
                test_pass = test_pass + 1;
            end else begin
                $display("FAIL: A2 - reg_b = %0d (expected %0d)", reg_b, reg_a * 2);
                test_fail = test_fail + 1;
            end

            $display("");
            $display("=== Results: %0d passed, %0d failed ===", test_pass, test_fail);
            if (test_fail == 0)
                $display("TEST PASSED");
            else
                $display("TEST FAILED");
            $finish;
        end
    end
endmodule
