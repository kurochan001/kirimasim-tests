/*
:name: test_pull_gate_instances_terminal_and_strength
:description: pullup and pulldown are the pull gates: each instance has the single output terminal, the name of an instance may be left out, and the value 1 or 0 has pull strength unless a strength for that value is given (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.10
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pull_gate_instances_terminal_and_strength.expected
*/
// IEEE 1800-2023 §28.3.1 (Table 28-1): pullup and pulldown are the two pull
// gates; an instance of a pull gate has an optional name and one terminal,
// the output (28.3). §28.10: pullup places 1 and pulldown places 0 on that
// net, with pull strength when no strength is given; a strength1 given to a
// pullup, or a strength0 given to a pulldown, is used instead, and the other
// strength of the pair is ignored.
//
// Each net below has one pull gate as its only driver, and %v prints its
// strength and value (21.2.1.4). n_up and n_dn are driven by named instances
// without strength, Pu1 and Pu0. One declaration of pullup has a named
// instance on n_a and an unnamed one on n_b, both Pu1. pullup (strong1) gives
// St1 and pulldown (weak0) gives We0. In pullup (strong0, weak1) and
// pulldown (weak1, supply0) the strength for the other value is ignored:
// We1 and Su0. Verilator 5.054 does not support the strength of a pullup.

module test_pull_gate_instances_terminal_and_strength;
  wire n_up, n_dn, n_a, n_b, n_st, n_we, n_pair1, n_pair0;

  pullup u_up (n_up);
  pulldown u_dn (n_dn);
  pullup u_a (n_a), (n_b);
  pullup (strong1) u_st (n_st);
  pulldown (weak0) u_we (n_we);
  pullup (strong0, weak1) u_pair1 (n_pair1);
  pulldown (weak1, supply0) u_pair0 (n_pair0);

  initial begin
    #1;
    $display("pullup %v, pulldown %v", n_up, n_dn);
    $display("named %v, unnamed %v", n_a, n_b);
    $display("pullup (strong1) %v, pulldown (weak0) %v", n_st, n_we);
    $display("pullup (strong0, weak1) %v, pulldown (weak1, supply0) %v", n_pair1, n_pair0);
  end
endmodule
