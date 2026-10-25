/*
:name: test_unit_scope_bind_construct
:description: A bind construct can stand in the compilation-unit scope, outside any module, and instantiates its module in every instance of the target module (IEEE 1800-2023 Section 3.12.1)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_scope_bind_construct.expected
*/
// IEEE 1800-2023 §3.12.1: besides the items allowed in a package, the
// compilation-unit scope can contain bind constructs. §23.11: a bind
// instantiates a module in the scope of each instance of the target module,
// as if the instantiation were written there.
// The bind below stands outside any module and binds bind_checker, named
// chk, into bind_target, connecting its input to the target's value. The
// test has two instances of bind_target, with values 6 and 9, and reads the
// value each bound instance sees through the hierarchical names t1.chk and
// t2.chk.
// Icarus Verilog 13.0 does not support bind.

module bind_checker(input var int seen);
endmodule

module bind_target #(parameter int V = 0);
  int value = V;
endmodule

bind bind_target bind_checker chk(.seen(value));

module test_unit_scope_bind_construct;
  bind_target #(.V(6)) t1();
  bind_target #(.V(9)) t2();

  initial #1 $display("t1.chk sees %0d, t2.chk sees %0d", t1.chk.seen, t2.chk.seen);
endmodule
