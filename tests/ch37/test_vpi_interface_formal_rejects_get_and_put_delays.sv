/*
:name: test_vpi_interface_formal_rejects_get_and_put_delays
:description: An interface formal rejects both delay routines while a module path exposes its delay
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.14 38.10 38.32
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_interface_formal_rejects_get_and_put_delays.expected
:expected_stderr_regex: (?im)\A(?=[\s\S]*^get delays error: [^\n]*(?:port|delay|object))(?=[\s\S]*^put delays error: [^\n]*(?:port|delay|object))[\s\S]*\Z
:vpi_c: @test_vpi_interface_formal_rejects_get_and_put_delays.c
*/
`timescale 1ns/1ns
interface delayed_port_interface;
  wire data;
endinterface

module delayed_port_model(delayed_port_interface bus, input wire a, output wire y);
  assign y = a ^ bus.data;

  specify
    (a => y) = 3;
  endspecify
endmodule

module test_vpi_interface_formal_rejects_get_and_put_delays;
  bit source;
  wire observed;
  delayed_port_interface bus();
  assign bus.data = 0;
  delayed_port_model instance_under_test(bus, source, observed);

  initial #1 $vt_probe_delays;
endmodule
