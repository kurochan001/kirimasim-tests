/*
:name: test_implication_constrains_condition
:description: An implication also constrains its condition, which is false whenever its constraint set cannot hold, its right side can be a constraint set in braces, and a false condition leaves the variables unconstrained (IEEE 1800-2023 Section 18.5.5)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.5 18.7 18.6.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_implication_constrains_condition.expected
*/
// IEEE 1800-2023 §18.5.5: c -> s means !c || s, and both sides are solved
// together: when the inline constraint of randomize() with (18.7) keeps the
// constraint set s from holding, the solver has to make c false. Here
// mode -> v == 9 with v != 9 makes mode 0 in every call, and
// kind == 1 -> { ... } with len == 5 makes kind other than 1. The right side
// can be a set of constraints in braces, which together leave len only the
// value 102 when kind is 1. With a false condition the implication does not
// constrain v, so v can be 3; with a true one it can not, and randomize()
// fails and leaves v as it was (18.6.3).

class icc_obj;
  rand bit mode;
  rand bit [3:0] v;
  rand bit [1:0] kind;
  rand bit [7:0] len;
  constraint c_mode { mode -> v == 4'd9; }
  constraint c_kind { (kind == 2'd1) -> { len > 8'd100; len < 8'd103; len != 8'd101; } }
endclass

module test_implication_constrains_condition;
  icc_obj o;
  int failed = 0;
  int mode_set = 0, kind_one = 0;
  int ok;

  initial begin
    o = new;
    repeat (50) begin
      if (!o.randomize() with { v != 4'd9; }) failed++;
      if (o.mode) mode_set++;
      if (!o.randomize() with { len == 8'd5; }) failed++;
      if (o.kind == 2'd1) kind_one++;
    end
    $display("100 calls: failed=%0d, mode=1 with v!=9: %0d, kind==1 with len==5: %0d",
             failed, mode_set, kind_one);
    ok = o.randomize() with { kind == 2'd1; };
    $display("kind==1: ok=%0d len=%0d", ok, o.len);
    ok = o.randomize() with { mode == 1'b0; v == 4'd3; };
    $display("mode==0, v==3: ok=%0d v=%0d", ok, o.v);
    ok = o.randomize() with { mode == 1'b1; v == 4'd3; };
    $display("mode==1, v==3: ok=%0d v=%0d", ok, o.v);
  end
endmodule
