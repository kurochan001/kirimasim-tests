/*
:name: test_vpi_put_value_net_deposit
:description: A value that vpi_put_value puts on a net or a net bit with vpiNoDelay, vpiInertialDelay, vpiTransportDelay or vpiPureTransportDelay overrides the resolved value of the net until a driver of the net changes, when the net takes its resolved value again (IEEE 1800-2023 Section 38.34)
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 38.19 38.36.2 38.36.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_put_value_net_deposit.c
:expected_stdout: @test_vpi_put_value_net_deposit.expected
*/
// IEEE 1800-2023 §38.34: when vpi_put_value is called for a vpiNet or a
// vpiNetBit with vpiInertialDelay, vpiTransportDelay, vpiPureTransportDelay
// or vpiNoDelay, the value overrides the resolved value of the net; it stays
// until one of the drivers of the net changes value, and the net is then
// evaluated again from its drivers. Five nets are driven by drv, which is 10
// until 20 and 20 afterwards. In a cbAfterDelay callback at 5 (38.36.2),
// registered at the start of the simulation (38.36.3), the application puts
// 99 into n_nd with vpiNoDelay and, with a delay of 2, into n_in, n_tr and
// n_pt with the three delay modes, and 1 into bit 0 of n_bit, obtained with
// vpi_handle_by_index (38.19), with vpiNoDelay. The design prints the nets at
// 8, 15 and 22.

`timescale 1ns/1ns

module test_vpi_put_value_net_deposit;
  logic [7:0] drv;
  wire [7:0] n_nd, n_in, n_tr, n_pt, n_bit;

  assign n_nd = drv;
  assign n_in = drv;
  assign n_tr = drv;
  assign n_pt = drv;
  assign n_bit = drv;

  initial begin
    drv = 10;
    #8 $display("8: n_nd=%0d n_in=%0d n_tr=%0d n_pt=%0d n_bit=%0d", n_nd, n_in, n_tr, n_pt, n_bit);
    #7 $display("15: n_nd=%0d n_in=%0d n_tr=%0d n_pt=%0d n_bit=%0d", n_nd, n_in, n_tr, n_pt, n_bit);
    #5 drv = 20;
    #2 $display("22: n_nd=%0d n_in=%0d n_tr=%0d n_pt=%0d n_bit=%0d", n_nd, n_in, n_tr, n_pt, n_bit);
  end
endmodule
