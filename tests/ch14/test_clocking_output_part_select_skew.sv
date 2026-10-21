/*
:name: test_clocking_output_part_select_skew
:description: Two output clockvars that name parts of one signal drive them after their own skews (IEEE 1800-2023 Sections 14.4, 14.5)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.5 14.4 14.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_output_part_select_skew.expected
*/
// IEEE 1800-2023 §14.5: a clockvar may name an expression such as a
// part-select of a signal, through the form "name = expression". §14.4: each
// output clockvar drives its signal after its own skew. §14.16: a drive
// matures in the Re-NBA region of that time step. The lower nibble of q is
// driven with skew #2 and its upper nibble with skew #5 at the edge at 5, so
// q is 00 at 6, 0a at 8 and 5a at 11.

`timescale 1ns/1ns

module test_clocking_output_part_select_skew;
  logic clk = 0;
  logic [7:0] q = 0;

  always #5 clk = ~clk;   // posedge at 5

  clocking cb @(posedge clk);
    output #2 lo = q[3:0];
    output #5 hi = q[7:4];
  endclocking

  initial begin
    @(cb);
    cb.lo <= 4'hA;
    cb.hi <= 4'h5;
    #1 $display("%0d: q=%h", $time, q);
    #2 $display("%0d: q=%h", $time, q);
    #3 $display("%0d: q=%h", $time, q);
    $finish;
  end
endmodule
