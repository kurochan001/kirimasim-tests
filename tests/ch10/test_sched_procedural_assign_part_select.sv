/*
:name: test_sched_procedural_assign_part_select
:description: A procedural assign statement cannot drive a part-select of a variable (IEEE 1800-2023 Section 10.6.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.6.1 4.9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the left-hand side of a procedural continuous assignment is a part-select
:expected_stderr_regex: test_sched_procedural_assign_part_select\.sv:25:
*/
// IEEE 1800-2023 §10.6.1: the left-hand side of an assign procedural
// continuous assignment shall be a singular variable reference or a
// concatenation of variables, not a bit-select or a part-select. The assign
// statement below drives q[3:0], so the design is illegal. Icarus Verilog
// 13.0 and Verilator 5.052 accept it, so neither is an oracle for this test.

module test_sched_procedural_assign_part_select;
  logic [7:0] q;
  logic [7:0] d = 8'h3c;

  initial begin
    assign q[3:0] = d[3:0];
    #1 deassign q[3:0];
  end
endmodule
