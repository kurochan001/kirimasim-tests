/*
:name: test_illegal_interconnect_left_after_elaboration
:description: When only interconnect nets meet through a port, the merged net stays an interconnect net, which is illegal at the end of elaboration (IEEE 1800-2023 Section 23.3.3.7.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.3.3.7.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interconnect net link is connected only to the interconnect port p, so the simulated net is an interconnect net
:expected_stderr_regex: test_illegal_interconnect_left_after_elaboration\.sv:(25|36|37):
*/
// IEEE 1800-2023 §23.3.3.7.1: a port connection with an interconnect net
// merges the two nets; when both are interconnect nets the merged net is an
// interconnect net, otherwise it takes the type of the other net. It is
// illegal for a simulated net to be an interconnect net at the end of
// elaboration. The net link meets only the interconnect port p of the
// instance u. The net good also meets the wire port of the instance d, so it
// becomes a wire and is legal.
// Oracle checks: Icarus Verilog 13.0 and the 5.052 release of Verilator do not
// support interconnect; their errors on the header of ile_pass, a line this
// test names, are about the unsupported construct, not about the rule.

module ile_pass(inout interconnect p);   // the error can also be reported here
endmodule

module ile_drive(output wire o);
  assign o = 1'b0;
endmodule

module test_illegal_interconnect_left_after_elaboration;
  interconnect good;
  ile_pass g (good);
  ile_drive d (good);
  interconnect link;   // the error can also be reported here
  ile_pass u (link);   // illegal: link remains an interconnect net
endmodule
