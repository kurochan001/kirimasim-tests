/*
:name: test_dist_default_only_and_conflicts
:description: A distribution whose only item is default :/ with a nonzero weight allows every value of the type, and with weight 0 allows none, so randomize() fails; a nonzero default keeps the values outside the other items solvable under another constraint, while without a default or with default :/ 0 they are excluded (IEEE 1800-2023 Section 18.5.3)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.3 18.6.3 18.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_default_only_and_conflicts.expected
*/
// IEEE 1800-2023 §18.5.3: dist is true when its expression is in the set of
// its items; default stands for every value of the self-determined type of the
// expression that no other item names, with the weight given after :/.
// Values not named by the distribution and values of total weight zero are a
// constraint: the expression shall not have them. Nonzero weights never make
// the solver fail. §18.6.3: when randomize() fails it returns 0 and the random
// variables keep their values.
// - only1: x (2 bits) dist { default :/ 1 } holds every value, so each of the
//   4 values can be asked for with an inline constraint (§18.7) and is given.
// - only0: dist { default :/ 0 } gives all 4 values the weight zero, so no
//   value is allowed: randomize() returns 0 and x keeps the 2 set before.
// - def1: y (4 bits) dist { [0:3] :/ 1, default :/ 1 } with y > 3 is solved by
//   the default values 4 to 15; all 100 calls succeed with y above 3.
// - none and def0: without a default, or with default :/ 0, the values above
//   3 are excluded, so y > 3 cannot hold and randomize() returns 0.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports a
// default item, so the expected output follows the cited clauses.

class only1_c;
  rand bit [1:0] x;
  constraint c { x dist { default :/ 1 }; }
endclass

class only0_c;
  rand bit [1:0] x;
  constraint c { x dist { default :/ 0 }; }
endclass

class def1_c;
  rand bit [3:0] y;
  constraint c { y dist { [0:3] :/ 1, default :/ 1 }; y > 3; }
endclass

class none_c;
  rand bit [3:0] y;
  constraint c { y dist { [0:3] :/ 1 }; y > 3; }
endclass

class def0_c;
  rand bit [3:0] y;
  constraint c { y dist { [0:3] :/ 1, default :/ 0 }; y > 3; }
endclass

module test_dist_default_only_and_conflicts;
  only1_c o1 = new;
  only0_c o0 = new;
  def1_c d1 = new;
  none_c dn = new;
  def0_c d0 = new;
  int ok, low;

  initial begin
    ok = 0;
    for (int k = 0; k < 4; k++)
      if (o1.randomize() with { x == k; } && o1.x == k) ok++;
    $display("only1: values allowed=%0d", ok);
    o0.x = 2;
    $display("only0: ok=%0d x=%0d", o0.randomize(), o0.x);
    ok = 0;
    low = 0;
    repeat (100) begin
      if (d1.randomize()) begin
        ok++;
        if (d1.y <= 3) low++;
      end
    end
    $display("def1: ok=%0d at most 3=%0d", ok, low);
    $display("none: ok=%0d", dn.randomize());
    $display("def0: ok=%0d", d0.randomize());
  end
endmodule
