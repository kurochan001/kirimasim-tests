/*
:name: test_illegal_pulsestyle_ondetect_after_path
:description: A pulsestyle_ondetect declaration cannot name a module path output that has already appeared in a path declaration, while one placed before the path of its output is legal (IEEE 1800-2023 Section 30.7.4.1)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.7.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: pulsestyle_ondetect names q after q appeared in the path declaration (a *> q)
:expected_stderr_regex: test_illegal_pulsestyle_ondetect_after_path\.sv:27:
*/
// IEEE 1800-2023 §30.7.4.1: a module path output shall not appear in a pulse
// style declaration after it has already appeared in a module path
// declaration. pulsestyle_ondetect p comes before the path to p, which is
// legal; pulsestyle_ondetect q comes after the full path from a to q.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design.

module psd_cell(input wire a, output wire p, output wire [1:0] q);
  assign p = a;
  assign q = {a, a};
  specify
    pulsestyle_ondetect p;
    (a => p) = (2, 4);
    (a *> q) = (2, 4);
    pulsestyle_ondetect q;   // illegal: q already appeared in a path declaration
  endspecify
endmodule

module test_illegal_pulsestyle_ondetect_after_path;
  logic a = 1'b1;
  wire p;
  wire [1:0] q;
  psd_cell u (.a(a), .p(p), .q(q));
  initial #10 $display("%b %b", p, q);
endmodule
