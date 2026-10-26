/*
:name: test_expr_inside_set_forms
:description: inside scans values, colon ranges, unbounded and tolerance ranges, treats a reversed range as empty, and uses wildcard equality for integral members and 1, 0 or x results (IEEE 1800-2023 11.4.13)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.13
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_expr_inside_set_forms.expected
*/
// IEEE 1800-2023 §11.4.13: the set is a comma-separated list of singular
// values and ranges, an unpacked array member is descended into, and the
// comparison uses == for nonintegral and ==? for integral members, so an x or
// z bit in a member is a do-not-care but one in the left operand is not. A
// colon range includes both bounds and is empty when its left bound is larger.
// $ is the lowest or highest value of the left operand's type. [A +/- B] is
// A - B to A + B, and [A +%- B] is A plus or minus B percent of A, in the type
// of A: for the integral 7 a 25 percent tolerance is truncated to 1, giving
// [6:8], while for the real 7.0 it stays [5.25:8.75]. No match with an x
// comparison gives x. Neither release simulated here supports the whole
// construct, so the expected output follows the clauses.

module test_expr_inside_set_forms;
  int v;
  int arr [3];
  logic [3:0] w;

  initial begin
    arr[0] = 3;
    arr[1] = 4;
    arr[2] = 5;
    v = 7;
    $display("colon_in=%0d", v inside {[5:9]});
    v = 10;
    $display("colon_out=%0d", v inside {[5:9]});
    v = -7;
    $display("neg=%0d", v inside {[-8:-6]});
    v = 5;
    $display("abs_in=%0d", v inside {[7 +/- 2]});
    v = 10;
    $display("abs_out=%0d", v inside {[7 +/- 2]});
    v = 5;
    $display("rel_low=%0d", v inside {[7 +%- 25]});
    v = 6;
    $display("rel_in=%0d", v inside {[7 +%- 25]});
    v = 8;
    $display("rel_high=%0d", v inside {[7 +%- 25]});
    v = -8;
    $display("rel_neg=%0d", v inside {[-7 +%- 25]});
    v = -9;
    $display("rel_neg_out=%0d", v inside {[-7 +%- 25]});
    $display("real_in=%0d", 5.3 inside {[7.0 +%- 25]});
    $display("real_out=%0d", 5.2 inside {[7.0 +%- 25]});
    v = 6;
    $display("arr_out=%0d", v inside {1, 2, arr});
    v = 3;
    $display("arr_in=%0d", v inside {1, 2, arr});
    v = 3;
    $display("dollar_low=%0d", v inside {[$:3]});
    v = 4;
    $display("dollar_low_out=%0d", v inside {[$:3]});
    v = 3;
    $display("dollar_high=%0d", v inside {[3:$]});
    v = 2;
    $display("dollar_high_out=%0d", v inside {[3:$]});
    v = 7;
    $display("reversed=%0d", v inside {[9:5]});
    w = 4'b10x1;
    $display("wild_in=%0d", w inside {4'b10?1});
    $display("wild_x=%b", w inside {4'b1?11});
    $finish;
  end
endmodule
