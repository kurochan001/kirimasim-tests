/*
:name: test_sequence_repetition_and_delay_shorthands
:description: a[*] matches as a[*0:$] and a[+] as a[*1:$], a[*n] as a[*n:n], ##[*] as ##[0:$] and ##[+] as ##[1:$], with the same end points of the same attempt (IEEE 1800-2023 Section 16.9.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.9.2 16.7 16.9.2.1 16.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_repetition_and_delay_shorthands.expected
*/
// IEEE 1800-2023 §16.9.2: [*] stands for [*0:$], [+] for [*1:$], and an
// exact count [*n] for the range [*n:n]. §16.7: ##[*] stands for ##[0:$]
// and ##[+] for ##[1:$]. Each cover sequence starts with start, which is
// high only at the tick T1 at 15; a is high at T2 and T3 (25, 35) and b at
// T1, T2 and T4 (15, 25, 45). For start ##1 a[*k] ##1 b, zero repetitions
// leave start ##1 b (§16.9.2.1), which ends at T2, two end at T4, and one
// or three do not match. start ##[k] b ends at T1 for k = 0, at T2 and at
// T4. A cover sequence runs its statement once for each match, in the time
// step where the match ends (§16.14.3); each statement adds that time to the
// list of its cover, and the lists are printed at the end, each shorthand
// next to its expansion.

`timescale 1ns/1ns

module test_sequence_repetition_and_delay_shorthands;
  logic clk = 0, start = 0, a = 0, b = 0;
  string m[string];

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  c_star: cover sequence (@(posedge clk) start ##1 a[*] ##1 b) hit("a[*]");
  c_star_r: cover sequence (@(posedge clk) start ##1 a[*0:$] ##1 b) hit("a[*0:$]");
  c_plus: cover sequence (@(posedge clk) start ##1 a[+] ##1 b) hit("a[+]");
  c_plus_r: cover sequence (@(posedge clk) start ##1 a[*1:$] ##1 b) hit("a[*1:$]");
  c_two: cover sequence (@(posedge clk) start ##1 a[*2] ##1 b) hit("a[*2]");
  c_two_r: cover sequence (@(posedge clk) start ##1 a[*2:2] ##1 b) hit("a[*2:2]");
  c_dstar: cover sequence (@(posedge clk) start ##[*] b) hit("##[*]");
  c_dstar_r: cover sequence (@(posedge clk) start ##[0:$] b) hit("##[0:$]");
  c_dplus: cover sequence (@(posedge clk) start ##[+] b) hit("##[+]");
  c_dplus_r: cover sequence (@(posedge clk) start ##[1:$] b) hit("##[1:$]");

  initial begin
    @(negedge clk) start = 1; b = 1;          // T1
    @(negedge clk) start = 0; a = 1; b = 1;   // T2
    @(negedge clk) a = 1; b = 0;              // T3
    @(negedge clk) a = 0; b = 1;              // T4
    @(negedge clk) b = 0;
    #30;
    $display("a[*]: [%s ] a[*0:$]: [%s ]", ends("a[*]"), ends("a[*0:$]"));
    $display("a[+]: [%s ] a[*1:$]: [%s ]", ends("a[+]"), ends("a[*1:$]"));
    $display("a[*2]: [%s ] a[*2:2]: [%s ]", ends("a[*2]"), ends("a[*2:2]"));
    $display("##[*]: [%s ] ##[0:$]: [%s ]", ends("##[*]"), ends("##[0:$]"));
    $display("##[+]: [%s ] ##[1:$]: [%s ]", ends("##[+]"), ends("##[1:$]"));
    $finish;
  end
endmodule
