/*
:name: test_illegal_override_specifier_in_interface_class
:description: a dynamic override specifier cannot be used on a method of an interface class (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2 8.26 8.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure virtual method put of the interface class put_if has the dynamic override specifier :initial
:expected_stderr_regex: test_illegal_override_specifier_in_interface_class\.sv:27:
*/
// IEEE 1800-2023 §9.2: the dynamic override specifiers (:initial, :extends,
// :final, 8.20) shall only be legal on method declarations inside a class
// that is not an interface class. The implementation of put in fifo_c with
// :extends is legal; the prototype of put in the interface class put_if has
// :initial.
// Icarus Verilog 13.0 does not support interface classes, and Verilator 5.052
// accepts the design.

interface class get_if;
  pure virtual function int get();
endclass

interface class put_if;
  pure virtual function :initial void put(int v);   // illegal: in an interface class
endclass

class fifo_c implements get_if;
  int last;
  virtual function int get();
    return last;
  endfunction
endclass

class fifo2_c extends fifo_c;
  virtual function :extends int get();
    return last + 1;
  endfunction
endclass

module test_illegal_override_specifier_in_interface_class;
  fifo2_c f = new;
  initial $display("%0d", f.get());
endmodule
