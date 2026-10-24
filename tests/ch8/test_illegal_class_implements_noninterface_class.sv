/*
:name: test_illegal_class_implements_noninterface_class
:description: a class cannot implement a class that is not an interface class (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class bad_c implements the class base_c, which is not an interface class
:expected_stderr_regex: test_illegal_class_implements_noninterface_class\.sv:36:
*/
// IEEE 1800-2023 §8.26.2: a class or virtual class may implement zero or
// more interface classes and extend at most one class, but it may not
// implement a class or virtual class. ok_c extends base_c and implements
// a_if, which is legal; bad_c implements base_c.
// Icarus Verilog 13.0 does not support interface classes.

interface class a_if;
  pure virtual function int fa();
endclass

class base_c;
  virtual function int fa();
    return 1;
  endfunction
endclass

class ok_c extends base_c implements a_if;
  virtual function int fa();
    return 4;
  endfunction
endclass

class bad_c implements base_c;   // illegal: base_c is not an interface class
  virtual function int fa();
    return 3;
  endfunction
endclass

module test_illegal_class_implements_noninterface_class;
  ok_c h = new;
  initial $display("%0d", h.fa());
endmodule
