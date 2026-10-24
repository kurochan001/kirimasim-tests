/*
:name: test_trireg_driven_capacitive_states_and_decay
:description: A trireg takes the value and drive strength of its drivers while one drives 0, 1 or x, keeps that value at its charge strength when all turn off, loses a stored value to x after the charge decay time of its third delay, restarts that time when driven again, and keeps it without a decay time (IEEE 1800-2023 Section 6.6.4)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.4 6.6.4.2 6.3.2.1 6.6 6.7 28.15.2 28.16.2 28.16.2.1 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_trireg_driven_capacitive_states_and_decay.expected
*/
// IEEE 1800-2023 §6.6.4: while at least one driver of a trireg drives 0, 1 or
// x, the trireg is in the driven state: it has the driven value, with the
// strength of the driver. When all its drivers are z, it is in the capacitive
// state: z does not reach it, and it keeps its last driven value with its
// charge strength, small, medium or large as declared, medium by default
// (6.3.2.1, 28.15.2). A trireg that has never been driven is x at its charge
// strength (6.6, 6.7.1). %v (21.2.1.4) shows Sm, Me and La for the charge
// strengths.
// §6.6.4.2, 28.16.2: the third delay of a trireg is its charge decay time.
// When the drivers turn off, the decay starts; when the time has passed, a
// stored 0 or 1 becomes x. Driving the trireg again ends the decay
// (28.16.2.1), so the time starts again at the next turn-off. Without a delay
// the charge is kept indefinitely.
// Five triregs, of each charge strength and one with a weak driver, are driven
// by bufif1 gates from d and turned on and off with en; each value is shown
// after the drivers turned on and after they turned off. decaying (decay time
// 4) and ideal (no delay) are then turned off, driven again, and turned off,
// and shown 3 and 5 time units after the last turn-off and much later. The
// rise and fall delays of decaying are 0, so being driven takes no time.
// Oracle checks: neither Icarus Verilog 13.0 nor the 5.052 release supports
// trireg nets, so the expected output follows the cited clauses alone.

module test_trireg_driven_capacitive_states_and_decay;
  logic d = 1'b1, en = 1'b1;
  logic dd = 1'b1, den = 1'b1;
  trireg (small) ts;
  trireg (medium) tm;
  trireg (large) tl;
  trireg tdef;
  trireg tw;
  trireg (large) never;
  trireg (medium) #(0, 0, 4) decaying;
  trireg ideal;

  bufif1 g_s(ts, d, en);
  bufif1 g_m(tm, d, en);
  bufif1 g_l(tl, d, en);
  bufif1 g_def(tdef, d, en);
  bufif1 (weak0, weak1) g_w(tw, d, en);
  bufif1 g_dec(decaying, dd, den);
  bufif1 g_ideal(ideal, dd, den);

  task automatic show(string what);
    $display("%s: small=%v medium=%v large=%v default=%v weak=%v", what, ts, tm, tl, tdef, tw);
  endtask

  initial begin
    #1 show("driven 1");
    $display("never driven: %v", never);
    en = 1'b0;
    #1 show("stored 1");
    d = 1'bx;
    en = 1'b1;
    #1 show("driven x");
    en = 1'b0;
    #1 show("stored x");
    d = 1'b0;
    en = 1'b1;
    #1 show("driven 0");
    en = 1'b0;
    #1 show("stored 0");
    $display("decay driven: decaying=%v ideal=%v", decaying, ideal);
    den = 1'b0;
    #3 $display("off for 3: decaying=%v ideal=%v", decaying, ideal);
    dd = 1'b0;
    den = 1'b1;
    #1 $display("driven again: decaying=%v ideal=%v", decaying, ideal);
    den = 1'b0;
    #3 $display("off again for 3: decaying=%v ideal=%v", decaying, ideal);
    #2 $display("off again for 5: decaying=%v ideal=%v", decaying, ideal);
    #100 $display("off again for 105: decaying=%v ideal=%v", decaying, ideal);
  end
endmodule
