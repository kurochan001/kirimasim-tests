/*
:name: test_illegal_checker_declares_package
:description: A package cannot be declared in the body of a checker (IEEE 1800-2023 Section 17.2)
:tags: ch17
:type: elaboration
:lrm: 1800-2023 17.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the checker body declares a package
:expected_stderr_regex: test_illegal_checker_declares_package\.sv:26:
*/
// IEEE 1800-2023 17.2: modules, interfaces, programs and packages shall not be
// declared inside checkers, and modules, interfaces and programs shall not be
// instantiated there. The checker below declares a package in its body, which
// the grammar of the checker body does not allow. The rest of the design is
// legal.
// The 5.052 release supports the unit-level checker and reports the package
// declaration as a syntax error on that line, so it rejects the design for this
// reason; Icarus Verilog 13.0 does not support checkers at all.

`timescale 1ns/1ns

checker with_package(input logic a, output logic y);
  package inner_pkg;   // illegal
  endpackage : inner_pkg
  assign y = a;
endchecker : with_package

module test_illegal_checker_declares_package;
  logic a = 1'b1, y;

  with_package u(.a(a), .y(y));

  initial #1 $display("y=%b", y);
endmodule
