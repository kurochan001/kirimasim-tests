/*
:name: test_illegal_checker_declares_interface
:description: An interface cannot be declared in the body of a checker (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker body declares an interface
:expected_stderr_regex: test_illegal_checker_declares_interface\.sv:28:
*/
// IEEE 1800-2023 17.2: modules, interfaces, programs and packages shall not be
// declared inside checkers, and modules, interfaces and programs shall not be
// instantiated there.
// The checker below declares an interface in its body, which the
// grammar of the checker body (Syntax 17-1) does not allow either. Without
// that declaration the design is legal.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator reports the declaration as a syntax error on that
// line and accepts the design without it, so it rejects the design for
// this reason.

`timescale 1ns/1ns

checker with_interface(input logic a, output logic y);
  interface inner_if;   // illegal
  endinterface : inner_if
  assign y = a;
endchecker : with_interface

module test_illegal_checker_declares_interface;
  logic a = 1'b1, y;

  with_interface u(.a(a), .y(y));

  initial #1 $display("y=%b", y);
endmodule
