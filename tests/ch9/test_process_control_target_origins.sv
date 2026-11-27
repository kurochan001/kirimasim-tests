/*
:name: test_process_control_target_origins
:description: Control processes from initial and always procedures and their fork descendants
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: process_control_target_origins/probe.cpp process_control_target_origins/guarded.expected process_control_target_origins/unguarded.expected
:expected_stdout: @test_process_control_target_origins.expected
*/
`timescale 1ns/1ns
module test_process_control_target_origins;
  process initial_root, initial_child, always_root, always_child, nested_child, terminal;
  process controller;
  event start_always;
  bit initial_progress, initial_child_progress, always_progress;
  bit always_child_progress, nested_progress;
  wire [4:0] seen = {nested_progress, always_child_progress, always_progress,
                     initial_child_progress, initial_progress};

  initial begin
    initial_root = process::self();
`ifdef OBSERVE_ORIGIN
    $observe_process("initial_root");
`endif
    fork
      begin
        initial_child = process::self();
`ifdef OBSERVE_ORIGIN
        $observe_process("initial_child");
`endif
        #8 initial_child_progress = 1;
        #8;
      end
    join_none
    #8 initial_progress = 1;
    #8;
  end

  always begin
    @start_always;
    always_root = process::self();
`ifdef OBSERVE_ORIGIN
    $observe_process("always_root");
`endif
    fork
      begin
        always_child = process::self();
`ifdef OBSERVE_ORIGIN
        $observe_process("always_child");
`endif
        fork
          begin
            nested_child = process::self();
`ifdef OBSERVE_ORIGIN
            $observe_process("nested_child");
`endif
            #8 nested_progress = 1;
            #8;
          end
        join_none
        #8 always_child_progress = 1;
        #8;
      end
    join_none
    #8 always_progress = 1;
  end

  initial begin
    process targets[5];
    automatic int distinct = 0, suspended = 0, joined = 0;
    controller = process::self();
`ifdef OBSERVE_ORIGIN
    $observe_process("controller");
`endif
    #1 -> start_always;
    #1;
    targets = '{initial_root, initial_child, always_root, always_child, nested_child};
    foreach (targets[i]) begin
      if (targets[i] != null && targets[i] != controller) distinct++;
      for (int j = 0; j < i; j++)
        if (targets[i] == targets[j]) $fatal(1, "duplicate target handle");
      targets[i].suspend();
      if (targets[i].status() == process::SUSPENDED) suspended++;
    end
    $display("target handles=%0d suspended=%0d progress=%0d", distinct, suspended, seen);
    #1;
    foreach (targets[i]) targets[i].resume();
    #7;
    $display("resumed progress=%0d", seen);
    for (int i = 4; i >= 0; i--) begin
      targets[i].kill();
      targets[i].await();
      if (targets[i].status() == process::KILLED) joined++;
    end
    $display("killed and awaited=%0d", joined);
    $finish(0);
  end

  final begin
    terminal = process::self();
`ifdef OBSERVE_ORIGIN
    $observe_process("terminal");
`endif
    $display("final distinct=%0d", terminal != null && terminal != controller
             && terminal != initial_root && terminal != initial_child && terminal != always_root
             && terminal != always_child && terminal != nested_child);
  end
endmodule
