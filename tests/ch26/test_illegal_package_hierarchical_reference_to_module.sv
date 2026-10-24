/*
:name: test_illegal_package_hierarchical_reference_to_module
:description: An item of a package cannot use a hierarchical reference to an identifier that the package neither declares nor imports, here a variable of the top-level module (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the function get of the package hm_pkg reads the module variable v by a hierarchical name
:expected_stderr_regex: test_illegal_package_hierarchical_reference_to_module\.sv:26:
*/
// IEEE 1800-2023 §26.2: items within packages shall not have hierarchical
// references to identifiers except those created within the package or made
// visible by import of another package. The function own of hm_pkg reads the
// package variable w, which the package declares. The function get
// reads v of the top-level module through a hierarchical name.

package hm_pkg;
  int w = 2;
  function automatic int own();
    return w;
  endfunction
  function automatic int get();
    return test_illegal_package_hierarchical_reference_to_module.v;   // illegal
  endfunction
endpackage

module test_illegal_package_hierarchical_reference_to_module;
  int v = 3;
  initial $display("%0d %0d", hm_pkg::own(), hm_pkg::get());
endmodule
