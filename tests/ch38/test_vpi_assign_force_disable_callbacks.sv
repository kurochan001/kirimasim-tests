/*
:name: test_vpi_assign_force_disable_callbacks
:description: cbAssign, cbDeassign, cbForce and cbRelease callbacks come after their statements, with the statement in obj and the resulting value of the left-hand side, cbForce and cbRelease also with a NULL obj at registration; a cbValueChange callback on an event statement comes when it runs, with a NULL value; a cbDisable callback comes after a named fork with a system task call is disabled; and the cbStmt callbacks of these statements come before them (IEEE 1800-2023 Sections 38.36.1 and 38.36.1.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 38.36.1.2 38.36.1.1 10.6.1 10.6.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assign_force_disable_callbacks.c
:expected_stdout: @test_vpi_assign_force_disable_callbacks.expected
*/
// IEEE 1800-2023 §38.36.1: cbAssign and cbDeassign callbacks occur after a
// procedural assign or deassign statement has executed, and cbForce and
// cbRelease after a force or release (10.6.1, 10.6.2); their obj is the
// statement and their value the resulting value of the left-hand side, after
// the release for cbRelease. A cbForce or cbRelease callback registered with
// a NULL obj covers every force or release. A cbValueChange callback placed
// on an event statement is called when the statement executes, with a NULL
// value. A cbDisable callback occurs after a named block or task that
// contains a system task or function call has been disabled; its obj is the
// named begin or fork, task, function or call. §38.36.1.2: the cbStmt
// callback of each of these statements comes before it executes.
//
// At the start of the simulation (38.36.3) the application registers, all
// with vpiSimTime and vpiIntVal: cbAssign and cbDeassign on q, cbForce and
// cbRelease with obj NULL, cbValueChange on the statement -> e, cbDisable on
// the named fork worker, whose branch has a $display, and a cbStmt callback
// on each of the six statements. Each callback prints the time, its reason
// and the type of its obj; the cbStmt ones print q or w, the others but
// cbDisable their value. As the clause allows either, the cbDisable one
// prints whether its obj is the named fork or the system task call in it.
// The worker branch never prints, as it is disabled at 4.

`timescale 1ns/1ns

module test_vpi_assign_force_disable_callbacks;
  int q = 0;
  logic [3:0] wd = 4'd1;
  wire [3:0] w;
  event e;

  assign w = wd;

  initial begin
    #1;
    fork : worker
      #10 $display("worker done");
    join_none
    #1;
    assign q = 8;
    #1;
    deassign q;
    force w = 4'd9;
    #1;
    release w;
    -> e;
    disable worker;
    #20 $display("%0t: design end, q=%0d w=%0d", $time, q, w);
  end
endmodule
