/*
:name: test_coverage_check_combines_parts
:description: A check of a hierarchy gives SV_COV_OK only when coverage is fully available in every part of it, SV_COV_NOCOV only when no part has any, and SV_COV_PARTIAL otherwise, so it follows from the checks of the top instance alone and of the hierarchies below it (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_check_combines_parts.expected
*/
// IEEE 1800-2023 §40.3.2.1, Table 40-1: on a check, SV_COV_OK means that
// coverage is fully available in the hierarchy, SV_COV_NOCOV that it is not
// available at any point of it, and SV_COV_PARTIAL that it is only partly
// available. Table 40-2: SV_COV_MODULE with an instance name covers just that
// instance, and SV_COV_HIER the instance and all the hierarchy below it.
//
// The hierarchy under the top module is made of three disjoint parts: the top
// instance alone, the hierarchy under u1 and the hierarchy under u2. Each part
// has signals, statements and an assertion, so each has items of the three
// coverage types checked. So the check of the whole hierarchy is OK exactly
// when the three parts are OK, NOCOV exactly when the three parts are NOCOV,
// and PARTIAL in every other case. Which parts have coverage depends on the
// tool and its options, so the test prints only whether the results agree. A
// tool that gave OK for a hierarchy with a part lacking coverage, or PARTIAL
// for one where every part is fully covered, prints no.

`timescale 1ns/1ns

module test_coverage_check_combines_parts_leaf(input logic clk);
  logic [1:0] s = 2'd0;

  always @(posedge clk) s <= s + 2'd1;
  a_leaf: assert property (@(posedge clk) 1'b1);
endmodule

module test_coverage_check_combines_parts;
  logic clk = 0;
  logic [1:0] r = 2'd0;

  test_coverage_check_combines_parts_leaf u1(.clk(clk));
  test_coverage_check_combines_parts_leaf u2(.clk(clk));

  always #5 clk = ~clk;
  always @(posedge clk) r <= r + 2'd1;
  a_top: assert property (@(posedge clk) 1'b1);

  function automatic string yes_no(bit ok);
    return ok ? "yes" : "no";
  endfunction

  function automatic int combine(int a, int b, int c);
    if (a == `SV_COV_OK && b == `SV_COV_OK && c == `SV_COV_OK)
      return `SV_COV_OK;
    if (a == `SV_COV_NOCOV && b == `SV_COV_NOCOV && c == `SV_COV_NOCOV)
      return `SV_COV_NOCOV;
    return `SV_COV_PARTIAL;
  endfunction

  function automatic bit availability(int r);
    return r inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL};
  endfunction

  task automatic probe(int t, string name);
    int own, h1, h2, whole;
    own = $coverage_control(`SV_COV_CHECK, t, `SV_COV_MODULE, test_coverage_check_combines_parts);
    h1 = $coverage_control(`SV_COV_CHECK, t, `SV_COV_HIER, u1);
    h2 = $coverage_control(`SV_COV_CHECK, t, `SV_COV_HIER, u2);
    whole = $coverage_control(`SV_COV_CHECK, t, `SV_COV_HIER, test_coverage_check_combines_parts);
    $display("%s: each check is OK, NOCOV or PARTIAL: %s", name,
             yes_no(availability(own) && availability(h1) && availability(h2)
                    && availability(whole)));
    $display("%s: the check of the hierarchy agrees with the checks of its parts: %s", name,
             yes_no(whole == combine(own, h1, h2)));
  endtask

  initial begin
    #20;
    probe(`SV_COV_TOGGLE, "toggle");
    probe(`SV_COV_STATEMENT, "statement");
    probe(`SV_COV_ASSERTION, "assertion");
    $finish;
  end
endmodule
