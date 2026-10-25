/*
:name: test_illegal_bind_instance_name_clashes_target_item
:description: An instance that a bind statement introduces cannot have the name of an item already declared in the target scope, though several binds can target the same scope (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second bind statement introduces an instance named mon into bnc_target, which already declares a variable mon
:expected_stderr_regex: test_illegal_bind_instance_name_clashes_target_item\.sv:(29|35):
*/
// IEEE 1800-2023 §23.11: more than one bind statement can bind into the same
// target scope, but a bound instance name that clashes with another name in
// the module name space of the target is an error, also for names declared
// in the target itself. Both binds target bnc_target: chk is a new name,
// legal; mon is the name of a variable of bnc_target.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator rejects the second bind only as unsupported in its C++ output,
// which is not counted either.

module bnc_mon(input logic a);
endmodule

module bnc_target;
  logic a = 1'b0;
  logic mon;   // the error can also be reported here
endmodule

module test_illegal_bind_instance_name_clashes_target_item;
  bnc_target t ();
  bind bnc_target bnc_mon chk (.a(a));
  bind bnc_target bnc_mon mon (.a(a));   // illegal: mon is already declared in the target
endmodule
