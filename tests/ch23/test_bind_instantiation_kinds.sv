/*
:name: test_bind_instantiation_kinds
:description: Bind directives in a module and, with an attribute, in the compilation unit insert a module, a program, an interface and a checker instance into all instances of a module, the listed instances, an interface and one instance, with their ports connected from the target (IEEE 1800-2023 Section 23.11)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.11 17.3 17.5 24.3 A.1.2 A.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bind_instantiation_kinds.expected
*/
// IEEE 1800-2023 §23.11 and A.1.4: a bind directive inserts a program,
// module, interface or checker instance into a target scope (all instances of
// a module or interface, or only those listed after a colon) or into one
// target instance; the actual ports are names seen from the target. A bind
// directive can be a module item and, with attribute instances before it, a
// description of the compilation unit (A.1.2). A.10 note 4: into an interface
// only an interface or checker instance is bound.
//   - bk_mod_probe goes into both instances of bk_cpu, so twice = 2 * a is
//     20 in c1 and 40 in c2;
//   - bk_if_probe goes into the interface instance u_bus: plus = level + 100;
//   - bk_prog_probe goes only into c1 (instance list) and prints at time 5;
//     the end of its initial procedure ends the simulation (24.3);
//   - bk_chk_probe goes only into c2 (second form) and prints in its final
//     procedure (17.5), the only final procedure of the design.
// Icarus Verilog 13.0 stops with a syntax error at the bind directive, and
// the 5.052 release of Verilator at the hierarchical target instance names;
// with only module targets it prints the expected values for each instance.

module bk_cpu (input var int a);
endmodule

interface bk_bus;
  int level = 3;
endinterface

module bk_mod_probe (input var int x);
  int twice;
  assign twice = 2 * x;
endmodule

program bk_prog_probe (input var int x);
  initial #5 $display("program %m x=%0d", x);
endprogram

interface bk_if_probe (input var int x);
  int plus;
  assign plus = x + 100;
endinterface

checker bk_chk_probe (int x);
  final $display("checker %m x=%0d", x);
endchecker

(* bk_note *) bind bk_cpu : test_bind_instantiation_kinds.c1 bk_prog_probe u_pp (.x(a));

module test_bind_instantiation_kinds;
  bk_cpu c1 (.a(10)), c2 (.a(20));
  bk_bus u_bus ();

  bind bk_cpu bk_mod_probe u_mp (.x(a));
  bind bk_bus bk_if_probe u_ip (.x(level));
  bind test_bind_instantiation_kinds.c2 bk_chk_probe u_cp (a);

  initial #1 $display("module c1=%0d c2=%0d interface=%0d", c1.u_mp.twice, c2.u_mp.twice,
                      u_bus.u_ip.plus);
endmodule
