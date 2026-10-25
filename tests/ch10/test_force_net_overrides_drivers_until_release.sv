/*
:name: test_force_net_overrides_drivers_until_release
:description: a force on a net overrides its gate output, module output and continuous assignment drivers while they change, and a release gives the net the value of its drivers at once (IEEE 1800-2023 Section 10.6.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.6.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_force_net_overrides_drivers_until_release.expected
*/
// IEEE 1800-2023 §10.6.2: a force on a net overrides every driver of the
// net (gate outputs, module outputs and continuous assignments) until a
// release of the net is executed. When the net is released, it is assigned
// at once the value that its drivers determine.
//
// wg is driven by an and gate, wm by the output of a module instance and wc
// by a continuous assignment. All three drivers give 1 when the nets are
// forced to 0. While forced, the inputs change twice, so the drivers go to
// 0 and back to 1 (wc stays 1), and the nets stay 0. The statement right
// after the releases, in the same time step and without any delay, reads
// the value of the drivers. Afterwards the drivers again reach the nets.

module test_force_net_overrides_drivers_until_release_buf(output wire o, input logic i);
  assign o = i;
endmodule

module test_force_net_overrides_drivers_until_release;
  logic a = 0, b = 0;
  wire wg, wm, wc;

  and g1 (wg, a, b);
  test_force_net_overrides_drivers_until_release_buf u1 (.o(wm), .i(a));
  assign wc = a | b;

  initial begin
    #1 a = 1; b = 1;
    #1 $display("driven:         wg=%b wm=%b wc=%b", wg, wm, wc);
    force wg = 1'b0;
    force wm = 1'b0;
    force wc = 1'b0;
    #1 $display("forced:         wg=%b wm=%b wc=%b", wg, wm, wc);
    a = 0;
    #1 $display("forced, a=0:    wg=%b wm=%b wc=%b", wg, wm, wc);
    a = 1;
    #1 $display("forced, a=1:    wg=%b wm=%b wc=%b", wg, wm, wc);
    release wg;
    release wm;
    release wc;
    $display("just released:  wg=%b wm=%b wc=%b", wg, wm, wc);
    a = 0; b = 0;
    #1 $display("released, a=b=0: wg=%b wm=%b wc=%b", wg, wm, wc);
  end
endmodule
