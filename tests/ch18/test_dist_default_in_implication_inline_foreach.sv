/*
:name: test_dist_default_in_implication_inline_foreach
:description: A distribution with a default item works under an implication, where its zero weights constrain only while the condition holds, in an inline constraint of randomize() with, where the default item may come first, and in a foreach constraint over the elements of an array (IEEE 1800-2023 Sections 18.5.3, 18.5.5, 18.5.7.1, 18.7)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3 18.5.5 18.5.7.1 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_default_in_implication_inline_foreach.expected
*/
// IEEE 1800-2023 §18.5.3: default :/ w stands for the values of the type of
// the dist expression that no other item names; a dist item is either a value
// range or the default, in any position of the list, and values whose total
// weight is zero shall not be taken. §18.5.5: an implication applies its
// constraints only when its condition holds. §18.5.7.1: foreach applies a
// constraint to each element, with the loop index as a constant. §18.7:
// randomize() with adds inline constraints.
// - x dist { [0:1] :/ 1, default :/ 0 } applies when mode is 1, so with
//   mode == 1 x is always 0 or 1; with mode == 0 and x > 13 the zero weight
//   does not apply and x is 14 or 15.
// - The inline dist { default :/ 1, 5 :/ 0 } names 5 with weight zero, so x is
//   never 5 in 100 calls.
// - Each arr[i] (3 bits) dist { i :/ 1, default :/ 0 } can only be i.
// The test counts the calls that fail and the results that break these rules.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports a
// default item, so the expected output follows the cited clauses.

class dd_mix_c;
  rand bit mode;
  rand bit [3:0] x;
  rand bit [2:0] arr[4];
  constraint c_mode { mode -> x dist { [0:1] :/ 1, default :/ 0 }; }
  constraint c_arr { foreach (arr[i]) arr[i] dist { i :/ 1, default :/ 0 }; }
endclass

module test_dist_default_in_implication_inline_foreach;
  dd_mix_c o = new;
  int failed, bad;

  initial begin
    failed = 0;
    bad = 0;
    repeat (100) begin
      if (!o.randomize() with { mode == 1; }) failed++;
      else if (o.x > 1) bad++;
    end
    $display("mode 1: failed=%0d x above 1=%0d", failed, bad);
    failed = 0;
    bad = 0;
    repeat (100) begin
      if (!o.randomize() with { mode == 0; x > 13; }) failed++;
      else if (o.x < 14) bad++;
    end
    $display("mode 0, x > 13: failed=%0d x below 14=%0d", failed, bad);
    failed = 0;
    bad = 0;
    repeat (100) begin
      if (!o.randomize() with { mode == 0; x dist { default :/ 1, 5 :/ 0 }; }) failed++;
      else if (o.x == 5) bad++;
    end
    $display("inline default first: failed=%0d x equal to 5=%0d", failed, bad);
    bad = 0;
    foreach (o.arr[i]) if (o.arr[i] != i) bad++;
    $display("foreach: elements not equal to their index=%0d", bad);
  end
endmodule
