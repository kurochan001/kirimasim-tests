/*
:name: test_illegal_specparam_in_package
:description: a specparam cannot be declared in a package, which is neither a module nor a specify block
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package body declares the specparam X outside a module or specify block
:expected_stderr_regex: test_illegal_specparam_in_package\.sv:22:
*/
// IEEE 1800-2023 6.20.5: a specparam shall be declared inside a module or a
// specify block, and may only be used inside a module or specify block. A
// package is neither, and the package grammar does not allow specparam, so
// the declaration is an error. The package is imported by a module to make it
// part of the design. Both recorded releases reject the declaration at this
// line.

package test_illegal_specparam_in_package_pkg;
  specparam X = 1;   // illegal: specparam in a package
endpackage

module test_illegal_specparam_in_package;
  import test_illegal_specparam_in_package_pkg::*;
endmodule
