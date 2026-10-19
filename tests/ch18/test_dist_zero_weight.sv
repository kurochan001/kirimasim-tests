/*
:name: test_dist_zero_weight
:description: A dist constraint allows only the values in its list and never picks a value of weight zero (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_zero_weight.expected
*/
// IEEE 1800-2023 §18.5.3: v dist { ... } is true only when v is one of the
// values or ranges in the list, so values outside the list are never chosen.
// Absent other constraints, the probability of each item is proportional to its
// weight, so an item of weight zero is never chosen either. := gives the weight
// to each value of a range, :/ divides it among them.

class dzw_obj;
  rand bit [3:0] v;
  constraint c { v dist { 0 := 0, [1:3] := 2, [8:9] :/ 3, 15 :/ 0 }; }
endclass

module test_dist_zero_weight;
  dzw_obj o;
  int outside = 0;
  int zero_weight = 0;

  initial begin
    o = new;
    repeat (300) begin
      void'(o.randomize());
      if (!(o.v inside {[0:3], [8:9], 15})) outside++;
      if (o.v == 0 || o.v == 15) zero_weight++;
    end
    $display("values outside the list: %0d, values of weight zero: %0d", outside, zero_weight);
  end
endmodule
