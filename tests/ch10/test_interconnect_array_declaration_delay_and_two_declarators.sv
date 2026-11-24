/*
:name: test_interconnect_array_declaration_delay_and_two_declarators
:description: Two interconnect array declarators use the declared delay and acquire types through their connected array ports
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.3 6.7.1 23.3.3.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interconnect_array_declaration_delay_and_two_declarators.expected
*/
`timescale 1ns/1ns
module grammar_array_source(input wire [7:0] left, right, output wire [7:0] words [3:2]);
  assign words[3] = left;
  assign words[2] = right;
endmodule

module grammar_array_sink(input wire [7:0] words [0:1], output wire [15:0] flat);
  assign flat = {words[0], words[1]};
endmodule

module grammar_scalar_source(input wire [7:0] data_in, output wire [7:0] link);
  assign link = data_in;
endmodule

module grammar_scalar_sink(input wire [7:0] link, output wire [7:0] data_out);
  assign data_out = link;
endmodule

module test_interconnect_array_declaration_delay_and_two_declarators;
  logic [7:0] left = 8'h25, right = 8'hd1;
  wire [15:0] first, second, direct;
  wire [7:0] ordinary [9:8];
  interconnect #3 path_first [1:0], path_second [5:4];
  interconnect #3 scalar_first, scalar_second;
  wire [7:0] scalar_a, scalar_b;

  grammar_array_source first_source(left, right, path_first);
  grammar_array_source second_source(right, left, path_second);
  grammar_array_sink first_sink(path_first, first);
  grammar_array_sink second_sink(path_second, second);
  grammar_array_source direct_source(left, right, ordinary);
  grammar_array_sink direct_sink(ordinary, direct);
  grammar_scalar_source scalar_source_a(left, scalar_first);
  grammar_scalar_source scalar_source_b(right, scalar_second);
  grammar_scalar_sink scalar_sink_a(scalar_first, scalar_a);
  grammar_scalar_sink scalar_sink_b(scalar_second, scalar_b);

  task automatic sample(input string label_text);
    $display("%s arrays=%h/%h direct=%h scalar=%h/%h", label_text,
             first, second, direct, scalar_a, scalar_b);
  endtask

  initial begin
    #6 sample("settled");
    left = 8'h6e;
    #1 sample("before");
    #3 sample("after");
    $finish(0);
  end
endmodule
