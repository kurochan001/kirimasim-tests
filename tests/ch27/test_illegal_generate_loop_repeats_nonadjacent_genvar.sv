/*
:name: test_illegal_generate_loop_repeats_nonadjacent_genvar
:description: A generate loop cannot continue by alternating between already elaborated genvar values
:tags: ch27
:type: elaboration
:lrm: 1800-2023 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the genvar alternates between zero and one and never exits its generate loop
:expected_stderr_regex: test_illegal_generate_loop_repeats_nonadjacent_genvar\.sv:15:(?:\d+:)?[^\n]*(?i:(?:generate|genvar|loop|index)[^\n]*(?:repeat|duplicat|unroll|not increment|infinite|non[- ]?terminat|iteration limit)|(?:repeat|duplicat|unroll|not increment|infinite|non[- ]?terminat|iteration limit)[^\n]*(?:generate|genvar|loop|index))
*/
module test_illegal_generate_loop_repeats_nonadjacent_genvar;
  for (genvar i = 0; i < 2; i = 1 - i) begin: repeated // illegal
    localparam int index_value = i;
  end

  initial $display("indices=%0d %0d",
                   repeated[0].index_value, repeated[1].index_value);
endmodule
