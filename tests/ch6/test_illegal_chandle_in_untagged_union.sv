/*
:name: test_illegal_chandle_in_untagged_union
:description: a chandle cannot be a member of an untagged union (IEEE 1800-2023 Sections 6.14, 7.3)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14 7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the untagged union type u_t has the chandle member h
:expected_stderr_regex: test_illegal_chandle_in_untagged_union\.sv:29:
*/
// IEEE 1800-2023 §6.14: chandles shall not be used in untagged unions. §7.3:
// dynamic types and chandle types can only be used in tagged unions. The union
// type u_t has no tagged qualifier and has a chandle member.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_in_untagged_union;
  chandle a, b;
  int k;
  typedef union { chandle h; int i; } u_t;   // illegal: chandle in an untagged union
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
