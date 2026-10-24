/*
:name: test_illegal_specify_ifnone_with_unconditional_path
:description: A module path cannot have both an ifnone delay and an unconditional simple path delay, while an ifnone delay next to conditional paths is legal (IEEE 1800-2023 Section 30.4.4.4)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the path from a to y has the delay ifnone (a => y) and the unconditional delay (a => y)
:expected_stderr_regex: test_illegal_specify_ifnone_with_unconditional_path\.sv:(30|31):
*/
// IEEE 1800-2023 §30.4.4.4: ifnone gives the delay of a path when all the
// conditions of its state-dependent paths are false, and it is illegal to
// specify both an ifnone condition and an unconditional simple module path
// for the same path. The path from b to z has a conditional delay and an
// ifnone delay, which is legal. The path from a to y has a conditional delay,
// an ifnone delay and an unconditional delay. A tool can report the conflict
// on the ifnone line or on the unconditional line.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design.

module siu_cell(input wire a, input wire b, input wire c, output wire y, output wire z);
  assign y = a;
  assign z = b;
  specify
    if (c) (b => z) = (1, 1);
    ifnone (b => z) = (2, 2);
    if (c) (a => y) = (1, 1);
    ifnone (a => y) = (2, 2);
    (a => y) = (3, 3);   // illegal: unconditional path next to ifnone
  endspecify
endmodule

module test_illegal_specify_ifnone_with_unconditional_path;
  logic a = 1'b1, b = 1'b0, c = 1'b1;
  wire y, z;
  siu_cell u (.a(a), .b(b), .c(c), .y(y), .z(z));
  initial #10 $display("%b %b", y, z);
endmodule
