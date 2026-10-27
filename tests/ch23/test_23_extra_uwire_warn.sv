/*
:name: test_23_extra_uwire_warn
:description: With an internal uwire, Table 23-1 selects the internal uwire for an external wand or wor and marks the cell warn, as the merged net delay and the warning show (IEEE 1800-2023 Section 23.3.3.7)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.7 28.16 6.6.2 6.6.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_23_extra_uwire_warn.expected
:expected_stderr_regex: (?i)warning
*/
// IEEE 1800-2023 §23.3.3.7: when a port connects nets of different net
// types, the simulated net takes the net type that Table 23-1 selects and
// the delay specified for that net; the cells the table marks warn also
// issue a warning. For an internal uwire with an external wand or triand,
// and with an external wor or trior, the table selects the internal uwire
// and marks the cell warn. A uwire allows one driver only (§6.6.2), so each
// cell has its single driver inside the module and none outside.
// The internal uwire has delay 3 and the external wand and wor have delay
// 7. Choosing the internal uwire gives the merged net delay 3; keeping the
// external net would give delay 7, and adding the two would give 10.
// The driver d goes to 1 at time 10 and to 0 at time 30, and each cell is
// sampled 2, 5 and 9 time units after each change. Delay 3 reads
// 0, 1, 1, 1, 0, 0 (011100); delay 7 reads 0, 0, 1, 1, 1, 0 (001110). The
// :expected_stderr_regex: records the warning the table requires for these
// cells.
// Icarus Verilog 13.0 does not support net delays and Verilator 5.052
// rejects these uwire inout connections, so this expected output follows the
// standard alone; see the note below.

module uw_in_wand(w, d);
  parameter int D = 3;
  inout w;
  input d;
  uwire #(D) w;
  assign w = d;
endmodule

module uw_in_wor(w, d);
  parameter int D = 3;
  inout w;
  input d;
  uwire #(D) w;
  assign w = d;
endmodule

module test_23_extra_uwire_warn;
  logic d;
  wand #7 n_wand;
  wor #7 n_wor;
  uw_in_wand #(.D(3)) u_wand(n_wand, d);
  uw_in_wor #(.D(3)) u_wor(n_wor, d);
  logic [0:5] s_wand, s_wor;

  task automatic sample(int k);
    s_wand[k] = n_wand;
    s_wor[k] = n_wor;
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
    $display("uwire inside, wand outside: %b", s_wand);
    $display("uwire inside, wor outside:  %b", s_wor);
  end
endmodule
