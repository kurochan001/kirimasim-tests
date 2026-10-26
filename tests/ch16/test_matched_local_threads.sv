/*
:name: test_matched_local_threads
:description: Several source matches in one destination clock cycle fork the continuation thread of a matched operand, each with its own copy of the local variable passed to the sequence, and the values of those local variables flow out of matched into the following terms (IEEE 1800-2023 Sections 16.13.5 and 16.13.6)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.5 16.13.6 16.10 16.8.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_matched_local_threads.expected
*/
// IEEE 1800-2023 §16.13.5: local variables can be passed into an instance to
// which matched is applied, under the same restrictions as for triggered, and
// their sampled values flow out under the same conditions, so after the match
// of the instance a term may read the value that the instance assigned to its
// output formal. When several source matches fall in one cycle of the
// destination clock, the destination thread forks, as for or, into one thread
// per distinct valuation of the local variables. c1 rises at 20, 60 and 100;
// c2 rises at 5, 15, 25, 35 and 45. a is 1 at the c2 ticks 5, 15, 25 and 35,
// and d is 1, 2, 3 and 4 there. At c1's tick 20 the matches at 5 and 15 are
// both pending, so two threads carry lv = 1 and 2 to the term after ##1 at
// 60, where hits grows by two and sum by three; the matches at 25 and 35 do
// the same at 100 with 3 and 4. The order of the threads is not observed: the
// two totals are always 4 and 10.

`timescale 1ns/1ns

module test_matched_local_threads;
  logic c1 = 0, c2 = 0, a = 0;
  int d = 0, hits = 0, sum = 0;

  always #20 c1 = ~c1;   // rising edges at 20, 60, 100
  always #5 c2 = ~c2;    // rising edges at 5, 15, 25, ...

  initial begin
    d = 1;
    #2 a = 1;
    #10 d = 2;    // 12
    #10 d = 3;    // 22
    #10 d = 4;    // 32
    #8 a = 0;     // 40
  end

  function automatic void record(input int v);
    hits++;
    sum += v;
  endfunction

  sequence s(local output int v);
    @(posedge c2) (a, v = d);
  endsequence

  property p;
    int lv;
    @(posedge c1) s(lv).matched ##1 (1'b1, record(lv));
  endproperty

  a_p: cover property (p);

  initial begin
    #150;
    $display("hits=%0d sum=%0d", hits, sum);
    $finish;
  end
endmodule
