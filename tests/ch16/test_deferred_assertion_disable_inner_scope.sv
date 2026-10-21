/*
:name: test_deferred_assertion_disable_inner_scope
:description: disabling a deferred assertion by its label cancels only its own pending report, while disabling a scope that is not the outermost one of the procedure, or a task, cancels none (IEEE 1800-2023 Section 16.4.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.4 16.4.1 9.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_deferred_assertion_disable_inner_scope.expected
*/
// IEEE 1800-2023 §16.4.4: a disable statement that names a deferred assertion
// cancels the pending reports of that assertion; the reports of other
// assertions on the same queue stay. Disabling a task, or a named block that is
// not the outermost scope of the procedure, does not flush the queue. A pending
// report matures in the Observed region and its action runs in the Reactive
// region (§16.4.1). Every assertion here fails; the procedures run when go
// rises at 10 and when it falls at 20. At 10 p_label disables a_lab after both
// of its assertions failed, so only a_keep is reported; at 20 it does not, so
// both are. a_inner and a_task are reported both times. The fail actions count
// the reports, printed at 30. Verilator 5.052 reports a_lab twice, as it runs
// the action of a deferred assertion at once, so disable a_lab cannot cancel
// it, and a_inner three times, as it runs p_inner once at time 0 although go
// does not change.

`timescale 1ns/1ns

module test_deferred_assertion_disable_inner_scope;
  logic go = 0;
  int n[string];

  function automatic void count(string what);
    n[what]++;
  endfunction

  always @(go) begin : p_label
    a_lab: assert #0 (1'b0) else count("a_lab");
    a_keep: assert #0 (1'b0) else count("a_keep");
    if (go) disable a_lab;
  end

  always @(go) begin : p_inner
    begin : inner
      a_inner: assert #0 (1'b0) else count("a_inner");
      disable inner;
    end
  end

  task t_check();
    a_task: assert #0 (1'b0) else count("a_task");
    disable t_check;
  endtask

  always @(go) begin : p_task
    t_check();
  end

  initial begin
    #10 go = 1;
    #10 go = 0;
    #10;
    foreach (n[what]) $display("%s: %0d", what, n[what]);
  end
endmodule
