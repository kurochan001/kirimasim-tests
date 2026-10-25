/*
:name: test_illegal_interconnect_declaration_assignment
:description: an interconnect net cannot have a net declaration assignment (IEEE 1800-2023 Section 10.3.1)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.3.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interconnect net ic_bad is declared with the assignment = w
:expected_stderr_regex: test_illegal_interconnect_declaration_assignment\.sv:33:
*/
// IEEE 1800-2023 §10.3.1: a net declaration assignment places a continuous
// assignment on a net where it is declared, as for the wire w, but an
// interconnect net (6.6.8) shall not have one. ic_ok, declared without an
// assignment, connects the output of src_m to the input of dst_m, which is
// legal; ic_bad is declared with an assignment.
// Icarus Verilog 13.0 gives a syntax error also at the legal declaration of
// ic_ok, and Verilator 5.052 reports interconnect as unsupported, so neither
// error counts.

module src_m (output wire o);
  assign o = 1'b1;
endmodule

module dst_m (input wire i);
endmodule

module test_illegal_interconnect_declaration_assignment;
  wire w = 1'b1;
  interconnect ic_ok;
  interconnect ic_bad = w;   // illegal: declaration assignment on an interconnect

  src_m u_src (.o(ic_ok));
  dst_m u_dst (.i(ic_ok));
  initial #1 $display("%b", w);
endmodule
