/*
:name: test_sequence_expression_forms_and_match_items
:description: each form of sequence expression of Syntax 16-3 is used once from the same start tick, a leading cycle delay, concatenation, the three Boolean repetitions, repetition of an instance and of a parenthesized sequence with match items, and, intersect, or, first_match, throughout, within and a clocking event, and the match items assign, increment and call a subroutine (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_expression_forms_and_match_items.expected
*/
// IEEE 1800-2023 §16.7 (Syntax 16-3): a sequence expression is a cycle delay
// followed by a sequence, two sequences joined by a cycle delay, a Boolean
// expression with an optional [*], [=] or [->] repetition, a sequence
// instance or a parenthesized sequence (with optional match items) with an
// optional [*] repetition, and, intersect, or, first_match, throughout,
// within, or a sequence after a clocking event. A match item is an
// assignment, an increment or decrement, or a subroutine call.
// Every cover starts its sequence with st ##0, and st is high only at tick 1.
// Tick k is at 10 * k + 5; a is high at ticks 1, 2 and 4, b at 2, 3 and 5, c
// at 3 and 4, d at 4 and 5. The comment of each cover gives its matches;
// each match adds its time to the list of its cover, printed at the end.
// s_items counts a over two ticks with n++ and adds 10 with += at the next b,
// then calls show with n, so it records 12 at tick 3.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// rejects the local variable, the clocking event inside the sequence, the
// variable-length intersect operand and the or form, finds no match for
// b[->2] and b[=2], and reports two matches of first_match (25 and 35).

`timescale 1ns/1ns

module test_sequence_expression_forms_and_match_items;
  logic clk = 0, st = 0, a = 0, b = 0, c = 0, d = 0;
  string m[string];
  string order[] = '{"##2 b", "a ##1 b", "a[*2]", "b[->2]", "b[=2]", "s_a[*2]", "match items",
                      "and", "intersect", "or", "first_match", "throughout", "within",
                      "clocking event"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic void show(int n);
    hit($sformatf("match items n=%0d", n));
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  sequence s_a;
    a;
  endsequence

  sequence s_items;
    int n = 0;
    st ##0 (a, n++)[*2] ##1 (b, n += 10, show(n));
  endsequence

  c1: cover sequence (@(posedge clk) st ##0 (##2 b)) hit("##2 b");                // 3
  c2: cover sequence (@(posedge clk) st ##0 (a ##1 b)) hit("a ##1 b");            // 2
  c3: cover sequence (@(posedge clk) st ##0 a[*2]) hit("a[*2]");                  // 2
  c4: cover sequence (@(posedge clk) st ##0 b[->2]) hit("b[->2]");                // 3
  c5: cover sequence (@(posedge clk) st ##0 b[=2]) hit("b[=2]");                  // 3, 4
  c6: cover sequence (@(posedge clk) st ##0 s_a[*2]) hit("s_a[*2]");              // 2
  c7: cover sequence (@(posedge clk) s_items) hit("match items");                 // 3
  c8: cover sequence (@(posedge clk) st ##0 (a[*2] and a ##2 c)) hit("and");      // 3
  c9: cover sequence (@(posedge clk) st ##0 (a ##1 b intersect a[*2])) hit("intersect");  // 2
  c10: cover sequence (@(posedge clk) st ##0 (a ##2 b or a ##3 d)) hit("or");     // 3, 4
  c11: cover sequence (@(posedge clk) st ##0 first_match(a ##[1:3] b)) hit("first_match");  // 2
  c12: cover sequence (@(posedge clk) st ##0 (a throughout ##1 b)) hit("throughout");  // 2
  c13: cover sequence (@(posedge clk) st ##0 (c ##1 c within st ##3 d)) hit("within");  // 4
  c14: cover sequence (@(posedge clk) st ##0 (@(posedge clk) a ##1 b)) hit("clocking event");  // 2

  // Sets the values sampled at the next tick.
  task automatic tick(logic vst, logic va, logic vb, logic vc, logic vd);
    st = vst;
    a = va;
    b = vb;
    c = vc;
    d = vd;
    #10;
  endtask

  initial begin
    tick(0, 0, 0, 0, 0);   // tick 0
    tick(1, 1, 0, 0, 0);   // tick 1
    tick(0, 1, 1, 0, 0);   // tick 2
    tick(0, 0, 1, 1, 0);   // tick 3
    tick(0, 1, 0, 1, 1);   // tick 4
    tick(0, 0, 1, 0, 1);   // tick 5
    tick(0, 0, 0, 0, 0);   // tick 6
    tick(0, 0, 0, 0, 0);   // tick 7
    foreach (order[i]) $display("%s: [%s ]", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $display("show: [%s ]", m.exists("match items n=12") ? m["match items n=12"] : "");
    $finish;
  end
endmodule
