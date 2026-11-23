/*
:name: test_illegal_instance_array_partition_one_bit_short
:description: Three instances with two-bit input ports reject a five-bit packed connection
:tags: ch28
:type: elaboration
:lrm: 1800-2023 28.3.6 23.3.3.5
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: instance_array_ports/two_bit_lane.sv
:should_fail_because: the five-bit input is neither the two-bit broadcast width nor the six-bit partition width
:expected_stderr_regex: test_illegal_instance_array_partition_one_bit_short\.sv:18:(?:\d+:)?[^\n]*(?i:port expression width 5\b|requires 2 or 6 bits[^\n]*5 bits|cannot connect [^\n]*\[4:0\][^\n]*to each port)
*/
module test_illegal_instance_array_partition_one_bit_short;
  wire [4:0] source_bus;
  wire [5:0] result;
  partition_lane lanes[4:6](source_bus, result);
endmodule
