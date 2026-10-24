/*
:name: test_illegal_chandle_continuous_assignment
:description: a chandle cannot be used in a continuous assignment (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment assign c = a drives the chandle variable c from the chandle a
:expected_stderr_regex: test_illegal_chandle_continuous_assignment\.sv:31:
*/
// IEEE 1800-2023 §6.14: chandles shall not be used in continuous assignments.
// The module item assign c = a continuously assigns the chandle a to the
// chandle variable c; a procedural assignment between the same chandles would
// be legal.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_continuous_assignment;
  chandle a, b;
  int k;
  chandle c;
  assign c = a;   // illegal: chandles in a continuous assignment
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
  end
endmodule
