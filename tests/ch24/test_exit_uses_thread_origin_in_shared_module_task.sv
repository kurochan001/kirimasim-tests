/*
:name: test_exit_uses_thread_origin_in_shared_module_task
:description: A shared module task applies exit according to the calling thread origin
:tags: ch24
:type: simulation
:lrm: 1800-2023 24.7 24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_exit_uses_thread_origin_in_shared_module_task.expected
:expected_exit: 0
*/
`timescale 1ns/1ns
program shared_exit_caller;
  initial begin
    #4;
    test_exit_uses_thread_origin_in_shared_module_task.shared_exit("program");
    $display("incorrect program return");
  end

  initial #7 $display("incorrect program sibling");
endprogram

program shared_exit_keeper;
  initial #10 $display("other program alive at %0d", $time);
endprogram

module test_exit_uses_thread_origin_in_shared_module_task;
  shared_exit_caller caller();
  shared_exit_keeper keeper();

  task automatic shared_exit(string origin);
    $display("%s enters exit task at %0d", origin, $time);
    $exit;
    $display("%s returned from exit at %0d", origin, $time);
  endtask

  initial begin
    #2;
    shared_exit("module");
    #4 $display("module alive at %0d", $time);
  end
endmodule
