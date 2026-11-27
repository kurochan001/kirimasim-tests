/*
:name: test_vpi_task_reference_parent
:description: Resolve a task or function parent to the selected VPI reference object
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.15 37.41
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_task_reference_parent.c
:files: vpi_task_reference_parent/seed.cpp vpi_task_reference_parent/seeded.expected vpi_task_reference_parent/swapped.expected
:expected_stdout: @test_vpi_task_reference_parent.expected
*/
`timescale 1ns/1ns
module test_vpi_task_reference_parent;
  int left = 17, right = 29;

  task automatic adjust(ref int bound);
    bound += 3;
  endtask

  function automatic int inspect(const ref int bound);
    return bound + 4;
  endfunction

  function automatic int plain(input int bound);
    return bound + 7;
  endfunction

  initial begin
    #1 $vt_tf_reference;
    adjust(left);
    $display("hdl task=%0d function=%0d control=%0d", left, inspect(right), plain(right));
    $finish(0);
  end
endmodule
