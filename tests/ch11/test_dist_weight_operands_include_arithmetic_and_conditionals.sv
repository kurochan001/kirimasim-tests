/*
:name: test_dist_weight_operands_include_arithmetic_and_conditionals
:description: Both distribution weight operators consume full arithmetic and conditional expressions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 18.5.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_weight_operands_include_arithmetic_and_conditionals.expected
*/
class disjoint_weight_mode;
  rand int pick_value;
  bit select_range;
  constraint allowed_choices {
    pick_value dist {
      3 := select_range ? 0 : 6 - 2 * 2,
      [8:8] :/ select_range ? 6 / (1 + 1) : 0
    };
  }
endclass

module test_dist_weight_operands_include_arithmetic_and_conditionals;
  initial begin
    disjoint_weight_mode selection;
    int ok;
    selection = new;
    for (int mode = 0; mode < 3; mode++) begin
      selection.select_range = mode[0];
      ok = selection.randomize();
      $display("mode=%0d ok=%0d choice=%0d", mode[0], ok, selection.pick_value);
    end
    $finish(0);
  end
endmodule
