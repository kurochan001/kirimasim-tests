/*
:name: test_function_body_order_and_empty_body
:description: The statements of a function or task body run one after another as in a begin-end block, a function with no statements returns the current value of its implicit result variable, and a task with no statements is legal and returns at once (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.3 13.4.1
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_function_body_order_and_empty_body.expected
*/
// IEEE 1800-2023 §13.4: the statements between the function header and
// endfunction run sequentially, as in a begin-end block, and a function can
// have no statements at all; it then returns the current value of the
// implicit variable named after the function. §13.3: the same holds for the
// statements of a task, and a task with no statements is legal.
//
// calc(3) runs t = a; t = t * 10; t = t + 2 in that order and returns 32.
// The empty automatic functions return the value their result variables
// get on entry, the default of the type (6.8): x for logic [3:0] and 0 for
// int. The task steps writes its output in order around a delay; the empty
// task and the task with only a declaration return without taking time.

`timescale 1ns/1ns

module test_function_body_order_and_empty_body;
  int r;

  function automatic int calc(int a);
    int t;
    t = a;
    t = t * 10;
    t = t + 2;
    calc = t;
  endfunction

  function automatic logic [3:0] empty_logic();
  endfunction

  function automatic int empty_int();
  endfunction

  task automatic steps(output int o);
    o = 1;
    o = o * 10;
    #1 o = o + 2;
  endtask

  task automatic nothing();
  endtask

  task automatic declaration_only();
    int unused;
  endtask

  initial begin
    $display("calc(3)=%0d", calc(3));
    $display("empty_logic()=%b empty_int()=%0d", empty_logic(), empty_int());
    steps(r);
    $display("t=%0t steps: o=%0d", $time, r);
    nothing();
    declaration_only();
    $display("t=%0t after the empty tasks", $time);
  end
endmodule
