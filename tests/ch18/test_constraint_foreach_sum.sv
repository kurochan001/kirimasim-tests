/*
:name: test_constraint_foreach_sum
:description: foreach constraints on the elements of an array and an array reduction in a constraint (IEEE 1800-2023 Section 18.5.7.1)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.1 18.5.7.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_foreach_sum.expected
*/
// IEEE 1800-2023 §18.5.7.1: a foreach constraint applies to every element of an
// array, and its loop index can compare neighbouring elements. §18.5.7.2: an
// array reduction such as sum() is a constraint on the sum of the elements,
// computed in the type given by with, so the 8-bit elements are summed as int.

class cfs_obj;
  rand bit [7:0] a[5];
  constraint c_range  { foreach (a[i]) a[i] inside {[1:10]}; }
  constraint c_sorted { foreach (a[i]) if (i > 0) a[i] >= a[i - 1]; }
  constraint c_sum    { a.sum() with (int'(item)) == 20; }
endclass

module test_constraint_foreach_sum;
  cfs_obj o;
  int bad = 0;
  int s;

  initial begin
    o = new;
    repeat (100) begin
      void'(o.randomize());
      s = 0;
      foreach (o.a[i]) begin
        s += o.a[i];
        if (!(o.a[i] inside {[1:10]})) bad++;
        if (i > 0 && o.a[i] < o.a[i - 1]) bad++;
      end
      if (s != 20) bad++;
    end
    $display("violations=%0d", bad);
  end
endmodule
