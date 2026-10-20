/*
:name: test_timing_timeskew_remain_active
:description: A conditioned reference event whose condition is false makes a timer-based $timeskew dormant, unless its remain_active_flag is set, in which case the running window goes on and expires (IEEE 1800-2023 Section 31.4.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.4.2 31.7 31.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timing_timeskew_remain_active.expected
*/
// IEEE 1800-2023 §31.4.2: a timer-based $timeskew becomes dormant when it sees
// a conditioned reference event whose condition (31.7) is false, unless the
// remain_active_flag is set, in which case that event is ignored. Both checks
// here have the reference event posedge r &&& mode and a limit of 10. r rises
// at 10 with mode 1 and at 15 with mode 0, and d stays 0: the check without
// the flag turns dormant at 15, the one with it reports at 20. Both then work
// alike: r at 30 and d at 35 are in time, and r at 40 without d expires at
// 50. Each violation toggles its notifier (31.6).

`timescale 1ns/1ns

module test_timing_timeskew_remain_active_dut(input r, input d, input mode);
  reg n_plain = 0, n_remain = 0;

  specify
    $timeskew(posedge r &&& mode, posedge d, 10, n_plain);
    $timeskew(posedge r &&& mode, posedge d, 10, n_remain, 0, 1);
  endspecify
endmodule

module test_timing_timeskew_remain_active;
  reg r = 0, d = 0, mode = 1;
  string log_plain = "", log_remain = "";

  test_timing_timeskew_remain_active_dut u(r, d, mode);

  always @(u.n_plain) log_plain = {log_plain, $sformatf(" %0d", $time)};
  always @(u.n_remain) log_remain = {log_remain, $sformatf(" %0d", $time)};

  initial begin
    #10 r = 1;          // 10, mode 1
    #2 r = 0;
    #1 mode = 0;
    #2 r = 1;           // 15, mode 0
    #2 r = 0;
    #8 mode = 1;
    #5 r = 1;           // 30
    #2 r = 0;
    #3 d = 1;           // 35
    #2 d = 0;
    #3 r = 1;           // 40
    #2 r = 0;
    #20;
    $display("without remain_active_flag:%s", log_plain);
    $display("with remain_active_flag:%s", log_remain);
  end
endmodule
