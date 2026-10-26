/*
:name: test_task_declaration_grammar_and_nesting
:description: Task declarations accept ANSI and body formals, body declarations, closing names, automatic and class scope, and a task may enable another task through a deep chain with no limit (IEEE 1800-2023 Section 13.3)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_task_declaration_grammar_and_nesting.expected
*/
// IEEE 1800-2023 §13.3: a task declaration may give its formals in ANSI
// form or in the body, may have a lifetime and a matching closing name, and
// a class-scope task may use ref. A task may enable other tasks with no
// limit on the number enabled, so the recursive task nest enables itself 100
// times and each activation adds one on the way back. body_form uses body
// declarations, and CB::bump is a class-scope task.
//
// Neither release compiles the :initial method specifier, so the
// expectation follows 13.3.

interface IF;
  int iv;
  task automatic set(input int x);
    iv = x;
  endtask : set
endinterface

module test_task_declaration_grammar_and_nesting;
  int sum;

  IF ifc();

  task automatic nest(input int n, output int r);
    int t;
    if (n == 0)
      r = 0;
    else begin
      nest(n - 1, t);
      r = t + 1;
    end
  endtask : nest

  task automatic body_form;
    input int p;
    output int q;
    q = p + 1;
  endtask : body_form

  class CB;
    int v = 0;
    task automatic bump(ref int x);
      v = v + 1;
      x = x + v;
    endtask : bump

    task :initial plain(output int x);
      x = 3;
    endtask : plain
  endclass

  initial begin
    int r, q;
    CB cb;
    cb = new;
    nest(100, r);
    $display("nest=%0d", r);
    body_form(4, q);
    $display("body=%0d", q);
    sum = 10;
    cb.bump(sum);
    $display("class=%0d,%0d", sum, cb.v);
    ifc.set(3);
    $display("ifc=%0d", ifc.iv);
    cb.plain(q);
    $display("plain=%0d", q);
  end
endmodule
