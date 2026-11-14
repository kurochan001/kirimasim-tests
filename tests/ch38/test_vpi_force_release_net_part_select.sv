/*
:name: test_vpi_force_release_net_part_select
:description: vpi_put_value with vpiForceFlag forces a constant part-select of a vector net over its continuous assignment while the other bits follow the driver, and with vpiReleaseFlag releases it so that the bits take the value of the driver at once, as a procedural force and release of the part-select would (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_force_release_net_part_select.c
:expected_stdout: @test_vpi_force_release_net_part_select.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value with vpiForceFlag forces the objects
// that a procedural force can force, and with vpiReleaseFlag releases them,
// with the same effect as the procedural force and release; 10.6.2 allows a
// constant part-select of a vector net. The forced bits keep their value
// whatever the drivers of the net do, the other bits follow the drivers,
// and after the release the forced bits take the value of the drivers at
// once.
//
// The system task $vt_force gets the part-select np[5:3] as its argument and
// forces it to 3'b101 with vpiIntVal 5; $vt_release releases it. The design
// drives np with drv, 8'h00, then 8'hff from 12 and 8'h0f from 16, forces at
// 10, releases at 14 and prints np at 11, 13, 15 and 17. The 5.054 release
// of Verilator does not run system tasks that a VPI application registers.

`timescale 1ns/1ns

module test_vpi_force_release_net_part_select;
  logic [7:0] drv;
  wire [7:0] np;

  assign np = drv;

  initial begin
    drv = 8'h00;
    #10 $vt_force(np[5:3]);
    #1 $display("11: np=%h", np);
    #1 drv = 8'hff;
    #1 $display("13: np=%h", np);
    #1 $vt_release(np[5:3]);
    #1 $display("15: np=%h", np);
    #1 drv = 8'h0f;
    #1 $display("17: np=%h", np);
    $finish;
  end
endmodule
