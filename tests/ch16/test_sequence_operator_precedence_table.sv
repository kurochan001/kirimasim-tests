/*
:name: test_sequence_operator_precedence_table
:description: the sequence operators group by the precedence of Table 16-3: repetition over ##, ## over throughout, throughout over within, within over intersect and grouping from the left, and intersect over and; each cover property is written without parentheses and succeeds only for the grouping of the table (IEEE 1800-2023 Section 16.12)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_operator_precedence_table.expected
*/
// IEEE 1800-2023 §16.12, Table 16-3: the sequence operators from higher to
// lower precedence are [*], [=] and [->]; ##; throughout; within, grouping
// from the left; intersect; and; or. So a1 ##1 b1[*2] is a1 ##1 (b1[*2]);
// x2 throughout a2 ##1 b2 is x2 throughout (a2 ##1 b2); x3 throughout a3 ##1
// b3 within c3 ##3 c3 is (x3 throughout (a3 ##1 b3)) within (c3 ##3 c3); d4
// ##2 d4 intersect b4 within c4 ##2 c4 is (d4 ##2 d4) intersect (b4 within
// (c4 ##2 c4)); a5 within b5 ##1 b5 within c5 ##3 c5 is (a5 within (b5 ##1
// b5)) within (c5 ##3 c5); and a6 ##1 b6 intersect c6 ##1 d6 and e6 ##2 e6
// is ((a6 ##1 b6) intersect (c6 ##1 d6)) and (e6 ##2 e6).
// Each cover property has its own signals, set by the initial procedure for
// the ticks at 15, 25, ..., 95 (tick k at 10 * k + 5). A cover property
// succeeds once per attempt, at the first match; it adds the time to its
// list. With the other grouping, the lists would be: [ ] for the repetition,
// [ 25 65 ] for ## and throughout, [ ] for throughout and within, [ ] for
// within and intersect, [ 45 95 ] for the two within, [ ] for intersect and
// and.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// groups x2 throughout a2 ##1 b2 as (x2 throughout a2) ##1 b2 and the two
// within from the right, giving [ 25 65 ] and [ 45 95 ].

`timescale 1ns/1ns

module test_sequence_operator_precedence_table;
  logic clk = 0;
  logic a1 = 0, b1 = 0;
  logic a2 = 0, b2 = 0, x2 = 0;
  logic a3 = 0, b3 = 0, c3 = 0, x3 = 0;
  logic b4 = 0, c4 = 0, d4 = 0;
  logic a5 = 0, b5 = 0, c5 = 0;
  logic a6 = 0, b6 = 0, c6 = 0, d6 = 0, e6 = 0;
  string m[string];
  string order[] = '{"a1 ##1 b1[*2]", "x2 throughout a2 ##1 b2",
                      "x3 throughout a3 ##1 b3 within c3 ##3 c3",
                      "d4 ##2 d4 intersect b4 within c4 ##2 c4",
                      "a5 within b5 ##1 b5 within c5 ##3 c5",
                      "a6 ##1 b6 intersect c6 ##1 d6 and e6 ##2 e6"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  c_r: cover property (@(posedge clk) a1 ##1 b1[*2]) hit("a1 ##1 b1[*2]");
  c_d: cover property (@(posedge clk) x2 throughout a2 ##1 b2) hit("x2 throughout a2 ##1 b2");
  c_t: cover property (@(posedge clk) x3 throughout a3 ##1 b3 within c3 ##3 c3)
    hit("x3 throughout a3 ##1 b3 within c3 ##3 c3");
  c_w: cover property (@(posedge clk) d4 ##2 d4 intersect b4 within c4 ##2 c4)
    hit("d4 ##2 d4 intersect b4 within c4 ##2 c4");
  c_w2: cover property (@(posedge clk) a5 within b5 ##1 b5 within c5 ##3 c5)
    hit("a5 within b5 ##1 b5 within c5 ##3 c5");
  c_i: cover property (@(posedge clk) a6 ##1 b6 intersect c6 ##1 d6 and e6 ##2 e6)
    hit("a6 ##1 b6 intersect c6 ##1 d6 and e6 ##2 e6");

  initial begin
    // tick 1
    #10 a1 = 1; a2 = 1; x2 = 1; c3 = 1; d4 = 1; c4 = 1; c5 = 1; a5 = 1;
    a6 = 1; c6 = 1; e6 = 1;
    // tick 2
    #10 a1 = 0; b1 = 1; a2 = 0; b2 = 1; x2 = 0; c3 = 0; a3 = 1; x3 = 1; d4 = 0; c4 = 0;
    b4 = 1; c5 = 0; a5 = 0; b5 = 1; a6 = 0; b6 = 1; c6 = 0; d6 = 1; e6 = 0;
    // tick 3
    #10 a3 = 0; b3 = 1; d4 = 1; c4 = 1; b4 = 0; b6 = 0; d6 = 0; e6 = 1;
    // tick 4
    #10 b1 = 0; b2 = 0; b3 = 0; x3 = 0; c3 = 1; d4 = 0; c4 = 0; b5 = 0; c5 = 1; e6 = 0;
    // tick 5
    #10 a2 = 1; x2 = 1; c3 = 0; c5 = 0;
    // tick 6
    #10 a2 = 0; b2 = 1; c5 = 1;
    // tick 7
    #10 b2 = 0; x2 = 0; c5 = 0; b5 = 1;
    // tick 8
    #10 a5 = 1;
    // tick 9
    #10 a5 = 0; b5 = 0; c5 = 1;
    // tick 10
    #10 c5 = 0;
    #20;
    foreach (order[i]) $display("%s: [%s ]", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
