/*
:name: test_nba_port_propagation
:description: NBA write should propagate through port connections
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.3 10.4.2 4.9.6 10.3
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nba_port_propagation.expected
*/
// NBA write should propagate through port connections
// within the same time step (IEEE 1800-2023 §4.3).
//
// Expected: child sees parent's NBA-updated value at the next posedge.

`timescale 1ns / 1ps

module child (
    input  logic       clk,
    input  logic       valid_i,
    output logic [7:0] result_o
);
    // Combinational: should update whenever valid_i changes
    assign result_o = valid_i ? 8'hAA : 8'h00;
endmodule

module testbench;
    logic clk = 0;
    always #5 clk = ~clk;

    logic valid;
    wire [7:0] result;

    child u_child (
        .clk      (clk),
        .valid_i  (valid),
        .result_o (result)
    );

    integer cycle = 0;

    // Parent drives valid via NBA (like a typical always_ff)
    always @(posedge clk) begin
        cycle <= cycle + 1;

        if (cycle == 0) begin
            valid <= 1'b0;
        end else if (cycle == 1) begin
            valid <= 1'b1;  // NBA: set valid=1
        end

        // At cycle 2, child should see valid=1 and result should be 0xAA
        if (cycle == 2) begin
            $display("cycle=%0d valid=%0b result=%02x", cycle, valid, result);
            if (result === 8'hAA) begin
                $display("TEST PASSED");
                $finish;
            end else begin
                $display("FAIL: expected result=AA, got %02x", result);
                $fatal;
            end
        end

        if (cycle > 10) begin
            $display("FAIL: timeout");
            $fatal;
        end
    end

    initial begin
        valid = 1'b0;
        #1;
    end
endmodule
