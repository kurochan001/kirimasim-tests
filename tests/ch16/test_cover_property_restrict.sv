/*
:name: test_cover_property_restrict
:description: cover property runs its statement at most once per evaluation attempt, when the attempt succeeds, while cover sequence runs it for every match; restrict property is not checked in simulation, whereas the same assume property fails (IEEE 1800-2023 Sections 16.14.3, 16.14.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.3 16.14.4 16.14.2 16.12.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_property_restrict.expected
*/
// IEEE 1800-2023 §16.14.3: for property coverage the count goes up at most once
// per evaluation attempt, and the pass statement runs once for each successful
// attempt, in the time step in which it succeeds; for sequence coverage every
// match counts and the pass statement runs for each. A sequence used as a
// property succeeds at its first match (§16.12.2). With a at 5 and b at 15, 25
// and 35, a ##[1:3] b succeeds at 15 and matches three times; with a at 55 and
// b at 85 it succeeds and matches once, at 85; with a at 95 and no b it does
// neither. §16.14.4: restrict property has the semantics of assume property but
// is not verified in simulation and has no action block, so its violations at
// 5, 55 and 95 have no effect, while the assume property (§16.14.2) with the
// same property fails three times.

`timescale 1ns/1ns

module test_cover_property_restrict;
  logic clk = 0, a = 0, b = 0;
  int m_prop[$], m_seq[$];
  int assume_fails = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_prop: cover property (@(posedge clk) a ##[1:3] b) m_prop.push_back($time);
  c_seq: cover sequence (@(posedge clk) a ##[1:3] b) m_seq.push_back($time);
  r_no_a: restrict property (@(posedge clk) !a);
  m_no_a: assume property (@(posedge clk) !a) else assume_fails++;

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb);
    a = va;
    b = vb;
    #10;
  endtask

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    tick(1, 0); tick(0, 1); tick(0, 1); tick(0, 1); tick(0, 0);
    tick(1, 0); tick(0, 0); tick(0, 0); tick(0, 1);
    tick(1, 0); tick(0, 0); tick(0, 0); tick(0, 0); tick(0, 0);
    $display("cover property:%s", times(m_prop));
    $display("cover sequence:%s", times(m_seq));
    $display("assume failures: %0d", assume_fails);
    $finish;
  end
endmodule
