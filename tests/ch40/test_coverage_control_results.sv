/*
:name: test_coverage_control_results
:description: $coverage_control returns what Table 40-1 allows for each control: a check gives the coverage availability, a start the same result, a stop and a reset success, repeated calls the same result, and a module name that does not exist an error (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_control_results.expected
*/
// IEEE 1800-2023 §40.3.2.1: which parts of a design have coverage depends on
// the tool and its options, so the test prints only what holds for every
// result. For each coverage type, a check of the whole hierarchy under this
// module gives SV_COV_OK, SV_COV_NOCOV or SV_COV_PARTIAL (Table 40-1). A start
// returns the same three values with the same meanings, so it gives what the
// check gave, and starting again has no effect. A stop and a reset can only
// succeed or fail on bad arguments, so with good arguments they give
// SV_COV_OK, also when repeated. The availability does not change by stopping
// coverage, so a later check gives the same result. A check of a module
// definition by name (SV_COV_MODULE) also gives one of the three values, and a
// module name that does not exist gives SV_COV_ERROR.

module cc_sub(input logic d);
  logic q;
  always @(d) q = d;
endmodule

module test_coverage_control_results;
  logic d = 0;

  cc_sub u(.d(d));

  task automatic expect_ok(string name, string what, bit ok, int got);
    if (ok)
      $display("%s: %s", name, what);
    else
      $display("%s: %s: wrong, got %0d", name, what, got);
  endtask

  task automatic check_type(string name, int check, int start, int start2, int stop, int stop2,
                            int reset, int check2, int by_def, int missing);
    expect_ok(name, "check gives OK, NOCOV or PARTIAL",
              check inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL}, check);
    expect_ok(name, "start gives the check result", start == check, start);
    expect_ok(name, "second start gives the same", start2 == check, start2);
    expect_ok(name, "stop gives OK", stop == `SV_COV_OK, stop);
    expect_ok(name, "second stop gives OK", stop2 == `SV_COV_OK, stop2);
    expect_ok(name, "reset gives OK", reset == `SV_COV_OK, reset);
    expect_ok(name, "check after stop gives the same", check2 == check, check2);
    expect_ok(name, "check of module cc_sub gives OK, NOCOV or PARTIAL",
              by_def inside {`SV_COV_OK, `SV_COV_NOCOV, `SV_COV_PARTIAL}, by_def);
    expect_ok(name, "check of a missing module gives ERROR", missing == `SV_COV_ERROR, missing);
  endtask

  int r[9];

  // The calls are made one by one, in this order, because the order in which
  // the arguments of a task call are evaluated is not fixed.
`define CONTROL(op, t) $coverage_control(op, t, `SV_COV_HIER, test_coverage_control_results)
`define CHECK_TYPE(name, t) \
  r[0] = `CONTROL(`SV_COV_CHECK, t); \
  r[1] = `CONTROL(`SV_COV_START, t); \
  r[2] = `CONTROL(`SV_COV_START, t); \
  r[3] = `CONTROL(`SV_COV_STOP, t); \
  r[4] = `CONTROL(`SV_COV_STOP, t); \
  r[5] = `CONTROL(`SV_COV_RESET, t); \
  r[6] = `CONTROL(`SV_COV_CHECK, t); \
  r[7] = $coverage_control(`SV_COV_CHECK, t, `SV_COV_MODULE, "cc_sub"); \
  r[8] = $coverage_control(`SV_COV_CHECK, t, `SV_COV_MODULE, "cc_missing"); \
  check_type(name, r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8]);

  initial begin
    #1 d = 1;
    #1;
    `CHECK_TYPE("assertion", `SV_COV_ASSERTION)
    `CHECK_TYPE("FSM state", `SV_COV_FSM_STATE)
    `CHECK_TYPE("statement", `SV_COV_STATEMENT)
    `CHECK_TYPE("toggle", `SV_COV_TOGGLE)
  end
endmodule
