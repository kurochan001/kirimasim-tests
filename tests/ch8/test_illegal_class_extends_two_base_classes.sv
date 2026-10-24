/*
:name: test_illegal_class_extends_two_base_classes
:description: a class can extend at most one class, even while it implements several interface classes (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class bad_c names two base classes, base_c and other_c, after extends
:expected_stderr_regex: test_illegal_class_extends_two_base_classes\.sv:48:
*/
// IEEE 1800-2023 §8.26.2: a class or virtual class may extend at most one
// other class or virtual class, while it may implement zero or more
// interface classes, also at the same time. ok_c extends base_c and
// implements a_if and b_if, which is legal; bad_c lists two classes after
// extends.
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

class other_c;
  int o = 5;
endclass

class ok_c extends base_c implements a_if, b_if;
  virtual function int fa();
    return 4;
  endfunction
  virtual function int fb();
    return 2;
  endfunction
endclass

class bad_c extends base_c, other_c;   // illegal: two base classes
endclass

module test_illegal_class_extends_two_base_classes;
  ok_c h = new;
  initial $display("%0d %0d", h.fa(), h.fb());
endmodule
