/*
:name: test_dist_default_complement
:description: The default item of a distribution covers exactly the values of the expression's self-determined type that no other item names, so 0 and 1 are not counted twice, and every value outside the named items can be chosen (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_default_complement.expected
*/
// IEEE 1800-2023 §18.5.3: a dist item default :/ weight denotes all the values
// of the self-determined type of the expression that are not present in
// another item. x is a 4-bit variable, and the items are 0 := 1, 1 := 1 and
// default :/ 100. The default therefore holds the 14 values 2 to 15 with the
// total weight 100, and 0 and 1 have weight 1 each, so x is 0 or 1 in 2 of 102
// samples, about 63 of 3200. A tool that adds 0 and 1 to the default gives the
// whole 16-value range the weight 100, so x is 0 or 1 in about 454 samples;
// the range below excludes that. The test also counts the values 0 to 15 that
// were seen and the samples outside 0 to 15, which must be none.
// The 5.052 release of Verilator does not support a default item in a
// distribution, so the expected values come from the cited clause.

class dd_obj;
  rand bit [3:0] x;
  constraint c {
    x dist { 0 := 1, 1 := 1, default :/ 100 };
  }
endclass

module test_dist_default_complement;
  dd_obj o = new;
  int low, failures, seen[16], outside, all_seen;

  initial begin
    low = 0;
    failures = 0;
    outside = 0;
    foreach (seen[i]) seen[i] = 0;
    repeat (3200) begin
      if (!o.randomize()) failures++;
      else begin
        if (o.x <= 1) low++;
        if (o.x > 15) outside++;
        else seen[o.x]++;
      end
    end
    all_seen = 1;
    foreach (seen[i]) if (seen[i] == 0) all_seen = 0;
    $display("x <= 1 in 40..100 %0d, failures %0d, outside %0d",
             low >= 40 && low <= 100, failures, outside);
    $display("all 16 values seen %0d", all_seen);
  end
endmodule
