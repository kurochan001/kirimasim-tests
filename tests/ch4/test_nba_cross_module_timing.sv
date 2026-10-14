/*
:name: test_nba_cross_module_timing
:description: Track exact NBA timing between parent and child modules
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nba_cross_module_timing.expected
*/
// Track exact NBA timing between parent and child modules
`timescale 1ns/1ps

module inner(
    input  wire        clk,
    input  wire        in_flag,
    output reg  [7:0]  out_state
);
    always @(posedge clk) begin
        if (in_flag)
            out_state <= out_state + 1;
    end

    initial out_state = 0;
endmodule

module testbench;
    reg clk;
    reg flag;
    wire [7:0] child_state;

    initial begin
        clk = 0;
        flag = 0;
    end

    always #5 clk = ~clk;

    inner dut(.clk(clk), .in_flag(flag), .out_state(child_state));

    integer cycle;
    initial cycle = 0;

    integer test_pass, test_fail;
    initial begin
        test_pass = 0;
        test_fail = 0;
    end

    always @(posedge clk) begin
        cycle = cycle + 1;

        // Set flag at cycle 2
        if (cycle == 2) flag <= 1;
        if (cycle == 4) flag <= 0;

        // Display at each cycle
        if (cycle >= 1 && cycle <= 8) begin
            $display("CYC[%0d] flag=%b dut.out_state=%0d child_state=%0d",
                     cycle, flag, dut.out_state, child_state);
        end

        // Per-cycle value checks (IEEE 1800-2023 §4.3 cross-module NBA timing)
        // CYC[1]: flag=0, out_state=0 (initial)
        if (cycle == 1) begin
            if (dut.out_state == 0) begin test_pass = test_pass + 1; end
            else begin $display("FAIL: A1 - CYC[1] out_state=%0d (expected 0)", dut.out_state); test_fail = test_fail + 1; end
        end
        // CYC[2]: flag<=1 scheduled (not yet visible), out_state=0
        if (cycle == 2) begin
            if (dut.out_state == 0) begin test_pass = test_pass + 1; end
            else begin $display("FAIL: A2 - CYC[2] out_state=%0d (expected 0)", dut.out_state); test_fail = test_fail + 1; end
        end
        // CYC[3]: flag=1 visible, inner samples flag=1, out_state<=1 scheduled, $display sees pre-NBA out_state=0
        if (cycle == 3) begin
            if (dut.out_state == 0) begin test_pass = test_pass + 1; end
            else begin $display("FAIL: A3 - CYC[3] out_state=%0d (expected 0)", dut.out_state); test_fail = test_fail + 1; end
        end
        // CYC[4]: out_state=1 visible, flag<=0 scheduled, inner sees flag=1 (pre-NBA), out_state<=2
        if (cycle == 4) begin
            if (dut.out_state == 1) begin test_pass = test_pass + 1; end
            else begin $display("FAIL: A4 - CYC[4] out_state=%0d (expected 1)", dut.out_state); test_fail = test_fail + 1; end
        end
        // CYC[5]: out_state=2, flag=0 visible
        if (cycle == 5) begin
            if (dut.out_state == 2) begin test_pass = test_pass + 1; end
            else begin $display("FAIL: A5 - CYC[5] out_state=%0d (expected 2)", dut.out_state); test_fail = test_fail + 1; end
        end

        if (cycle == 8) begin
            $display("");
            $display("=== Cross-Module NBA Timing ===");

            // Final check: out_state should be 2 (inner saw flag=1 at CYC[3] and CYC[4])
            if (dut.out_state == 2) begin
                $display("PASS: A6 - out_state=%0d (expected 2)", dut.out_state);
                test_pass = test_pass + 1;
            end else begin
                $display("FAIL: A6 - out_state=%0d (expected 2)", dut.out_state);
                test_fail = test_fail + 1;
            end

            $display("=== Results: %0d passed, %0d failed ===", test_pass, test_fail);
            if (test_fail == 0)
                $display("TEST PASSED");
            else
                $display("TEST FAILED");
            $finish;
        end
    end
endmodule
