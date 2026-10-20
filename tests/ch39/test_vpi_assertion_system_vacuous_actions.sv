/*
:name: test_vpi_assertion_system_vacuous_actions
:description: The system controls for vacuous and nonvacuous pass actions turn off the pass action of vacuous successes only, and turn on that of nonvacuous ones only, and their system callbacks report them (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1 39.4.1 16.12.7 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_system_vacuous_actions.c
:expected_stdout: @test_vpi_assertion_system_vacuous_actions.expected
*/
// IEEE 1800-2023 §39.5.1: with a NULL scope, the system controls act on every
// assertion. vpiAssertionSysDisableVacuousAction stops the pass action of
// vacuous successes; vpiAssertionSysEnablePassAction runs the pass action of
// both kinds of success again; after vpiAssertionSysDisablePassAction,
// vpiAssertionSysEnableNonvacuousAction turns on only that of nonvacuous ones.
// By default all pass actions run, vacuous ones too (16.14.1). §39.4.1: each
// control is reported by its system callback. Each phase has three ticks: a
// and b hold (a nonvacuous success), a does not (a vacuous success, 16.12.7),
// and a holds without b (a failure). The pass action tells the two kinds of
// success apart by the sampled value of a; the fail action stays on.

`timescale 1ns/1ns

module test_vpi_assertion_system_vacuous_actions;
  logic clk = 0, a = 0, b = 0;
  int nonvacuous = 0, vacuous = 0, fails = 0;

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) a |-> b)
    if ($sampled(a)) nonvacuous++; else vacuous++;
  else fails++;

  task phase(string name);
    a = 1; b = 1;
    #10 a = 0; b = 0;
    #10 a = 1;
    #10 a = 0;
    $display("%s: nonvacuous %0d, vacuous %0d, fail %0d", name, nonvacuous, vacuous, fails);
    nonvacuous = 0; vacuous = 0; fails = 0;
  endtask

  initial begin
    $vt_watch;
    phase("all enabled");
    $vt_control("disable vacuous");
    phase("vacuous disabled");
    $vt_control("enable pass");
    phase("pass enabled");
    $vt_control("disable pass");
    $vt_control("enable nonvacuous");
    phase("nonvacuous enabled");
    $vt_report;
    $finish;
  end
endmodule
