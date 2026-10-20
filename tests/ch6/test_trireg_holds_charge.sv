/*
:name: test_trireg_holds_charge
:description: When its driver turns off, a trireg net keeps the last value with the charge strength of its size, small, medium or large (IEEE 1800-2023 Section 6.6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.4 6.6.4.1 28.11 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_holds_charge.expected
*/
// IEEE 1800-2023 §6.6.4: a trireg net in the driven state has the strength of
// its driver; when all its drivers are z it keeps its last value, with the
// strength of its size: small, medium or large (28.11), shown by %v as Sm, Me
// and La (21.2.1.4). Each net here is driven by a bufif1 gate whose enable
// turns on and off.

`timescale 1ns/1ns

module test_trireg_holds_charge;
  logic d, en;
  trireg (small) ts;
  trireg (medium) tm;
  trireg (large) tl;

  bufif1 bs(ts, d, en);
  bufif1 bm(tm, d, en);
  bufif1 bl(tl, d, en);

  task show(string what);
    #1 $display("%s: %v %v %v", what, ts, tm, tl);
  endtask

  initial begin
    d = 1; en = 1;
    show("driven 1");
    en = 0;
    show("held 1");
    d = 0; en = 1;
    show("driven 0");
    en = 0;
    show("held 0");
  end
endmodule
