/*
:name: test_vpi_assertion_sys_action_controls_running_attempts
:description: The assertion system controls of pass and fail actions leave the attempts already running as they were, apply to the attempts that start later, and change nothing when the actions are already disabled or enabled (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_sys_action_controls_running_attempts.c
:expected_stdout: @test_vpi_assertion_sys_action_controls_running_attempts.expected
*/
// IEEE 1800-2023 §39.5.1: $vt_system calls vpi_control with a system control
// and a NULL scope, which acts on all assertions, here p1 and f1.
// vpiAssertionSysDisablePassAction and vpiAssertionSysEnablePassAction turn
// the pass actions off and on, vpiAssertionSysDisableFailAction and
// vpiAssertionSysEnableFailAction the fail actions. None of them changes an
// attempt that has already started, and none has an effect when the actions
// are already in the state it asks for; by default all actions are enabled.
// The clock rises at 5, 15, 25 and so on. a is 1 at the ticks 5, 15, 45, 55, 95
// and 125, and b two ticks later, so each of these attempts of p1 passes and
// the same attempt of f1 fails two ticks after it started; the other attempts
// of p1 fail and those of f1 succeed vacuously, with an empty action. The
// actions record their time. The controls of the pass and of the fail actions
// come at 10 (off), 40 (off again), 50 (on), 80 (on again), 90 (off) and 120
// (on). So the attempt of 5 still runs its action at 25, that of 15 does not at
// 35, that of 45 started while the action was off and does not run it at 65
// although it is on by then, that of 55 does at 75, that of 95 does not at 115
// and that of 125 does at 145. No simulator here runs the application: the
// expected output is derived from §39.5.1.

`timescale 1ns/1ns

module test_vpi_assertion_sys_action_controls_running_attempts;
  logic clk = 0, a = 0, b = 0;
  int pass_at[$], fail_at[$];

  // The values of a and b sampled at the ticks 5, 15, ..., 145, from left.
  localparam bit [0:14] A_AT = 15'b110011000100100;
  localparam bit [0:14] B_AT = 15'b001100110001001;

  always #5 clk = ~clk;

  p1: assert property (@(posedge clk) a ##2 b) pass_at.push_back($time); else ;
  f1: assert property (@(posedge clk) a |-> ##2 !b) else fail_at.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial
    for (int k = 0; k < 15; k++) begin
      a = A_AT[k];
      b = B_AT[k];
      #10;
    end

  initial begin
    #10 $vt_system("disable pass action");   // 10
    $vt_system("disable fail action");
    #30 $vt_system("disable pass action");   // 40
    $vt_system("disable fail action");
    #10 $vt_system("enable pass action");    // 50
    $vt_system("enable fail action");
    #30 $vt_system("enable pass action");    // 80
    $vt_system("enable fail action");
    #10 $vt_system("disable pass action");   // 90
    $vt_system("disable fail action");
    #30 $vt_system("enable pass action");    // 120
    $vt_system("enable fail action");
    #40;                                     // 160
    $display("p1 pass actions at:%s", times(pass_at));
    $display("f1 fail actions at:%s", times(fail_at));
    $finish;
  end
endmodule
