/*
:name: test_illegal_implements_type_parameter
:description: a class cannot implement a type parameter even when it resolves to an interface class
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the implements list names the type parameter I instead of an interface class
:expected_stderr_regex: test_illegal_implements_type_parameter\.sv:22:
*/
// IEEE 1800-2023 8.26.4: a class cannot implement a type parameter, even if
// that parameter resolves to an interface class. The marked class names the
// type parameter I in its implements list, which a tool has to reject.

interface class iface_c;
  pure virtual function int f();
endclass

class impl_t #(type I = iface_c) implements I; // illegal: I is a type parameter
  virtual function int f();
    return 1;
  endfunction
endclass

module test_illegal_implements_type_parameter;
  impl_t#(iface_c) c;
  initial c = new;
endmodule
