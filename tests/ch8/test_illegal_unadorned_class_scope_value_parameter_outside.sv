/*
:name: test_illegal_unadorned_class_scope_value_parameter_outside
:description: outside a parameterized class the unadorned class name cannot prefix the scope resolution operator for a value parameter (IEEE 1800-2023 Section 8.25.1)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.25.1 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sized_c::p, with the unadorned name of the parameterized class sized_c, is used outside the class
:expected_stderr_regex: test_illegal_unadorned_class_scope_value_parameter_outside\.sv:34:
*/
// IEEE 1800-2023 §8.25.1: the unadorned name of a parameterized class may
// prefix :: only inside the class and its out-of-block declarations, where
// it names the members of the class itself. Elsewhere an explicit
// specialization shall be used, such as C#() for the default one, and it can
// reach the value and type parameters and local parameters. sized_c::q in
// the class, sized_c#()::p and sized_c#(5)::q in the module are legal;
// sized_c::p in the module is not.
// Icarus Verilog 13.0 stops with a syntax error at the parameterized class
// declaration.

class sized_c #(int p = 3, type T = byte);
  localparam int q = p * 2;
  static function int twice();
    return sized_c::q;
  endfunction
endclass

module test_illegal_unadorned_class_scope_value_parameter_outside;
  int a = sized_c#()::p;
  int b = sized_c#(5)::q;
  int c = sized_c::p;   // illegal: unadorned name outside the class

  initial $display("%0d %0d %0d", a, b, sized_c#()::twice());
endmodule
