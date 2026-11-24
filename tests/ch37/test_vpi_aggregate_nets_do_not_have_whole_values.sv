/*
:name: test_vpi_aggregate_nets_do_not_have_whole_values
:description: VPI exposes array, unpacked structure and union, and interconnect net objects without a whole value
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.16 6.6.7 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_aggregate_nets_do_not_have_whole_values.expected
:vpi_c: @test_vpi_aggregate_nets_do_not_have_whole_values.c
*/
module net_value_pullup(inout tri1 channel, output wire sample);
  assign sample = channel;
endmodule

module test_vpi_aggregate_nets_do_not_have_whole_values;
  typedef struct { logic [7:0] left; logic [7:0] right; } record_t;
  typedef union { logic [7:0] view; logic [7:0] alternate; } choice_t;
  nettype record_t record_nettype;
  nettype choice_t choice_nettype;

  wire [7:0] ordinary;
  wire [7:0] bank[0:1];
  record_nettype record_bus;
  choice_nettype choice_bus;
  interconnect routes[0:1];
  record_t record_source;
  choice_t choice_source;
  wire sample0, sample1;

  assign ordinary = 8'h35;
  assign bank[0] = 8'h52;
  assign bank[1] = 8'h6b;
  assign record_bus = record_source;
  assign choice_bus = choice_source;
  net_value_pullup first(routes[0], sample0);
  net_value_pullup second(routes[1], sample1);

  initial begin
    record_source = '{left:8'h19, right:8'h97};
    choice_source.view = 8'ha6;
    #1 $vt_probe_whole_nets;
    $display("controls record=%h %h union_source=%h pulled=%b%b",
             record_bus.left, record_bus.right, choice_source.view, sample0, sample1);
  end
endmodule
