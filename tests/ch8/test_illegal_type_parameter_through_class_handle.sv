/*
:name: test_illegal_type_parameter_through_class_handle
:description: a type parameter of a class cannot be reached through a class handle, while a value parameter can (IEEE 1800-2023 Section 8.5)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.5 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the type parameter elem_t is accessed through the class handle h
:expected_stderr_regex: test_illegal_type_parameter_through_class_handle\.sv:32:
*/
// IEEE 1800-2023 §8.5: the value parameters and local value parameters of
// an object can be read through a handle of the object, but a data type
// cannot be accessed through a class handle. The value parameter width and
// the type elem_t reached with the class scope operator are legal; $bits of
// h.elem_t reaches the type through the handle h.
// Icarus Verilog 13.0 stops with a syntax error at the declaration of the
// parameterized class, which does not count.

class holder_c #(parameter int width = 4, type elem_t = int);
  elem_t data;
endclass

module test_illegal_type_parameter_through_class_handle;
  holder_c #(8, byte) h = new;

  initial begin
    $display("%0d", h.width);
    $display("%0d", $bits(holder_c#(8, byte)::elem_t));
    $display("%0d", $bits(h.elem_t));   // illegal: a data type through a handle
  end
endmodule
