/*
:name: test_illegal_extern_header_mismatch
:description: an external method body must repeat the prototype argument types
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.24
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the external body declares byte where the extern prototype declares int
:expected_stderr_regex: test_illegal_extern_header_mismatch\.sv:23:
*/
// IEEE 1800-2023 8.24: the header of an external method definition shall match
// its class-body prototype, apart from the permitted scope qualifications and
// the omission of default expressions. The marked body changes the argument
// type from int to byte, which a tool has to reject.

class ext_c;
  extern function int f(int a);
endclass

function int ext_c::f(byte a); // illegal: argument type differs from prototype
  return a + 1;
endfunction

module test_illegal_extern_header_mismatch;
  ext_c c;
  initial c = new;
endmodule
