/*
:name: test_final_vpi_control_finish_inside_final
:description: vpi_control(vpiFinish, 0) called from a system task inside a final procedure ends the simulation at once, so the rest of the final procedure does not run and it does not run again (IEEE 1800-2023 Section 9.2.3)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.3 38.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_final_vpi_control_finish_inside_final.c
:expected_stdout: @test_final_vpi_control_finish_inside_final.expected
*/
// IEEE 1800-2023 §9.2.3: calling vpi_control(vpiFinish, ...) from within a
// final procedure ends the simulation immediately, as $finish does there,
// and a final procedure is triggered only once. The VPI application
// registers $vt_finish, whose calltf routine calls vpi_control(vpiFinish, 0)
// (38.4: $finish(0) takes effect when the routine returns).
//
// The simulation ends by $finish at time 5. The final procedure counts its
// runs, prints the count, calls $vt_finish and would then print a second
// line. Only the first line, with run 1, is expected.

`timescale 1ns/1ns
module test_final_vpi_control_finish_inside_final;
  int runs = 0;

  initial #5 $finish;

  final begin
    runs++;
    $display("final at t=%0t, run %0d", $time, runs);
    $vt_finish;
    $display("after vpi_control in final, run %0d", runs);
  end
endmodule
