/*
:name: test_illegal_unit_scope_import
:description: An import declaration that names the compilation-unit scope with $unit is rejected (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12.1 26.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the compilation-unit scope has no name, so it cannot be named by an import declaration
:expected_stderr_regex: test_illegal_unit_scope_import\.sv:25:
*/
// IEEE 1800-2023 §3.12.1: the compilation-unit scope is not a package and has
// no name, so it cannot be used with an import declaration; $unit is only a
// prefix for the scope resolution operator, as in $unit::unit_limit. The
// module below reads the compilation-unit variable both directly and through
// $unit::, which is legal; the import on the marked line is the only error.
// Icarus Verilog 13.0 accepts the import and runs the design, which the
// clause does not allow.

int unit_limit = 9;

module test_illegal_unit_scope_import;
  import $unit::*;   // illegal: the compilation-unit scope cannot be imported

  initial $display("limit=%0d %0d", unit_limit, $unit::unit_limit);
endmodule
