/*
:name: test_23_extra_signed_interconnect
:description: Signed is illegal on an interconnect port, while a non-ANSI port and its separate net declaration share one signedness (IEEE 1800-2023 Section 23.2.2.1)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-ANSI inout port io of si is declared as an interconnect port and as signed
:expected_stderr_regex: test_23_extra_signed_interconnect\.sv:26:
*/
// IEEE 1800-2023 §23.2.2.1: the signed attribute may be attached to a port
// declaration, to the corresponding net or variable declaration, or to
// both; if either is signed both are signed. That rule covers nets and
// variables, not interconnect ports: it shall be illegal to specify signed
// for a port declared as an interconnect port.
// The port io of si has no net type in its port declaration, and the
// separate declaration names it as an interconnect port with signed. The
// declaration is the one place the clause forbids, so the design is illegal.
// Neither release parses an interconnect port at all, so both report an
// error at this line for a reason other than this rule; see the note below.

module si(io);
  inout interconnect signed [3:0] io;  // illegal: signed interconnect port
endmodule

module test_23_extra_signed_interconnect;
  wire [3:0] n;
  si u(.io(n));
endmodule
