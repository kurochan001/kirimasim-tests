/*
:name: test_illegal_package_explicit_import_two_packages
:description: one scope cannot explicitly import the same name from two different packages, while importing a name twice from the same package is allowed (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module explicitly imports width from ec_b after importing width from ec_a
:expected_stderr_regex: test_illegal_package_explicit_import_two_packages\.sv:33:
*/
// IEEE 1800-2023 §26.3: an explicit import is illegal if the identifier is
// already explicitly imported from another package; importing an identifier
// from the same package several times is allowed. The module imports
// ec_a::depth twice, which is legal, and width from ec_a and then from ec_b.
// The 5.052 release of Verilator accepts the design.

package ec_a;
  localparam int width = 8;
  localparam int depth = 4;
endpackage

package ec_b;
  localparam int width = 16;
endpackage

module test_illegal_package_explicit_import_two_packages;
  import ec_a::depth;
  import ec_a::depth;
  import ec_a::width;
  import ec_b::width;   // illegal
  initial $display("%0d %0d", depth, width);
endmodule
