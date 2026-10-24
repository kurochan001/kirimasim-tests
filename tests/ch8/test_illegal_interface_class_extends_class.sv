/*
:name: test_illegal_interface_class_extends_class
:description: an interface class cannot extend a class that is not an interface class (IEEE 1800-2023 Section 8.26.2)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.2 8.26
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class bad_if extends the class base_c
:expected_stderr_regex: test_illegal_interface_class_extends_class\.sv:38:
*/
// IEEE 1800-2023 §8.26.2: an interface class may extend zero or more
// interface classes, but it may not extend a class or virtual class, nor
// implement anything. both_if extends two interface classes, which is legal;
// bad_if extends the class base_c.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

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

interface class both_if extends a_if, b_if;
endclass

interface class bad_if extends base_c;   // illegal: base_c is not an interface class
endclass

module test_illegal_interface_class_extends_class;
  initial $display("done");
endmodule
