/*
:name: test_product_constraint_signed_singleton
:description: A singleton product constraint applies its signed with expression at int width (IEEE 1800-2023 Section 18.5.7.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.2 7.12.3 18.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_product_constraint_signed_singleton.expected
*/
// A one-element product is exactly the projected element (18.5.7.2, 7.12.3).
// Subtracting one after sign extension maps the four-bit range -8..7 to
// -9..6. An impossible target must retain the preceding solution (18.6.3).
// At seeds 1 and 73, Verilator 5.054 reports failure for the first target
// and leaves the dynamic array empty.
class singleton_box;
  rand bit signed [3:0] data[];
  int target;
  constraint c {
    data.size() == 1;
    data.product() with (int'(item) - 1) == target;
  }
endclass

module test_product_constraint_signed_singleton;
  singleton_box box_to_solve;
  task automatic attempt(input int target);
    int ok;
    box_to_solve.target = target;
    ok = box_to_solve.randomize();
    $display("target=%0d ok=%0d size=%0d value=%0d",
             target, ok, box_to_solve.data.size(), $signed(box_to_solve.data[0]));
  endtask

  initial begin
    box_to_solve = new;
    attempt(-9);
    attempt(7);
    attempt(6);
    $finish;
  end
endmodule
