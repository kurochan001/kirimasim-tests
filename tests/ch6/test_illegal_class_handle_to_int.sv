/*
:name: test_illegal_class_handle_to_int
:description: A class handle is type incompatible with every other type and cannot be assigned to an int (IEEE 1800-2023 Section 6.22.5)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.22.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: a class handle is assigned to an int variable
:expected_stderr_regex: test_illegal_class_handle_to_int\.sv:25:
*/
// IEEE 1800-2023 §6.22.5: class handles, interface class handles and chandles
// are type incompatible with all other types, so not even a cast converts a
// class handle to an int.

module test_illegal_class_handle_to_int;
  class item;
  endclass
  item h;
  int i;
  initial begin
    h = new();
    i = h;             // illegal: a class handle to an int
  end
endmodule
