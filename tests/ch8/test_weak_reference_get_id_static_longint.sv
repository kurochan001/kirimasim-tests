/*
:name: test_weak_reference_get_id_static_longint
:description: weak_reference get_id() is a static function with one argument obj of the parameter type T and a longint result: it is called through the class scope with no weak_reference object, its argument is bound by position or by the name obj and accepts a handle of a derived class, and its result is a signed 64-bit longint (IEEE 1800-2023 Section 8.30.5)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_get_id_static_longint.expected
*/
// IEEE 1800-2023 §8.30.5: get_id() is a static function whose one argument,
// named obj, has the parameter type T and whose result is a longint; it
// returns 0 for null and, for an object, a nonzero value that is the same at
// every call.
//
// The test creates no weak_reference object. From outside a class, the class
// scope operator reaches the static members of the class (8.23), and every
// call here goes through it, so the calls need get_id() to be static. The
// argument is bound once by position and once by the name obj (13.5.4), and
// a handle of circle, which extends the parameter type shape, is passed where
// a shape is expected. $typename (20.6.1) and $bits (20.6.2) give the type
// and the width of the result without calling get_id(). Subtracting 1 from
// the result for null gives -1 when the result is signed, and 2**64 - 1 if it
// were an unsigned 64-bit type. The identification values themselves are not
// printed, only how they compare.

module test_weak_reference_get_id_static_longint;
  class shape;
  endclass

  class circle extends shape;
  endclass

  typedef weak_reference #(shape) shape_ref;
  typedef weak_reference #(circle) circle_ref;

  shape s;
  circle c;
  longint by_position, by_name, from_derived;

  initial begin
    s = new();
    c = new();
    by_position = shape_ref::get_id(s);
    by_name = shape_ref::get_id(.obj(s));
    from_derived = shape_ref::get_id(c);
    $display("type of the result: %s", $typename(shape_ref::get_id(s)));
    $display("width of the result: %0d", $bits(shape_ref::get_id(s)));
    $display("result for null minus 1: %0d", shape_ref::get_id(null) - 1);
    $display("bound by name equals bound by position: %0d, nonzero: %0d",
             by_name == by_position, by_position != 0);
    $display("circle handle as shape: nonzero %0d, differs from s %0d, same as circle_ref %0d",
             from_derived != 0, from_derived != by_position,
             from_derived == circle_ref::get_id(.obj(c)));
  end
endmodule
