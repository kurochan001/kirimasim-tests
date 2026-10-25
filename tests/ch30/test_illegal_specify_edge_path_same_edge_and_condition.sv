/*
:name: test_illegal_specify_edge_path_same_edge_and_condition
:description: Two delays for the same edge-sensitive path need a different edge or condition; repeating both the edge and the condition is an error, while the same path with the other edge is legal (IEEE 1800-2023 Section 30.4.4.3)
:tags: ch30
:type: elaboration
:lrm: 1800-2023 30.4.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the path from clk to q[0] is declared twice with the edge posedge and the condition en
:expected_stderr_regex: test_illegal_specify_edge_path_same_edge_and_condition\.sv:(27|29):
*/
// IEEE 1800-2023 §30.4.4.3: different delays can be assigned to the same
// edge-sensitive path only when the edge, the condition, or both make each
// declaration unique, and the port is referenced in the same way in all of
// them. The cell declares the path from clk to q[0] for posedge under en, for
// negedge without a condition, which is legal, and again for posedge under
// en. A tool can report the repeated declaration on either of its lines.
// Icarus Verilog 13.0 applies a path to a bit-select to the whole vector and
// then reports a width mismatch on the first parallel path, which does
// not count; the 5.052 release of Verilator accepts the design.

module sec_cell(input wire clk, input wire en, input wire d, output wire [1:0] q);
  assign q = {d, d};
  specify
    if (en) (posedge clk => (q[0] : d)) = (2, 3);
    (negedge clk => (q[0] : d)) = (4, 5);
    if (en) (posedge clk => (q[0] : d)) = (6, 7);   // illegal: same edge and condition
  endspecify
endmodule

module test_illegal_specify_edge_path_same_edge_and_condition;
  logic clk = 1'b0, en = 1'b1, d = 1'b1;
  wire [1:0] q;
  sec_cell u (.clk(clk), .en(en), .d(d), .q(q));
  initial #10 $display("%b", q);
endmodule
