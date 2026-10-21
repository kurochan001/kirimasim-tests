/*
:name: test_vpi_stmt_callback_data
:description: A cbStmt callback runs before its statement with the statement in obj, the time in the requested type or NULL for vpiSuppressTime, a NULL value, index 0 and the user data; it comes before the delay of a delay control and before the condition of an if, and registering the same data twice gives two callbacks (IEEE 1800-2023 Sections 38.36.1.1 and 38.36.1.2)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1.1 38.36.1.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_stmt_callback_data.c
:expected_stdout: @test_vpi_stmt_callback_data.expected
*/
// IEEE 1800-2023 §38.36.1.1: a cbStmt callback is called just before its
// statement executes, with a new s_cb_data whose obj is the statement, whose
// time holds the current time in the type requested, or is NULL for
// vpiSuppressTime, whose value is NULL and index 0, and whose user_data is the
// one registered. Registering the same data twice gives two callbacks.
// §38.36.1.2 (Table 38-6): for a delay control the callback comes when it is
// encountered, before the delay; for an if statement, before its condition is
// evaluated; for an assignment or a system task call, before it executes. The
// application places the callbacks at the start of the simulation (38.36.3).
// The callback on the assignment of the delay control reads x before the
// assignment, and the one on the if reads calls before bump() runs.

`timescale 1ns/1ns

module test_vpi_stmt_callback_data;
  int x = 0, calls = 0;

  function int bump();
    calls++;
    return calls;
  endfunction

  initial begin
    #2 x = 5;
    if (bump() > 0) x = 6;
    $display("design: x=%0d calls=%0d at %0t", x, calls, $time);
  end
endmodule
