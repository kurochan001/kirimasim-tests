/*
:name: test_vpi_stmt_callback_instance
:description: A cbStmt callback placed on one instance of a module covers the statements of that instance only, not those of another instance of the same module, and passes each statement in obj (IEEE 1800-2023 Section 38.36.1.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.3 38.36.1.1 38.36.1.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_stmt_callback_instance.c
:expected_stdout: @test_vpi_stmt_callback_instance.expected
*/
// IEEE 1800-2023 §38.36.1.3: vpi_register_cb with cbStmt and a module
// instance in obj places a callback on every statement of that instance, and
// returns one callback handle. §38.36.1.1: each callback passes the statement
// that is about to execute in obj. u1 and u2 are instances of one module whose
// initial procedure runs its assignment N times, 2 in u1 and 5 in u2. The
// application places the callback on u1 alone at the start of the simulation
// and counts the callbacks by the type of statement, printing them at the end
// (38.36.3): the begin block and the delay control once each (38.36.1.2), and
// the assignment twice, as u2's statements get no callback.

`timescale 1ns/1ns

module test_vpi_stmt_callback_instance_unit #(parameter int N = 1);
  int v = 0;

  initial begin
    #1;
    repeat (N) v = v + 1;
  end
endmodule

module test_vpi_stmt_callback_instance;
  test_vpi_stmt_callback_instance_unit #(.N(2)) u1();
  test_vpi_stmt_callback_instance_unit #(.N(5)) u2();

  initial #3 $display("design: u1.v=%0d u2.v=%0d", u1.v, u2.v);
endmodule
