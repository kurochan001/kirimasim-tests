/*
:name: test_class_enum_and_parameters_via_handle_and_scope
:description: an enum constant declared in a class is reached through an object handle as well as the class scope, class parameters and local parameters are public and readable through handles, and through the class scope they are constant expressions (IEEE 1800-2023 Sections 8.5, 8.18, 8.23)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.5 8.18 8.23
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_enum_and_parameters_via_handle_and_scope.expected
*/
// IEEE 1800-2023 §8.5: the enum names of a class can be qualified with an
// instance name as well as with the class scope, and the value parameters and
// local parameters of an object can be read through the instance name.
// §8.18: class parameters and local parameters are public, so code outside the
// class can read them. §8.23: a parameter or local parameter selected with the
// class scope operator is a constant expression.
// The module reads SIDES and DOUBLE through handles of two specializations,
// the enum names through a handle and through class scopes, and uses
// shape_c#(4)::DOUBLE as the value of a localparam and shape_c#(5)::SIDES in a
// packed dimension, both places that need constant expressions.
// Icarus Verilog 13.0 does not support parameterized classes.

class shape_c #(int SIDES = 3);
  typedef enum {RED = 2, GREEN = 5} color_e;
  localparam int DOUBLE = SIDES * 2;
  color_e c;
  function new();
    c = GREEN;
  endfunction
endclass

module test_class_enum_and_parameters_via_handle_and_scope;
  localparam int L = shape_c#(4)::DOUBLE;
  logic [shape_c#(5)::SIDES-1:0] vec;
  shape_c #(4) s4;
  shape_c s3;

  initial begin
    s4 = new;
    s3 = new;
    $display("via handle: s4.SIDES=%0d s4.DOUBLE=%0d s3.SIDES=%0d s3.DOUBLE=%0d", s4.SIDES,
             s4.DOUBLE, s3.SIDES, s3.DOUBLE);
    $display("enum via handle: s4.RED=%0d s4.GREEN=%0d c==s4.GREEN=%0d", s4.RED, s4.GREEN,
             s4.c == s4.GREEN);
    $display("enum via scope: %0d %0d", shape_c#(4)::RED, shape_c#()::GREEN);
    $display("constants: L=%0d bits(vec)=%0d", L, $bits(vec));
  end
endmodule
