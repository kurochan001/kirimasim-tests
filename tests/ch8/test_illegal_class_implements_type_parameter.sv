/*
:name: test_illegal_class_implements_type_parameter
:description: A class cannot implement a type parameter, even one whose value is an interface class (IEEE 1800-2023 Section 8.26.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the class implements its type parameter T
:expected_stderr_regex: test_illegal_class_implements_type_parameter\.sv:24:
*/
// IEEE 1800-2023 §8.26.4: a class shall not implement a type parameter, even
// when the parameter resolves to an interface class. Icarus Verilog 13.0 does
// not support interface classes, so the syntax errors it reports there, as on
// most other lines, do not count.

module test_illegal_class_implements_type_parameter;
  interface class sink_if;
    pure virtual function void take(int v);
  endclass

  class buffer #(type T = sink_if) implements T;   // illegal: T is a type parameter
    virtual function void take(int v);
    endfunction
  endclass

  buffer b;
endmodule
