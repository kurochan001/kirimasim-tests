/*
:name: test_illegal_package_import_in_class
:description: an import declaration cannot be an item of a class (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: class inner_cls has an import declaration directly among its items
:expected_stderr_regex: test_illegal_package_import_in_class\.sv:31:
*/
// IEEE 1800-2023 §26.3, footnote 15 of Syntax 26-2: an import statement
// directly within a class scope is illegal. Class outer_cls uses the name
// LIMIT that the module imports, which is legal; class inner_cls tries to
// import the package itself.

package ic_pkg;
  localparam int LIMIT = 3;
endpackage

module test_illegal_package_import_in_class;
  import ic_pkg::LIMIT;

  class outer_cls;
    int v = LIMIT;
  endclass

  class inner_cls;
    import ic_pkg::*;   // illegal
    int w = 1;
  endclass
endmodule
