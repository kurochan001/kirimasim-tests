/*
:name: test_illegal_matching_methods_without_implements
:description: a class that has the methods of an interface class but does not name it with implements does not implement it (IEEE 1800-2023 Section 8.26)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26 8.22
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sq_c is assigned to the interface class variable s, but neither sq_c nor a superclass of it implements shape_if
:expected_stderr_regex: test_illegal_matching_methods_without_implements\.sv:49:
*/
// IEEE 1800-2023 §8.26: providing implementations for all the pure virtual
// methods of an interface class is not enough: the class or a superclass of
// it shall name the interface class with implements, or the class does not
// implement it. tri_c implements shape_if, and so does its subclass tri2_c;
// sq_c has the same method but no implements, so a handle of it cannot be
// assigned to a shape_if variable.
// Icarus Verilog 13.0 does not support interface classes.

interface class shape_if;
  pure virtual function int sides();
endclass

class tri_c implements shape_if;
  virtual function int sides();
    return 3;
  endfunction
endclass

class tri2_c extends tri_c;
endclass

class sq_c;
  virtual function int sides();
    return 4;
  endfunction
endclass

module test_illegal_matching_methods_without_implements;
  shape_if s;
  tri2_c t = new;
  sq_c q = new;

  initial begin
    s = t;
    $display("%0d", s.sides());
    s = q;   // illegal: sq_c does not implement shape_if
  end
endmodule
