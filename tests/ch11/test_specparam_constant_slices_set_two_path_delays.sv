/*
:name: test_specparam_constant_slices_set_two_path_delays
:description: Two constant slices of one specparam select distinct rise and fall delays in a specify path
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 30.4 30.5.1 6.20.5 A.8.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_specparam_constant_slices_set_two_path_delays.expected
*/
`timescale 1ns/1ns
module specparam_slice_path(input wire source, output wire result);
  assign result = source;
  specify
    specparam [7:0] DELAYS = 8'h74;
    (source => result) = (DELAYS[6:4], DELAYS[3:1]);
  endspecify
endmodule

module test_specparam_constant_slices_set_two_path_delays;
  logic driving = 0;
  wire observed;
  specparam_slice_path path_instance(driving, observed);

  initial begin
    #10 driving = 1;
    #6 $display("rise before=%b", observed);
    #2 $display("rise after=%b", observed);
    #2 driving = 0;
    #1 $display("fall before=%b", observed);
    #2 $display("fall after=%b", observed);
    $finish(0);
  end
endmodule
