/*
:name: test_illegal_interface_contains_module_instance
:description: An interface cannot instantiate a module, while a module can instantiate an interface and an interface can instantiate another interface (IEEE 1800-2023 Section 25.3)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.3 A.1.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface icm_bus instantiates the module icm_leaf
:expected_stderr_regex: test_illegal_interface_contains_module_instance\.sv:38:
*/
// IEEE 1800-2023 §25.3: interfaces can be declared and instantiated in
// modules, and an interface can contain smaller interfaces, but modules can
// neither be declared nor instantiated in interfaces. A.1.6: the items of an
// interface include interface and program instances but not module
// instances. The top module instantiates icm_bus and the leaf module, and
// icm_bus instantiates the interface icm_inner, all of which is legal; only
// the instance of icm_leaf inside icm_bus, on the marked line, breaks the
// rule.
// Icarus Verilog 13.0 rejects the marked line, but also the legal instance
// of the interface icm_inner with the same message, so its error is not
// counted; Verilator 5.052 accepts the design.

module icm_leaf (input logic a, output logic y);
  assign y = ~a;
endmodule

interface icm_inner;
  logic k = 1'b1;
endinterface

interface icm_bus;
  logic a = 1'b0;
  logic y;
  icm_inner u_inner ();
  icm_leaf u_leaf (.a(a), .y(y));   // illegal: a module instance in an interface
endinterface

module test_illegal_interface_contains_module_instance;
  logic y_top;
  icm_bus bus ();
  icm_leaf u_top (.a(bus.a), .y(y_top));
  initial #1 $display("y_top=%b k=%b", y_top, bus.u_inner.k);
endmodule
