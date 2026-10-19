/*
:name: test_coverage_get_values
:description: $coverage_get_max stays the same during the simulation and agrees with the coverage check, $coverage_get stays between zero and the maximum and does not decrease, and both give an error for a module name that does not exist (IEEE 1800-2023 Sections 40.3.2.2 and 40.3.2.3)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.2 40.3.2.3 40.3.2.1 40.2.2 40.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_get_values.expected
*/
// IEEE 1800-2023 §40.3.2.2: $coverage_get_max gives the number of coverable
// items of a coverage type, SV_COV_NOCOV when there is no such coverage, or
// SV_COV_OVERFLOW, and the value does not change during the simulation.
// §40.3.2.3: $coverage_get gives the number of those items covered so far
// (40.2.2), so it is never more than the maximum and, without a reset, never
// decreases. Which items have coverage depends on the tool, so the test prints
// only these relations. A check (40.3.2.1) that finds no coverage goes with a
// maximum of SV_COV_NOCOV, and a check that finds some with a positive maximum
// or SV_COV_OVERFLOW. A module name that does not exist gives SV_COV_ERROR.
// The design has items of every type: an assertion, statements, signals and an
// FSM named by pragmas (40.4), so a tool that has a type of coverage has items
// to count. Between the two samples, at time 1 and time 50, the design runs:
// signals toggle, statements run, the FSM changes state and the assertion
// passes.

module cg_sub(input logic clk, input logic [1:0] d);
  logic [1:0] q = 0;
  /* tool state_vector st enum cg_states */
  logic [1:0] /* tool enum cg_states */ st = 0;
  parameter [1:0] /* tool enum cg_states */ S_A = 0, S_B = 1, S_C = 2;

  always @(posedge clk) q <= d;
  always @(posedge clk) st <= st == S_C ? S_A : st + 1;
  a_q: assert property (@(posedge clk) q == q) else $display("a_q failed");
endmodule

module test_coverage_get_values;
  logic clk = 0;
  logic [1:0] d = 0;
  int max0[4], cur0[4], max1[4], cur1[4], check[4], max_missing[4], cur_missing[4];
  string names[4] = '{"assertion", "FSM state", "statement", "toggle"};

  cg_sub u(.clk(clk), .d(d));

  always #5 clk = ~clk;
  always @(negedge clk) d <= d + 1;

  task automatic expect_ok(int i, string what, bit ok);
    if (ok)
      $display("%s: %s", names[i], what);
    else
      $display("%s: %s: wrong; check %0d, max %0d then %0d, current %0d then %0d", names[i],
               what, check[i], max0[i], max1[i], cur0[i], cur1[i]);
  endtask

`define SAMPLE(max, cur, i, t) \
  max[i] = $coverage_get_max(t, `SV_COV_HIER, test_coverage_get_values); \
  cur[i] = $coverage_get(t, `SV_COV_HIER, test_coverage_get_values);
`define SAMPLE_ALL(max, cur) \
  `SAMPLE(max, cur, 0, `SV_COV_ASSERTION) \
  `SAMPLE(max, cur, 1, `SV_COV_FSM_STATE) \
  `SAMPLE(max, cur, 2, `SV_COV_STATEMENT) \
  `SAMPLE(max, cur, 3, `SV_COV_TOGGLE)
`define MISSING(i, t) \
  max_missing[i] = $coverage_get_max(t, `SV_COV_MODULE, "cg_missing"); \
  cur_missing[i] = $coverage_get(t, `SV_COV_MODULE, "cg_missing");

  initial begin
    #1 `SAMPLE_ALL(max0, cur0)
    #49 `SAMPLE_ALL(max1, cur1)
    check[0] = $coverage_control(`SV_COV_CHECK, `SV_COV_ASSERTION, `SV_COV_HIER,
                                 test_coverage_get_values);
    check[1] = $coverage_control(`SV_COV_CHECK, `SV_COV_FSM_STATE, `SV_COV_HIER,
                                 test_coverage_get_values);
    check[2] = $coverage_control(`SV_COV_CHECK, `SV_COV_STATEMENT, `SV_COV_HIER,
                                 test_coverage_get_values);
    check[3] = $coverage_control(`SV_COV_CHECK, `SV_COV_TOGGLE, `SV_COV_HIER,
                                 test_coverage_get_values);
    `MISSING(0, `SV_COV_ASSERTION)
    `MISSING(1, `SV_COV_FSM_STATE)
    `MISSING(2, `SV_COV_STATEMENT)
    `MISSING(3, `SV_COV_TOGGLE)
    for (int i = 0; i < 4; i++) begin
      expect_ok(i, "maximum is the same at both times", max1[i] == max0[i]);
      expect_ok(i, "maximum agrees with the check",
                check[i] == `SV_COV_NOCOV ? max1[i] == `SV_COV_NOCOV
                : check[i] inside {`SV_COV_OK, `SV_COV_PARTIAL}
                  && (max1[i] > 0 || max1[i] == `SV_COV_OVERFLOW));
      expect_ok(i, "current value is between zero and the maximum",
                max1[i] == `SV_COV_OVERFLOW
                || (cur0[i] >= 0 && cur0[i] <= max1[i] && cur1[i] >= 0 && cur1[i] <= max1[i]));
      expect_ok(i, "current value does not decrease",
                max1[i] == `SV_COV_OVERFLOW || cur1[i] >= cur0[i]);
      expect_ok(i, "missing module gives ERROR",
                max_missing[i] == `SV_COV_ERROR && cur_missing[i] == `SV_COV_ERROR);
    end
    $finish;
  end
endmodule
