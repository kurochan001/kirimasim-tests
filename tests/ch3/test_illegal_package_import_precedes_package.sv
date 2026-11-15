/*
:name: test_illegal_package_import_precedes_package
:description: The compilation of a package has to come before references to its items, so a module that imports a function of a package written only after the module is an error (IEEE 1800-2023 Section 3.12)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12 26.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module imports the function triple of package late_ops, which comes only after the module in the compilation
:expected_stderr_regex: test_illegal_package_import_precedes_package\.sv:36:
*/
// IEEE 1800-2023 §3.12: the standard does not normally fix the order in
// which design elements are compiled, but references to package items are
// an exception: the compilation of a package has to precede references to
// it. §26.3: a package is compiled before the scopes that import it. The
// file is compiled from top to bottom. Package early_ops comes before the
// module, so importing its function twice is legal; package late_ops comes
// after the module, so the import of its function triple is the error.
// With late_ops moved above the module the design is legal and prints
// 6 9.
// Icarus Verilog 13.0 reports a syntax error at the reference, as the name
// is not yet known as a package there; it accepts the design with the
// package moved above the module, so the error follows from the order.
// The 5.054 release of Verilator accepts the design.

package early_ops;
  function automatic int twice(int v);
    return 2 * v;
  endfunction
endpackage

module test_illegal_package_import_precedes_package;
  import early_ops::twice;
  import late_ops::triple;   // illegal: late_ops is compiled after this module
  initial $display("%0d %0d", twice(3), triple(3));
endmodule

package late_ops;
  function automatic int triple(int v);
    return 3 * v;
  endfunction
endpackage
