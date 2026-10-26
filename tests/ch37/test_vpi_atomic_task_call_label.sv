/*
:name: test_vpi_atomic_task_call_label
:description: A task call and a function call used as statements are atomic statements in the task/function call group, and their vpiName is the statement label or NULL without one (IEEE 1800-2023 Section 37.60)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.60 13.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_atomic_task_call_label.c
:expected_stdout: @test_vpi_atomic_task_call_label.expected
*/
// IEEE 1800-2023 §37.60: the atomic statement group includes the task and
// function call statement, and the group property vpiName gives the statement
// label if one was written and NULL otherwise (detail 1). The task body has
// four call statements, two with a label and two without; the application
// lists them through vpiStmt with their type and vpiName, sorted, so a tool
// that does not treat a call as an atomic statement, or that returns the
// callee name instead of the label, changes the output.

module test_vpi_atomic_task_call_label;
  int v;

  task t;
    v = 1;
  endtask

  function int f;
    return 2;
  endfunction

  task body;
    call_label: t();
    t();
    func_label: f();
    f();
  endtask

  initial begin
    body();
    #1 $vt_calls;
  end
endmodule
