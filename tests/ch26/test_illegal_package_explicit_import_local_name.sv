/*
:name: test_illegal_package_explicit_import_local_name
:description: a scope cannot explicitly import a name that it declares itself, while importing a name twice from the same package is allowed (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module declares width and then explicitly imports el_pkg::width
:expected_stderr_regex: test_illegal_package_explicit_import_local_name\.sv:29:
*/
// IEEE 1800-2023 §26.3: an explicit import is illegal if the imported
// identifier is declared in the same scope. The module imports
// el_pkg::depth twice, which is legal, declares its own width, and then
// imports el_pkg::width.
// The 5.052 release of Verilator accepts the design.

package el_pkg;
  localparam int width = 8;
  localparam int depth = 4;
endpackage

module test_illegal_package_explicit_import_local_name;
  import el_pkg::depth;
  import el_pkg::depth;
  localparam int width = 2;
  import el_pkg::width;   // illegal
  initial $display("%0d %0d", depth, width);
endmodule
