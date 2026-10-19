/*
:name: test_hierarchical_task_call_without_parentheses
:description: A task without arguments called through a hierarchical name with and without parentheses (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 23.6
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchical_task_call_without_parentheses.expected
*/
// IEEE 1800-2023 §13.5: the argument list of a task call, parentheses
// included, is optional (tf_call in A.8.2), so a task without arguments can
// be called by its name alone. This holds when the task is named through a
// hierarchical name (23.6) as well: a.bump; runs the task of instance a, as
// a.bump(); does. Each call waits one time unit.

module counter_holder;
  int n;
  task bump;
    #1 n++;
  endtask
endmodule

module test_hierarchical_task_call_without_parentheses;
  counter_holder a ();
  int m;

  task local_bump;
    #1 m++;
  endtask

  initial begin
    a.bump;
    $display("t=%0d a.n=%0d after a.bump;", $time, a.n);
    a.bump();
    $display("t=%0d a.n=%0d after a.bump();", $time, a.n);
    local_bump;
    $display("t=%0d m=%0d after local_bump;", $time, m);
  end
endmodule
