/*
:name: test_coverage_root_hierarchy
:description: Coverage of the hierarchy under $root equals that of the hierarchy under the only top-level instance, for the maximum and the current values of every coverage type (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 23.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_root_hierarchy.expected
*/
// IEEE 1800-2023 §40.3.2.1: an instance can be given as $root, and with
// `SV_COV_HIER the coverage covers it and all the hierarchy below. This design
// has one top-level instance (23.3.1), so the hierarchy under $root is the
// hierarchy under it, and $coverage_get_max (40.3.2.2) and $coverage_get
// (40.3.2.3) give the same for both. Which items have coverage depends on the
// tool, so only the equality is printed, read when nothing changes.

module test_coverage_root_hierarchy_leaf(input logic d, output logic q);
  always @(d) q = ~d;
endmodule

module test_coverage_root_hierarchy;
  logic d = 0, q;

  test_coverage_root_hierarchy_leaf u(.d(d), .q(q));

  task compare(int t, string name);
    $display("%s: maximum %s, current %s", name,
             $coverage_get_max(t, `SV_COV_HIER, $root)
             == $coverage_get_max(t, `SV_COV_HIER, test_coverage_root_hierarchy)
             ? "equal" : "different",
             $coverage_get(t, `SV_COV_HIER, $root)
             == $coverage_get(t, `SV_COV_HIER, test_coverage_root_hierarchy)
             ? "equal" : "different");
  endtask

  initial begin
    #1 d = 1;
    #1 d = 0;
    #5;
    compare(`SV_COV_TOGGLE, "toggle");
    compare(`SV_COV_FSM_STATE, "FSM state");
    compare(`SV_COV_ASSERTION, "assertion");
  end
endmodule
