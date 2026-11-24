/*
:name: test_directives_from_nested_include_persist_until_superseded
:description: Macro and default net type directives from a nested include affect later design elements until replaced
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.4 22.2 22.4 22.5.1 22.8
:oracle: spec iverilog@13.0
:spec_check: ai
:files: directive_extent/extent_wrapper.svh directive_extent/extent_switch.svh
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_directives_from_nested_include_persist_until_superseded.expected
*/
`timescale 1ns/1ns
`default_nettype wire
`define EXTENT_KIND 17

module extent_no_driver(output wire y);
endmodule

module extent_before(output wire sensed, output wire [7:0] selected);
  extent_no_driver u(outside_implicit);
  assign sensed = outside_implicit;
  assign selected = `EXTENT_KIND;
endmodule

`include "extent_wrapper.svh"

module extent_after_nested(output wire sensed, output wire [7:0] selected);
  extent_no_driver u(nested_implicit);
  assign sensed = nested_implicit;
  assign selected = `EXTENT_KIND;
endmodule

`default_nettype tri0
`undef EXTENT_KIND
`define EXTENT_KIND 31

module extent_after_override(output wire sensed, output wire [7:0] selected);
  extent_no_driver u(override_implicit);
  assign sensed = override_implicit;
  assign selected = `EXTENT_KIND;
endmodule

`default_nettype wire
`undef EXTENT_KIND

module test_directives_from_nested_include_persist_until_superseded;
  wire before_wire, nested_wire, override_wire;
  wire [7:0] before_value, nested_value, override_value;
  extent_before before_change(before_wire, before_value);
  extent_after_nested after_include(nested_wire, nested_value);
  extent_after_override after_override(override_wire, override_value);
  initial begin
    #1 $display("nets=%b/%b/%b macros=%0d/%0d/%0d",
                before_wire, nested_wire, override_wire,
                before_value, nested_value, override_value);
    $finish(0);
  end
endmodule
