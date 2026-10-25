/*
:name: test_if_else_binds_nearest_if
:description: An else goes with the closest earlier if that has no else yet, and a begin-end block around the inner if makes the else belong to the outer if (IEEE 1800-2023 Section 12.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_if_else_binds_nearest_if.expected
*/
// IEEE 1800-2023 §12.4: when an if is nested in another if without a
// begin-end block, a following else is associated with the closest previous
// if that lacks an else, so it belongs to the inner if. Putting the inner if
// in a begin-end block ends it, and the else then belongs to the outer if.
//
// Each task records which statement ran ("-" when none did):
//   plain   - the else follows a nested if: it is the inner if's else, so
//             p=1 q=0 runs it and p=0 runs nothing;
//   grouped - the same with the inner if in begin-end: p=1 q=0 runs nothing
//             and p=0 runs the else;
//   two     - two elses: the first belongs to the inner if, so the second,
//             skipping the inner if that already has an else, belongs to the
//             outer if;
//   three   - three nested ifs and one else: it belongs to the innermost if.

module test_if_else_binds_nearest_if;
  string took;

  task automatic plain(bit p, bit q);
    took = "-";
    if (p)
      if (q) took = "inner-then";
    else took = "else";
    $display("plain   p=%0d q=%0d: %s", p, q, took);
  endtask

  task automatic grouped(bit p, bit q);
    took = "-";
    if (p) begin
      if (q) took = "inner-then";
    end
    else took = "else";
    $display("grouped p=%0d q=%0d: %s", p, q, took);
  endtask

  task automatic two(bit p, bit q);
    took = "-";
    if (p)
      if (q) took = "inner-then";
      else took = "first-else";
    else took = "second-else";
    $display("two     p=%0d q=%0d: %s", p, q, took);
  endtask

  task automatic three(bit p, bit q, bit r);
    took = "-";
    if (p)
      if (q)
        if (r) took = "innermost-then";
    else took = "else";
    $display("three   p=%0d q=%0d r=%0d: %s", p, q, r, took);
  endtask

  initial begin
    plain(1, 1);
    plain(1, 0);
    plain(0, 1);
    plain(0, 0);
    grouped(1, 1);
    grouped(1, 0);
    grouped(0, 1);
    grouped(0, 0);
    two(1, 1);
    two(1, 0);
    two(0, 0);
    three(1, 1, 0);
    three(1, 0, 0);
    three(0, 0, 0);
  end
endmodule
