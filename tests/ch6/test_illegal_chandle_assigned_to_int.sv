/*
:name: test_illegal_chandle_assigned_to_int
:description: a chandle cannot be assigned to a variable of another type, such as int (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the chandle a is assigned to the int variable k
:expected_stderr_regex: test_illegal_chandle_assigned_to_int\.sv:42:
*/
// IEEE 1800-2023 §6.14: chandles shall not be assigned to variables of any
// other type. The last statement assigns the chandle a to the int variable k.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_assigned_to_int;
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
    k = a;   // illegal: a chandle assigned to an int
  end
endmodule
