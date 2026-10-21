/*
:name: test_dist_default_weight
:description: The default item of a dist covers the values that no other item lists, and its weight applies to them (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_default_weight.expected
*/
// IEEE 1800-2023 §18.5.3: default :/ w stands for every value of the type of
// the expression that no other item lists, with the weight w spread over them.
// With default :/ 0 those values are never chosen, so x stays in [0:3]; with 5
// := 0 and default :/ 1, y can take any value but 5. The test counts the
// results of 100 calls that break this.
// Neither Icarus Verilog 13.0 nor Verilator 5.052 supports this construct of
// IEEE 1800-2023.

class test_dist_default_weight_c;
  rand bit [7:0] x;
  rand bit [7:0] y;
  constraint cx { x dist {[0:3] :/ 1, default :/ 0}; }
  constraint cy { y dist {5 := 0, default :/ 1}; }
endclass

module test_dist_default_weight;
  test_dist_default_weight_c o = new;
  int x_outside = 0, y_five = 0, failed = 0;
  initial begin
    repeat (100) begin
      if (!o.randomize()) failed++;
      if (o.x > 3) x_outside++;
      if (o.y == 5) y_five++;
    end
    $display("failed=%0d x outside [0:3]=%0d y equal to 5=%0d", failed, x_outside, y_five);
  end
endmodule
