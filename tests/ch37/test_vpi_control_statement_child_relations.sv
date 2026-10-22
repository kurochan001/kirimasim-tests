/*
:name: test_vpi_control_statement_child_relations
:description: VPI control statements retain condition body else target and repeat control relationships (IEEE 1800-2023 Section 37.55)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.55 37.62 37.66 37.67 37.69 37.70 37.71 37.73 37.74 37.77 37.78
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_control_statement_child_relations.c
:expected_stdout: @test_vpi_control_statement_child_relations.expected
*/
// IEEE 1800-2023 37.55 37.62 37.66 37.67 37.69 37.70 37.71 37.73 37.74 37.77
// 37.78: Unlike a statement-type inventory, this checks the outgoing relations
// of each control object, including loop clauses, a disabled task, and an
// intra-assignment repeat event control. The task is not executed.
// Oracle checks: Icarus Verilog 13.0 does not build this case. The 5.052
// release does not build this case.

module test_vpi_control_statement_child_relations;
  bit enabled, clk;
  int value;
  event changed;
  task inspected;
    a1: assert (enabled) value = 1; else value = 2;
    a2: assume (enabled) value = 1; else value = 2;
    a3: cover (enabled) value = 1;
    -> changed;
    while (enabled) value = 1;
    repeat (3) value = 2;
    wait (enabled) value = 3;
    forever value = 4;
    if (enabled) value = 5; else value = 6;
    expect (@(posedge clk) enabled) value = 7; else value = 8;
    for (int index = 0; index < 2; index++) value = index;
    disable inspected;
    return;
    value = repeat (2) @(posedge clk) 9;
  endtask
  initial #1 $depth_children;
endmodule
