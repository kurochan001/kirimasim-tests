/*
:name: test_vpi_stmt_callback_module_wide
:description: vpi_register_cb with cbStmt and a module instance in obj places a callback on every statement of that instance, of every kind and in every procedure, and on none of another instance of the same module (IEEE 1800-2023 Section 38.36.1.3)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.3 38.36.1.1 38.36.1.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_stmt_callback_module_wide.c
:expected_stdout: @test_vpi_stmt_callback_module_wide.expected
*/
// IEEE 1800-2023 §38.36.1.3: a cbStmt callback registered with a handle to a
// module instance in obj is placed on every statement of the instance that
// can have one, and vpi_register_cb returns one callback handle. §38.36.1.1:
// each callback passes the statement about to execute in obj. §38.36.1.2:
// a block gets one callback before its statements, and every other
// statement one before it executes. The two procedures of each instance of
// stmt_unit execute once, without loops: one begin block, four assignments,
// one if statement, one case statement, two delay controls and one system
// task call, ten statements in all. The application registers the callback
// on u1 at the start of the simulation and prints, at its end (38.36.3), the
// number of callbacks for each type of statement in obj and the number whose
// statement does not have u1 as its vpiScope. u1 prints at 5 and u2 at 6.

`timescale 1ns/1ns

module stmt_unit #(parameter int D = 5);
  int v;

  initial begin
    v = 1;
    if (v == 1)
      v = 2;
    #1 v = 3;
    case (v)
      3: v = 4;
    endcase
  end

  initial #D $display("%m: v=%0d", v);
endmodule

module test_vpi_stmt_callback_module_wide;
  stmt_unit #(5) u1();
  stmt_unit #(6) u2();
endmodule
