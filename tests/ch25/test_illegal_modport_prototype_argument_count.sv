/*
:name: test_illegal_modport_prototype_argument_count
:description: The number of arguments of a subroutine prototype in a modport has to match the declaration of the subroutine (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the modport bad imports sum with a prototype of one argument, while the function sum of mpc_bus is declared with two
:expected_stderr_regex: ^(?![^\n]*(?i:unsupported|not supported|not implemented|syntax error|invalid module))[^\n]*test_illegal_modport_prototype_argument_count\.sv:(?:26|30):(?:\d+:)?[^\n]*(?i:(?:number|count)[^\n]*arguments?|arguments?[^\n]*(?:number|count|too few|too many))
*/
// IEEE 1800-2023 §25.7: the number and types of the arguments of a prototype
// shall match those of the subroutine declaration. The function sum of mpc_bus
// has two arguments, a and b. The modport ok imports it with a prototype of
// the same two arguments, and mpc_ok_user calls sum(1, 2) through it, which is
// legal; the modport bad imports it with a prototype that has only a. The
// module mpc_bad_user is connected to bad and makes no call, so the only
// error is the prototype itself, not a call that leaves out b.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the lines named here, are not counted; the
// 5.052 release of Verilator accepts the design.

interface mpc_bus;
  function int sum(input int a, input int b);
    return a + b;
  endfunction
  modport ok (import function int sum(input int a, input int b));
  modport bad (import function int sum(input int a));   // illegal: one argument too few
endinterface

module mpc_ok_user(mpc_bus.ok p);
  initial $display("%0d", p.sum(1, 2));
endmodule

module mpc_bad_user(mpc_bus.bad p);
endmodule

module test_illegal_modport_prototype_argument_count;
  mpc_bus bus ();
  mpc_ok_user u1 (bus);
  mpc_bad_user u2 (bus);
endmodule
