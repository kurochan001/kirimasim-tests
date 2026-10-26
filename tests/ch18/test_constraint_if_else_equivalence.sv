/*
:name: test_constraint_if_else_equivalence
:description: An if-else constraint is equivalent to the corresponding implications, so the condition and the selected constraint set constrain each other, a set groups several constraints, and the solution probabilities follow the sizes of the two sets (IEEE 1800-2023 Section 18.5.6)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.6 18.5.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_if_else_equivalence.expected
*/
// IEEE 1800-2023 §18.5.6: if (e) { ... } else { ... } is equivalent to the
// implications e -> first set and !e -> second set; the condition and the set
// are interdependent, and a set may group several constraints. §18.5.9: the
// legal value combinations are equally likely. mode is a bit, len has the
// values 0 to 9, and other is a bit. mode selects len < 2 with other == 1, and
// !mode selects len > 4 with other == 0. The seven legal combinations are
// (1, 0, 1), (1, 1, 1), and the five (0, 5, 0) to (0, 9, 0), so mode is 1 in
// two of seven of 1400 calls, about 400. A tool that picks the branch with
// equal probability would make mode 1 about 700 times, and a tool that does
// not let len constrain mode fails the call with len == 1 or len == 8. The
// four counts below show that the bidirectional constraint and the grouped
// set work as the implication form requires.
// The 5.052 release of Verilator follows the distribution here.

class ie_obj;
  rand bit mode;
  rand int len;
  rand bit other;

  constraint c_if {
    if (mode) {
      len >= 0;
      len < 2;
      other == 1;
    } else {
      len > 4;
      len < 10;
      other == 0;
    }
  }
endclass

module test_constraint_if_else_equivalence;
  ie_obj o = new;
  int mode1, calls, failures, bad, forced1, forced0, other_bad;

  initial begin
    mode1 = 0;
    failures = 0;
    bad = 0;
    calls = 0;
    repeat (1400) begin
      if (!o.randomize()) failures++;
      else begin
        calls++;
        if (o.mode) mode1++;
        if (o.mode != (o.len < 2)) bad++;
        if (o.other != o.mode) other_bad++;
      end
    end
    forced1 = o.randomize() with { len == 1; };
    forced1 = forced1 && o.mode == 1 && o.other == 1;
    forced0 = o.randomize() with { len == 8; };
    forced0 = forced0 && o.mode == 0 && o.other == 0;
    $display("mode 1 in 340..460 %0d, failures %0d, illegal %0d",
             mode1 >= 340 && mode1 <= 460, failures, bad + other_bad);
    $display("len 1 forces mode 1 %0d, len 8 forces mode 0 %0d",
             forced1, forced0);
  end
endmodule
