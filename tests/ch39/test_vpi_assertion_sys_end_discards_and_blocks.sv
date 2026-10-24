/*
:name: test_vpi_assertion_sys_end_discards_and_blocks
:description: vpiAssertionSysEnd discards the attempts in progress and starts no new ones, and after it neither turning the system on nor enabling an assertion has an effect or calls an assertion callback (IEEE 1800-2023 Section 39.5.1)
:tags: ch39
:type: simulation
:lrm: 1800-2023 39.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_assertion_sys_end_discards_and_blocks.c
:expected_stdout: @test_vpi_assertion_sys_end_discards_and_blocks.expected
*/
// IEEE 1800-2023 §39.5.1: vpi_control(vpiAssertionSysEnd, NULL) discards all
// attempts in progress, lets no further attempt start and removes all
// assertion callbacks, and after it no further assertion-related action is
// permitted.
// The clock rises at 5, 15, 25 and so on. go and b are always 1, so every
// attempt of a1 passes two ticks after it starts, and the pass action records
// the time. At 1, $vt_watch places a cbAssertionStart callback on a1 (39.4.2)
// and, with vpi_register_cb, the system callbacks cbAssertionSysOn and
// cbAssertionSysOff (39.4.1). The attempt of 5 passes at 25. At 30, $vt_end
// ends the assertion system: the attempts of 15 and 25, which would pass at 35
// and 45, are discarded, and no attempt starts at 35. At 40, $vt_system calls
// vpiAssertionSysOff and vpiAssertionSysOn, and at 42 vpiAssertionEnable on
// a1; none of them has an effect, so no attempt starts at 45 and 55, and no
// callback comes after the end. The application prints the start times and
// the callbacks after the end at 60. No simulator here runs the application:
// the expected output is derived from §39.5.1.

`timescale 1ns/1ns

module test_vpi_assertion_sys_end_discards_and_blocks;
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
    #1 $vt_watch;              // 1
    #29 $vt_end;               // 30
    #10 $vt_system("off");     // 40
    $vt_system("on");
    #2 $vt_enable;             // 42
    #18;                       // 60
    $display("a1 pass actions at:%s", times(pass_at));
    $vt_report;
    $finish;
  end
endmodule
