/*
:name: test_vpi_assertion_sys_reset_restores_actions
:description: vpiAssertionSysReset returns the assertion system to its initial state, in which pass and fail actions are enabled, so actions that system controls had disabled run again after the reset (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_sys_reset_restores_actions.c
:expected_stdout: @test_vpi_assertion_sys_reset_restores_actions.expected
*/
// IEEE 1800-2023 §39.5.1: vpi_control(vpiAssertionSysReset, NULL) restores the
// entire assertion system to its initial state. In that state all pass and
// fail actions are enabled, which is the default that
// vpiAssertionSysDisablePassAction and vpiAssertionSysDisableFailAction
// change.
// The clock rises at 5, 15, 25, 35 and 45; a1 needs x, which is 1 at 5, 25 and
// 45 and 0 at 15 and 35, so a1 passes and fails in turn and each attempt ends
// at the tick where it starts. The actions record their time. At 10,
// $vt_system turns the pass and fail actions off, so the failure at 15 and the
// success at 25 run no action. At 30 it resets the assertion system, after
// which the failure at 35 and the success at 45 run their actions again. No
// simulator here runs the application: the expected output is derived from
// §39.5.1.

`timescale 1ns/1ns

module test_vpi_assertion_sys_reset_restores_actions;
  logic clk = 0, x = 1;
  int pass_at[$], fail_at[$];

  always #5 clk = ~clk;
  always #10 x = ~x;   // 0 at 15 and 35, 1 at 25 and 45

  a1: assert property (@(posedge clk) x) pass_at.push_back($time); else fail_at.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #10 $vt_system("disable pass action");   // 10
    $vt_system("disable fail action");
    #20 $vt_system("reset");                 // 30
    #20;                                     // 50
    $display("a1 pass actions at:%s", times(pass_at));
    $display("a1 fail actions at:%s", times(fail_at));
    $finish;
  end
endmodule
