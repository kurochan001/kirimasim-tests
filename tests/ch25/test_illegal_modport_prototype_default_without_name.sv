/*
:name: test_illegal_modport_prototype_default_without_name
:description: A subroutine prototype in a modport that gives a default argument value has to name that argument (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of sum in the modport bad gives the default value 5 to its second argument without naming the argument
:expected_stderr_regex: test_illegal_modport_prototype_default_without_name\.sv:31:
*/
// IEEE 1800-2023 §25.7: a default argument value needed in a call is given in
// the prototype, and the formal argument names of a prototype are optional
// unless default values are used. The modport ok imports the function sum of
// mpd_bus with a prototype that names b and gives it the default 2. The
// prototype of the modport bad gives its second argument the default 5 but
// no name.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the lines named here, are not counted; the
// 5.052 release of Verilator rejects the line with a syntax error that asks for
// a name, but it also rejects legal prototypes without argument names, so that
// is not counted either.

interface mpd_bus;
  function int sum(input int a, input int b = 2);
    return a + b;
  endfunction
  modport ok (import function int sum(input int a, input int b = 2));
  modport bad (import function int sum(input int a, input int = 5));   // illegal: no name
endinterface

module mpd_ok_user(mpd_bus.ok p);
  initial $display("%0d", p.sum(1));
endmodule

module test_illegal_modport_prototype_default_without_name;
  mpd_bus bus ();
  mpd_ok_user u1 (bus);
endmodule
