/*
:name: test_unique_if_evaluates_every_condition
:description: A unique-if and a unique0-if go on evaluating their conditions after finding a true one, so every condition is evaluated when exactly one is true, and the statement of that condition runs (IEEE 1800-2023 Section 12.4.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_if_evaluates_every_condition.expected
*/
// IEEE 1800-2023 §12.4.2: in a unique-if or unique0-if the conditions may be
// evaluated and compared in any order, but the implementation shall continue
// the evaluations after finding a true condition, so that it can see an
// overlap. Only after finding a violation may it stop.
//
// Each condition is a call cond(id, value), which sets bit id of "seen", so
// the output shows which conditions were evaluated but not in which order.
// At most one condition is true in every chain, so there is no overlap; the
// unique chains end with an else, so no violation report is due when none
// is true, and a unique0-if reports nothing then (12.4.2). Whatever the
// order, all three conditions have to be evaluated (seen=111), also when the
// first one is the true one.

module test_unique_if_evaluates_every_condition;
  bit [3:1] seen;
  string took;

  function automatic bit cond(int id, bit value);
    seen[id] = 1'b1;
    return value;
  endfunction

  task automatic run_unique(bit a, bit b, bit c);
    seen = '0;
    unique if (cond(1, a)) took = "s1";
    else if (cond(2, b)) took = "s2";
    else if (cond(3, c)) took = "s3";
    else took = "else";
    $display("unique  %b%b%b: seen=%b took %s", a, b, c, seen, took);
  endtask

  task automatic run_unique0(bit a, bit b, bit c);
    seen = '0;
    took = "none";
    unique0 if (cond(1, a)) took = "s1";
    else if (cond(2, b)) took = "s2";
    else if (cond(3, c)) took = "s3";
    $display("unique0 %b%b%b: seen=%b took %s", a, b, c, seen, took);
  endtask

  initial begin
    run_unique(1, 0, 0);
    run_unique(0, 1, 0);
    run_unique(0, 0, 1);
    run_unique(0, 0, 0);
    run_unique0(1, 0, 0);
    run_unique0(0, 1, 0);
    run_unique0(0, 0, 0);
  end
endmodule
