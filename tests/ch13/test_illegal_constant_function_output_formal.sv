/*
:name: test_illegal_constant_function_output_formal
:description: A constant expression rejects a nested function call with an unused output formal
:tags: ch13
:type: elaboration
:lrm: 1800-2023 13.4.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:files: constant_function_ports/port_directions.svh
:should_fail_because: the localparam calls probe which calls a function with an output formal
:expected_stderr_regex: test_illegal_constant_function_output_formal\.sv:(?:20:(?:\d+:)?[^\n]*(?i:(?:output|inout|ref)[^\n]*constant (?:expression|function))|23:(?:\d+:)?[^\n]*(?i:expecting expression to be constant)[^\n]*\bprobe\b)
*/
module test_illegal_constant_function_output_formal;
  `include "port_directions.svh"

  function automatic int probe(input int seed);
    int slot = seed;
    return port_output(seed, slot);
  endfunction

  localparam int value = probe(7);
  initial $display("value=%0d", value);
endmodule
