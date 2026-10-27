/*
:name: test_23_extra_bound_param_constant
:description: A parameter of a bound instantiation cannot be referenced hierarchically outside that instantiation in a constant-expression context such as a localparam initializer (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: elaboration
:lrm: 1800-2023 23.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the localparam X refers to the parameter P of the bound instance b through the hierarchical name u.b.P
:expected_stderr_regex: test_23_extra_bound_param_constant\.sv:36:
*/
// IEEE 1800-2023 §23.11: hierarchical references to a bind_instantiation's
// parameters may not be used outside the instantiation in any context that
// requires a constant expression, and a localparam initializer is such a
// context. The bind statement inserts the instance b of bpc_mod with P = 7
// into the scope of u. The localparam X then tries to read u.b.P while
// elaborating the enclosing module, which the clause forbids, so the design
// is illegal. The bound instance itself and the use of P inside its own
// hierarchy are legal; only the outside reference is not.
// The 5.052 release of Verilator reports the unresolved reference at this
// line; Icarus Verilog 13.0 has no bind directive, so the expected
// rejection is recorded with Verilator alone.

module bpc_mod #(parameter int P = 5) ();
endmodule

module bpc_bt;
endmodule

module test_23_extra_bound_param_constant;
  bpc_bt u();
  bind u bpc_mod #(.P(7)) b();

  localparam int X = test_23_extra_bound_param_constant.u.b.P;
  initial #1 $display("X=%0d", X);
endmodule
