/*
:name: test_illegal_config_package_binding
:description: A configuration cannot change the binding of a package (IEEE 1800-2023 Section 33.4)
:tags: ch33
:type: elaboration
:lrm: 1800-2023 33.4 33.4.1.4 33.4.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a cell clause of the config binds a package name to another package
:expected_stderr_regex: test_illegal_config_package_binding\.sv:36:
*/
// IEEE 1800-2023 §33.4: a configuration may change the binding of module,
// primitive, interface and program instances, but shall not change the
// binding of a package.
// Icarus Verilog 13.0 reports a syntax error on that line, which does not
// count: it skips config declarations, and the error comes from the package
// name in the cell clause. Verilator 5.052 accepts the design
// (docs/simulator-differences.md).

package cfgpk_a;
  parameter int V = 1;
endpackage

package cfgpk_b;
  parameter int V = 2;
endpackage

module cfgpk_top;
  initial $display("V=%0d", cfgpk_a::V);
endmodule

config cfgpk;
  design work.cfgpk_top;
  cell cfgpk_a use work.cfgpk_b;   // illegal: binding of a package
endconfig
