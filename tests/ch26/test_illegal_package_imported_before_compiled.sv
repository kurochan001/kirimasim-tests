/*
:name: test_illegal_package_imported_before_compiled
:description: a package has to be compiled before a scope that imports it (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module imports package late_pkg, which comes only after the module in the source
:expected_stderr_regex: test_illegal_package_imported_before_compiled\.sv:25:
*/
// IEEE 1800-2023 §26.3: the compilation of a package shall precede the
// compilation of the scopes in which it is imported. Package early_pkg comes
// before the module that imports it, which is legal; package late_pkg comes
// after it. The 5.052 release of Verilator accepts the design.

package early_pkg;
  localparam int E = 1;
endpackage

module test_illegal_package_imported_before_compiled;
  import early_pkg::E;
  import late_pkg::L;   // illegal
  initial $display("%0d %0d", E, L);
endmodule

package late_pkg;
  localparam int L = 2;
endpackage
