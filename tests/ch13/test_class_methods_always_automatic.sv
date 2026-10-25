/*
:name: test_class_methods_always_automatic
:description: Tasks and functions declared in a class without a lifetime keyword are automatic even inside a static module, so overlapping calls of a class task and recursive calls of a class function each get their own variables (IEEE 1800-2023 Section 13.3.1)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.1 13.4.2 13.3.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_methods_always_automatic.expected
*/
// IEEE 1800-2023 §13.3.1: tasks defined within a class are always automatic;
// §13.4.2: so are functions defined within a class. Their variables are
// allocated for each call (13.3.2), while a task or function of a module is
// static unless declared automatic.
//
// The class Keeper is declared in a module with the default static
// lifetime, and its methods have no lifetime keyword. Two calls of the task
// hold that overlap in time (from 0 and from 1) store their input in a
// local variable, wait 3 and return it: each returns its own input. The
// recursive function sum_down(n) keeps n in a local variable across the
// recursive call and returns n + (n-1) + ... + 0, which is 10 for 4. The
// module function with the same body is static: its local variables are
// shared by all the nested calls, so every level adds the 0 stored by the
// deepest call and the result is 0.

`timescale 1ns/1ns

module test_class_methods_always_automatic;
  class Keeper;
    task hold(input int v, output int seen);
      int keep;
      keep = v;
      #3 seen = keep;
    endtask

    function int sum_down(int n);
      int mine;
      int rest;
      mine = n;
      if (n == 0) return 0;
      rest = sum_down(n - 1);
      return mine + rest;
    endfunction
  endclass

  function int static_sum_down(int n);
    int mine;
    int rest;
    mine = n;
    if (n == 0) return 0;
    rest = static_sum_down(n - 1);
    return mine + rest;
  endfunction

  Keeper k;
  int a, b;

  initial begin
    k = new;
    fork
      k.hold(1, a);
      #1 k.hold(2, b);
    join
    $display("class task, calls at 0 and 1: %0d %0d", a, b);
    $display("class function sum_down(4) = %0d", k.sum_down(4));
    $display("static module function static_sum_down(4) = %0d", static_sum_down(4));
  end
endmodule
