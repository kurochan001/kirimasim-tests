/*
:name: test_product_constraint_zero_factor
:description: Two product constraints apply different projections to the same zero factor (IEEE 1800-2023 Section 18.5.7.2)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.7.2 7.12.3 18.6.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_product_constraint_zero_factor.expected
*/
// For [3, 0, x] with x positive, the two products are 0 and 3*x. Each
// reduction uses its own with expression (18.5.7.2, 7.12.3). Contradict
// each one separately and check that failure preserves x (18.6.3).
class zero_factor_box;
  rand bit [3:0] data[3];
  int raw_target, projected_target;
  constraint c {
    data[0] == 3;
    data[1] == 0;
    data[2] inside {[1:15]};
    data.product() with (int'(item)) == raw_target;
    data.product() with (item == 0 ? 1 : int'(item)) == projected_target;
  }
endclass

module test_product_constraint_zero_factor;
  zero_factor_box box_to_solve;
  task automatic attempt(input int raw_target, input int projected_target);
    int ok;
    box_to_solve.raw_target = raw_target;
    box_to_solve.projected_target = projected_target;
    ok = box_to_solve.randomize();
    $display("raw=%0d projected=%0d ok=%0d values=%0d,%0d,%0d",
             raw_target, projected_target, ok,
             box_to_solve.data[0], box_to_solve.data[1], box_to_solve.data[2]);
  endtask

  initial begin
    box_to_solve = new;
    attempt(0, 15);
    attempt(15, 15);
    attempt(0, 0);
    attempt(0, 21);
    $finish;
  end
endmodule
