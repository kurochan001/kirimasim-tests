/*
:name: test_call_without_parentheses_subroutine_kinds
:description: The parentheses of a subroutine call can be left out for a task, a void function and a class method, but the bare name of a nonvoid function is not a call: inside a directly recursive class method it is the return variable, and outside a module function it names the function scope (IEEE 1800-2023 Section 13.5.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.5 13.4.1 A.8.2 A.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_call_without_parentheses_subroutine_kinds.expected
*/
// IEEE 1800-2023 §13.5.5 and footnote 42 of A.10 (on tf_call, A.8.2): the
// parentheses of a call can be left out only when the subroutine is a task, a
// void function or a class method, and not in a directly recursive call of a
// nonvoid class function method. §13.4.1: inside a nonvoid function its name
// is a variable that holds the return value; outside, the name of a function
// used in a hierarchical name denotes the scope of the function.
//
// Calls without parentheses: the task bump, the task setab whose arguments
// all have defaults, the void function vbump, the void function vadd with a
// default, and, inside the class Counter, its nonvoid methods get and twice
// (twice with its default argument 3). Counter::report also is called as
// c.report with no parentheses.
//
// sum_to is a directly recursive nonvoid class method. Its recursive call
// has parentheses; the bare name sum_to inside it is the return variable,
// so sum_to(3) = 3 + 2 + 1 + 0 = 6. If the bare name were a recursive call,
// it would be sum_to(0) (the default of n), which returns 0, and sum_to(3)
// would be 0.
//
// next_id is a nonvoid function of the module. next_id.calls is a
// hierarchical reference to its static local variable calls; the bare
// name does not call it, so the second call still returns 200 and calls is
// 1 and then 2 when it is read.
//
// Icarus Verilog 13.0 rejects the call get without parentheses inside
// Counter: it looks for a variable named get and finds none.

module test_call_without_parentheses_subroutine_kinds;
  int tcount = 0;
  int last_a = 0, last_b = 0;
  int vcount = 0;

  task bump;
    tcount += 1;
  endtask

  task setab(int a = 7, int b = 9);
    last_a = a;
    last_b = b;
  endtask

  function void vbump;
    vcount += 10;
  endfunction

  function void vadd(int k = 5);
    vcount += k;
  endfunction

  function int next_id();
    int calls;
    calls++;
    return calls * 100;
  endfunction

  class Counter;
    int val = 4;

    function int get();
      return val;
    endfunction

    function int twice(int k = 3);
      return 2 * k;
    endfunction

    function int sum_to(int n = 0);
      sum_to = n;
      if (n > 0) sum_to = sum_to + sum_to(n - 1);
    endfunction

    function void report();
      int g, t, s;
      g = get;
      t = twice;
      s = sum_to(3);
      $display("get=%0d twice=%0d sum_to(3)=%0d", g, t, s);
    endfunction
  endclass

  initial begin
    Counter c;
    int id1, id2, seen1, seen2;
    c = new;
    bump;
    bump;
    setab;
    vbump;
    vadd;
    $display("tcount=%0d a=%0d b=%0d vcount=%0d", tcount, last_a, last_b, vcount);
    c.report;
    id1 = next_id();
    seen1 = next_id.calls;
    id2 = next_id();
    seen2 = next_id.calls;
    $display("id1=%0d calls=%0d id2=%0d calls=%0d", id1, seen1, id2, seen2);
  end
endmodule
