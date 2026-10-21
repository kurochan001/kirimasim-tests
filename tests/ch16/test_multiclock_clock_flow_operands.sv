/*
:name: test_multiclock_clock_flow_operands
:description: a clock does not flow out of the parentheses it is written in, nor out of the instance of a sequence that declares it, a clock that reaches an instance whose declaration starts with its own clock is overridden, and in a multiclocked property the outer clock distributes to the operands of and and to the else branch, while if checks its clocked branch at the nearest, possibly overlapping tick (IEEE 1800-2023 Sections 16.13.3, 16.13.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.13.3 16.13.2 16.13.1 16.14.3 16.14.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_multiclock_clock_flow_operands.expected
*/
// IEEE 1800-2023 §16.13.3: a clock applies from where it is written until
// another one, but not out of the parentheses around it, and the clock in the
// declaration of a sequence does not flow out of an instance of it; a clock
// that flows into an instance whose declaration starts with a clock of its own
// is overridden by it. So in @(c1) (st ##0 @(c2) md) ##1 fin and in @(c1) x ##1
// s_c2 ##1 z, the last operand is clocked by c1, while in @(c1) st ##0 @(c2) md
// ##1 fin it is clocked by c2; @(c1) s_dd, with s_dd declared on c2, is clocked
// by c2. §16.13.1: ##1 goes to the nearest tick of the next clock strictly
// after, ##0 to the nearest one at or after. §16.13.2: in @(c1) go |=> ((@(c2)
// b) and d), d is clocked by c1, at the next c1 tick, and b at the nearest c2
// tick strictly after go; in @(c1) go |-> if (sel) (@(c2) b) else (d ##1 d), b
// is checked at the nearest c2 tick at or after go, and the else branch at c1
// ticks. c1 rises at 5, 15, 25, ...; c2 at 8, 22, 31, 45, 52, 68, 85, 93, 108,
// 121, 135, 142, 158, 171 and 182. Each signal is sampled high at the ticks
// listed in the code. The covers (§16.14.3) record their matches, the fail
// actions (§16.14.1) the failures. From st at 15, md at 22 is followed by fin
// at 25, the next c1 tick, but not at 31, the next c2 tick; from st at 65, md
// at 68 is followed by fin at 85, the next c2 tick, but not at 75. s_c2 ends at
// 45, after x at 35, and z follows at 55, not at 52. dd is high at the c2 ticks
// 22 and 31 only, and only the c1 tick 15 lies between the c2 ticks 8 and 22,
// so one match of s_dd ends at 31 whether its attempts start at the c2 ticks or
// at the c1 ticks. go at 135 is also a c2 tick: the if checks b there, the and
// at 142.

`timescale 1ns/1ns

module test_multiclock_clock_flow_operands;
  logic c1 = 0, c2 = 0, st = 0, md = 0, fin = 0, x = 0, y = 0, z = 0, dd = 0;
  logic go = 0, sel = 0, b = 0, d = 0;
  int m_paren[$], m_noparen[$], m_inst[$], m_juxt[$], f_and[$], f_if[$];
  int c2_rise[$] = '{8, 22, 31, 45, 52, 68, 85, 93, 108, 121, 135, 142, 158, 171, 182};

  sequence s_c2;
    @(posedge c2) y;
  endsequence

  sequence s_dd;
    @(posedge c2) dd ##1 dd;
  endsequence

  c_paren: cover sequence (@(posedge c1) (st ##0 @(posedge c2) md) ##1 fin)
    m_paren.push_back($time);
  c_noparen: cover sequence (@(posedge c1) st ##0 @(posedge c2) md ##1 fin)
    m_noparen.push_back($time);
  c_inst: cover sequence (@(posedge c1) x ##1 s_c2 ##1 z) m_inst.push_back($time);
  c_juxt: cover sequence (@(posedge c1) s_dd) m_juxt.push_back($time);
  a_and: assert property (@(posedge c1) go |=> ((@(posedge c2) b) and d))
    else f_and.push_back($time);
  a_if: assert property (@(posedge c1) go |-> if (sel) (@(posedge c2) b) else (d ##1 d))
    else f_if.push_back($time);

  // True when a signal sampled high at the times listed has to be high at t:
  // it is high from one time unit before each such time.
  function automatic logic at(int t, int times[$]);
    foreach (times[i]) if (t == times[i] - 1 || t == times[i]) return 1'b1;
    return 1'b0;
  endfunction

  function automatic string times(int q[$]);
    string s = "";
    foreach (q[i]) s = {s, $sformatf(" %0d", q[i])};
    return s;
  endfunction

  initial begin
    for (int t = 0; t < 200; t++) begin
      c1 = t % 10 == 5;
      c2 = t inside {c2_rise};
      st = at(t, '{15, 65});
      md = at(t, '{22, 68});
      fin = at(t, '{25, 85});
      x = at(t, '{35});
      y = at(t, '{45});
      z = at(t, '{55});
      dd = at(t, '{22, 31});
      go = at(t, '{105, 135, 165});
      sel = at(t, '{105, 135});
      b = at(t, '{108, 135, 171});
      d = at(t, '{115, 145, 165});
      #1;
    end
    $display("@(c1) (st ##0 @(c2) md) ##1 fin:%s", times(m_paren));
    $display("@(c1) st ##0 @(c2) md ##1 fin:%s", times(m_noparen));
    $display("@(c1) x ##1 s_c2 ##1 z:%s", times(m_inst));
    $display("@(c1) s_dd:%s", times(m_juxt));
    $display("go |=> ((@(c2) b) and d) failures:%s", times(f_and));
    $display("go |-> if (sel) (@(c2) b) else (d ##1 d) failures:%s", times(f_if));
    $finish;
  end
endmodule
