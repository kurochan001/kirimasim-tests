/*
:name: test_static_deferred_assertion_always_comb
:description: a deferred assertion outside procedural code behaves as if it were in an always_comb, so it is evaluated once at time zero, again when a variable read by a function it calls changes, and not when a variable of its action block changes (IEEE 1800-2023 Section 16.4.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.4.3 16.4.1 9.2.2.2.1 9.2.2.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_deferred_assertion_always_comb.expected
*/
// IEEE 1800-2023 §16.4.3: a static deferred assertion is treated as if it were
// the only statement of an always_comb procedure. Such a procedure runs once at
// time zero (§9.2.2.2.2), is woken by a change of a variable read in a function
// it calls (§9.2.2.2.1), and not by a change of a variable used only in an
// action block. The reports mature in the Observed region and their action, a
// single call whose arguments are evaluated when the assertion is (§16.4.1),
// runs in the Reactive region. a_zero fails at 0 although nothing changes then,
// passes at 10 when go rises and fails again at 20. a_func passes at 0, fails
// at 10 when g rises, a change seen only inside g_low, and passes at 20.
// a_action passes at 0, with v = 0, and is not evaluated again when v changes
// at 30. The action blocks count the reports, and the counts are printed at 40.
// The run stops with DIDNOTCONVERGE in Verilator 5.052, as the writes of the
// action blocks wake the assertions again.

`timescale 1ns/1ns

module test_static_deferred_assertion_always_comb;
  logic go = 0, g = 0, v = 0;
  int zero_fails = 0, func_passes = 0, func_fails = 0, action_passes = 0, action_v = -1;

  function automatic void zero_fail();
    zero_fails++;
  endfunction

  function automatic void func_result(bit pass);
    if (pass) func_passes++;
    else func_fails++;
  endfunction

  function automatic void action_pass(logic value);
    action_passes++;
    action_v = value;
  endfunction

  function automatic bit g_low();
    return !g;
  endfunction

  a_zero: assert #0 (go) else zero_fail();
  a_func: assert #0 (g_low()) func_result(1); else func_result(0);
  a_action: assert #0 (1'b1) action_pass(v);

  initial begin
    #10 go = 1;
    g = 1;
    #10 go = 0;
    g = 0;
    #10 v = 1;
    #10;
    $display("a_zero: %0d failures", zero_fails);
    $display("a_func: %0d passes, %0d failures", func_passes, func_fails);
    $display("a_action: %0d passes, the last with v=%0d", action_passes, action_v);
  end
endmodule
