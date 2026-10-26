/*
:name: test_extern_method_class_type_visibility
:description: An out-of-block method sees every declaration of its class, and a prototype declared after a class type uses that class type rather than a same-named outer type (IEEE 1800-2023 Section 8.24)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.24
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_extern_method_class_type_visibility.expected
*/
// IEEE 1800-2023 §8.24: an out-of-block method declaration can access all
// declarations of its class, and the prototype sees class types that are
// declared before it. The outer typedef real T and the class typedef int T
// have the same name. Because C::T is declared before the prototype, the
// prototype's T is int, and the out-of-block definition repeats C::T. The
// property v is declared after the prototype and is read by the body.

typedef real T;

class C;
  typedef int T;
  extern function T f();
  int v = 5;
endclass

function C::T C::f();
  return v;
endfunction

module test_extern_method_class_type_visibility;
  C c;

  initial begin
    c = new;
    $display("extern=%0d", c.f());
  end
endmodule
