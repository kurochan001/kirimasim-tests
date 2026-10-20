/*
:name: test_coverage_reset_and_stop
:description: Right after $coverage_control resets toggle coverage its current value is zero, and while coverage is stopped, toggles and new statements do not raise the current values (IEEE 1800-2023 Section 40.3.2.1)
:tags: ch40
:type: simulation
:lrm: 1800-2023 40.3.2.1 40.3.2.3 40.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_coverage_reset_and_stop.expected
*/
// IEEE 1800-2023 §40.3.2.1: `SV_COV_RESET clears all available coverage of
// the hierarchy and `SV_COV_STOP stops collecting it. So toggle coverage read
// with $coverage_get (40.3.2.3) right after a reset, before any signal
// changes, is zero, and while coverage is stopped neither the bits of t
// toggling (toggle coverage, 40.2.2) nor statements that never ran before
// (statement coverage) raise the values. This holds whether or not the tool
// collects these kinds of coverage, as a value of NOCOV is zero too; the
// values are read only after the controls, so that no statement that is still
// counted runs between them.

module test_coverage_reset_and_stop;
  logic [7:0] t = 8'h00;
  int r, toggle0, toggle1, statement0, statement1, extra;

  task new_statements;
    extra = 1;
    extra = extra + 2;
    t = 8'hff;
    t = 8'h00;
  endtask

  initial begin
    t = 8'hff;
    t = 8'h00;
    r = $coverage_control(`SV_COV_RESET, `SV_COV_TOGGLE, `SV_COV_HIER,
                          test_coverage_reset_and_stop);
    toggle0 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_reset_and_stop);
    $display("toggle coverage right after a reset: %0d", toggle0);
    r = $coverage_control(`SV_COV_STOP, `SV_COV_TOGGLE, `SV_COV_HIER,
                          test_coverage_reset_and_stop);
    r = $coverage_control(`SV_COV_STOP, `SV_COV_STATEMENT, `SV_COV_HIER,
                          test_coverage_reset_and_stop);
    toggle0 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_reset_and_stop);
    statement0 = $coverage_get(`SV_COV_STATEMENT, `SV_COV_HIER, test_coverage_reset_and_stop);
    new_statements;
    toggle1 = $coverage_get(`SV_COV_TOGGLE, `SV_COV_HIER, test_coverage_reset_and_stop);
    statement1 = $coverage_get(`SV_COV_STATEMENT, `SV_COV_HIER, test_coverage_reset_and_stop);
    $display("toggle coverage unchanged while stopped: %s",
             toggle1 == toggle0 ? "yes" : "no");
    $display("statement coverage unchanged while stopped: %s",
             statement1 == statement0 ? "yes" : "no");
  end
endmodule
