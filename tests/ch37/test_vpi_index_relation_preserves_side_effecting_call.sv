/*
:name: test_vpi_index_relation_preserves_side_effecting_call
:description: Looking up the index relation leaves an index function unevaluated before the explicit value read
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5 37.22
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_queries_preserve_expression_state.c
:expected_stdout: @test_vpi_index_relation_preserves_side_effecting_call.expected
:expected_stderr_regex: (?m)^relation decision=1 untouched=1 value=1 once=1$\n^relation decision=1 untouched=1 value=1 once=1$
*/
module test_vpi_index_relation_preserves_side_effecting_call;
  int calls = 0;
  logic [7:0] data = 8'b0010_0000;

  function automatic int next_index(input int position);
    calls++;
    return position;
  endfunction

  initial begin
    $vt_index_query(data[next_index(5)], 1, calls);
    calls = 0;
    $vt_index_query(data[next_index(2)], 0, calls);
  end
endmodule
