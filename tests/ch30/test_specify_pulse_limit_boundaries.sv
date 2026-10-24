/*
:name: test_specify_pulse_limit_boundaries
:description: A pulse narrower than the reject limit is rejected, one at least as wide as the reject limit and narrower than the error limit becomes x, and one at least as wide as the error limit passes; both limits default to the delay, PATHPULSE$ with one value sets both, a module-wide PATHPULSE$ is overridden by a path-specific one, and only the first input and output of a multiple path declaration select its limits (IEEE 1800-2023 Section 30.7)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7 30.7.1 30.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_specify_pulse_limit_boundaries.expected
*/
// IEEE 1800-2023 §30.7: two scheduled transitions of a path output closer than
// the path delay form a pulse. A pulse narrower than the reject limit is
// rejected; one at least as wide as the reject limit but narrower than the
// error limit is filtered to x; one at least as wide as the error limit
// passes. Both limits default to the delay. §30.7.4.1: by default (on-event)
// an x pulse goes to x and back at the times its edges were scheduled.
// §30.7.1: PATHPULSE$ gives a reject limit and an optional error limit,
// constant min:typ:max expressions, for the path from one input to one output
// or, without terminals, for every path of the module; a path-specific one
// takes precedence over the module-wide one. With one value it is both
// limits. For a multiple path declaration only the first input and the first
// output name its limits, which apply to all of its paths, and a PATHPULSE$
// that names another pair is ignored.
//
// Every path has the delay 6, for both edges. The input p carries pulses of
// width 1 to 6, 20 time units apart, so each output pulse would be as wide as
// its input pulse and start 6 later.
//   pd: default limits 6 and 6: widths 1 to 5 rejected, 6 passes.
//   pl: (2:2:2, 4:4:4): 1 rejected, 2 and 3 x, 4 to 6 pass.
//   po: (3): 1 and 2 rejected, 3 to 6 pass (an error limit of 6 would make 3
//       to 5 x).
//   ps: PATHPULSE$ = (5) for all paths, PATHPULSE$b$z = (1, 2): y (from a)
//       rejects 1 to 4 and passes 5 and 6; z (from b) shows 1 as x and passes
//       2 to 6.
//   pm: (a, b *> y, z) with PATHPULSE$a$y = (1, 2) and PATHPULSE$b$z = (4, 5);
//       a stays 0 and the pulses come on b, so b->y and b->z use (1, 2): 1 is
//       x and 2 to 6 pass on both outputs.
// The changes of each output from time 20 on are recorded and printed at the
// end.
//
// Icarus Verilog 13.0 ignores PATHPULSE$ and rejects every pulse narrower
// than the delay.

`timescale 1ns/1ns

module pl_default_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 6;
  endspecify
endmodule

module pl_limits_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 6;
    specparam PATHPULSE$a$y = (2:2:2, 4:4:4);
  endspecify
endmodule

module pl_one_cell (input a, output y);
  buf (y, a);
  specify
    (a => y) = 6;
    specparam PATHPULSE$a$y = (3);
  endspecify
endmodule

module pl_scope_cell (input a, b, output y, z);
  buf (y, a);
  buf (z, b);
  specify
    (a => y) = 6;
    (b => z) = 6;
    specparam PATHPULSE$ = (5), PATHPULSE$b$z = (1, 2);
  endspecify
endmodule

module pl_multi_cell (input a, b, output y, z);
  or (y, a, b);
  or (z, a, b);
  specify
    (a, b *> y, z) = 6;
    specparam PATHPULSE$a$y = (1, 2), PATHPULSE$b$z = (4, 5);
  endspecify
endmodule

module test_specify_pulse_limit_boundaries;
  reg p = 0, zero = 0;
  wire yd, yl, yo, ysy, ysz, ymy, ymz;
  string ld = "", ll = "", lo = "", lsy = "", lsz = "", lmy = "", lmz = "";

  pl_default_cell pd (p, yd);
  pl_limits_cell pl (p, yl);
  pl_one_cell po (p, yo);
  pl_scope_cell ps (p, p, ysy, ysz);
  pl_multi_cell pm (zero, p, ymy, ymz);

  always @(yd) if ($time >= 20) ld = {ld, $sformatf(" %0d:%b", $time, yd)};
  always @(yl) if ($time >= 20) ll = {ll, $sformatf(" %0d:%b", $time, yl)};
  always @(yo) if ($time >= 20) lo = {lo, $sformatf(" %0d:%b", $time, yo)};
  always @(ysy) if ($time >= 20) lsy = {lsy, $sformatf(" %0d:%b", $time, ysy)};
  always @(ysz) if ($time >= 20) lsz = {lsz, $sformatf(" %0d:%b", $time, ysz)};
  always @(ymy) if ($time >= 20) lmy = {lmy, $sformatf(" %0d:%b", $time, ymy)};
  always @(ymz) if ($time >= 20) lmz = {lmz, $sformatf(" %0d:%b", $time, ymz)};

  initial begin
    #20 p = 1;
    #1 p = 0;     // 20 to 21: width 1
    #19 p = 1;
    #2 p = 0;     // 40 to 42: width 2
    #18 p = 1;
    #3 p = 0;     // 60 to 63: width 3
    #17 p = 1;
    #4 p = 0;     // 80 to 84: width 4
    #16 p = 1;
    #5 p = 0;     // 100 to 105: width 5
    #15 p = 1;
    #6 p = 0;     // 120 to 126: width 6
    #24 $display("pd y:%s", ld);
    $display("pl y:%s", ll);
    $display("po y:%s", lo);
    $display("ps y:%s", lsy);
    $display("ps z:%s", lsz);
    $display("pm y:%s", lmy);
    $display("pm z:%s", lmz);
  end
endmodule
