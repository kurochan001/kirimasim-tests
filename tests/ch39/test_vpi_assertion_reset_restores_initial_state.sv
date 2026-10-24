/*
:name: test_vpi_assertion_reset_restores_initial_state
:description: vpiAssertionReset returns one assertion to its initial state, so pass and fail actions that were disabled for it run again and an assertion that was disabled starts attempts again, while another assertion keeps its disabled actions (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_reset_restores_initial_state.c
:expected_stdout: @test_vpi_assertion_reset_restores_initial_state.expected
*/
// IEEE 1800-2023 §39.5.2: vpi_control(vpiAssertionReset, assertion) resets
// that assertion to its initial state. By default an assertion is enabled and
// its pass and fail actions are enabled; vpiAssertionDisable,
// vpiAssertionDisablePassAction and vpiAssertionDisableFailAction change that
// for one assertion.
// The clock rises at 5, 15, 25, 35 and 45; a1, a2 and a3 all need x, which is 1
// at 5, 25 and 45 and 0 at 15 and 35, so each passes and fails in turn and
// each attempt ends at the tick where it starts. The actions record their
// time. At 2, $vt_control disables the pass and fail actions of a1 and a2 and
// disables a3, so none of them runs an action at 5, 15 and 25. At 30 it resets
// a1 and a3: a1 runs its actions again at 35 and 45, and a3 starts attempts
// again, whose actions run at 35 and 45. a2, which is not reset, still runs no
// action. No simulator here runs the application: the expected output is
// derived from §39.5.2.

`timescale 1ns/1ns

module test_vpi_assertion_reset_restores_initial_state;
  logic clk = 0, x = 1;
  int pass_at[3][$], fail_at[3][$];

  always #5 clk = ~clk;
  always #10 x = ~x;   // 0 at 15 and 35, 1 at 25 and 45

  a1: assert property (@(posedge clk) x) pass_at[0].push_back($time);
    else fail_at[0].push_back($time);
  a2: assert property (@(posedge clk) x) pass_at[1].push_back($time);
    else fail_at[1].push_back($time);
  a3: assert property (@(posedge clk) x) pass_at[2].push_back($time);
    else fail_at[2].push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #2 $vt_control("a1", "disable pass action");   // 2
    $vt_control("a1", "disable fail action");
    $vt_control("a2", "disable pass action");
    $vt_control("a2", "disable fail action");
    $vt_control("a3", "disable");
    #28 $vt_control("a1", "reset");                // 30
    $vt_control("a3", "reset");
    #20;                                           // 50
    for (int i = 0; i < 3; i++)
      $display("a%0d pass actions at:%s, fail actions at:%s", i + 1, times(pass_at[i]),
               times(fail_at[i]));
    $finish;
  end
endmodule
