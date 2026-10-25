/*
:name: test_syntax_procedural_continuous_assignment_forms
:description: assign, deassign, force and release override procedural and continuous assignments, and the assign and force statements take a variable_assignment or net_assignment of A.6.2 (IEEE 1800-2023 Sections 10.6.1 and 10.6.2, A.6.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6 10.6.1 10.6.2 A.6.2 A.6.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_syntax_procedural_continuous_assignment_forms.expected
*/
// IEEE 1800-2023 A.6.2: a procedural continuous assignment is "assign
// variable_assignment", "deassign variable_lvalue", "force
// variable_assignment", "force net_assignment", "release variable_lvalue" or
// "release net_lvalue", where variable_assignment is "variable_lvalue =
// expression" and net_assignment is the same with a net on the left.
// §10.6.1: assign overrides procedural writes to its variable and deassign
// ends it, leaving the last value. §10.6.2: force does the same for a
// variable, and for a net it overrides the net's drivers until release, when
// the net takes its driven value again.
//
// The test assigns 5 to v, writes 9 (ignored), deassigns, writes 3, forces
// 12, writes 1 (ignored), releases and writes 2. It also drives the net n
// with the value 1, forces 7, changes the driver to 2 (still overridden) and
// releases, so n returns to 2. Each step prints v or n.
//
// Icarus Verilog 13.0 and Verilator 5.052 do not support a procedural
// continuous assignment to a variable, so the expected output follows the
// standard.

module test_syntax_procedural_continuous_assignment_forms;
  logic [3:0] v;
  logic [3:0] drive = 1;
  wire [3:0] n;

  assign n = drive;

  initial begin
    v = 0;
    #1 assign v = 5;
    #1 $display("assign: v=%0d", v);
    v = 9;
    #1 $display("write under assign: v=%0d", v);
    #1 deassign v;
    #1 $display("deassign: v=%0d", v);
    v = 3;
    #1 $display("write after deassign: v=%0d", v);
    #1 force v = 12;
    #1 $display("force variable: v=%0d", v);
    v = 1;
    #1 $display("write under force: v=%0d", v);
    #1 release v;
    #1 $display("release variable: v=%0d", v);
    v = 2;
    #1 $display("write after release: v=%0d", v);
    #1 force n = 7;
    #1 $display("force net: n=%0d", n);
    drive = 2;
    #1 $display("driver change under force: n=%0d", n);
    #1 release n;
    #1 $display("release net: n=%0d", n);
  end
endmodule
