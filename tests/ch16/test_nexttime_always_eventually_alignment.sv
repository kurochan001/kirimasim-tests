/*
:name: test_nexttime_always_eventually_alignment
:description: nexttime, always and eventually evaluated in a time step that is not a tick of their clock first align to the next tick of that clock and count it as tick 0, so nexttime[0] checks that tick, nexttime and nexttime[1] the one after, always [0:1] both and eventually [1:2] the two after it (IEEE 1800-2023 Sections 16.12.10, 16.12.11, 16.12.13)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.10 16.12.11 16.12.13
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nexttime_always_eventually_alignment.expected
*/
// IEEE 1800-2023 §16.12.10, §16.12.11, §16.12.13: when nexttime, always or
// eventually is evaluated in a time step that is not a tick of its own clock,
// it first aligns to the nearest tick of that clock at or after the time
// step, and the counting of ticks starts there: nexttime[0] checks the
// aligned tick, nexttime[n] the n+1st tick counted from it, always [n:m] and
// s_always [n:m] the n+1st to m+1st ticks, eventually [n:m] and s_eventually
// [n:m] one of them. When the time step is a tick, the aligned tick is the
// current one.
// Each assertion is clocked by c1 and joins a, which is always 1, with a
// property clocked by c2 (§16.13.2), so that property is evaluated from the
// c1 tick. c2 rises at 5, 15, ..., 75 and c1 at 5, a c2 tick, and at 27,
// between the c2 ticks at 25 and 35, which aligns to 35. The signals n0, n1,
// al and ev take the values of the tables below at the c2 ticks, chosen so
// that counting from the c2 tick before 27, or from 35 without counting it,
// gives a failure or another time. Each assertion records time:P or time:F.
// Icarus Verilog 13.0 does not support these assertions and Verilator
// 5.052 rejects a clocking event inside the property.

`timescale 1ns/1ns

module test_nexttime_always_eventually_alignment;
  logic c1 = 0, c2 = 0, a = 1, n0 = 0, n1 = 0, al = 0, ev = 0;
  // values at the c2 ticks 5, 15, ..., 75
  bit t_n0[8] = '{1, 0, 0, 1, 0, 0, 0, 0};
  bit t_n1[8] = '{0, 1, 0, 0, 1, 0, 0, 0};
  bit t_al[8] = '{1, 1, 0, 1, 1, 0, 0, 0};
  bit t_ev[8] = '{0, 0, 1, 1, 0, 1, 0, 0};
  string m[string];
  string order[] = '{"nexttime[0]", "nexttime", "nexttime[1]", "s_nexttime[1]", "always [0:1]",
                      "s_always [0:1]", "eventually [1:2]", "s_eventually [1:2]"};

  function automatic void hit(string name, string r);
    string t = $sformatf(" %0t:%s", $time, r);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  always #5 c2 = ~c2;   // rising edges at 5, 15, ..., 75

  a0: assert property (@(posedge c1) a and (@(posedge c2) nexttime[0] n0))
    hit("nexttime[0]", "P"); else hit("nexttime[0]", "F");
  a1: assert property (@(posedge c1) a and (@(posedge c2) nexttime n1))
    hit("nexttime", "P"); else hit("nexttime", "F");
  a2: assert property (@(posedge c1) a and (@(posedge c2) nexttime[1] n1))
    hit("nexttime[1]", "P"); else hit("nexttime[1]", "F");
  a3: assert property (@(posedge c1) a and (@(posedge c2) s_nexttime[1] n1))
    hit("s_nexttime[1]", "P"); else hit("s_nexttime[1]", "F");
  a4: assert property (@(posedge c1) a and (@(posedge c2) always [0:1] al))
    hit("always [0:1]", "P"); else hit("always [0:1]", "F");
  a5: assert property (@(posedge c1) a and (@(posedge c2) s_always [0:1] al))
    hit("s_always [0:1]", "P"); else hit("s_always [0:1]", "F");
  a6: assert property (@(posedge c1) a and (@(posedge c2) eventually [1:2] ev))
    hit("eventually [1:2]", "P"); else hit("eventually [1:2]", "F");
  a7: assert property (@(posedge c1) a and (@(posedge c2) s_eventually [1:2] ev))
    hit("s_eventually [1:2]", "P"); else hit("s_eventually [1:2]", "F");

  initial begin   // c1 rises at 5 and at 27
    #5 c1 = 1;
    #2 c1 = 0;
    #20 c1 = 1;
    #2 c1 = 0;
  end

  initial begin
    foreach (t_n0[k]) begin
      n0 = t_n0[k];
      n1 = t_n1[k];
      al = t_al[k];
      ev = t_ev[k];
      #10;
    end
    #10;
    foreach (order[i]) $display("%s: [%s ]", order[i], m.exists(order[i]) ? m[order[i]] : "");
    $finish;
  end
endmodule
