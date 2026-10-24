/*
:name: test_sequence_match_search_and_extension
:description: a linear sequence matches only when each of its Boolean expressions holds at its own successive tick, a sequence with a repetition range matches when one of the linear sequences it stands for does, an attempt stops at its first match or at the tick where no match is left, and ##n 1'b1 lengthens a match by n ticks (IEEE 1800-2023 Section 16.7)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.7 16.14.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_match_search_and_extension.expected
*/
// IEEE 1800-2023 §16.7: a linear sequence matches over consecutive ticks
// when its first expression holds at the first tick, the second at the next
// one, and so on; a lone Boolean expression matches at each tick where it
// holds. A sequence such as a ##1 b[*1:$] ##1 c stands for many linear
// sequences (one per repetition count) and matches wherever one of them
// does. An attempt evaluates from its first tick on until it finds a match
// or no match can exist any more. Joining an always-true term with ##3 makes
// a match three ticks longer whatever the other signals do.
// Tick k is at 10 * k + 5. a is high at ticks 1 and 4, b at 2, 5 and 6, c at
// 3 and 7. a ##1 b ##1 c matches from tick 1 to 3 (35); the attempt at tick
// 4 fails at tick 6 where c is low. The repeated form also matches from 4 to
// 7 (75) with two b. go is high at 1 and 5 and ack at 2 and 3.
// cover sequence (§16.14.3) runs its statement for every match, cover
// property once per attempt, when it succeeds: here at the first match, 25.
// The attempt of go |-> ##[1:3] ack from tick 5 finds no ack at 6, 7 or 8
// and fails at 8 (85), when no match is left. Each statement adds the time
// to the list of its statement; the lists are printed at the end.

`timescale 1ns/1ns

module test_sequence_match_search_and_extension;
  logic clk = 0, a = 0, b = 0, c = 0, go = 0, ack = 0;
  string m[string];

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  c_lin: cover sequence (@(posedge clk) a ##1 b ##1 c) hit("lin");
  c_one: cover sequence (@(posedge clk) c) hit("one");
  c_reg: cover sequence (@(posedge clk) a ##1 b[*1:$] ##1 c) hit("reg");
  c_ext: cover sequence (@(posedge clk) a ##1 b ##1 c ##3 1'b1) hit("ext");
  c_seq: cover sequence (@(posedge clk) go ##[1:3] ack) hit("cseq");
  c_prop: cover property (@(posedge clk) go ##[1:3] ack) hit("cprop");
  a_srch: assert property (@(posedge clk) go |-> ##[1:3] ack) else hit("fail");

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc, logic vgo, logic vack);
    a = va;
    b = vb;
    c = vc;
    go = vgo;
    ack = vack;
    #10;
  endtask

  initial begin
    tick(0, 0, 0, 0, 0);   // tick 0
    tick(1, 0, 0, 1, 0);   // tick 1
    tick(0, 1, 0, 0, 1);   // tick 2
    tick(0, 0, 1, 0, 1);   // tick 3
    tick(1, 0, 0, 0, 0);   // tick 4
    tick(0, 1, 0, 1, 0);   // tick 5
    tick(0, 1, 0, 0, 0);   // tick 6
    tick(0, 0, 1, 0, 0);   // tick 7
    tick(0, 0, 0, 0, 0);   // tick 8
    tick(0, 0, 0, 0, 0);   // tick 9
    $display("a ##1 b ##1 c: [%s ]", ends("lin"));
    $display("c: [%s ]", ends("one"));
    $display("a ##1 b[*1:$] ##1 c: [%s ]", ends("reg"));
    $display("a ##1 b ##1 c ##3 1'b1: [%s ]", ends("ext"));
    $display("cover sequence go ##[1:3] ack: [%s ]", ends("cseq"));
    $display("cover property go ##[1:3] ack: [%s ]", ends("cprop"));
    $display("go |-> ##[1:3] ack failures: [%s ]", ends("fail"));
    $finish;
  end
endmodule
