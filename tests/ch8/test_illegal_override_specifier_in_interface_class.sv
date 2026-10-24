/*
:name: test_illegal_override_specifier_in_interface_class
:description: the dynamic override specifiers such as :initial are not allowed on a method of an interface class (IEEE 1800-2023 Section 8.3)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the method put of the interface class is declared with the dynamic override specifier :initial
:expected_stderr_regex: test_illegal_override_specifier_in_interface_class\.sv:28:
*/
// IEEE 1800-2023 §8.3 (Syntax 8-1, footnote 25): the dynamic override
// specifiers :initial, :extends and :final shall be legal only on method
// declarations inside a class that is not an interface class.
// The interface class declares the pure virtual methods get and put, and the
// class impl_c implements both. impl_c also declares the new method extra with
// :initial, which is legal in a class that is not an interface class; the legal
// design prints what get and put return through an interface class handle and
// what extra returns: 4 5 6. The method put of the interface class has
// :initial.
// Icarus Verilog 13.0 reports syntax errors on the interface class, which do
// not count.

interface class test_illegal_override_specifier_in_interface_class_ic;
  pure virtual function int get();
  pure virtual function :initial int put();   // illegal: override specifier in an interface class
endclass

class test_illegal_override_specifier_in_interface_class_impl_c
    implements test_illegal_override_specifier_in_interface_class_ic;
  virtual function int get();
    return 4;
  endfunction
  virtual function int put();
    return 5;
  endfunction
  function :initial int extra();
    return 6;
  endfunction
endclass

module test_illegal_override_specifier_in_interface_class;
  test_illegal_override_specifier_in_interface_class_impl_c o;
  test_illegal_override_specifier_in_interface_class_ic h;
  initial begin
    o = new;
    h = o;
    $display("%0d %0d %0d", h.get(), h.put(), o.extra());
  end
endmodule
