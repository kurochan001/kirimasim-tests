/*
:name: test_solve_before_changes_distribution
:description: solve a, b before c makes a and b uniform over their legal values without considering c, which changes the probability of a from the unordered legal-combination distribution, and the comma-separated list does not order a against b (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_changes_distribution.expected
*/
// IEEE 1800-2023 §18.5.9: solve a, b before c orders both a and b before c
// but does not order a against b; the ordered variables are chosen without
// considering the lower-priority constraint, and the variables of a comma
// list have no order among themselves. In ob_obj, a bit a selects whether c
// must equal b: a -> (c == b). The six legal combinations without an order
// are four with a == 0 and two with a == 1, so the probability of a == 1 is
// 2/6; with solve a, b before c, a is chosen 0 or 1 with equal probability, so
// a == 1 is 1/2. In cb_obj the constraint a <= b leaves the three pairs 00,
// 01 and 11; without an order between a and b they are equally likely, while
// an order a before b would make 11 twice as likely as 00. The pass and fail
// actions count calls; the counts are printed as ranges, not as exact values.
// The 5.052 release of Verilator does not change the distribution for solve
// before, so the probability checks fail there.

class ob_obj;
  rand bit a, b, c;

  constraint c_value {
    a -> (c == b);
  }

  constraint c_order {
    solve a, b before c;
  }
endclass

class cb_obj;
  rand bit a, b, c;

  constraint c_value {
    a <= b;
  }

  constraint c_order {
    solve a, b before c;
  }
endclass

module test_solve_before_changes_distribution;
  ob_obj oo = new;
  cb_obj co = new;
  int a1, calls, failures, n00, n01, n11, bad;

  initial begin
    a1 = 0;
    calls = 0;
    failures = 0;
    repeat (1600) begin
      if (!oo.randomize()) failures++;
      else begin
        calls++;
        if (oo.a) a1++;
      end
    end
    $display("a == 1 in 44..56%% %0d, failures %0d",
             a1 * 100 >= 44 * calls && a1 * 100 <= 56 * calls, failures);
    n00 = 0;
    n01 = 0;
    n11 = 0;
    failures = 0;
    repeat (1600) begin
      if (!co.randomize()) failures++;
      else if (co.a == 0 && co.b == 0) n00++;
      else if (co.a == 0 && co.b == 1) n01++;
      else if (co.a == 1 && co.b == 1) n11++;
    end
    bad = n00 > n11 - 120 && n00 < n11 + 120 && n01 > 0;
    $display("00 and 11 within 120 %0d, 01 seen %0d, failures %0d",
             bad, n01 > 0, failures);
  end
endmodule
