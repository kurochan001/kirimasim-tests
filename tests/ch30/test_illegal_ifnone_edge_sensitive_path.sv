/*
:name: test_illegal_ifnone_edge_sensitive_path
:description: Only a simple module path can have an ifnone condition, so an ifnone edge-sensitive path is illegal, while a simple ifnone path whose conditional paths are edge-sensitive is legal (IEEE 1800-2023 Section 30.4.4.4)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.4.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the ifnone path from clk to q is an edge-sensitive path
:expected_stderr_regex: test_illegal_ifnone_edge_sensitive_path\.sv:29:
*/
// IEEE 1800-2023 §30.4.4.4: only simple module paths may be described with an
// ifnone condition, while the state-dependent paths that correspond to the
// ifnone path may be simple or edge-sensitive paths. The path from clk to y
// has an edge-sensitive conditional path and a simple ifnone path, which is
// legal. The path from clk to q has an edge-sensitive conditional path and an
// edge-sensitive ifnone path.
// Icarus Verilog 13.0 and the 5.052 release of Verilator accept the design.

module ies_cell(input wire clk, input wire en, input wire d, output wire y, output wire q);
  assign y = d;
  assign q = d;
  specify
    if (en) (posedge clk => (y : d)) = (1, 1);
    ifnone (clk => y) = (2, 2);
    if (en) (posedge clk => (q : d)) = (1, 1);
    ifnone (posedge clk => (q : d)) = (2, 2);   // illegal: an edge-sensitive ifnone path
  endspecify
endmodule

module test_illegal_ifnone_edge_sensitive_path;
  logic clk = 1'b0, en = 1'b1, d = 1'b1;
  wire y, q;
  ies_cell u (.clk(clk), .en(en), .d(d), .y(y), .q(q));
  initial #10 $display("%b %b", y, q);
endmodule
