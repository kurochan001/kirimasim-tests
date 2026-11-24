`timescale 1ns/1ns
`define PROVIDER_FEATURE_FLAG 81
`default_nettype none
module directive_unit_provider(output wire value);
  assign value = 1'b1;
endmodule
