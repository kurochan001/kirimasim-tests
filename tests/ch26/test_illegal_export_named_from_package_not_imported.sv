/*
:name: test_illegal_export_named_from_package_not_imported
:description: A named export is an error when the named package provides no import candidate in the exporting package, while a named export of an unreferenced candidate of an imported package is legal (IEEE 1800-2023 Section 26.6)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: xn_mid exports xn_other::depth although nothing is imported from xn_other in xn_mid
:expected_stderr_regex: test_illegal_export_named_from_package_not_imported\.sv:33:
*/
// IEEE 1800-2023 §26.6: an export of the form package::name is an error if
// the declaration is not a candidate for import or is not imported in the
// exporting package, and the declaration has to be imported from the package
// that the export names. xn_mid imports xn_base with a wildcard, so
// xn_base::width is a candidate and its export is legal. xn_base also has a
// depth, but the export names xn_other, from which xn_mid imports nothing.

package xn_base;
  localparam int width = 8;
  localparam int depth = 4;
endpackage

package xn_other;
  localparam int depth = 16;
endpackage

package xn_mid;
  import xn_base::*;
  export xn_base::width;
  export xn_other::depth;   // illegal: no import from xn_other in this package
endpackage

module test_illegal_export_named_from_package_not_imported;
  import xn_mid::*;
  initial $display("%0d", width);
endmodule
