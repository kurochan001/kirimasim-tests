/*
:name: test_illegal_config_parameter_wildcard_import
:description: A parameter override of a config may not name an identifier that only a wildcard import makes a candidate in the parent of the configured instance, since a bind statement could not name it there (IEEE 1800-2023 Section 33.4.3)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4.3 23.11 26.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a parameter override of the config names a package parameter that is only a wildcard import candidate in the parent of the instance
:expected_stderr_regex: test_illegal_config_parameter_wildcard_import\.sv:47:
*/
// IEEE 1800-2023 §33.4.3: the identifiers of a parameter override in a config
// are resolved starting in the parent scope of the configured instance, and
// an identifier that binds into that parent has to be one that a bind
// statement could use there. §23.11: a bind statement sees what is declared in
// or imported into its target scope, but cannot cause the import of a
// wildcard candidate (§26.3), and does not see $unit. cpw_top imports cpw_pkg
// with a wildcard and never names PKG_W, so PKG_W is only a candidate there.
// The override of u1 names TOP_W, a parameter declared in cpw_top, by its
// hierarchical name cpw_top.TOP_W, as Example 3 of §33.4.3 does; that is legal
// whether a simple name in a config resolves in the parent scope or, as Example
// 4 suggests, in the config itself. The override of u2 names PKG_W, which is an
// error either way: the config declares no PKG_W, and in the parent scope only
// an import of the candidate could resolve it.

package cpw_pkg;
  parameter int PKG_W = 5;
endpackage

module cpw_leaf #(parameter int W = 4) ();
  initial $display("%m: W=%0d", W);
endmodule

module cpw_top;
  import cpw_pkg::*;
  parameter int TOP_W = 6;

  cpw_leaf u1();
  cpw_leaf u2();
endmodule

config cpw_cfg;
  design work.cpw_top;
  instance cpw_top.u1 use #(.W(cpw_top.TOP_W));
  instance cpw_top.u2 use #(.W(PKG_W));   // illegal: PKG_W is only a wildcard candidate
endconfig
