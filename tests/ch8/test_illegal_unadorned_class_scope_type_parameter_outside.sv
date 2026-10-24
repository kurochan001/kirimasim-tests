/*
:name: test_illegal_unadorned_class_scope_type_parameter_outside
:description: outside a parameterized class the unadorned class name cannot prefix the scope resolution operator for a type parameter (IEEE 1800-2023 Section 8.25.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.25.1 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sized_c::T, with the unadorned name of the parameterized class sized_c, is used outside the class
:expected_stderr_regex: test_illegal_unadorned_class_scope_type_parameter_outside\.sv:29:
*/
// IEEE 1800-2023 §8.25.1: outside a parameterized class and its out-of-block
// declarations, the class scope operator reaches a value parameter, type
// parameter or local parameter only through an explicit specialization; the
// unadorned name of the class is illegal there. sized_c#()::T and
// sized_c#(1, shortint)::T declare legal variables; sized_c::T does not.
// Icarus Verilog 13.0 stops with a syntax error at the parameterized class
// declaration.

class sized_c #(int p = 3, type T = byte);
  localparam int q = p * 2;
endclass

module test_illegal_unadorned_class_scope_type_parameter_outside;
  sized_c#()::T a = 8'd7;
  sized_c#(1, shortint)::T b = 16'd300;
  sized_c::T c;   // illegal: unadorned name outside the class

  initial $display("%0d %0d %0d", a, b, sized_c#(4)::q);
endmodule
