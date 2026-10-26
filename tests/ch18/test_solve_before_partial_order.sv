/*
:name: test_solve_before_partial_order
:description: solve before orders comma-separated lists of random variables without ordering within a list, partially ordered variables are solved in the latest group allowed by every ordering constraint, and a variable without an order is solved with the last ordered group (IEEE 1800-2023 Section 18.5.9)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_solve_before_partial_order.expected
*/
// IEEE 1800-2023 §18.5.9: solve a, b before c orders both a and b before c
// but not a against b. With a <= b the three legal pairs (0,0), (0,1) and
// (1,1) are then equally likely; an implementation that ordered a before b
// would make (1,1) twice as likely as (0,0). The chain solve s before d and
// solve d before e puts each variable in its own group, so s is 0 or 1 with
// equal probability and, after s == 0, d is 0 or 1 with equal probability;
// with d in the earlier group the first probability would be 1/3, with d in
// the later group the second would be 1/3. In the third class e has no order,
// so it is solved with the last group, that of d, and s is 1 in half of the
// calls; in the earlier group it would be 1 in five.
// In Verilator 5.052 solve before does not change the probabilities, so the
// two probability checks of this test fail there.

class sp_obj;
  rand bit a, b;
  rand bit [1:0] c;
  constraint c_order {
    a <= b;
    c == {a, b};
    solve a, b before c;
  }
endclass

class spl_obj;
  rand bit s, d, e;
  constraint c_chain {
    s <= d;
    d <= e;
    solve s before d;
    solve d before e;
  }
endclass

class su_obj;
  rand bit s;
  rand bit [1:0] d, e;
  constraint c_order {
    s -> d == 0;
    d == e;
    solve s before d;
  }
endclass

module test_solve_before_partial_order;
  sp_obj op = new;
  spl_obj ol = new;
  su_obj ou = new;
  int n00, n01, n11, pfail, cbad;
  int s1, s0, d1, lfail;
  int us1, ufail, ubad;

  initial begin
    n00 = 0;
    n01 = 0;
    n11 = 0;
    pfail = 0;
    cbad = 0;
    repeat (900) begin
      if (!op.randomize()) pfail++;
      else begin
        if (op.a == 0 && op.b == 0) n00++;
        else if (op.a == 0 && op.b == 1) n01++;
        else if (op.a == 1 && op.b == 1) n11++;
        else cbad++;
        if (op.c != {op.a, op.b}) cbad++;
      end
    end
    $display("comma lists: failures %0d, illegal %0d, 00 and 11 differ under 80 %0d, 01 seen %0d",
             pfail, cbad, n00 > n11 - 80 && n11 < n00 + 80, n01 > 0);
    s1 = 0;
    s0 = 0;
    d1 = 0;
    lfail = 0;
    repeat (900) begin
      if (!ol.randomize()) lfail++;
      else begin
        if (ol.s == 0) begin
          s0++;
          if (ol.d == 1) d1++;
        end else begin
          s1++;
        end
        if (ol.e < ol.d || ol.d < ol.s) lfail++;
      end
    end
    $display("partial order: failures %0d, s==1 in 45..55%% %0d, d==1 in 42..58%% of s==0 %0d",
             lfail, s1 * 100 >= 45 * (s1 + s0) && s1 * 100 <= 55 * (s1 + s0),
             d1 * 100 >= 42 * s0 && d1 * 100 <= 58 * s0);
    us1 = 0;
    ufail = 0;
    ubad = 0;
    repeat (800) begin
      if (!ou.randomize()) ufail++;
      else begin
        if (ou.s) begin
          us1++;
          if (ou.d != 0) ubad++;
        end
        if (ou.d != ou.e) ubad++;
      end
    end
    $display("unordered last: failures %0d, illegal %0d, s==1 in 40..60%% %0d",
             ufail, ubad, us1 * 100 >= 40 * 800 && us1 * 100 <= 60 * 800);
  end
endmodule
