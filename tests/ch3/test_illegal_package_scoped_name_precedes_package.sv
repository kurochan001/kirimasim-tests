/*
:name: test_illegal_package_scoped_name_precedes_package
:description: The compilation of a package has to come before references to its items, so a package-scoped name pkg::item in a module written before the package is an error (IEEE 1800-2023 Section 3.12)
:tags: ch3
:type: elaboration
:lrm: 1800-2023 3.12
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module refers to late_cfg::DEPTH, a parameter of package late_cfg, which comes only after the module in the compilation
:expected_stderr_regex: test_illegal_package_scoped_name_precedes_package\.sv:34:
*/
// IEEE 1800-2023 §3.12: the standard does not normally fix the order in
// which design elements are compiled, but references to package items are
// an exception: the compilation of a package has to precede references to
// it (see §26.3). A name with the package scope resolution operator, such as
// early_cfg::WIDTH, is such a reference without an import. The file is
// compiled from top to bottom. Package early_cfg comes before the module,
// so early_cfg::WIDTH is legal; package late_cfg comes after the module,
// so the reference late_cfg::DEPTH is the error. With late_cfg moved above
// the module the design is legal and prints 8 4.
// Icarus Verilog 13.0 reports a syntax error at the reference, as the name
// is not yet known as a package there; it accepts the design with the
// package moved above the module, so the error follows from the order.
// The 5.054 release of Verilator accepts the design.

package early_cfg;
  localparam int WIDTH = 8;
endpackage

module test_illegal_package_scoped_name_precedes_package;
  int w = early_cfg::WIDTH;
  int d = late_cfg::DEPTH;   // illegal: late_cfg is compiled after this module
  initial $display("%0d %0d", w, d);
endmodule

package late_cfg;
  localparam int DEPTH = 4;
endpackage
