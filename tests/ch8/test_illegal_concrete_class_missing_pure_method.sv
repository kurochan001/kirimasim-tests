/*
:name: test_illegal_concrete_class_missing_pure_method
:description: a non-abstract class derived from abstract classes has to implement every pure virtual method it inherits, also one declared two levels up (IEEE 1800-2023 Section 8.21)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.21 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the non-abstract class leaf_c does not implement the pure virtual method area that it inherits
:expected_stderr_regex: test_illegal_concrete_class_missing_pure_method\.sv:39:
*/
// IEEE 1800-2023 §8.21: an abstract class (virtual class) may declare pure
// virtual methods, and a class derived from it may stay abstract; a class
// that is not abstract shall provide implementations of all the pure virtual
// methods it inherits. mid_c is abstract and implements name only; full_c
// implements area as well and is legal; leaf_c, not abstract, implements
// no method at all, so area is missing.
// Icarus Verilog 13.0 does not support pure virtual methods.

virtual class shape_c;
  pure virtual function string name();
  pure virtual function int area();
endclass

virtual class mid_c extends shape_c;
  virtual function string name();
    return "mid";
  endfunction
endclass

class full_c extends mid_c;
  virtual function int area();
    return 4;
  endfunction
endclass

class leaf_c extends mid_c;   // illegal: area is not implemented
endclass

module test_illegal_concrete_class_missing_pure_method;
  full_c f = new;
  initial $display("%s %0d", f.name(), f.area());
endmodule
