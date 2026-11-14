/*
:name: test_illegal_checker_declares_module
:description: A module cannot be declared in the body of a checker (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker body declares a module
:expected_stderr_regex: test_illegal_checker_declares_module\.sv:28:
*/
// IEEE 1800-2023 17.2: modules, interfaces, programs and packages shall not be
// declared inside checkers, and modules, interfaces and programs shall not be
// instantiated there.
// The checker below declares a module in its body, which the
// grammar of the checker body (Syntax 17-1) does not allow either. Without
// that declaration the design is legal.
// Icarus Verilog 13.0 does not support checkers. The 5.054 release of
// the Verilator simulator reports the declaration as a syntax error on that
// line and accepts the design without it, so it rejects the design for
// this reason.

`timescale 1ns/1ns

checker with_module(input logic a, output logic y);
  module inner_mod;   // illegal
  endmodule : inner_mod
  assign y = a;
endchecker : with_module

module test_illegal_checker_declares_module;
  logic a = 1'b1, y;

  with_module u(.a(a), .y(y));

  initial #1 $display("y=%b", y);
endmodule
