/*
:name: test_empty_unpacked_concatenation_constant_primary
:description: Empty unpacked concatenation is valid as a constant dynamic array and queue value
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.12 A.8.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_empty_unpacked_concatenation_constant_primary.expected
*/
module test_empty_unpacked_concatenation_constant_primary;
  localparam int EMPTY_QUEUE[$] = {};
  localparam int EMPTY_DYNAMIC[] = {};
  localparam int QUEUE_COUNT = EMPTY_QUEUE.size();
  localparam int DYNAMIC_COUNT = EMPTY_DYNAMIC.size();

  initial $display("queue=%0d dynamic=%0d", QUEUE_COUNT, DYNAMIC_COUNT);
endmodule
