/*
:name: test_illegal_base_handle_assigned_to_derived
:description: a superclass handle cannot be assigned directly to a subclass variable, though $cast may do it (IEEE 1800-2023 Section 8.16)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the base_c handle b is assigned directly to the derived_c variable d2
:expected_stderr_regex: test_illegal_base_handle_assigned_to_derived\.sv:36:
*/
// IEEE 1800-2023 §8.16: assigning a subclass expression to a superclass
// variable is always legal, and $cast may assign a superclass handle to a
// subclass variable when the object it refers to is assignment compatible;
// a direct assignment of a superclass variable to a subclass variable is
// illegal.

class base_c;
  int b = 1;
endclass

class derived_c extends base_c;
  int d = 2;
endclass

module test_illegal_base_handle_assigned_to_derived;
  base_c b;
  derived_c d1, d2;

  initial begin
    d1 = new;
    b = d1;
    if ($cast(d2, b)) $display("%0d", d2.d);
    d2 = b;   // illegal: superclass handle into a subclass variable
  end
endmodule
