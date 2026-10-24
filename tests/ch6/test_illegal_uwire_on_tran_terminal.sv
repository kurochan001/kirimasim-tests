/*
:name: test_illegal_uwire_on_tran_terminal
:description: A uwire net cannot be connected to a bidirectional terminal of a tran switch, even as its only connection (IEEE 1800-2023 Section 6.6.2)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.6.2 28.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the uwire u is connected to a bidirectional terminal of the tran switch t
:expected_stderr_regex: test_illegal_uwire_on_tran_terminal\.sv:(23|25):
*/
// IEEE 1800-2023 §6.6.2: it is an error to connect a uwire net to a
// bidirectional terminal of a bidirectional pass switch (28.8). The uwire u
// has no other connection, so it has no second driver; the only error is
// that it is a terminal of the tran. A tool can report the connection or the
// declaration of u.
// Oracle checks: Icarus Verilog 13.0 accepts the design, and the 5.052 release
// does not support tran.

module test_illegal_uwire_on_tran_terminal;
  uwire u;
  wire w;
  tran t(u, w);   // illegal: u is a uwire
endmodule
