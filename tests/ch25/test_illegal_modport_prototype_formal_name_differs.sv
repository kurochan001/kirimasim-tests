/*
:name: test_illegal_modport_prototype_formal_name_differs
:description: The formal argument names given in a subroutine prototype of a modport have to be the names of the subroutine declaration (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of sum in the modport bad names its arguments x and y, while the function sum of mpn_bus names them a and b
:expected_stderr_regex: test_illegal_modport_prototype_formal_name_differs\.sv:(31|43):
*/
// IEEE 1800-2023 §25.7: formal argument names in a prototype are optional in
// general, but the names that a prototype gives shall be the same as the
// formal argument names of the declaration. The function sum of mpn_bus has
// the arguments a and b. The modport ok gives the names a and b and the
// modport anon gives no names, both legal; the modport bad names them x and y.
// Every call binds its arguments by position.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the lines named here, are not counted; the
// 5.052 release of Verilator does not parse the legal prototype without
// argument names of the modport anon.

interface mpn_bus;
  function int sum(input int a, input int b);
    return a + b;
  endfunction
  modport ok (import function int sum(input int a, input int b));
  modport anon (import function int sum(input int, input int));
  modport bad (import function int sum(input int x, input int y));   // illegal: x and y
endinterface

module mpn_ok_user(mpn_bus.ok p);
  initial $display("%0d", p.sum(1, 2));
endmodule

module mpn_anon_user(mpn_bus.anon p);
  initial #1 $display("%0d", p.sum(3, 4));
endmodule

module mpn_bad_user(mpn_bus.bad p);
  initial #2 $display("%0d", p.sum(5, 6));   // the error can also be reported here
endmodule

module test_illegal_modport_prototype_formal_name_differs;
  mpn_bus bus ();
  mpn_ok_user u1 (bus);
  mpn_anon_user u2 (bus);
  mpn_bad_user u3 (bus);
endmodule
