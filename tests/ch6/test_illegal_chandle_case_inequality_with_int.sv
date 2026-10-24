/*
:name: test_illegal_chandle_case_inequality_with_int
:description: the case inequality operator !== on a chandle is valid only with another chandle or null, not with an int (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the chandle a is compared with the int variable k by !==
:expected_stderr_regex: test_illegal_chandle_case_inequality_with_int\.sv:43:
*/
// IEEE 1800-2023 §6.14: the only operators valid on chandle variables are ==,
// !=, === and !==, each with another chandle or with null as the other operand.
// The last statement compares the chandle a with the int variable k by !==.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_case_inequality_with_int;
  chandle a, b;
  int k;
  class holder;
    chandle h;
  endclass
  holder o;
  function automatic chandle pass(chandle x);
    return x;
  endfunction
  initial begin
    b = pass(a);
    o = new;
    o.h = b;
    a = null;
    $display("%0d %0d %0d %0d", a == null, a != b, a === o.h, b !== null);
    if (b) $display("set"); else $display("null");
    if (a !== k) $display("same");   // illegal: !== between a chandle and an int
  end
endmodule
