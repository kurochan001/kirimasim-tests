/*
:name: test_illegal_package_refers_to_unit_scope_item
:description: A package cannot refer to an item declared in the compilation-unit scope, while a module of the same compilation unit can (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function get of the package hu_pkg reads unit_limit, which is declared in the compilation-unit scope
:expected_stderr_regex: test_illegal_package_refers_to_unit_scope_item\.sv:24:
*/
// IEEE 1800-2023 §26.2: a package shall not refer to items defined in the
// compilation-unit scope (3.12.1). unit_limit is declared outside of any
// design element, so it belongs to the compilation-unit scope of this file.
// The module reads it, which is legal; the function get of hu_pkg reads it
// as well.

localparam int unit_limit = 6;

package hu_pkg;
  function automatic int get();
    return unit_limit;   // illegal: unit_limit is a compilation-unit item
  endfunction
endpackage

module test_illegal_package_refers_to_unit_scope_item;
  initial $display("%0d %0d", unit_limit, hu_pkg::get());
endmodule
