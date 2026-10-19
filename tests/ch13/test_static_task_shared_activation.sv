/*
:name: test_static_task_shared_activation
:description: Concurrent calls of a static task share its variables and arguments, while an automatic task gets new ones for each call (IEEE 1800-2023 Section 13.3.2)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.3.2 13.3 6.8
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_task_shared_activation.expected
*/
// IEEE 1800-2023 §13.3.2: a task may run several times at once. A static task
// has one copy of each of its variables, arguments included, shared by all the
// calls, and these keep their values from one call to the next; they start
// with the default value of their type (6.8). An automatic task gets new
// variables for each call. So when a second call of a static task starts while
// the first is waiting, both return the input of the second call.

module test_static_task_shared_activation;
  int r1, r2, a1, a2;
  int n1, n2, n3;

  // Tasks in a module are static unless declared automatic (13.3).
  task hold_s(input int v, output int o);
    #2 o = v;
  endtask

  task automatic hold_a(input int v, output int o);
    #2 o = v;
  endtask

  task count_calls(output int n);
    int c;
    c++;
    n = c;
  endtask

  initial begin
    fork
      hold_s(10, r1);
      #1 hold_s(20, r2);
    join
    fork
      hold_a(10, a1);
      #1 hold_a(20, a2);
    join
    count_calls(n1);
    count_calls(n2);
    count_calls(n3);
    $display("static:    r1=%0d r2=%0d", r1, r2);
    $display("automatic: a1=%0d a2=%0d", a1, a2);
    $display("calls:     %0d %0d %0d", n1, n2, n3);
  end
endmodule
