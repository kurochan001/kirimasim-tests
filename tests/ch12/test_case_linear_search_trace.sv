/*
:name: test_case_linear_search_trace
:description: A case statement evaluates its case expression once and first, then evaluates and compares its item expressions in source order, skips a default written first, runs the first matching item and stops; with no match it runs the default, or nothing without one (IEEE 1800-2023 Section 12.5)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_case_linear_search_trace.expected
*/
// IEEE 1800-2023 §12.5: the case expression is evaluated exactly once, before
// any case item expression. The item expressions are then evaluated and
// compared in the exact order in which they appear, also within an item
// that lists several, and the default item takes no part in this search
// wherever it is written. The first match runs its statement and ends the
// search. If nothing matches, the default statement runs; without a default,
// no statement runs.
//
// The case expression ctl() appends "C" to the trace, and each item
// expression item(k) appends k, so the trace shows every evaluation in
// order. Item 2 appears twice: its second item can never be the first match.
//
// Simulator note: in a run with Verilator 5.052 the trace for v=1 is
// C123241, so every item expression is evaluated before the search (and
// item(1) once more), against the order and the end of the search that
// 12.5 requires.

module test_case_linear_search_trace;
  string trace;
  string took;
  int v;

  function automatic int ctl();
    trace = {trace, "C"};
    return v;
  endfunction

  function automatic int item(int k);
    trace = {trace, $sformatf("%0d", k)};
    return k;
  endfunction

  task automatic with_default(int value);
    v = value;
    trace = "";
    took = "none";
    case (ctl())
      default: took = "default";
      item(1), item(2): took = "one or two";
      item(3): took = "three";
      item(2): took = "second two";
      item(4): took = "four";
    endcase
    $display("with default    v=%0d: trace %s took %s", value, trace, took);
  endtask

  task automatic without_default(int value);
    v = value;
    trace = "";
    took = "none";
    case (ctl())
      item(5): took = "five";
      item(6), item(7): took = "six or seven";
    endcase
    $display("without default v=%0d: trace %s took %s", value, trace, took);
  endtask

  initial begin
    with_default(1);
    with_default(2);
    with_default(3);
    with_default(4);
    with_default(9);
    without_default(7);
    without_default(9);
  end
endmodule
