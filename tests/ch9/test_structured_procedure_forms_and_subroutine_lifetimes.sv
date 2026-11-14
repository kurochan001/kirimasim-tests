/*
:name: test_structured_procedure_forms_and_subroutine_lifetimes
:description: initial takes a null statement, each always keyword takes a statement, final takes a function statement, and tasks and functions take dynamic override specifiers in a class and no, static or automatic lifetime with ANSI or non-ANSI bodies, with the lifetime deciding whether locals keep their values between calls (IEEE 1800-2023 Section 9.2)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2 9.3.4 13.3.1 13.4.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_structured_procedure_forms_and_subroutine_lifetimes.expected
*/
// IEEE 1800-2023 §9.2 (Syntax 9-1): an initial procedure takes a statement or
// the null statement, always, always_comb, always_latch and always_ff each
// take a statement, a final procedure takes a function statement, and a task
// or function declaration has optional dynamic override specifiers (in a
// class) and an optional lifetime before its body, which can declare its
// ports in a list or as items. §13.3.1 and §13.4.2: without
// a lifetime a task or function in a module is static, so its local
// variables are shared by all calls and keep their values; with automatic
// they are new, and initialized, on every call.
//
// Each subroutine adds its argument to a local total and returns it. The
// default and the static ones are called twice with the same argument and
// return the argument, then twice it; the automatic ones return the
// argument both times. A tool that took a missing or static lifetime as
// automatic would print the same number twice, and one that took automatic
// as static would print twice the argument the second time.
//
// In the class shape_c, sides is declared with :initial and describe with
// :final; square_c overrides sides with :extends :final. Called through a
// shape_c handle to a square_c object, sides gives 4 and describe, which
// calls sides, gives 40.
//
// The first initial procedure has the null statement as its body. The
// always procedures each run their statement: the general one toggles the
// clock, always_comb follows its input (10, then 30), always_latch copies
// its input while enabled and then holds 1, and always_ff counts two rising
// edges. The final procedure is a call of a void function, a function
// statement.
//
// Icarus Verilog 13.0 rejects the null statement as the body of an initial
// procedure and does not support the override specifiers (syntax errors on
// those lines); without them it prints the other lines of the expected
// output. The expected output follows the standard and matches the 5.054
// release of Verilator.

`timescale 1ns/1ns

module test_structured_procedure_forms_and_subroutine_lifetimes;
  logic clk = 0;
  int comb_in = 1, comb_out;
  logic latch_en = 1, latch_d = 1, latch_q;
  int ff_count = 0;
  int r1, r2;

  function int f_default(input int step);
    int total;
    total += step;
    return total;
  endfunction

  function static int f_static;
    input int step;
    int total;
    total += step;
    return total;
  endfunction : f_static

  function automatic int f_automatic(int step);
    int total = 0;
    total += step;
    return total;
  endfunction

  task t_default(input int step, output int result);
    int total;
    total += step;
    result = total;
  endtask

  task static t_static;
    input int step;
    output int result;
    int total;
    total += step;
    result = total;
  endtask : t_static

  task automatic t_automatic(input int step, output int result);
    int total = 0;
    total += step;
    result = total;
  endtask

  class shape_c;
    virtual function :initial int sides();
      return 0;
    endfunction
    task :final describe(output int n);
      n = sides() * 10;
    endtask
  endclass

  class square_c extends shape_c;
    function :extends :final int sides();
      return 4;
    endfunction
  endclass

  shape_c shape_h;
  square_c square_h = new;

  function void report();
    $display("final: ff_count=%0d comb_out=%0d latch_q=%b", ff_count, comb_out, latch_q);
  endfunction

  always #5 clk = ~clk;

  always_comb comb_out = comb_in * 10;

  always_latch if (latch_en) latch_q = latch_d;

  always_ff @(posedge clk) ff_count <= ff_count + 1;

  initial ;

  initial begin
    r1 = f_default(2);
    r2 = f_default(2);
    $display("function, no lifetime: %0d %0d", r1, r2);
    r1 = f_static(3);
    r2 = f_static(3);
    $display("function static: %0d %0d", r1, r2);
    r1 = f_automatic(4);
    r2 = f_automatic(4);
    $display("function automatic: %0d %0d", r1, r2);
    t_default(5, r1);
    t_default(5, r2);
    $display("task, no lifetime: %0d %0d", r1, r2);
    t_static(6, r1);
    t_static(6, r2);
    $display("task static: %0d %0d", r1, r2);
    t_automatic(7, r1);
    t_automatic(7, r2);
    $display("task automatic: %0d %0d", r1, r2);
    shape_h = square_h;
    shape_h.describe(r1);
    $display("override specifiers: sides %0d, describe %0d", shape_h.sides(), r1);
    #1 $display("always_comb: %0d", comb_out);
    comb_in = 3;
    #1 $display("always_comb: %0d", comb_out);
    $display("always_latch enabled: %b", latch_q);
    latch_en = 0;
    latch_d = 0;
    #1 $display("always_latch holds: %b", latch_q);
    repeat (2) @(posedge clk);
    #1 $display("always_ff edges: %0d", ff_count);
    $finish;
  end

  final report();
endmodule
