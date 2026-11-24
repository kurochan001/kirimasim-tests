/*
:name: test_vpi_put_value_rejects_user_nettype_subelement
:description: A whole user-defined-nettype net and ordinary bit selects can be written while a user-defined-nettype bit select is excluded
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 6.6.7 38.20
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_put_value_rejects_user_nettype_subelement.expected
:vpi_c: @test_vpi_put_value_rejects_user_nettype_subelement.c
*/
module test_vpi_put_value_rejects_user_nettype_subelement;
  typedef logic [3:0] nibble;
  nettype nibble nibble_net;

  logic [3:0] source = '0;
  wire [3:0] ordinary;
  nibble_net typed_net;
  logic [3:0] variable_bits = '0;

  assign ordinary = source;
  assign typed_net = source;

  initial begin
    #1 $vt_put_legal_targets;
    #1 $display("legal typed=%h net=%h variable=%h", typed_net, ordinary, variable_bits);
    $vt_put_excluded_target;
    #1 $display("after excluded put typed=%h", typed_net);
  end
endmodule
