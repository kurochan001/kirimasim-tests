/*
:name: test_illegal_typed_new_not_assignment_compatible
:description: the class of a typed constructor call has to be assignment compatible with the target (IEEE 1800-2023 Section 8.8)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.8 8.16
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: base_c::new constructs a base_c object for a derived_c variable, to which base_c is not assignment compatible
:expected_stderr_regex: test_illegal_typed_new_not_assignment_compatible\.sv:34:
*/
// IEEE 1800-2023 §8.8: a class scope before new gives the type of the object
// to construct independently of the target, and that type shall be
// assignment compatible with the target. derived_c::new into a base_c
// variable is legal (8.16); base_c::new into a derived_c variable is not,
// as a superclass handle cannot be assigned to a subclass variable.

class base_c;
  int b = 1;
endclass

class derived_c extends base_c;
  int d = 2;
endclass

module test_illegal_typed_new_not_assignment_compatible;
  base_c bh;
  derived_c dh;

  initial begin
    bh = derived_c::new;
    dh = base_c::new;   // illegal: base_c is not assignment compatible
    $display("%0d", bh.b);
  end
endmodule
