/*
:name: test_illegal_export_named_imports_candidate
:description: A named export of an unreferenced import candidate counts as a reference and imports it, so a later local declaration of that name in the package is an error (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: xi_mid declares depth after export xi_base::depth has imported xi_base::depth into xi_mid
:expected_stderr_regex: test_illegal_export_named_imports_candidate\.sv:31:
*/
// IEEE 1800-2023 §26.6: when the declaration named by an export is a
// candidate for import that nothing has referenced, the export is a reference
// to it and imports it into the package by the rules of a direct import.
// xi_mid imports xi_base with a wildcard. Its other candidate, width, is never
// referenced, so a local width is legal. The export of xi_base::depth imports
// depth, and the local declaration of depth that follows is an error.
// The 5.052 release of Verilator accepts the design.

package xi_base;
  localparam int width = 8;
  localparam int depth = 4;
endpackage

package xi_mid;
  import xi_base::*;
  localparam int width = 2;
  export xi_base::depth;
  localparam int depth = 1;   // illegal: depth was imported by the export
endpackage

module test_illegal_export_named_imports_candidate;
  initial $display("%0d", xi_mid::width);
endmodule
