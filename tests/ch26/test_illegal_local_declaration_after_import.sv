/*
:name: test_illegal_local_declaration_after_import
:description: A local declaration cannot reuse a name that a wildcard import has already made visible (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a local declaration conflicts with a name imported from a package and already referenced
:expected_stderr_regex: test_illegal_local_declaration_after_import\.sv:26:
*/
// IEEE 1800-2023 §26.3: a wildcard import makes a name of the package locally
// visible when it is first referenced; a later local declaration of the same
// name in that scope conflicts with it and is illegal.
// The design is accepted by Verilator 5.052 (docs/simulator-differences.md).

package test_illegal_local_declaration_after_import_pkg;
  int limit = 3;
endpackage

module test_illegal_local_declaration_after_import;
  import test_illegal_local_declaration_after_import_pkg::*;
  int copy = limit;
  int limit = 7;   // illegal: limit is already the imported one
  initial $display("copy=%0d", copy);
endmodule
