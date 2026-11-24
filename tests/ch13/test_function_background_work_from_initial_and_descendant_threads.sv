/*
:name: test_function_background_work_from_initial_and_descendant_threads
:description: A function queues later work when called directly from an initial thread or its forked child
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4.4 9.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_background_work_from_initial_and_descendant_threads.expected
*/
`timescale 1ns/1ns
module test_function_background_work_from_initial_and_descendant_threads;
  int results [2];

  function automatic int launch(input int slot, input int value);
    fork
      automatic int saved_slot = slot;
      automatic int saved_value = value;
      begin
        #3 results[saved_slot] = saved_value;
      end
    join_none
    return value + 2;
  endfunction

  initial begin
    int direct, from_child;
    direct = launch(0, 11);
    fork
      from_child = launch(1, 23);
    join
    $display("returned=%0d/%0d pending=%0d/%0d", direct, from_child, results[0], results[1]);
    #4 $display("completed=%0d/%0d", results[0], results[1]);
  end
endmodule
