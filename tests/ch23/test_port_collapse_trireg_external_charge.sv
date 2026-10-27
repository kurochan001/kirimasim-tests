/*
:name: test_port_collapse_trireg_external_charge
:description: A trireg port connected to an outer trireg net merges into the external trireg, whose charge strength the simulated net takes, for every pair of small, medium and large strengths (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 6.6.4 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_port_collapse_trireg_external_charge.expected
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets, the simulated net
// takes the net type that Table 23-1 selects, and "if the dominating net is
// of the type trireg, any strength value specified for the trireg net shall
// apply to the simulated net". Cell 3-3 of the table selects the external
// net when both nets are trireg, without a warning. Two trireg nets
// have the same type, so the resolved value cannot show which declaration
// the table selected; the charge strength declared for each one (§6.6.4)
// can. The six cells below pair every internal strength with an external
// strength that differs from it. The internal module declares only the port
// net and has no driver; a continuous assignment on the external net drives
// 1, then z, then 0, then z, and after each step the test prints the merged
// net with %v from outside and from inside, which are the same net. In the
// driven state the strength is strong, St1 or St0. In the capacitive state
// the strength is the charge strength of the dominating trireg, printed by
// %v as St, Sm or Me (§21.2.1.4): taking the external trireg gives La for
// the large external strengths, Sm for the small ones and Me for the
// medium ones. Taking the internal trireg would print Sm, La, Me, La, Sm
// and Me instead, so every hold line distinguishes the two declarations.
// Icarus Verilog 13.0 does not support trireg nets, so this expected output
// follows the standard alone.

module pctc_in_small(w);
  inout w;
  trireg (small) w;
endmodule

module pctc_in_medium(w);
  inout w;
  trireg (medium) w;
endmodule

module pctc_in_large(w);
  inout w;
  trireg (large) w;
endmodule

module test_port_collapse_trireg_external_charge;
  // Code of the driver outside the ports: 0 drives 0, 1 drives 1, 2 drives z.
  logic [1:0] co;

  trireg (large) n_sl;
  trireg (small) n_ls;
  trireg (large) n_ml;
  trireg (medium) n_lm;
  trireg (medium) n_sm;
  trireg (small) n_ms;
  assign n_sl = co[1] ? 1'bz : co[0];
  assign n_ls = co[1] ? 1'bz : co[0];
  assign n_ml = co[1] ? 1'bz : co[0];
  assign n_lm = co[1] ? 1'bz : co[0];
  assign n_sm = co[1] ? 1'bz : co[0];
  assign n_ms = co[1] ? 1'bz : co[0];

  pctc_in_small u_sl(n_sl);
  pctc_in_large u_ls(n_ls);
  pctc_in_medium u_ml(n_ml);
  pctc_in_large u_lm(n_lm);
  pctc_in_small u_sm(n_sm);
  pctc_in_medium u_ms(n_ms);

  task automatic show(string step);
    $display("%s small inside, large outside:  outside %v inside %v",
             step, n_sl, u_sl.w);
    $display("%s large inside, small outside:  outside %v inside %v",
             step, n_ls, u_ls.w);
    $display("%s medium inside, large outside: outside %v inside %v",
             step, n_ml, u_ml.w);
    $display("%s large inside, medium outside: outside %v inside %v",
             step, n_lm, u_lm.w);
    $display("%s small inside, medium outside: outside %v inside %v",
             step, n_sm, u_sm.w);
    $display("%s medium inside, small outside: outside %v inside %v",
             step, n_ms, u_ms.w);
  endtask

  initial begin
    co = 1;
    #1 show("drive 1:");
    co = 2;
    #1 show("hold 1: ");
    co = 0;
    #1 show("drive 0:");
    co = 2;
    #1 show("hold 0: ");
  end
endmodule
