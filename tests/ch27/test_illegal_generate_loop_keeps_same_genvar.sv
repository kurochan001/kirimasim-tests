/*
:name: test_illegal_generate_loop_keeps_same_genvar
:description: A generate loop that keeps its controlling value unchanged has no terminating iteration
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the generate loop's assignment keeps its exit condition permanently false
:expected_stderr_regex: test_illegal_generate_loop_keeps_same_genvar\.sv:15:(?:\d+:)?[^\n]*(?i:(?:generate|genvar|loop|index)[^\n]*(?:repeat|duplicat|unroll|not increment|infinite|non[- ]?terminat|iteration limit)|(?:repeat|duplicat|unroll|not increment|infinite|non[- ]?terminat|iteration limit)[^\n]*(?:generate|genvar|loop|index))
*/
module test_illegal_generate_loop_keeps_same_genvar;
  for (genvar i = 0; i == 0; i = i) begin: stalled // illegal
    localparam int index_value = i;
  end

  initial $display("index=%0d", stalled[0].index_value);
endmodule
