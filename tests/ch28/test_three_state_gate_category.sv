/*
:name: test_three_state_gate_category
:description: bufif0, bufif1, notif0 and notif1 are three-state gates with an output, a data input and a control input, which drive z while their control disables them (IEEE 1800-2023 Section 28.3.1)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.3.1 28.6
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_three_state_gate_category.expected
*/
// IEEE 1800-2023 §28.3.1, Table 28-1: bufif0, bufif1, notif0 and notif1 are
// the three-state gates. §28.6: such a gate has an output, a data input and
// a control input, in that order. bufif1 and notif1 are enabled while the
// control is 1, bufif0 and notif0 while it is 0; an enabled bufif passes the
// data and an enabled notif inverts it, and a disabled gate drives z.
// Each gate drives a net of its own, and the data and control inputs take
// all four pairs of 0 and 1. With data and control different, a gate that
// took its second terminal as the control would give another result.

module test_three_state_gate_category;
  logic d, c;
  wire y_bufif0, y_bufif1, y_notif0, y_notif1;

  bufif0 g1 (y_bufif0, d, c);
  bufif1 g2 (y_bufif1, d, c);
  notif0 g3 (y_notif0, d, c);
  notif1 g4 (y_notif1, d, c);

  initial begin
    for (int i = 0; i < 4; i++) begin
      {c, d} = i[1:0];
      #1 $display("d=%b c=%b: bufif0=%b bufif1=%b notif0=%b notif1=%b",
                  d, c, y_bufif0, y_bufif1, y_notif0, y_notif1);
    end
  end
endmodule
