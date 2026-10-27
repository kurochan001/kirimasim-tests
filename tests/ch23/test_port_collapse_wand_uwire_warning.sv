/*
:name: test_port_collapse_wand_uwire_warning
:description: A wand or triand port connected to an outer uwire net merges into the external uwire net, whose delay the simulated net takes, and the connection issues the warning Table 23-1 marks (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.3 6.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_collapse_wand_uwire_warning.expected
:expected_stderr_regex: (?i)warning
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets, the simulated net
// takes the net type that Table 23-1 selects and "the delay specified for
// the dominating net"; the cells the table marks warn also issue a warning.
// The wand/triand row selects the external net with a warning when the
// internal net is a wand or triand and the external net is a uwire. A
// uwire net allows a single driver only (§6.6.2) and passes that driver,
// so with one driver the value cannot show which of the two declarations
// the table selected; the net delay each declaration specifies (§28.16)
// can. Each cell has the one driver inside the module, so the design stays
// legal whichever net is chosen. The internal declaration has delay 3 and
// the external uwire has delay 7. Choosing the external uwire, as the
// table says, gives the merged net delay 7; keeping the internal wand or
// triand would give delay 3, adding the two delays would give 10 and no
// delay 0.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. Delay 7 reads
// 0, 0, 1, 1, 1, 0 (001110); delay 3 would read 011100, delay 10 000111
// and no delay 111000. The :expected_stderr_regex: records the warning the
// table requires for these cells. Icarus Verilog 13.0 does not support net
// delays and issues no such warning, so this expected output follows the
// standard alone.

module pcwu_in_wand(w, d);
  parameter int D = 3;
  inout w;
  input d;
  wand #(D) w;
  assign w = d;
endmodule

module pcwu_in_triand(w, d);
  parameter int D = 3;
  inout w;
  input d;
  triand #(D) w;
  assign w = d;
endmodule

module test_port_collapse_wand_uwire_warning;
  logic d;

  uwire #7 n_wand, n_triand;
  pcwu_in_wand #(.D(3)) u_wand(n_wand, d);
  pcwu_in_triand #(.D(3)) u_triand(n_triand, d);

  logic [0:5] s_wand, s_triand;

  task automatic sample(int k);
    s_wand[k] = n_wand;
    s_triand[k] = n_triand;
  endtask

  initial begin
    d = 1'b0;
    #10 d = 1'b1;
    #2 sample(0);
    #3 sample(1);
    #4 sample(2);
    #11 d = 1'b0;
    #2 sample(3);
    #3 sample(4);
    #4 sample(5);
    $display("wand inside, uwire outside:   %b", s_wand);
    $display("triand inside, uwire outside: %b", s_triand);
  end
endmodule
