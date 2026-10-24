/*
:name: test_vpi_thread_parent_children_frame
:description: the frame of a thread is its active frame; the threads of the branches of a fork are the children of the thread that ran the fork and lead back to it with vpiParent; vpi_iterate(vpiThread, NULL) gives the threads of the live processes when only static processes are left (IEEE 1800-2023 Section 37.44)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.44 37.43 9.3.2 9.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_thread_parent_children_frame.c
:expected_stdout: @test_vpi_thread_parent_children_frame.expected
*/
// IEEE 1800-2023 §37.44: a thread is a process, such as an initial or always
// procedure or a branch of a fork, and it activates a new frame for each task
// it enters (detail 1). Its relations: vpiFrame to its frame, which is the one
// active frame of the thread (37.43 detail 4), vpiParent to the thread that
// created it, and an iteration over vpiThread to the threads it created; an
// iteration over vpiThread with a NULL reference gives the threads.
//
// The initial procedure parent_proc starts the two branches of a fork with
// join_none (9.3.2): branch_a enters mid, which calls deep, and branch_b enters
// idle; every task declares one automatic variable and has no argument.
// At 0, in deep, the frame of the current thread is the active frame of deep
// and not the frame of its caller mid. At 1, while both branches are
// suspended, parent_proc calls probe: the current thread has two children,
// each of type vpiThread and leading back to it with vpiParent; the frames of
// the children are those of deep (automatic variable level) and of idle (w),
// the active ones, and the caller of the frame of deep is that of mid (m). At
// 10 both branches have ended, and only the static processes are left: the
// initial procedures parent_proc and sleeper and the always procedure, so the
// NULL iteration gives three threads, among them the current one.
//
// Icarus Verilog 13.0 cannot build the application (its sv_vpi_user.h lacks
// the frame and thread constants of Annex M), and Verilator 5.052 cannot call
// a system task registered by a VPI application.

`timescale 1ns/1ns

module test_vpi_thread_parent_children_frame;
  event never;
  int wakes;

  task automatic deep();
    int level;
    level = 2;
    $vt_in_deep;
    #3;
  endtask

  task automatic mid();
    int m;
    m = 1;
    deep();
  endtask

  task automatic idle();
    int w;
    w = 5;
    #5;
  endtask

  task automatic probe();
    $vt_children;
  endtask

  task automatic probe_all();
    $vt_all;
  endtask

  always @(never) wakes++;

  initial begin : sleeper
    #20;
  end

  initial begin : parent_proc
    fork
      begin : branch_a
        mid();
      end
      begin : branch_b
        idle();
      end
    join_none
    #1 probe();
    #9 probe_all();
  end
endmodule
