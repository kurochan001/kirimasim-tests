/*
:name: test_illegal_interface_contains_module_declaration
:description: An interface cannot declare a module, while it can declare a nested interface and a module can declare a nested interface (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3 A.1.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface icd_bus declares the module icd_inner in its body
:expected_stderr_regex: test_illegal_interface_contains_module_declaration\.sv:32:
*/
// IEEE 1800-2023 §25.3: interfaces can be declared and instantiated in
// modules, and an interface can contain smaller interfaces, but modules can
// neither be declared nor instantiated in interfaces. A.1.6: the non-port
// items of an interface include interface and program declarations but no
// module declaration. The top module declares and instantiates the nested
// interface icd_local, and icd_bus declares the nested interface icd_small,
// which is legal; only the module declaration inside icd_bus, on the marked
// line, breaks the rule.
// Icarus Verilog 13.0 rejects the marked line because module declarations
// are not allowed in interfaces. Verilator 5.052 does not support interface
// declarations within interfaces and also reports a syntax error at the
// marked line, which is not counted.

interface icd_bus;
  int n = 1;
  interface icd_small;
    int k = 2;
  endinterface
  module icd_inner;   // illegal: a module declaration in an interface
    initial $display("inner");
  endmodule
endinterface

module test_illegal_interface_contains_module_declaration;
  interface icd_local;
    int m = 3;
  endinterface
  icd_local u_local ();
  icd_bus bus ();
  initial #1 $display("%0d %0d", bus.n, u_local.m);
endmodule
