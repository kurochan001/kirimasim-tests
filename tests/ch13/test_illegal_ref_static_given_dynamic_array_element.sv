/*
:name: test_illegal_ref_static_given_dynamic_array_element
:description: a ref static argument cannot be passed an element of a dynamic array, although the array variable itself is static (IEEE 1800-2023 Section 13.5.2)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the element dyn[1] of a dynamic array is passed to the ref static argument of bump
:expected_stderr_regex: test_illegal_ref_static_given_dynamic_array_element\.sv:36:
*/
// IEEE 1800-2023 §13.5.2: a ref static argument shall not be passed elements
// of dynamically sized array variables, even when the array variable has
// static lifetime: such an element can be removed while the reference is in
// use. The first call passes an element of the fixed-size array fixed_a,
// which is legal, and the legal design prints it after the increment: 1. The
// second call passes dyn[1], an element of a dynamic array declared in the
// module.
// Icarus Verilog 13.0 does not support ref arguments, and the 5.052 release
// of Verilator does not support ref static ones; both stop at a task header.

module test_illegal_ref_static_given_dynamic_array_element;
  int fixed_a[2];
  int dyn[];

  task automatic bump(ref static int r);
    r++;
  endtask

  initial begin
    dyn = new[2];
    bump(fixed_a[1]);
    $display("%0d", fixed_a[1]);
    bump(dyn[1]);   // illegal: an element of a dynamic array for a ref static argument
  end
endmodule
