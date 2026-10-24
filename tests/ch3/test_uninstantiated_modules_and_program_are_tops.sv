/*
:name: test_uninstantiated_modules_and_program_are_tops
:description: Two modules and a program that nothing instantiates each become a top-level block, instantiated once under their own names, while a module that one of them instantiates is not a top; the program's initial procedure runs as an entry point of the testbench without any instance in a module (IEEE 1800-2023 Sections 3.11 and 3.4)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.11 3.4 23.3.1 24.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_uninstantiated_modules_and_program_are_tops.expected
*/
// IEEE 1800-2023 §3.11: a module or program that is elaborated but not
// instantiated is implicitly instantiated once at the top of the hierarchy,
// and a design can have several top-level blocks (§23.3.1). §24.3: such a
// program is instantiated once with the name of its declaration.
// Nothing instantiates this module, tops_second or tops_prog, so there are
// three top-level blocks; tops_leaf is instantiated by tops_second and so is
// not one. Each block prints %m, its full name, at its own time: a block
// that were not a top would print a longer path or nothing, and one that
// were instantiated twice would print twice.
// §3.4: a program is an entry point for the execution of a testbench: the
// initial procedure of tops_prog runs although no module instantiates it.

`timescale 1ns/1ns

module tops_leaf;
  initial #3 $display("t=%0t %m", $time);
endmodule

module tops_second;
  tops_leaf u_leaf();
  initial #2 $display("t=%0t %m", $time);
endmodule

program tops_prog;
  initial #4 $display("t=%0t %m", $time);
endprogram

module test_uninstantiated_modules_and_program_are_tops;
  initial #1 $display("t=%0t %m", $time);
endmodule
