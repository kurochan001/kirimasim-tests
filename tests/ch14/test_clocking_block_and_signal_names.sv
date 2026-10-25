/*
:name: test_clocking_block_and_signal_names
:description: A clocking block is named by an identifier and each signal it lists is named by an identifier; an input signal is sampled at the clocking event, so cb.d keeps the value d had just before the rising edge, and the output q is driven one time unit after the edge (IEEE 1800-2023 Sections 14.3 and 14.4)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.3 14.4 A.9.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_block_and_signal_names.expected
*/
// IEEE 1800-2023 A.9.3: a clocking identifier and a signal identifier are
// identifiers. §14.3: the clocking block cb is declared with the clocking
// event @(posedge clk) and lists the signal d as an input and q as an output;
// the clocking block scope names them as cb.d and cb.q. §14.4: the default
// input skew #1step samples the value just before the edge, and the output
// skew #1 drives q one time unit after the edge.
//
// d is 1 before the first rising edge at time 5, so cb.d is 1 at time 6. The
// assignment cb.q <= 1 before that edge drives q at time 6, and q is still 1
// at time 15. The test prints those two times.
//
// Icarus Verilog 13.0 has no clocking blocks; Verilator 5.052 produces this
// output.

`timescale 1ns/1ps

module test_clocking_block_and_signal_names;
  logic clk = 0, d = 0, q = 0;

  always #5 clk = ~clk;

  clocking cb @(posedge clk);
    default input #1step output #1;
    input d;
    output q;
  endclocking

  initial begin
    d = 1;
    #3;
    cb.q <= 1;
    @(cb);
    #1;
    $display("t %0d in %b %b", $time, cb.d, d);
    #9;
    $display("t %0d out %b", $time, q);
    #5 $finish;
  end
endmodule
