/*
:name: test_vpi_assertion_disable_enable_running_attempts
:description: Disabling one assertion stops the start of new attempts while the attempts already running finish, enabling it starts them again without touching the running ones, and a repeated disable or enable changes nothing (IEEE 1800-2023 Section 39.5.2)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_disable_enable_running_attempts.c
:expected_stdout: @test_vpi_assertion_disable_enable_running_attempts.expected
*/
// IEEE 1800-2023 §39.5.2: $vt_control calls vpi_control with the handle of a1.
// vpiAssertionDisable stops the start of new attempts of a1 and
// vpiAssertionEnable lets them start again; neither changes the attempts
// already running, and neither has an effect when a1 is already disabled or
// enabled. By default assertions are enabled.
// The clock rises at 5, 15, 25 and so on. go and b are always 1, so every
// attempt of a1 passes two ticks after it starts, and the pass action records
// the time. $vt_watch places a cbAssertionStart callback on a1 at 1 (39.4.2),
// which records the start of each attempt. Controls: 10 disable, 20 disable
// again, 30 enable, 40 enable again, 60 disable. So the attempt of 5 starts
// and passes at 25, none starts at 15 and 25, the attempts of 35, 45 and 55
// start, the second enable at 40 leaves the attempt of 35 running, and the
// disable at 60 leaves those of 45 and 55 running, which pass at 65 and 75;
// none starts after 60. The callback times are printed at the end, sorted.
// No simulator here runs the application: the expected output is derived
// from §39.5.2.

`timescale 1ns/1ns

module test_vpi_assertion_disable_enable_running_attempts;
  logic clk = 0, go = 1, b = 1;
  int pass_at[$];

  always #5 clk = ~clk;

  a1: assert property (@(posedge clk) go |-> ##2 b) pass_at.push_back($time);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #1 $vt_watch;                         // 1
    #9 $vt_control("a1", "disable");      // 10
    #10 $vt_control("a1", "disable");     // 20
    #10 $vt_control("a1", "enable");      // 30
    #10 $vt_control("a1", "enable");      // 40
    #20 $vt_control("a1", "disable");     // 60
    #30;                                  // 90
    $display("a1 pass actions at:%s", times(pass_at));
    $vt_report;
    $finish;
  end
endmodule
