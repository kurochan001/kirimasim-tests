/*
:name: test_vpi_put_value_force_net_bit
:description: vpi_put_value with vpiForceFlag forces a constant bit-select of a vector net over its continuous assignment, and with vpiReleaseFlag releases it so that the bit takes the value of the driver at once, as a procedural force and release of the bit would (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2 38.19 38.36.2 38.36.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_force_net_bit.c
:expected_stdout: @test_vpi_put_value_force_net_bit.expected
*/
// IEEE 1800-2023 §38.34: vpi_put_value with vpiForceFlag and vpiReleaseFlag
// forces and releases the same kinds of objects as the procedural force and
// release, with the same effect; 10.6.2 allows a constant bit-select of a
// vector net. A forced bit keeps its value whatever the drivers of the net
// do, and after the release it takes the value of the drivers at once; the
// other bits follow the driver all along. The application gets m[0] with
// vpi_handle_by_index (38.19) and, in cbAfterDelay callbacks (38.36.2)
// registered at the start of the simulation (38.36.3), forces it to 1 at 15
// and releases it at 25, reading m right after each call. The design drives
// m with drv, 10 and then 12 from 20, and prints m at 21 and 31.
// Icarus Verilog 13.0 does not support force and release of a net bit
// through vpi_put_value.

`timescale 1ns/1ns

module test_vpi_put_value_force_net_bit;
  logic [7:0] drv;
  wire [7:0] m;

  assign m = drv;

  initial begin
    drv = 10;
    #20 drv = 12;
    #1 $display("21: design m=%0d", m);
    #10 $display("31: design m=%0d", m);
  end
endmodule
