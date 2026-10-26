/*
:name: test_illegal_bits_interface_class
:description: $bits is applied to an object of an interface class type (IEEE 1800-2023 Section 20.6.2)
:tags: ch20
:type: elaboration
:lrm: 1800-2023 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: $bits is called on obj, whose type is the interface class ic
:expected_stderr_regex: test_illegal_bits_interface_class\.sv:22:
*/
// The $bits system function shall not be used on an object of an
// interface class type, whose size is not a fixed bit stream.

interface class ic;
  pure virtual function int f();
endclass
module test_illegal_bits_interface_class;
  ic obj;
  localparam int W = $bits(obj);   // illegal: interface class object
  initial $display(W);
endmodule
