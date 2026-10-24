/*
:name: test_illegal_modport_prototype_unnamed_named_binding
:description: A call that binds arguments by name through a modport needs a prototype that names the formal arguments (IEEE 1800-2023 Section 25.7)
:tags: ch25
:type: elaboration
:lrm: 1800-2023 25.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the module mpu_bad_user binds the arguments of sum by name through the modport anon, whose prototype of sum gives no argument names
:expected_stderr_regex: test_illegal_modport_prototype_unnamed_named_binding\.sv:43:
*/
// IEEE 1800-2023 §25.7: formal argument names in a prototype are optional
// unless argument binding by name is used. The modport named imports the
// function sum of mpu_bus with a prototype that names a and b, and
// mpu_ok_user calls sum(.a(1), .b(2)) through it; the modport anon imports
// it with a prototype without names, and mpu_pos_user calls sum(3, 4)
// through it by position. Both are legal. mpu_bad_user calls sum(.a(5),
// .b(6)) through anon.
// Oracle checks: Icarus Verilog 13.0 does not support subroutines in modports
// and its errors, which also fall on the lines named here, are not counted; the
// 5.052 release of Verilator does not parse the legal prototype without
// argument names of the modport anon.

interface mpu_bus;
  function int sum(input int a, input int b);
    return a + b;
  endfunction
  modport named (import function int sum(input int a, input int b));
  modport anon (import function int sum(input int, input int));
endinterface

module mpu_ok_user(mpu_bus.named p);
  initial $display("%0d", p.sum(.a(1), .b(2)));
endmodule

module mpu_pos_user(mpu_bus.anon p);
  initial #1 $display("%0d", p.sum(3, 4));
endmodule

module mpu_bad_user(mpu_bus.anon p);
  initial #2 $display("%0d", p.sum(.a(5), .b(6)));   // illegal: names not in the prototype
endmodule

module test_illegal_modport_prototype_unnamed_named_binding;
  mpu_bus bus ();
  mpu_ok_user u1 (bus);
  mpu_pos_user u2 (bus);
  mpu_bad_user u3 (bus);
endmodule
