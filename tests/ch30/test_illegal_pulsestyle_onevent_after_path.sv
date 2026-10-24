/*
:name: test_illegal_pulsestyle_onevent_after_path
:description: A pulsestyle_onevent declaration cannot name a module path output that has already appeared in a path declaration, while one placed before the path of its output is legal (IEEE 1800-2023 Section 30.7.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: pulsestyle_onevent names y after the path declaration (a => y)
:expected_stderr_regex: test_illegal_pulsestyle_onevent_after_path\.sv:27:
*/
// IEEE 1800-2023 §30.7.4.1: it is an error if a module path output appears in
// a pulse style declaration after it has already appeared in a module path
// declaration. pulsestyle_onevent z comes before the path to z, which is
// legal; pulsestyle_onevent y comes after the path to y.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design.

module pse_cell(input wire a, input wire b, output wire y, output wire z);
  assign y = a;
  assign z = b;
  specify
    pulsestyle_onevent z;
    (b => z) = (3, 3);
    (a => y) = (3, 3);
    pulsestyle_onevent y;   // illegal: y already appeared in a path declaration
  endspecify
endmodule

module test_illegal_pulsestyle_onevent_after_path;
  logic a = 1'b1, b = 1'b0;
  wire y, z;
  pse_cell u (.a(a), .b(b), .y(y), .z(z));
  initial #10 $display("%b %b", y, z);
endmodule
