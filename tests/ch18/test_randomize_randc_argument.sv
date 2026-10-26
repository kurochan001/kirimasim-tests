/*
:name: test_randomize_randc_argument
:description: Naming a randc variable as the only argument of randomize does not turn it into a noncyclical random variable, and naming a non-rand property does not turn it into a cyclical one (IEEE 1800-2023 Section 18.11)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.11 18.4.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_randomize_randc_argument.expected
*/
// IEEE 1800-2023 §18.11: the arguments of randomize() control the random mode
// for one call, but they cannot change a cyclical random variable into a
// noncyclical one or a noncyclical variable into a cyclical one. cyc stays
// randc when it is the only argument, so four consecutive calls return 0, 1,
// 2 and 3 once each, whatever the initial position of its permutation is.
// plain is not random; randomize(plain) makes it random for that call but not
// randc, so over 100 calls it repeats a value on two consecutive calls, which
// a randc variable with two values would never do before the cycle ends.

class rca_obj;
  randc bit [1:0] cyc;
  rand int other;
endclass

class rcp_obj;
  bit plain;
endclass

module test_randomize_randc_argument;
  rca_obj o = new;
  rcp_obj p = new;
  bit [3:0] seen;
  int failed;
  int prev;
  int repeats, calls, bad, s0, s1;

  initial begin
    seen = 4'b0000;
    failed = 0;
    for (int i = 0; i < 4; i++) begin
      if (!o.randomize(cyc)) failed++;
      else seen[o.cyc] = 1'b1;
    end
    $display("four calls: all values seen %0d, failures %0d",
             seen == 4'b1111, failed);
    repeats = 0;
    calls = 0;
    bad = 0;
    s0 = 0;
    s1 = 0;
    prev = 2;
    for (int i = 0; i < 100; i++) begin
      if (!p.randomize(plain)) bad++;
      else begin
        calls++;
        if (p.plain) s1 = 1;
        else s0 = 1;
        if (i > 0 && p.plain == prev) repeats++;
      end
      prev = p.plain;
    end
    $display("non-rand argument: calls %0d, failures %0d, both values %0d, repeats %0d",
             calls, bad, s0 && s1, repeats > 0);
  end
endmodule
