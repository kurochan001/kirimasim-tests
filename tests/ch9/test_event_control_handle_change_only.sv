/*
:name: test_event_control_handle_change_only
:description: An event control on a class handle variable, and one on a chandle variable, resume when a write gives the variable a value different from its previous one, and not when a write gives it its current value again, including null over null (IEEE 1800-2023 Section 9.4.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_event_control_handle_change_only.c
:expected_stdout: @test_event_control_handle_change_only.expected
*/
// IEEE 1800-2023 §9.4.2: when the event expression is a reference to a
// simple class handle or chandle variable, an event occurs when a write to
// the variable gives it a value that is not equal to its previous value.
// §6.14 forbids chandles in event expressions; this suite reads the bare
// reference to a chandle variable allowed by §9.4.2 as the only exception
// (docs/denominator-review-20261028.md), and the test uses only that form.
// A chandle that is not null comes from C: vt_slot(n) returns the address
// of the element n of a static C array, so slot 1 and slot 2 differ from
// each other and from null.
// One process waits with @h on the class handle h and prints the time and
// the id of the object h refers to (0 for null) each time it resumes;
// another does the same with @c on the chandle c and the slot number. h is
// written at 10 (null over null), 20 (a), 30 (a again), 40 (b), 50 (null)
// and 60 (null again); c is written 5 time units later with null, slot 1,
// slot 1 again, slot 2, null and null again. So @h resumes at 20, 40 and
// 50 only, and @c at 25, 45 and 55 only. A tool that resumed on every write
// would print lines at 10, 30 and 60 (and 15, 35 and 65) too, and one that
// never resumed would print nothing. The writes of h and c come at
// different times, so the order of the lines is fixed.
// Icarus Verilog 13.0 does not compile the DPI import declaration.

`timescale 1ns/1ns

module test_event_control_handle_change_only;
  import "DPI-C" function chandle vt_slot(int n);

  class item;
    int id;
    function new(int i);
      id = i;
    endfunction
  endclass

  item h, a, b;
  chandle c, c1, c2;

  function automatic int slot_of(chandle x);
    if (x == null) return 0;
    if (x == c1) return 1;
    if (x == c2) return 2;
    return -1;
  endfunction

  initial forever begin
    @h $display("t=%0d @h resumed, h is %0d", $time, (h == null) ? 0 : h.id);
  end

  initial forever begin
    @c $display("t=%0d @c resumed, c is slot %0d", $time, slot_of(c));
  end

  initial begin
    a = new(1);
    b = new(2);
    c1 = vt_slot(1);
    c2 = vt_slot(2);
    #10 h = null;
    #5 c = null;
    #5 h = a;
    #5 c = c1;
    #5 h = a;
    #5 c = c1;
    #5 h = b;
    #5 c = c2;
    #5 h = null;
    #5 c = null;
    #5 h = null;
    #5 c = null;
    #5 $finish;
  end
endmodule
