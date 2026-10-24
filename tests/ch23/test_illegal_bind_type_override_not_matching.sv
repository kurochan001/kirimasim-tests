/*
:name: test_illegal_bind_type_override_not_matching
:description: A user-defined type that overrides a type parameter in a bind instantiation has to name matching types in the scope of the bind statement and in the target scope (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type name data_t that overrides the type parameter T is visible in both scopes but names logic [3:0] in the scope of the bind statement and logic [7:0] in the target
:expected_stderr_regex: test_illegal_bind_type_override_not_matching\.sv:43:
*/
// IEEE 1800-2023 §23.11: user-defined type names that override type
// parameters in a bind instantiation shall be visible and matching in both
// the scope containing the bind statement and the target scope. The type
// byte_t of the package btm_pkg is imported into both and is the same type,
// so its bind is legal. data_t is declared in both modules, but as logic [3:0]
// with the bind statements and as logic [7:0] in btm_target, which do not
// match (6.22.1).
// Oracle checks: Icarus Verilog 13.0 does not support bind and reports a syntax
// error on every bind statement, which is not counted; the 5.052 release
// of Verilator accepts the design.

package btm_pkg;
  typedef logic [7:0] byte_t;
endpackage

module btm_chk #(parameter type T = logic) ();
  T v;
endmodule

module btm_target;
  import btm_pkg::byte_t;
  typedef logic [7:0] data_t;
endmodule

module test_illegal_bind_type_override_not_matching;
  import btm_pkg::byte_t;
  typedef logic [3:0] data_t;
  btm_target t ();
  bind btm_target btm_chk #(.T(byte_t)) ok ();
  bind btm_target btm_chk #(.T(data_t)) c ();   // illegal: data_t differs in the two scopes
endmodule
