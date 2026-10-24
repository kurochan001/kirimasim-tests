/*
:name: test_vpi_assertion_vacuous_action_controls_running_attempts
:description: The controls of the pass action on vacuous and on nonvacuous success of one assertion act on one kind of success only, leave the attempts already running as they were, and change nothing when repeated (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_vacuous_action_controls_running_attempts.c
:expected_stdout: @test_vpi_assertion_vacuous_action_controls_running_attempts.expected
*/
// IEEE 1800-2023 §39.5.2: $vt_control calls vpi_control with the handle of a1.
// vpiAssertionDisableVacuousAction turns off the pass action on vacuous
// success only, vpiAssertionEnableNonvacuousAction turns on the pass action on
// nonvacuous success only, and vpiAssertionDisablePassAction and
// vpiAssertionEnablePassAction act on both kinds of success. None of them
// changes an attempt that has already started or has an effect when repeated.
// The clock rises at 5, 15, 25 and so on. go is always 1, so every attempt of
// a1 waits one tick for c: it succeeds vacuously at that tick when c is 0 and
// nonvacuously when c is 1 (b is always 1). So each success at a tick belongs
// to the attempt of the tick before, and the pass action tells the two kinds
// apart by the sampled value of c and records the time.
// Controls: 30 vacuous off, 60 vacuous off again, 70 pass on, 90 pass off, 110
// nonvacuous on, 140 nonvacuous on again, 150 pass off. The vacuous success of
// the attempt of 25 still runs the action at 35, that of 35 does not at 45;
// the nonvacuous one at 55 does. The vacuous successes at 65 and 75 come from
// attempts that started while the action was off, and that at 85 runs it. The
// nonvacuous success at 95 comes from an attempt that started before 90 and
// runs it, those at 105 and 115 do not, that at 125 does, the vacuous one at
// 135 does not, those at 145 and 155 do (the second enable changes nothing),
// and that at 165 does not. No simulator here runs the application: the
// expected output is derived from §39.5.2.

`timescale 1ns/1ns

module test_vpi_assertion_vacuous_action_controls_running_attempts;
  logic clk = 0, go = 1, b = 1, c = 0;
  int nonvacuous_at[$], vacuous_at[$];

  // The values of c sampled at the ticks 5, 15, ..., 165, from left.
  localparam bit [0:16] C_AT = 17'b00100100011110111;

  always #5 clk = ~clk;

  // The pass action is the begin-end block, so the else belongs to the if.
  a1: assert property (@(posedge clk) go ##1 c |-> b) begin
    if ($sampled(c)) nonvacuous_at.push_back($time); else vacuous_at.push_back($time);
  end

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial
    for (int k = 0; k < 17; k++) begin
      c = C_AT[k];
      #10;
    end

  initial begin
    #30 $vt_control("a1", "disable vacuous action");     // 30
    #30 $vt_control("a1", "disable vacuous action");     // 60
    #10 $vt_control("a1", "enable pass action");         // 70
    #20 $vt_control("a1", "disable pass action");        // 90
    #20 $vt_control("a1", "enable nonvacuous action");   // 110
    #30 $vt_control("a1", "enable nonvacuous action");   // 140
    #10 $vt_control("a1", "disable pass action");        // 150
    #20;                                                 // 170
    $display("nonvacuous pass actions at:%s", times(nonvacuous_at));
    $display("vacuous pass actions at:%s", times(vacuous_at));
    $finish;
  end
endmodule
