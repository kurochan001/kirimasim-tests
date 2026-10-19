/*
:name: test_net_delay_port_driver_and_undriven
:description: A net delay also delays changes that come through a variable output port of a child module, and an undriven net with a net delay stays z (IEEE 1800-2023 Section 10.3.3)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3.3 23.3.3.2 6.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_delay_port_driver_and_undriven.expected
*/
// IEEE 1800-2023 §10.3.3: a net delay delays every value change applied to
// the net. A net connected to a variable output port of a child module is
// driven by that port as by a continuous assignment (23.3.3.2), so the
// changes of the port take effect after the net delay too. A net delay is
// not a driver: a net with a delay and no driver has the value z (6.6), as
// one without a delay does.

module var_driver (output logic o);
  initial begin
    o = 0;
    #10 o = 1;
  end
endmodule

module test_net_delay_port_driver_and_undriven;
  wire #5 nv;
  wire #5 undriven;
  wire [3:0] #5 undriven_vec;

  var_driver dv (nv);

  initial begin
    #12 $display("t=%0d nv=%b", $time, nv);
    #4 $display("t=%0d nv=%b", $time, nv);
    $display("undriven=%b undriven_vec=%b", undriven, undriven_vec);
  end
endmodule
