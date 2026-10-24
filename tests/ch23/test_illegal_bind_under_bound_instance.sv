/*
:name: test_illegal_bind_under_bound_instance
:description: A bind statement cannot place an instantiation inside the scope of an instance that another bind statement created (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second bind statement targets the instance c, which the first bind statement created
:expected_stderr_regex: test_illegal_bind_under_bound_instance\.sv:36:
*/
// IEEE 1800-2023 §23.11: it is an error for a bind statement to bind an
// instantiation underneath the scope of another bind instantiation. The first
// bind puts an instance c of bub_chk into the instance t of bub_target, which
// is legal. The second bind targets test_illegal_bind_under_bound_instance.t.c,
// that bound instance, and so would put bub_inner under it.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator reports a syntax error at the dot of the hierarchical target
// instance, a form of bind it does not parse, which is not counted.

module bub_inner;
endmodule

module bub_chk;
endmodule

module bub_target;
endmodule

module test_illegal_bind_under_bound_instance;
  bub_target t ();
  bind bub_target bub_chk c ();
  bind test_illegal_bind_under_bound_instance.t.c bub_inner i ();   // illegal: under c
endmodule
