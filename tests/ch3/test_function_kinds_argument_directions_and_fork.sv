/*
:name: test_function_kinds_argument_directions_and_fork
:description: Nonvoid functions are operands of expressions, a void function is called as a statement from two places, a function takes input, output, inout and ref arguments, and a function returns at once after forking off a process that waits (IEEE 1800-2023 Section 3.8)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.8 13.4 13.4.4 13.5 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_kinds_argument_directions_and_fork.expected
*/
// IEEE 1800-2023 §3.8: a nonvoid function returns a value and its call is an
// operand of an expression; a void function returns no value and is called
// as a statement; a function can have input, output, inout and ref
// arguments; a function does not block, but it can fork off processes that
// do (§13.4.4). §13.5: output and inout values are passed back when the
// function returns; §13.5.2: a ref argument is a reference to the actual.
// - scale(2, g_o, g_io, g_r) starts with g_o = 5, g_io = 7 and g_r = 4,
//   sets o = 3, io = 14 and r = 12, records the actuals while it runs and
//   returns 20; twice(3) returns 6. The sum 26 is assigned to y, and twice
//   is also an operand of a comparison. While scale ran, g_o and g_io still
//   had 5 and 7 and g_r had 12 already; afterwards they are 3, 14 and 12.
// - The void function note is called as a statement at time 0 and time 1
//   and counts its calls.
// - spawn forks a process that waits 3 time units and returns at once, so
//   the caller prints time 0 and the forked process prints at time 3.
// Icarus Verilog 13.0 does not support ref arguments ("sorry: Reference
// ports not supported yet").

`timescale 1ns/1ns

module test_function_kinds_argument_directions_and_fork;
  int g_o = 5, g_io = 7, g_r = 4;
  int seen_o, seen_io, seen_r;
  int y;
  int notes = 0;

  function automatic int scale(input int a, output int o, inout int io, ref int r);
    o = a + 1;
    io = io * 2;
    r = r * 3;
    seen_o = g_o;
    seen_io = g_io;
    seen_r = g_r;
    return a * 10;
  endfunction

  function int twice(int v);
    return 2 * v;
  endfunction

  function void note(string what);
    notes++;
    $display("t=%0t note %s: notes=%0d", $time, what, notes);
  endfunction

  function void spawn();
    fork
      #3 $display("t=%0t forked process done", $time);
    join_none
  endfunction

  initial begin
    y = scale(2, g_o, g_io, g_r) + twice(3);
    $display("value: y=%0d twice(4)>7=%0d", y, twice(4) > 7);
    $display("during scale: g_o=%0d g_io=%0d g_r=%0d", seen_o, seen_io, seen_r);
    $display("after scale: g_o=%0d g_io=%0d g_r=%0d", g_o, g_io, g_r);
    note("first");
    spawn();
    $display("t=%0t spawn returned", $time);
    #1 note("second");
  end
endmodule
