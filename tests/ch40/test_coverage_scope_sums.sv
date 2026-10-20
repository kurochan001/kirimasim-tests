/*
:name: test_coverage_scope_sums
:description: Coverage of a module definition is the sum over its instances, and coverage of a hierarchy is that of its top plus that of the hierarchies below, for the maximum and the current values of every coverage type (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.2 40.3.2.3 40.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_scope_sums.expected
*/
// IEEE 1800-2023 §40.3.2.1 (Table 40-2): with `SV_COV_MODULE a module
// definition name gives the sum over all instances of the module, and an
// instance just that instance; with `SV_COV_HIER either one also includes the
// hierarchy below. §40.2.2: over instances, a coverage number is the sum of
// the primitives they contain. So, for $coverage_get_max and $coverage_get
// alike (40.3.2.2, 40.3.2.3), the definition is the sum of u1 and u2, the
// hierarchy of u1 is u1 plus u1.in, and the hierarchy of the top is the top
// plus those of u1 and u2. Which items have coverage depends on the tool, so
// only these relations are printed, read when nothing changes. The maximum
// stays the same during the simulation, also across stop, reset and start.

`timescale 1ns/1ns

module test_coverage_scope_sums_inner(input logic d, output logic q);
  always @(d) q = ~d;
endmodule

module test_coverage_scope_sums_leaf(input logic d, output logic q);
  logic t;

  test_coverage_scope_sums_inner in(.d(d), .q(t));
  always @(t) q = t;
endmodule

module test_coverage_scope_sums;
  logic d = 0, q1, q2;

  test_coverage_scope_sums_leaf u1(.d(d), .q(q1));
  test_coverage_scope_sums_leaf u2(.d(d), .q(q2));

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  task check(int t, string name, bit current);
    int def, m1, m2, in1, h1, h2, top, htop, hdef;
    if (current) begin
      def = $coverage_get(t, `SV_COV_MODULE, "test_coverage_scope_sums_leaf");
      m1 = $coverage_get(t, `SV_COV_MODULE, u1);
      m2 = $coverage_get(t, `SV_COV_MODULE, u2);
      in1 = $coverage_get(t, `SV_COV_MODULE, u1.in);
      h1 = $coverage_get(t, `SV_COV_HIER, u1);
      h2 = $coverage_get(t, `SV_COV_HIER, u2);
      top = $coverage_get(t, `SV_COV_MODULE, test_coverage_scope_sums);
      htop = $coverage_get(t, `SV_COV_HIER, test_coverage_scope_sums);
      hdef = $coverage_get(t, `SV_COV_HIER, "test_coverage_scope_sums_leaf");
    end else begin
      def = $coverage_get_max(t, `SV_COV_MODULE, "test_coverage_scope_sums_leaf");
      m1 = $coverage_get_max(t, `SV_COV_MODULE, u1);
      m2 = $coverage_get_max(t, `SV_COV_MODULE, u2);
      in1 = $coverage_get_max(t, `SV_COV_MODULE, u1.in);
      h1 = $coverage_get_max(t, `SV_COV_HIER, u1);
      h2 = $coverage_get_max(t, `SV_COV_HIER, u2);
      top = $coverage_get_max(t, `SV_COV_MODULE, test_coverage_scope_sums);
      htop = $coverage_get_max(t, `SV_COV_HIER, test_coverage_scope_sums);
      hdef = $coverage_get_max(t, `SV_COV_HIER, "test_coverage_scope_sums_leaf");
    end
    $display("%s %s: definition is u1 + u2: %s, u1 hierarchy is u1 + u1.in: %s",
             name, current ? "current" : "maximum", yes_no(def == m1 + m2),
             yes_no(h1 == m1 + in1));
    $display("%s %s: definition hierarchy is u1 + u2 hierarchies: %s, top hierarchy: %s",
             name, current ? "current" : "maximum", yes_no(hdef == h1 + h2),
             yes_no(htop == top + h1 + h2));
  endtask

  task keeps_max(int t, string name);
    int max_before, max_after, r;
    max_before = $coverage_get_max(t, `SV_COV_HIER, test_coverage_scope_sums);
    r = $coverage_control(`SV_COV_STOP, t, `SV_COV_HIER, test_coverage_scope_sums);
    r = $coverage_control(`SV_COV_RESET, t, `SV_COV_HIER, test_coverage_scope_sums);
    r = $coverage_control(`SV_COV_START, t, `SV_COV_HIER, test_coverage_scope_sums);
    max_after = $coverage_get_max(t, `SV_COV_HIER, test_coverage_scope_sums);
    $display("%s maximum unchanged by stop, reset and start: %s", name, yes_no(max_before == max_after));
  endtask

  initial begin
    #1 d = 1;
    #1 d = 0;
    #1 d = 1;
    #5;
    check(`SV_COV_STATEMENT, "statement", 0);
    check(`SV_COV_STATEMENT, "statement", 1);
    check(`SV_COV_TOGGLE, "toggle", 0);
    check(`SV_COV_TOGGLE, "toggle", 1);
    check(`SV_COV_FSM_STATE, "FSM state", 0);
    check(`SV_COV_ASSERTION, "assertion", 0);
    keeps_max(`SV_COV_STATEMENT, "statement");
    keeps_max(`SV_COV_TOGGLE, "toggle");
  end
endmodule
