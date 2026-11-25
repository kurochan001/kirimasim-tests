/*
:name: test_vpi_size_query_preserves_side_effecting_string_call
:description: A string size query returns an inferred length or reports an error before the call changes state
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.3.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_queries_preserve_expression_state.c
:expected_stdout: @test_vpi_size_query_preserves_side_effecting_string_call.expected
:expected_stderr_regex: (?m)^property decision=1 untouched=1 value=1 once=1$\n^property decision=1 untouched=1 value=1 once=1$
*/
module test_vpi_size_query_preserves_side_effecting_string_call;
  int calls = 0;

  function automatic string color(input int choice);
    calls++;
    if (calls > 1)
      return "evaluated again";
    if (choice == 1)
      return "amber";
    return "violet!";
  endfunction

  initial begin
    $vt_property_query(color(1), "amber", calls);
    calls = 0;
    $vt_property_query(color(2), "violet!", calls);
  end
endmodule
