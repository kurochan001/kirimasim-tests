/*
:name: test_illegal_chandle_increment
:description: a chandle cannot be incremented like a C pointer (IEEE 1800-2023 Section 8.4)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the chandle a is incremented with ++
:expected_stderr_regex: test_illegal_chandle_increment\.sv:27:
*/
// IEEE 1800-2023 §8.4 (Table 8-1): unlike a C pointer, neither an object handle
// nor a chandle allows arithmetic operations such as incrementing.
// The legal part assigns the chandle a to the chandle b and compares a with
// null and with b, and prints 1 1. The last statement increments a with ++.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on its declaration, which do not count. The 5.052 release accepts the
// design.

module test_illegal_chandle_increment;
  chandle a, b;
  initial begin
    b = a;
    $display("%0d %0d", a == null, a === b);
    a++;   // illegal: increment of a chandle
  end
endmodule
