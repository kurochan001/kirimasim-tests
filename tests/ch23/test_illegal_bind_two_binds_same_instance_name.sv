/*
:name: test_illegal_bind_two_binds_same_instance_name
:description: Two bind statements cannot introduce instances of the same name into one target scope (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: two bind statements both introduce an instance named mon into btn_target
:expected_stderr_regex: test_illegal_bind_two_binds_same_instance_name\.sv:(34|35):
*/
// IEEE 1800-2023 §23.11: it is legal for more than one bind statement to bind
// into the same target scope, but an instance name that a bind introduces
// shall not clash with a name introduced by another bind statement in that
// scope. The binds of first and second use different names and are legal;
// the bind of the second instance named mon clashes with the first one.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator reports the duplicate instance mon.

module btn_mon(input logic a);
endmodule

module btn_target;
  logic a = 1'b0;
endmodule

module test_illegal_bind_two_binds_same_instance_name;
  btn_target t ();
  bind btn_target btn_mon first (.a(a));
  bind btn_target btn_mon second (.a(a));
  bind btn_target btn_mon mon (.a(a));   // the error can also be reported here
  bind btn_target btn_mon mon (.a(a));   // illegal: mon is introduced twice
endmodule
