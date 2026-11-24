/*
:name: test_resolved_user_nettype_counts_local_drivers_across_port_merges
:description: A user-defined resolver receives every driver once through a matching typed or interconnect port merge
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3 23.3.3.7.1 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_resolved_user_nettype_counts_local_drivers_across_port_merges.expected
*/
package local_driver_types;
  typedef bit [15:0] counted_value;

  function automatic counted_value resolve_drives(input counted_value drives[]);
    bit [7:0] sum = 0;
    foreach (drives[i]) sum += drives[i][7:0];
    return {8'(drives.size()), sum};
  endfunction

  nettype counted_value counted_net with resolve_drives;
endpackage

module local_nettype_driver import local_driver_types::*;
  (input bit [7:0] a, b, inout counted_net port_n);
  assign port_n = {8'd0, a};
  assign port_n = {8'd0, b};
endmodule

module local_nettype_reader import local_driver_types::*;
  (inout counted_net port_n, output wire [15:0] value);
  assign value = port_n;
endmodule

module test_resolved_user_nettype_counts_local_drivers_across_port_merges;
  import local_driver_types::*;
  bit [7:0] a = 8'h19, b = 8'h40;
  counted_net direct, typed;
  interconnect indirect;
  wire [15:0] typed_result, indirect_result;

  assign direct = {8'd0, a};
  assign direct = {8'd0, b};
  local_nettype_driver typed_driver(a, b, typed);
  local_nettype_driver indirect_driver(a, b, indirect);
  local_nettype_reader typed_reader(typed, typed_result);
  local_nettype_reader indirect_reader(indirect, indirect_result);

  initial begin
    #1;
    $display("before direct=%h typed=%h interconnect=%h", direct, typed_result, indirect_result);
    a = 8'h92;
    b = 8'hfb;
    #1;
    $display("after direct=%h typed=%h interconnect=%h", direct, typed_result, indirect_result);
  end
endmodule
