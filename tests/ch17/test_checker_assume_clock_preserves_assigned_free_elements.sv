/*
:name: test_checker_assume_clock_preserves_assigned_free_elements
:description: An assume clock preserves assigned free scalars and packed aggregates
:tags: ch17
:type: simulation
:lrm: 1800-2023 17.7.2 17.7.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_checker_assume_clock_preserves_assigned_free_elements
:expected_stdout: @test_checker_assume_clock_preserves_assigned_free_elements.expected
*/
`timescale 1ns/1ns

checker assigned_elements(input bit solve_clock, input bit write_clock,
                          input bit formal_value, output bit [7:0] scalar_out,
                          output bit [7:0] packed_out, output bit [7:0] element_out,
                          output bit [7:0] fixed_out, output bit [7:0] ordinary_out,
                          output bit [7:0] packed_struct_out, unpacked_field_out);
  typedef struct packed { bit [3:0] high, low; } packed_fields;
  typedef struct { bit [7:0] controlled, unassigned; } unpacked_fields;
  rand bit [7:0] scalar_value = 8'h25;
  rand bit [7:0] packed_value = 8'ha6;
  rand bit [7:0] elements[2] = '{8'h71, 8'h4d};
  rand const bit [7:0] fixed_value = 8'h39;
  bit [7:0] ordinary = 8'hc2;
  rand packed_fields packed_struct = 8'ha4;
  rand unpacked_fields unpacked_struct = '{8'h91, 8'hb2};

  always_ff @(posedge write_clock) begin
    scalar_value <= scalar_value + 8'd3;
    packed_value[0] <= !packed_value[0];
    elements[0] <= elements[0] - 8'd2;
    ordinary <= ordinary + 8'd1;
    packed_struct.low <= 4'hb;
    unpacked_struct.controlled <= unpacked_struct.controlled + 8'd1;
  end

  // Use the separate unpacked element in an assumption without requiring the
  // randomizer to find a particular value. Neither outcome changes the checks.
  at_solve: assume property (@(posedge solve_clock)
    ^{elements[1], unpacked_struct.unassigned, scalar_value, packed_value,
      elements[0], packed_struct, unpacked_struct.controlled, fixed_value,
      ordinary, formal_value})
    $display("assumption t=%0d", $time);
  else
    $display("assumption t=%0d", $time);

  assign scalar_out = scalar_value;
  assign packed_out = packed_value;
  assign element_out = elements[0];
  assign fixed_out = fixed_value;
  assign ordinary_out = ordinary;
  assign packed_struct_out = packed_struct;
  assign unpacked_field_out = unpacked_struct.controlled;
endchecker

module test_checker_assume_clock_preserves_assigned_free_elements;
  bit solve_clock, write_clock, formal_value = 1;
  wire [7:0] scalar_out, packed_out, element_out, fixed_out, ordinary_out;
  wire [7:0] packed_struct_out, unpacked_field_out;
  assigned_elements u(solve_clock, write_clock, formal_value,
                      scalar_out, packed_out, element_out, fixed_out, ordinary_out,
                      packed_struct_out, unpacked_field_out);

  task automatic record(input string phase);
    $display("%s scalar=%02h packed=%02h element=%02h const=%02h ordinary=%02h",
             phase, scalar_out, packed_out, element_out, fixed_out, ordinary_out);
    $display("structs packed=%02h unpacked field=%02h",
             packed_struct_out, unpacked_field_out);
  endtask

  initial begin
    #1 record("initial");
    #4 solve_clock = 1;
    #1 record("first solve");
    #2 solve_clock = 0;
    #2 write_clock = 1;
    #1 record("write");
    #4 solve_clock = 1;
    #1 record("second solve");
    $finish;
  end
endmodule
