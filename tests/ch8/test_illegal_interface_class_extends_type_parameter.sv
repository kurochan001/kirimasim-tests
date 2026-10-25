/*
:name: test_illegal_interface_class_extends_type_parameter
:description: An interface class cannot extend its type parameter, even when the parameter is an interface class (IEEE 1800-2023 Section 8.26.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.26.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the interface class wrap_if extends its type parameter T
:expected_stderr_regex: test_illegal_interface_class_extends_type_parameter\.sv:26:
*/
// IEEE 1800-2023 §8.26.4: an interface class shall not extend a type
// parameter, even if the type parameter resolves to an interface class.
// The default of T below is the interface class put_if. Icarus Verilog 13.0
// does not support interface classes, so the syntax errors it reports do
// not count.
// The 5.052 release of Verilator accepts the design.

module test_illegal_interface_class_extends_type_parameter;
  interface class put_if;
    pure virtual function void put(int x);
  endclass

  interface class wrap_if #(type T = put_if) extends T;   // illegal: extends a type parameter
  endclass
endmodule
