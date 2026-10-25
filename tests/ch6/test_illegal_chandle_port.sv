/*
:name: test_illegal_chandle_port
:description: a port cannot have the chandle data type (IEEE 1800-2023 Section 6.14)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.14
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the input port h of the module test_illegal_chandle_port_m has the chandle data type
:expected_stderr_regex: test_illegal_chandle_port\.sv:28:
*/
// IEEE 1800-2023 §6.14: ports shall not have the chandle data type; chandles
// can be passed as arguments to subroutines instead. The module
// test_illegal_chandle_port_m, which is not instantiated, declares the variable
// input port h of type chandle, while the function pass of the main module
// takes a chandle argument legally.
// The legal part of the design uses chandles only in ways that the clause
// lists: b is assigned the chandle that a function returns for its chandle
// argument a, the chandle property of a class object is assigned b, a is
// assigned null, the chandles are compared with ==, !=, === and !== against
// another chandle or null, and b is tested for its Boolean value; it prints
// 1 0 1 0 and null.
// Icarus Verilog 13.0 does not support the chandle type and reports syntax
// errors on the declarations that use it, which do not count.

module test_illegal_chandle_port_m (input var chandle h);   // illegal: chandle port
endmodule

module test_illegal_chandle_port;
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
  end
endmodule
