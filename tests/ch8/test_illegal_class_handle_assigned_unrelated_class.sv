/*
:name: test_illegal_class_handle_assigned_unrelated_class
:description: a handle can be assigned only an object of an assignment compatible class or null; an object of an unrelated class is an error (IEEE 1800-2023 Section 8.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the handle o of the class other_c is assigned to the handle b of the unrelated class base_c
:expected_stderr_regex: test_illegal_class_handle_assigned_unrelated_class\.sv:47:
*/
// IEEE 1800-2023 §8.4: the only operators valid on object handles are == and !=
// with another class object or null, one of the two being assignment compatible
// with the other, === and !== with the same operands, the conditional operator,
// the assignment of a class object whose class is assignment compatible with
// the target, and the assignment of null. Unlike a C pointer, a handle cannot
// be incremented or take part in other arithmetic (Table 8-1).
// The legal part assigns a derived_c object to the base_c handle b, selects b
// or null with the conditional operator, and compares the handles with ==, !=,
// === and !== against a compatible handle or null; it prints 1 1 1 1 1. The
// last statement assigns the handle o of other_c to b, of base_c.
// Icarus Verilog 13.0 also rejects the legal conditional operator with a class
// handle and null ("Data types class and logic of ternary do not match").

module test_illegal_class_handle_assigned_unrelated_class;
  class base_c;
    int v = 1;
  endclass
  class derived_c extends base_c;
  endclass
  class other_c;
    int w = 2;
  endclass
  base_c b, r;
  derived_c d;
  other_c o;
  int k = 0;
  bit sel = 1;
  initial begin
    d = new;
    b = d;
    o = new;
    r = sel ? b : null;
    $display("%0d %0d %0d %0d %0d", b == d, b != null, r === b, o !== null, r.v);
    b = o;   // illegal: an object of an unrelated class
  end
endmodule
