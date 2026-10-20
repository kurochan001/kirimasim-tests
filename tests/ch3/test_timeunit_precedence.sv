/*
:name: test_timeunit_precedence
:description: A timeunit declaration in a module overrides `timescale, its slash form also sets the precision, a nested module takes the time unit of its parent, and a module without one takes the last `timescale (IEEE 1800-2023 Section 3.14.2.3)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.14.2.3 3.14.2.2 3.14.1 23.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_precedence.expected
*/
// IEEE 1800-2023 §3.14.2.2: timeunit 100ps / 10ps sets both the unit and the
// precision of m_slash, so its #25 is 2.5 ns, whatever `timescale says.
// §3.14.2.3: a nested module without a timeunit (23.4) takes the time unit
// and precision of the module around it, so the #2 of m_inner is 20 ns. A
// module without its own declaration that is not nested takes the last
// `timescale, so the #7 of m_plain is 7 ns. Each module reports through a
// task of the top module, whose $realtime is in the top's unit, 1 ns (3.14.1).

`timescale 1ns/1ps

module test_timeunit_precedence;
  task report(string who);
    $display("%0.2f ns: %s", $realtime, who);
  endtask

  m_slash a();
  m_outer b();
  m_plain c();
endmodule

module m_slash;
  timeunit 100ps / 10ps;
  initial #25 test_timeunit_precedence.report("m_slash, #25 in units of 100ps");
endmodule

module m_outer;
  timeunit 10ns;
  timeprecision 1ns;

  module m_inner;
    initial #2 test_timeunit_precedence.report("m_inner, #2 in the units of m_outer");
  endmodule

  m_inner i();
endmodule

module m_plain;
  initial #7 test_timeunit_precedence.report("m_plain, #7 in the units of the timescale directive");
endmodule
