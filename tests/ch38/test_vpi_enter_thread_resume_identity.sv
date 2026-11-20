/*
:name: test_vpi_enter_thread_resume_identity
:description: cbEnterThread identifies the watched thread at delay, event and wait resumptions, with distinct automatic marker values in two workers (IEEE 1800-2023 Section 38.36.1)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.36.1 37.43 37.44
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_enter_thread_resume_identity.c
:expected_stdout: @test_vpi_enter_thread_resume_identity.expected
*/
// 38.36.1 B002 calls cbEnterThread whenever its particular thread resumes.
// Each worker installs its callback while already executing, then blocks
// at a delay, an event control and a false wait. Worker 91 enters at 1 and
// resumes at 3,6,9; worker 52 enters at 2 and resumes at 4,7,10.
// The callback compares its trigger object with the watched thread and
// reads the actual automatic variable named marker in that worker frame
// (37.43). Distinct values 91 and 52 distinguish the two live frames.
// No observation assumes the callback precedes a resumed body assignment:
// marker remains unchanged for the entire lifetime of each registration.
// Each registration is removed while its worker frame remains alive, and
// no frame/thread handle is used after the worker returns. Reports at 13
// print saved integers only; the sum shows that both workers completed.

`timescale 1ns/1ns

module test_vpi_enter_thread_resume_identity;
  event wake_first, wake_second;
  bit go_first = 0, go_second = 0;
  int completed = 0;

  task automatic worker(input int tag);
    int marker;
    marker = tag;
    $vt_watch_resume(tag);
    #2;
    if (tag == 91) @(wake_first); else @(wake_second);
    if (tag == 91) wait (go_first); else wait (go_second);
    $vt_unwatch_resume(tag);
    completed = completed + marker;
  endtask

  initial begin #1 worker(91); end
  initial begin #2 worker(52); end

  initial begin
    #6 -> wake_first;
    #1 -> wake_second;
    #2 go_first = 1;
    #1 go_second = 1;
    #3;
    $vt_report_resume;
    $display("completed=%0d", completed);
    $finish;
  end
endmodule
