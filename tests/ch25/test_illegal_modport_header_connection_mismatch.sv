/*
:name: test_illegal_modport_header_connection_mismatch
:description: when both the module header and the port connection select a modport, they have to select the same one (IEEE 1800-2023 Section 25.5)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the port of hm_user selects modport src in its header, while the connection of instance bad selects modport dst
:expected_stderr_regex: test_illegal_modport_header_connection_mismatch\.sv:(29|36):
*/
// IEEE 1800-2023 §25.5: a modport can be selected in the module header or in
// the port connection; if both name one, the two names shall be the same.
// Module hm_user selects src in its header. Instance good connects bus.src,
// the same modport, which is legal; instance bad connects bus.dst. A tool
// may report the mismatch at the connection or at the header. Icarus
// Verilog 13.0 stops at the header only because it does not parse the
// interface port, which the runner cannot tell apart; the design is
// accepted by the 5.052 release of Verilator.

interface hm_if;
  logic [3:0] d;
  modport src (output d);
  modport dst (input d);
endinterface

module hm_user (hm_if.src p);
  initial p.d = 4'h1;
endmodule

module test_illegal_modport_header_connection_mismatch;
  hm_if bus ();
  hm_user good (.p(bus.src));
  hm_user bad (.p(bus.dst));   // illegal
endmodule
