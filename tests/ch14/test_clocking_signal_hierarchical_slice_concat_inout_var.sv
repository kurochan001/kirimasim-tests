/*
:name: test_clocking_signal_hierarchical_slice_concat_inout_var
:description: Clockvars can be associated by an expression with a signal in another module, with a slice, with a concatenation of local and cross-module signals, and with an output slice, and a clocking inout can use a variable (IEEE 1800-2023 Section 14.5)
:tags: ch14
:type: simulation
:lrm: 1800-2023 14.5 14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_clocking_signal_hierarchical_slice_concat_inout_var.expected
*/
// IEEE 1800-2023 §14.3, §14.5: "= expression" after a clockvar name
// associates the clockvar with that expression instead of a signal of the
// same name, for example a signal of another module reached by a
// hierarchical name, and the expression can also be a slice or a
// concatenation of signals of the current scope or of other scopes, as
// long as it could be connected to a module port of that direction. A
// clocking inout only has to be legal both as an input and as an output,
// so a variable can be its signal.
//
// With the default skews (input 1step, output 0), the values set at 2 are
// sampled at the clocking event at 5:
//   st    = u.state (cross-module)          -> 9
//   low   = regb[2:0] (local slice)         -> 3'b110
//   mix   = {u.state[1:0], rega} (concat)   -> 6'b01_1010
//   q     (inout, a variable)               -> 8'h11
// and the drives at 5, cb.q <= 8'h22 and cb.o <= 2'b11 with o = outv[1:0],
// change q and the low two bits of outv at 5; at 6 cb.q still holds the
// value sampled at 5.

`timescale 1ns/1ns

module state_holder;
  logic [3:0] state = 4'd0;
endmodule

module test_clocking_signal_hierarchical_slice_concat_inout_var;
  state_holder u ();
  logic clk = 0;
  logic [3:0] rega = 4'd0;
  logic [7:0] regb = 8'd0;
  logic [7:0] q = 8'd0;
  logic [3:0] outv = 4'd0;

  always #5 clk = ~clk;   // posedges at 5, 15, ...

  clocking cb @(posedge clk);
    input st = u.state;
    input low = regb[2:0];
    input mix = {u.state[1:0], rega};
    inout q;
    output o = outv[1:0];
  endclocking

  initial begin
    #2;
    u.state = 4'd9;
    rega = 4'hA;
    regb = 8'b0101_0110;
    q = 8'h11;
    @(cb);
    $display("t=%0t cb.st=%0d cb.low=%b cb.mix=%b cb.q=%h", $time, cb.st, cb.low, cb.mix, cb.q);
    cb.q <= 8'h22;
    cb.o <= 2'b11;
    #1;
    $display("t=%0t q=%h outv=%b cb.q=%h", $time, q, outv, cb.q);
    $finish;
  end
endmodule
