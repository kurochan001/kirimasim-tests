/*
:name: test_illegal_modport_prototype_type_not_matching
:description: The argument types of a subroutine prototype in a modport have to be matching types, not only equivalent types, of the declaration (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7 6.22.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of twice in the modport bad has an argument of type bit signed [0:31], which is equivalent to int but does not match it
:expected_stderr_regex: test_illegal_modport_prototype_type_not_matching\.sv:31:
*/
// IEEE 1800-2023 §25.7: the types of the arguments of a prototype shall match
// the argument types of the declaration, by the rules of type matching of
// 6.22.1. The function twice of mpt_bus takes an int. The modport ok imports
// it with the argument type bit signed [31:0], which matches int (6.22.1 e:
// a 2-state signed vector of the same width with the range [31:0]); the
// modport bad uses bit signed [0:31], which is equivalent to int (6.22.2) but
// does not match it, because its range is not [31:0]. mpt_bad_user is
// connected to bad and makes no call.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the line named here, are not counted; the
// 5.052 release of Verilator accepts the design.

interface mpt_bus;
  function int twice(input int v);
    return 2 * v;
  endfunction
  modport ok (import function int twice(input bit signed [31:0] v));
  modport bad (import function int twice(input bit signed [0:31] v));   // illegal: not int
endinterface

module mpt_ok_user(mpt_bus.ok p);
  initial $display("%0d", p.twice(21));
endmodule

module mpt_bad_user(mpt_bus.bad p);
endmodule

module test_illegal_modport_prototype_type_not_matching;
  mpt_bus bus ();
  mpt_ok_user u1 (bus);
  mpt_bad_user u2 (bus);
endmodule
