/*
:name: test_ch6_extra_const_handle_write
:description: A const class handle cannot be written after its declaration, although the members of its object can be (IEEE 1800-2023 Section 6.20.6)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.20.6 8.7
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the initial procedure assigns a new object to the const handle obj
:expected_stderr_regex: test_ch6_extra_const_handle_write\.sv:30:
*/
// IEEE 1800-2023 §6.20.6: an object handle declared const acts like a
// variable that cannot be written; the members of its object can be written
// unless they are const themselves. The declaration of obj on the marked line
// is the one allowed write; assigning another object to obj later is illegal.
// Writing obj.n would be legal and is covered by
// test_const_runtime_automatic_and_class_handle.

class test_ch6_extra_const_handle_write_c;
  int n;
  function new();
    n = 1;
  endfunction
endclass

module test_ch6_extra_const_handle_write;
  const test_ch6_extra_const_handle_write_c obj = new();
  initial obj = new();   // illegal: the handle is const
endmodule
