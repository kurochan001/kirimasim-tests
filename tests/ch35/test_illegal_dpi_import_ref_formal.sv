/*
:name: test_illegal_dpi_import_ref_formal
:description: A formal argument of an import declaration cannot be passed by reference with ref (IEEE 1800-2023 Section 35.5.4)
:tags: ch35
:type: elaboration
:lrm: 1800-2023 35.5.4 35.5.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a formal argument of an import declaration has the direction ref
:expected_stderr_regex: test_illegal_dpi_import_ref_formal\.sv:23:
*/
// IEEE 1800-2023 §35.5.4: the qualifier ref cannot be used in import
// declarations, and footnote 27 of Syntax 35-1 says that the formals of an
// imported subroutine cannot use pass by reference; how arguments are passed
// is left to the foreign language layer. c_bump declares its formal x as
// ref int, which is an error at its declaration.
// Icarus Verilog 13.0 does not support DPI, so an error it reports on that
// line does not count. Verilator 5.052 accepts the design.

module test_illegal_dpi_import_ref_formal;
  import "DPI-C" function void c_bump(ref int x);   // illegal: ref in an import

  int v = 1;

  initial c_bump(v);
endmodule
