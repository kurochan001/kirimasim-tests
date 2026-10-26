/*
:name: test_cover_property_sequence_counters
:description: a cover property counts at most one success for an attempt, so its action runs once although the sequence has several matches, while a cover sequence runs its action at every match; a disabled evaluation of a cover property runs no success action; restrict property has no action block (IEEE 1800-2023 Sections 16.14.3 and 16.14.4)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.14.3 16.14.4 16.14.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_cover_property_sequence_counters.expected
*/
// IEEE 1800-2023 §16.14.3: a cover property reports an attempt count, a
// success count with at most one success for each attempt, and a vacuous
// success count; a cover sequence reports its attempts and every match, so it
// can count more than one match for an attempt. A disabled evaluation adds to
// the attempt count but not to the success or vacuous-success counts, so its
// action does not run. The pass actions record the time at which the coverage
// success occurs. §16.14.4: restrict property has no action block and adds a
// constraint for formal tools; it is legal here and changes no output. The
// ticks are at 5, 15 and 25, a is high at all of them, and dis is high at 5 and
// 15 and low at 25. a[*1:2] has matches at the tick at 5 and at the tick at 15
// for the attempt that starts at 5. The cover property succeeds once for that
// attempt, at its first match, and the cover sequence once for each match.

`timescale 1ns/1ns

module test_cover_property_sequence_counters;
  logic clk = 0, a = 1, dis = 1;
  int prop_at[$], multi_at[$], seq_at[$], disabled_at[$];

  always #5 clk = ~clk;   // rising edges at 5, 15, 25

  c_prop: cover property (@(posedge clk) a) prop_at.push_back($time);
  c_multi: cover property (@(posedge clk) a[*1:2]) multi_at.push_back($time);
  c_seq: cover sequence (@(posedge clk) a[*1:2]) seq_at.push_back($time);
  c_dis: cover property (@(posedge clk) disable iff (dis) a)
    disabled_at.push_back($time);
  r_never: restrict property (@(posedge clk) 1'b1);

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    #21 dis = 0;
    #9;
    $display("cover property a:%s", times(prop_at));
    $display("cover property a[*1:2]:%s", times(multi_at));
    $display("cover sequence a[*1:2]:%s", times(seq_at));
    $display("cover property with disable iff:%s", times(disabled_at));
    $display("restrict accepted");
    $finish;
  end
endmodule
