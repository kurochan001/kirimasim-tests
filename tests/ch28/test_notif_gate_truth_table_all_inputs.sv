/*
:name: test_notif_gate_truth_table_all_inputs
:description: notif0 and notif1 give the output of Table 28-5 for every data and control value 0, 1, x and z, including H and L for an unknown control (IEEE 1800-2023 Section 28.6)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_notif_gate_truth_table_all_inputs.expected
*/
// IEEE 1800-2023 §28.6: the three-state gates notif0 and notif1 take their
// output, data input and control input in this order and drive the inverse
// of their data while the control is 0 (notif0) or 1 (notif1), and z while
// it has the other value (Table 28-5). A control that is x or z gives H
// (1 or z) for data 0 and L (0 or z) for data 1, and a data input that is x
// or z gives x unless the gate is off. Both gates share one data and one
// control variable, each drives its own net with the default strong
// strength, and every one of the 16 input pairs is shown with %v
// (21.2.1.4), which prints L and H as StL and StH.
// Icarus Verilog 13.0 shows StX instead of StH and StL for data 0 or 1 with
// a control that is x or z; Table 28-5 gives H and L there.

module test_notif_gate_truth_table_all_inputs;
  logic data, ctrl;
  wire o_notif0, o_notif1;

  notif0 g_notif0(o_notif0, data, ctrl);
  notif1 g_notif1(o_notif1, data, ctrl);

  logic vals[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        data = vals[i];
        ctrl = vals[j];
        #1 $display("data=%b ctrl=%b: notif0=%v notif1=%v", data, ctrl, o_notif0, o_notif1);
      end
    end
  end
endmodule
