/*
:name: test_alias_chain_with_typed_net_assignment_pattern
:description: A net alias chain includes a typed assignment-pattern lvalue and a swapped concatenation
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11 A.8.5 A.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_chain_with_typed_net_assignment_pattern.expected
*/
`timescale 1ns/1ns
module test_alias_chain_with_typed_net_assignment_pattern;
  typedef struct packed {
    logic [3:0] left;
    logic [3:0] right;
  } fields_t;

  wire fields_t typed_bus;
  wire [3:0] a, b;
  wire [7:0] swapped_bus;
  logic [3:0] high_driver = 4'ha;
  logic [3:0] low_driver = 4'h3;

  alias typed_bus[7:0] = fields_t'{a, b} = {swapped_bus[3:0], swapped_bus[7:4]};

  assign a = high_driver;
  assign swapped_bus[7:4] = low_driver;

  task automatic report;
    $display("typed=%h parts=%h%h swap=%h", typed_bus, a, b, swapped_bus);
  endtask

  initial begin
    #1 report();
    high_driver = 4'h5;
    low_driver = 4'h9;
    #1 report();
  end
endmodule
