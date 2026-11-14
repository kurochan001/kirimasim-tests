/*
:name: test_illegal_handle_parameter_in_packed_dimension
:description: A class value parameter read through an object handle is not a constant expression, so it cannot bound a packed dimension (IEEE 1800-2023 Section 8.5)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed dimension of bad is bounded by g.WIDTH, a value parameter read through the handle g, which is not a constant expression
:expected_stderr_regex: test_illegal_handle_parameter_in_packed_dimension\.sv:34:
*/
// IEEE 1800-2023 §8.5: a value parameter or local value parameter of an
// object can be read by qualifying its name with a handle of the object, but
// such an expression is not a constant expression. A packed dimension needs a
// constant expression. The module reads g.WIDTH and g.TOP in $display, where
// any expression is allowed, and bounds the packed dimension of ok with
// gauge_c#(3)::WIDTH, which the class scope operator makes a constant
// expression (8.23). The packed dimension of bad is bounded by g.WIDTH.
// Without the declaration of bad the design prints 3 7 3.
// Icarus Verilog 13.0 stops with a syntax error at the parameterized class,
// which does not count, and the 5.054 release of Verilator accepts the
// design.

class gauge_c #(int WIDTH = 4);
  localparam int TOP = (1 << WIDTH) - 1;
  int reading;
endclass

module test_illegal_handle_parameter_in_packed_dimension;
  gauge_c #(3) g;
  logic [gauge_c#(3)::WIDTH-1:0] ok;
  logic [g.WIDTH-1:0] bad;   // illegal: g.WIDTH is not a constant expression

  initial begin
    g = new;
    $display("%0d %0d %0d", g.WIDTH, g.TOP, $bits(ok));
  end
endmodule
