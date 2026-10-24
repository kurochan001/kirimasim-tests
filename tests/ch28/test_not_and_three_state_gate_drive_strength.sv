/*
:name: test_not_and_three_state_gate_drive_strength
:description: not, bufif0, bufif1, notif0 and notif1 gates accept a drive strength, which sets the strength of the 0 and the 1 they drive (IEEE 1800-2023 Section 28.3.2)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.2 28.6 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_not_and_three_state_gate_drive_strength.expected
*/
// IEEE 1800-2023 §28.3.2: not and the four three-state gates are among the
// gate types that can have a drive strength, a strength0 and a strength1 in
// either order after the gate keyword. A 0 on the output then has the
// strength0 and a 1 the strength1. §28.6: a three-state gate drives z,
// shown by %v as HiZ (§21.2.1.4), while its control input disables it.
// Each gate has a different pair of strengths, none of them the default
// strong pair, and drives a net of its own. The data and control inputs
// take all four pairs of 0 and 1, so that each gate drives both a 0 and a 1
// while it is enabled.

module test_not_and_three_state_gate_drive_strength;
  logic d, en;
  wire y_not, y_bufif0, y_bufif1, y_notif0, y_notif1;

  not    (weak0, pull1)   g_not    (y_not, d);
  bufif0 (pull0, weak1)   g_bufif0 (y_bufif0, d, en);
  bufif1 (supply1, weak0) g_bufif1 (y_bufif1, d, en);
  notif0 (weak1, supply0) g_notif0 (y_notif0, d, en);
  notif1 (pull0, supply1) g_notif1 (y_notif1, d, en);

  task automatic show;
    $display("d=%b en=%b not=%v bufif0=%v bufif1=%v notif0=%v notif1=%v",
             d, en, y_not, y_bufif0, y_bufif1, y_notif0, y_notif1);
  endtask

  initial begin
    d = 0; en = 0;
    #1 show;
    d = 1; en = 0;
    #1 show;
    d = 0; en = 1;
    #1 show;
    d = 1; en = 1;
    #1 show;
  end
endmodule
