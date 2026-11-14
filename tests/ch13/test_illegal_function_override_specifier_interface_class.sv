/*
:name: test_illegal_function_override_specifier_interface_class
:description: a function method of an interface class cannot have a dynamic override specifier (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pure virtual function size of the interface class is declared with the dynamic override specifier :initial
:expected_stderr_regex: test_illegal_function_override_specifier_interface_class\.sv:26:
*/
// IEEE 1800-2023 13.4 (Syntax 13-2, footnote 25): the dynamic override
// specifiers are legal only on methods of a class that is not an interface
// class. The interface class (suffix _ic) declares the function size with
// :initial; the class (suffix _box) implements it, and its own new method
// volume has :initial, which is legal there. :initial adds no other rule
// here: size overrides nothing. Without the specifier on size, the design
// prints 4 64.
// Icarus Verilog 13.0 reports a syntax error at the start of the interface
// class, which does not count; release 5.054 of Verilator accepts the
// design.

interface class test_illegal_function_override_specifier_interface_class_ic;
  pure virtual function :initial int size();   // illegal: in an interface class
endclass

class test_illegal_function_override_specifier_interface_class_box
    implements test_illegal_function_override_specifier_interface_class_ic;
  virtual function int size();
    return 4;
  endfunction
  function :initial int volume();
    return size() * size() * size();
  endfunction
endclass

module test_illegal_function_override_specifier_interface_class;
  test_illegal_function_override_specifier_interface_class_box b = new;
  initial $display("%0d %0d", b.size(), b.volume());
endmodule
