/*
:name: test_vpi_net_variable_bit_select_drivers
:description: vpiDriver and vpiLoad of a net bit-select with a variable index give the drivers and loads of the bit that the index selects when the iteration begins, so they change after the index changes (IEEE 1800-2023 Section 37.16)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 37.47 11.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_net_variable_bit_select_drivers.c
:expected_stdout: @test_vpi_net_variable_bit_select_drivers.expected
*/
// IEEE 1800-2023 §37.16: an iteration on the loads or drivers of a variable
// bit-select gives those of the bit that the bit-select refers to at the
// beginning of the iteration (detail 19). The right-hand side of the
// continuous assignment to y (37.47) is w[i] (11.5.1). Bit 0 of w is driven
// by the assignment from d0 and read by the assignment to z0, bit 1 by the
// assignment from d1 and the assignment to z1. With i = 0 the drivers and the
// other loads of w[i] are those of bit 0, and after i becomes 1 those of bit
// 1. The assignment to y itself reads both bits through w[i], so it is left
// out of the loads; w is not connected to any port, so no net collapsing can
// add drivers or loads.

module test_vpi_net_variable_bit_select_drivers;
  logic d0 = 1'b0, d1 = 1'b1;
  int i = 0;
  wire [1:0] w;
  wire y, z0, z1;

  assign w[0] = d0;
  assign w[1] = d1;
  assign z0 = w[0];
  assign z1 = w[1];
  assign y = w[i];

  initial begin
    #1 $vt_select;
    i = 1;
    #1 $vt_select;
  end
endmodule
