/*
:name: test_seven_design_element_keywords_coexist_in_one_source_file
:description: Seven design element kinds coexist, including a selected configuration and a program that observes the NBA update
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.2 24.4 33.4.1.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_seven_design_element_keywords_coexist_in_one_source_file.expected
:top_module: taxonomy_configuration
*/
`timescale 1ns/1ns

package taxonomy_values;
  localparam int DEFAULT_ROUTE = 19;
  localparam int CONFIGURED_ROUTE = 73;
endpackage

interface taxonomy_bus(input wire source);
  wire inverted = !source;
endinterface

primitive taxonomy_udp(result, source);
  output result;
  input source;
  table
    0 : 1;
    1 : 0;
    x : x;
  endtable
endprimitive

program taxonomy_program(input wire observed, input wire scheduled);
  initial begin
    #2 $display("program observed=%b after-nba=%b", observed, scheduled);
    #4 $display("program after drive=%b", observed);
  end
endprogram

checker taxonomy_checker(input logic observed, output logic [3:0] proof);
  assign proof = observed ? 4'd13 : 4'd0;
endchecker

module taxonomy_default_cell(output wire [7:0] route);
  assign route = 8'(taxonomy_values::DEFAULT_ROUTE);
endmodule

module taxonomy_configured_cell(output wire [7:0] route);
  assign route = 8'(taxonomy_values::CONFIGURED_ROUTE);
endmodule

module test_seven_design_element_keywords_coexist_in_one_source_file;
  logic source = 1;
  logic scheduled = 0;
  wire [3:0] proof;
  wire observed;
  wire [7:0] route;
  taxonomy_bus bus(source);
  taxonomy_udp source_output(observed, bus.inverted);
  taxonomy_program observer(observed, scheduled);
  taxonomy_checker assertion_monitor(observed, proof);
  taxonomy_default_cell selected_cell(route);

  initial begin
    #1 $display("module route=%0d interface=%b primitive=%b checker=%0d",
                route, bus.inverted, observed, proof);
    #2 source = 0;
    #1 $display("after drive interface=%b primitive=%b checker=%0d", bus.inverted, observed, proof);
  end

  initial begin
    #2 $display("module before-nba=%b", scheduled);
    scheduled <= 1;
  end
endmodule

config taxonomy_default_configuration;
  design work.test_seven_design_element_keywords_coexist_in_one_source_file;
  default liblist work;
endconfig

config taxonomy_configuration;
  design work.test_seven_design_element_keywords_coexist_in_one_source_file;
  default liblist work;
  instance test_seven_design_element_keywords_coexist_in_one_source_file.selected_cell
      use work.taxonomy_configured_cell;
endconfig
