/*
:name: test_coverage_api_minimum_types
:description: The coverage API takes the same calls for every coverage type, accepts at least statement, toggle, FSM and assertion coverage, and can query a whole subhierarchy by naming only its top instance (IEEE 1800-2023 Section 40.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.2.1 40.3.2.1 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_api_minimum_types.expected
*/
// IEEE 1800-2023 §40.2.1: the coverage API is the same for all coverage types,
// it supports at least statement, toggle, FSM and assertion coverage, and it
// gives coverage of a subhierarchy without listing its instances. For each of
// the four types, $coverage_control (40.3.2.1) checks the subhierarchy under
// the instance u with SV_COV_HIER, which covers the instance inside it as
// well; whether coverage is available depends on the tool and its options, so
// the test only prints that the call is not refused as an error, with the
// predefined macros of 40.3.1.

module test_coverage_api_minimum_types_leaf(input logic d);
  logic q;
  always @(d) q = d;
endmodule

module test_coverage_api_minimum_types_sub(input logic d);
  test_coverage_api_minimum_types_leaf l(.d(d));
endmodule

module test_coverage_api_minimum_types;
  logic d = 0;
  string names[4] = '{"statement", "toggle", "FSM state", "assertion"};
  int types[4] = '{`SV_COV_STATEMENT, `SV_COV_TOGGLE, `SV_COV_FSM_STATE, `SV_COV_ASSERTION};
  int r;

  test_coverage_api_minimum_types_sub u(.d(d));

  initial begin
    #1 d = 1;
    foreach (types[k]) begin
      r = $coverage_control(`SV_COV_CHECK, types[k], `SV_COV_HIER, u);
      $display("%s: check of the subhierarchy is %s", names[k],
               r == `SV_COV_ERROR ? "an error" : "accepted");
    end
  end
endmodule
