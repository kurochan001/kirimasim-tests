/*
:name: test_program_design_signals_in_package_unit_and_interface
:description: Variables of a module, an interface, a package and the compilation unit are design signals, so a program waiting for their changes resumes in the Reactive region, and module code may read a package variable that a program writes (IEEE 1800-2023 Section 24.3)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.3 24.3.1 4.4.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_program_design_signals_in_package_unit_and_interface.expected
*/
// IEEE 1800-2023 §24.3: a net or variable declared in a module, an interface,
// a package or the compilation unit ($unit) is a design signal; only nets and
// variables declared in a program are program signals, and only references to
// program signals from outside every program are errors. §24.3.1: a program
// statement that waits for a change of a design signal is scheduled in the
// Reactive region, which runs after the Active and NBA regions of the time
// step (4.4.1).
// - At 5 the module writes the $unit variable dsu_unit_v, the package
//   variable dsu_pkg::pkg_v, the interface variable bus.if_v and its own
//   mod_v with blocking assignments, and stamp with a nonblocking one. Four
//   branches of the program wait for these four changes and copy stamp. As
//   all four variables are design signals, each branch resumes in the
//   Reactive region and copies the updated stamp 7; a branch resumed in the
//   Active region would copy 0. The program prints the copies after the join.
// - The program then writes the package variable from_prog. It is a design
//   signal, not a program signal, so the module may read it, at 6.
// The initial procedure of the program ends at 7, which ends the simulation.
// Icarus Verilog 13.0 does not accept the assignments to package variables
// by their package-scoped names, and Verilator 5.052 resumes the program in
// the Active region and copies 0.

`timescale 1ns/1ns

int dsu_unit_v = 0;

package dsu_pkg;
  int pkg_v = 0;
  int from_prog = 0;
endpackage

interface dsu_if;
  int if_v = 0;
endinterface

program dsu_prog;
  int s_pkg, s_unit, s_if, s_mod;

  initial begin
    fork
      begin
        @(dsu_pkg::pkg_v);
        s_pkg = test_program_design_signals_in_package_unit_and_interface.stamp;
      end
      begin
        @(dsu_unit_v);
        s_unit = test_program_design_signals_in_package_unit_and_interface.stamp;
      end
      begin
        @(test_program_design_signals_in_package_unit_and_interface.bus.if_v);
        s_if = test_program_design_signals_in_package_unit_and_interface.stamp;
      end
      begin
        @(test_program_design_signals_in_package_unit_and_interface.mod_v);
        s_mod = test_program_design_signals_in_package_unit_and_interface.stamp;
      end
    join
    $display("t=%0t stamp after the change of: package=%0d unit=%0d interface=%0d module=%0d",
             $time, s_pkg, s_unit, s_if, s_mod);
    dsu_pkg::from_prog = 9;
    #2;
  end
endprogram

module test_program_design_signals_in_package_unit_and_interface;
  int mod_v = 0;
  int stamp = 0;

  dsu_if bus ();
  dsu_prog p ();

  initial begin
    #5;
    stamp <= 7;
    dsu_unit_v = 1;
    dsu_pkg::pkg_v = 1;
    bus.if_v = 1;
    mod_v = 1;
    #1 $display("t=%0t module reads from_prog=%0d", $time, dsu_pkg::from_prog);
  end
endmodule
