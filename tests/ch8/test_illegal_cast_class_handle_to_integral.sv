/*
:name: test_illegal_cast_class_handle_to_integral
:description: a class handle cannot be cast to an integral type (IEEE 1800-2023 Section 8.28)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.28 6.24.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class handle h is cast to longint
:expected_stderr_regex: test_illegal_cast_class_handle_to_integral\.sv:36:
*/
// IEEE 1800-2023 §8.28: unlike a C pointer, a class handle cannot be cast
// onto other data types. Handles may be compared, assigned to a variable of
// a superclass, and converted with $cast between class types (8.16); the cast
// longint'(h) of a handle to an integral type is illegal.
// Icarus Verilog 13.0 stops with a failed internal assertion. Verilator 5.052
// reports the cast as unsupported, which does not count as rejecting it.

class base_c;
  int v = 1;
endclass

class derived_c extends base_c;
endclass

module test_illegal_cast_class_handle_to_integral;
  derived_c h = new;
  base_c b;
  longint n;

  initial begin
    b = h;
    $display("%0d", b != null);
    n = longint'(h);   // illegal: a handle cast to an integral type
  end
endmodule
