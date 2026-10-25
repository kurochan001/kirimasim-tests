/*
:name: test_unique_case_evaluates_every_item
:description: A unique-case and a unique0-case evaluate their case expression once, before any item expression, and go on evaluating item expressions after finding a match, so every item is evaluated when one item matches (IEEE 1800-2023 Section 12.5.3)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unique_case_evaluates_every_item.expected
*/
// IEEE 1800-2023 §12.5.3: in a unique-case or unique0-case the case
// expression is evaluated exactly once and before any case item expression.
// The item expressions may be evaluated and compared in any order, but the
// implementation shall continue after finding a matching item, to see
// whether another one matches; only after finding a violation may it stop.
//
// ctl() counts its evaluations in nctl. Each item expression item(k) sets
// bit k of "seen" and stores in at[k] the value of nctl when it ran, so
// at[k] is 1 for every item when the case expression was evaluated once and
// first. At most one item matches each time, so there is no overlap; the
// unique-case has a default, so no violation report is due when nothing
// matches, and a unique0-case reports nothing then. The output shows the
// set of evaluated items, not their order.
//
// Simulator note: Icarus Verilog 13.0 says that it ignores unique and
// unique0 on a case and stops at the first match (seen=001 for v=1), which
// 12.5.3 does not allow.

module test_unique_case_evaluates_every_item;
  int v;
  int nctl;
  bit [3:1] seen;
  int at [1:3];
  string took;

  function automatic int ctl();
    nctl++;
    return v;
  endfunction

  function automatic int item(int k);
    seen[k] = 1'b1;
    at[k] = nctl;
    return k;
  endfunction

  task automatic show(string kind);
    $display("%s v=%0d: ctl evaluated %0d time(s), seen=%b, nctl at items %0d %0d %0d, took %s",
             kind, v, nctl, seen, at[1], at[2], at[3], took);
  endtask

  task automatic clear(int value);
    v = value;
    nctl = 0;
    seen = '0;
    foreach (at[i]) at[i] = -1;
  endtask

  task automatic run_unique(int value);
    clear(value);
    unique case (ctl())
      item(1): took = "1";
      item(2): took = "2";
      item(3): took = "3";
      default: took = "default";
    endcase
    show("unique ");
  endtask

  task automatic run_unique0(int value);
    clear(value);
    took = "none";
    unique0 case (ctl())
      item(1): took = "1";
      item(2): took = "2";
      item(3): took = "3";
    endcase
    show("unique0");
  endtask

  initial begin
    run_unique(1);
    run_unique(2);
    run_unique(9);
    run_unique0(1);
    run_unique0(9);
  end
endmodule
