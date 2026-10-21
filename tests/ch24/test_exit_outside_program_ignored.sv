/*
:name: test_exit_outside_program_ignored
:description: $exit called from a process that does not start in an initial procedure of a program is ignored, so the module process goes on and the program still ends the simulation (IEEE 1800-2023 Section 24.7)
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exit_outside_program_ignored.expected
*/
// IEEE 1800-2023 §24.7: $exit ends the initial procedures of the program whose
// initial procedure the calling thread comes from; called from a thread that
// does not come from an initial procedure of a program it is ignored, and a
// tool may warn about it. The module process calls $exit at time 1 and goes
// on. §24.3: when the initial procedure of the only program ends at time 5,
// the simulation ends with an implicit $finish, before the module process
// reaches time 9.
// Icarus Verilog 13.0 does not support $exit, and Verilator 5.052 ends the
// simulation at the call (docs/simulator-differences.md).

`timescale 1ns / 1ns

program test_exit_outside_program_ignored_p;
  initial #5 $display("program ends at %0t", $time);
endprogram

module test_exit_outside_program_ignored;
  test_exit_outside_program_ignored_p p();
  initial begin
    #1 $exit();
    $display("module goes on at %0t", $time);
    #8 $display("module at %0t", $time);
  end
endmodule
