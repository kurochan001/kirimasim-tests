/*
:name: test_illegal_modport_prototype_unpacked_dimension_without_name
:description: A subroutine prototype in a modport that declares an unpacked dimension of an argument has to name that argument (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the prototype of first in the modport bad declares the unpacked dimension [2] of its argument without naming the argument
:expected_stderr_regex: test_illegal_modport_prototype_unpacked_dimension_without_name\.sv:31:
*/
// IEEE 1800-2023 §25.7: the formal argument names of a prototype are optional
// unless additional unpacked dimensions are declared. The function first of
// mpa_bus takes an argument v of the unpacked array type int [2]. The modport
// ok imports it with a prototype that names v and declares its dimension
// [2]; the prototype of the modport bad declares the dimension [2] without a
// name.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the lines named here, are not counted; the
// 5.052 release of Verilator rejects the line with a syntax error that asks for
// a name, but it also rejects legal prototypes without argument names, so that
// is not counted either.

interface mpa_bus;
  function int first(input int v[2]);
    return v[0];
  endfunction
  modport ok (import function int first(input int v[2]));
  modport bad (import function int first(input int [2]));   // illegal: no name
endinterface

module mpa_ok_user(mpa_bus.ok p);
  int a[2] = '{7, 8};
  initial $display("%0d", p.first(a));
endmodule

module test_illegal_modport_prototype_unpacked_dimension_without_name;
  mpa_bus bus ();
  mpa_ok_user u1 (bus);
endmodule
