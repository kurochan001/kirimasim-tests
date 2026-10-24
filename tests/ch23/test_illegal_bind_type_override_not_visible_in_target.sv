/*
:name: test_illegal_bind_type_override_not_visible_in_target
:description: A user-defined type that overrides a type parameter in a bind instantiation has to be visible in the target scope as well as in the scope of the bind statement (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type word_t that overrides the type parameter T is declared in the module of the bind statement but is not visible in the target module btv_target
:expected_stderr_regex: test_illegal_bind_type_override_not_visible_in_target\.sv:41:
*/
// IEEE 1800-2023 §23.11: user-defined type names that override type
// parameters in a bind instantiation shall be visible and matching in both
// the scope containing the bind statement and the target scope. The type
// byte_t comes from the package btv_pkg, which both the module with the bind
// statements and btv_target import, so its bind is legal. The type word_t is
// declared only in the module with the bind statements.
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator does not find word_t in the target scope.

package btv_pkg;
  typedef logic [7:0] byte_t;
endpackage

module btv_chk #(parameter type T = logic) ();
  T v;
endmodule

module btv_target;
  import btv_pkg::byte_t;
endmodule

module test_illegal_bind_type_override_not_visible_in_target;
  import btv_pkg::byte_t;
  typedef logic [15:0] word_t;
  btv_target t ();
  bind btv_target btv_chk #(.T(byte_t)) ok ();
  bind btv_target btv_chk #(.T(word_t)) c ();   // illegal: word_t is not visible in btv_target
endmodule
