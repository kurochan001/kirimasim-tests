/*
:name: test_nba_cross_module
:description: Test: NBA cross-module visibility
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 10.4.2 4.6
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_nba_cross_module.expected
*/
// Test: NBA cross-module visibility
// IEEE 1800-2023 §4.3: All always @(posedge clk) blocks should sample
// pre-edge values. NBAs from one block must not be visible to another
// block at the same clock edge.

`timescale 1ns/1ps

module inner(
    input  wire        clk,
    input  wire        in_valid,
    input  wire        in_ready,
    output reg         out_trigger
);
    // Wire depends on both inputs
    wire xfer = in_valid && in_ready;

    reg [1:0] state;

    always @(posedge clk) begin
        case (state)
            0: begin
                if (in_valid) state <= 1;
            end
            1: begin
                if (xfer) state <= 0;  // xfer depends on in_ready
            end
        endcase
        // trigger fires when state=1 and xfer=1
        out_trigger <= (state == 1) && xfer;
    end

    initial begin
        state = 0;
        out_trigger = 0;
    end
endmodule

module testbench;
    reg clk;
    reg in_valid;
    reg in_ready;
    wire out_trigger;

    initial begin
        clk = 0;
        in_valid = 0;
        in_ready = 0;
    end

    always #5 clk = ~clk;

    inner dut(
        .clk(clk),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_trigger(out_trigger)
    );

    // Testbench always @(posedge clk) — generates in_ready with 1-cycle latency
    always @(posedge clk) begin
        in_ready <= 0;
        if (in_valid && !in_ready) begin
            in_ready <= 1;  // NBA: acknowledge after 1 cycle
        end
    end

    integer cycle;
    initial cycle = 0;

    integer test_pass, test_fail;
    initial begin
        test_pass = 0;
        test_fail = 0;
    end

    // Stimulus
    always @(posedge clk) begin
        cycle = cycle + 1;

        // Drive in_valid at cycle 3
        if (cycle == 3) in_valid <= 1;
        if (cycle == 5) in_valid <= 0;

        // Trace
        if (cycle >= 1 && cycle <= 12) begin
            $display("CYC[%0d] in_valid=%b in_ready=%b xfer=%b state=%0d trigger=%b",
                     cycle, in_valid, in_ready, dut.xfer, dut.state, out_trigger);
        end

        if (cycle == 12) begin
            // Check: trigger should have fired exactly once
            // Pattern should be:
            //   CYC3: in_valid=1, in_ready=0, state goes 0->1
            //   CYC4: in_valid=1, in_ready=0, state=1 (ready not yet visible)
            //   CYC5: in_valid=1, in_ready=1, state=1, xfer=1, trigger=1
            //   But wait - inner module should see in_ready from PRE-edge
            //   If inner sees in_ready=1 at same cycle as testbench sets it,
            //   trigger fires too early (1 cycle too soon)

            // Expected: out_trigger should fire at a predictable cycle
            // If trigger never fired, that's also wrong

            $display("");
            $display("=== Cross-Module NBA Test ===");

            // The critical test: state should transition to 0 when xfer is detected
            // If inner module sees in_ready=1 from the SAME clock edge as testbench
            // sets it, then xfer fires 1 cycle too early

            // In correct simulation (iverilog):
            // CYC4: in_ready becomes 1 (NBA from CYC3 applied)
            // CYC5: inner sees in_ready=1 (pre-edge), state=1, xfer=1
            //        -> trigger <= 1, state <= 0
            // CYC6: trigger=1 visible, state=0

            // In buggy simulation:
            // CYC3: testbench sets in_ready<=1
            //        inner ALSO sees in_ready=1 (should see 0)
            //        -> inner fires trigger 1 cycle early

            if (dut.state == 0) begin
                $display("PASS: A1 - state returned to 0 (handshake completed)");
                test_pass = test_pass + 1;
            end else begin
                $display("FAIL: A1 - state=%0d (expected 0)", dut.state);
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
