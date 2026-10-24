/*
:name: test_bufif_gate_truth_table_all_inputs
:description: bufif0 and bufif1 give the output of Table 28-5 for every data and control value 0, 1, x and z, shown with its strength (IEEE 1800-2023 Section 28.6)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.6 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bufif_gate_truth_table_all_inputs.expected
*/
// IEEE 1800-2023 §28.6: the three-state gates bufif0 and bufif1 take their
// output, data input and control input in this order and drive 0, 1, x or z
// as Table 28-5 says: bufif0 passes its data while the control is 0 and
// bufif1 while it is 1, and the gate drives z while the control has the
// other value. A control that is x or z gives L (0 or z) or H (1 or z) when
// the data is 0 or 1, and a data input that is x or z gives x unless the
// gate is off. Both gates share one data and one control variable, each
// drives its own net with the default strong strength, and every one of
// the 16 input pairs is shown with %v (21.2.1.4), which prints L and H as
// StL and StH.

module test_bufif_gate_truth_table_all_inputs;
  logic data, ctrl;
  wire o_bufif0, o_bufif1;

  bufif0 g_bufif0(o_bufif0, data, ctrl);
  bufif1 g_bufif1(o_bufif1, data, ctrl);

  logic vals[4] = '{1'b0, 1'b1, 1'bx, 1'bz};

  initial begin
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        data = vals[i];
        ctrl = vals[j];
        #1 $display("data=%b ctrl=%b: bufif0=%v bufif1=%v", data, ctrl, o_bufif0, o_bufif1);
      end
    end
  end
endmodule
