/*
:name: test_illegal_super_parameter_in_packed_dimension
:description: A value parameter of the base class read with super is not a constant expression, so it cannot bound a packed dimension (IEEE 1800-2023 Section 8.15)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.15
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed dimension of the variable v in bad_width is bounded by super.W, which is not a constant expression
:expected_stderr_regex: test_illegal_super_parameter_in_packed_dimension\.sv:41:
*/
// IEEE 1800-2023 §8.15: a derived class can reach the value parameters and
// local value parameters of its base class with super, but an expression
// that does so is not a constant expression. A packed dimension needs a
// constant expression. narrow_c extends base_c#(3): width_now returns
// super.W, a use where any expression is allowed, and fixed_width bounds a
// packed dimension with base_c#(3)::W, which the class scope operator makes
// a constant expression (8.23). bad_width bounds a packed dimension with
// super.W. Without bad_width and its call the design prints 3 3.
// Icarus Verilog 13.0 stops with a syntax error at the parameterized class,
// which does not count, and the 5.054 release of Verilator accepts the
// design.

class base_c #(int W = 4);
  int data;
endclass

class narrow_c extends base_c #(3);
  function int width_now();
    return super.W;
  endfunction

  function int fixed_width();
    logic [base_c#(3)::W-1:0] ok;
    return $bits(ok);
  endfunction

  function int bad_width();
    logic [super.W-1:0] v;   // illegal: super.W is not a constant expression
    return $bits(v);
  endfunction
endclass

module test_illegal_super_parameter_in_packed_dimension;
  narrow_c n;

  initial begin
    n = new;
    $display("%0d %0d", n.width_now(), n.fixed_width());
    $display("%0d", n.bad_width());
  end
endmodule
