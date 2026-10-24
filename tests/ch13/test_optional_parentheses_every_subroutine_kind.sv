/*
:name: test_optional_parentheses_every_subroutine_kind
:description: tasks, void functions and class methods can be called without () when they have no arguments or all have defaults (IEEE 1800-2023 Section 13.5.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5.5 13.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_optional_parentheses_every_subroutine_kind.expected
*/
// IEEE 1800-2023 §13.5.5: the empty parentheses after the name of a void
// function or class function method that has no arguments are optional, and
// so are those of a task, void function or class method whose arguments all
// have defaults (13.5.3), which are then used. The module calls, each without
// parentheses: a void function and a task without arguments, a void function
// and a task whose arguments all have defaults, and, through a class object, a
// void method, a nonvoid method and a task method without arguments and a
// void method and a nonvoid method whose arguments all have defaults. Each
// call changes or returns a value that is printed, so a call that did not run,
// or ran with other argument values, changes the output.
// Icarus Verilog 13.0 rejects the calls of the nonvoid methods get and scaled
// without parentheses.

module test_optional_parentheses_every_subroutine_kind;
  int log_v;

  function void vf_none;
    log_v = log_v + 1;
  endfunction

  task t_none;
    log_v = log_v + 10;
  endtask

  function void vf_dflt(input int a = 100, input int b = 200);
    log_v = log_v + a + b;
  endfunction

  task t_dflt(input int a = 1000);
    log_v = log_v + a;
  endtask

  class C;
    int k = 5;
    function void bump;
      k = k + 1;
    endfunction
    function int get;
      return k * 2;
    endfunction
    task tbump;
      k = k + 10;
    endtask
    function void add(input int n = 7);
      k = k + n;
    endfunction
    function int scaled(input int m = 3);
      return k * m;
    endfunction
  endclass

  C c;

  initial begin
    log_v = 0;
    vf_none;
    $display("vf_none %0d", log_v);
    t_none;
    $display("t_none %0d", log_v);
    vf_dflt;
    $display("vf_dflt %0d", log_v);
    t_dflt;
    $display("t_dflt %0d", log_v);
    c = new;
    c.bump;
    $display("bump %0d", c.k);
    $display("get %0d", c.get);
    c.tbump;
    $display("tbump %0d", c.k);
    c.add;
    $display("add %0d", c.k);
    $display("scaled %0d", c.scaled);
  end
endmodule
