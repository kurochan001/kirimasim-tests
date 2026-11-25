/*
:name: test_global_system_calls_and_object_methods
:description: A queue method updates its receiver while time and finish operate across independent processes
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.13 20.2 20.3.1 7.10.2.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_global_system_calls_and_object_methods.expected
*/
// pop_front acts on one queue. An unrelated process can read the time
// without a receiver, and a later $finish ends both instances.
`timescale 1ns/1ns
module global_system_task_observer;
  initial begin
    #1 $display("observer time=%0d", $time);
    #3 $display("observer resumed after finish");
  end
endmodule

module test_global_system_calls_and_object_methods;
  global_system_task_observer observer();
  int first_values[$];
  int other_values[$];
  int popped;

  initial begin
    first_values.push_back(11);
    first_values.push_back(22);
    other_values.push_back(33);
    popped = first_values.pop_front();
    $display("popped=%0d first_head=%0d other_head=%0d", popped, first_values[0], other_values[0]);
    #2 $display("finish time=%0d", $time);
    $finish(0);
    #1 $display("caller resumed after finish");
  end
endmodule
