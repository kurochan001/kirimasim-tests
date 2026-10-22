/*
:name: test_illegal_handle_to_real_cast
:description: A class handle cannot be converted to a real even by an explicit cast (IEEE 1800-2023 Section 6.22.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a class handle is cast to an incompatible real type
:expected_stderr_regex: test_illegal_handle_to_real_cast\.sv:(?:21)(?::|\s)
*/
// IEEE 1800-2023 6.22.5: Object handles are incompatible with scalar arithmetic
// types; an explicit cast does not expose an address value.

module test_illegal_handle_to_real_cast;
  class item; endclass
  item obj;
  real value;
  initial value = real'(obj); // illegal
endmodule
