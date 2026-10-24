/*
:name: test_illegal_class_extends_interface_class
:description: a class cannot extend an interface class; it has to implement it (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class bad_c extends the interface class a_if
:expected_stderr_regex: test_illegal_class_extends_interface_class\.sv:44:
*/
// IEEE 1800-2023 §8.26.2: a class or virtual class may extend at most one
// class or virtual class and implement any number of interface classes, also
// both at once, but it may not extend an interface class, nor implement a
// class. ok_c extends base_c and implements a_if and b_if, which is legal;
// bad_c extends a_if.
// Icarus Verilog 13.0 does not support interface classes.

interface class a_if;
  pure virtual function int fa();
endclass

interface class b_if;
  pure virtual function int fb();
endclass

class base_c;
  virtual function int fa();
    return 1;
  endfunction
endclass

class ok_c extends base_c implements a_if, b_if;
  virtual function int fa();
    return 4;
  endfunction
  virtual function int fb();
    return 2;
  endfunction
endclass

class bad_c extends a_if;   // illegal: extends an interface class
  virtual function int fa();
    return 3;
  endfunction
endclass

module test_illegal_class_extends_interface_class;
  ok_c h = new;
  initial $display("%0d %0d", h.fa(), h.fb());
endmodule
