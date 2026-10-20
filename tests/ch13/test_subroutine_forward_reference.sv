/*
:name: test_subroutine_forward_reference
:description: A call can name a task or function declared later in the same or an enclosing scope, and a simple name not found in a module is looked up in the module that instantiates it (IEEE 1800-2023 Section 13.7)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.7 23.8.1 23.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_forward_reference.expected
*/
// IEEE 1800-2023 §13.7: task and function names follow a form of the upward
// name resolution of 23.8 (23.8.1), so a call can refer to a task or function
// declared later in the same scope or in an enclosing one. The top module
// calls scale() and, from a named block, show(), both declared at its end.
// The child module declares scale() itself, which it finds first, but not
// tenfold(), which it finds in the module that instantiates it.

`timescale 1ns/1ns

module test_subroutine_forward_reference_child;
  initial #1 $display("child: scale(5)=%0d tenfold(5)=%0d", scale(5), tenfold(5));

  function automatic int scale(int v);
    return 3 * v;
  endfunction
endmodule

module test_subroutine_forward_reference;
  test_subroutine_forward_reference_child c();

  initial begin : early
    $display("top: scale(5)=%0d", scale(5));
    show("from a named block");
  end

  function automatic int scale(int v);
    return 2 * v;
  endfunction

  function automatic int tenfold(int v);
    return 10 * v;
  endfunction

  task automatic show(string what);
    $display("show %s", what);
  endtask
endmodule
