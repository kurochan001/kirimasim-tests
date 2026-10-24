/*
:name: test_illegal_chandle_in_packed_struct
:description: a chandle cannot be used in a packed type, such as a member of a packed structure (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the packed structure type ps_t has the chandle member h
:expected_stderr_regex: test_illegal_chandle_in_packed_struct\.sv:29:
*/
// IEEE 1800-2023 §6.14: chandles shall not be used in packed types. The
// structure type ps_t is packed and has a chandle member; the class holder,
// which also has a chandle member, is legal.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_in_packed_struct;
  chandle a, b;
  int k;
  typedef struct packed { chandle h; bit f; } ps_t;   // illegal: chandle in a packed type
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
