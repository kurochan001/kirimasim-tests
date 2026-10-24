/*
:name: test_immediate_assertion_statement_places
:description: an immediate assertion can stand wherever a procedural statement can: in initial, always and final procedures, functions, tasks, if and case branches, loop bodies, fork branches, named blocks and the action of another assertion; $assertoff stops its checking until $asserton (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 20.11
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_statement_places.expected
*/
// IEEE 1800-2023 §16.3: an immediate assertion is a statement item, so it can
// be written wherever a procedural statement can, and its execution is
// subject to the assertion control tasks (§20.11). Each assertion below sits
// in a different place and records that place in its pass action: the
// initial procedure in time step 0 goes through a branch of if and of case,
// a loop body, a fork branch, a named block, the pass action of another
// assertion, a function and a task; an always procedure woken at 5 and a
// final procedure add theirs. At 10 $assertoff stops the checking of all
// assertions, so the failing a_off runs no fail action, and after $asserton
// the same failing assertion in a_on does. The final procedure prints the
// list. Icarus Verilog 13.0 does not know $assertoff and $asserton, and the
// assertion in the fork branch stops Verilator 5.052 with an internal error.

`timescale 1ns/1ns

module test_immediate_assertion_statement_places;
  string where[$];
  int k = 2;
  logic go = 0;

  function automatic int twice(int v);
    a_func: assert (v > 0) where.push_back("function");
    return 2 * v;
  endfunction

  task automatic check_task();
    a_task: assert (k == 2) where.push_back("task");
  endtask

  always @(posedge go) a_always: assert (go) where.push_back("always");

  initial begin
    if (k > 0) a_if: assert (k == 2) where.push_back("if branch");
    case (k)
      1: where.push_back("wrong case item");
      2: a_case: assert (k == 2) where.push_back("case item");
    endcase
    for (int i = 0; i < 2; i++)
      a_loop: assert (i < 2) where.push_back($sformatf("loop body %0d", i));
    fork
      assert (k == 2) where.push_back("fork branch");
    join
    begin : named
      a_named: assert (k == 2) where.push_back("named block");
    end
    a_outer: assert (k == 2) a_inner: assert (k > 1) where.push_back("action of an assertion");
    k = twice(1);
    check_task();
    #5 go = 1;
    #5 $assertoff;
    a_off: assert (k == 3) else where.push_back("fail action while off");
    $asserton;
    a_on: assert (k == 3) else where.push_back("fail action after $asserton");
  end

  final begin
    a_final: assert (where.size() == 11) where.push_back("final");
    foreach (where[i]) $display("%0d: %s", i, where[i]);
  end
endmodule
