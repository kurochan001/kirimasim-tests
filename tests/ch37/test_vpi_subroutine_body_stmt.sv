/*
:name: test_vpi_subroutine_body_stmt
:description: vpiStmt of a task or function gives NULL for an empty body, the statement itself for a body of one statement, and an unnamed begin holding the statements for a body of several; vpiScope of a task or function gives the scope that encloses it (IEEE 1800-2023 Section 37.12)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.12 37.41 13.3 13.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_subroutine_body_stmt.c
:expected_stdout: @test_vpi_subroutine_body_stmt.expected
*/
// IEEE 1800-2023 §37.12: a task or function can have zero or more statements
// (13.3, 13.4). With zero, vpiStmt gives NULL; with more than one, vpiStmt
// gives an unnamed begin that contains them (detail 5); with exactly one, the
// one-to-one relation from task func to stmt gives that statement, which in tn
// is the named begin nb. A task func is in the scope group, so vpiScope gives
// the scope it is declared in: the module, or the generate block g for tg.
// The application prints the kind of the statement that vpiStmt gives, and for
// a begin the kinds of the statements in it in the order of their lines.

module test_vpi_subroutine_body_stmt;
  int x, y;

  task t0;
  endtask

  task t1;
    x = 1;
  endtask

  task t2;
    x = 1;
    y = 2;
  endtask

  task tn;
    begin : nb
      x = 1;
    end
  endtask

  function void f0();
  endfunction

  function int f1();
    return 5;
  endfunction

  function int f3();
    x = 3;
    y = 4;
    return x;
  endfunction

  if (1) begin : g
    task tg;
      y = 0;
    endtask
  end

  initial #1 $vt_bodies;
endmodule
