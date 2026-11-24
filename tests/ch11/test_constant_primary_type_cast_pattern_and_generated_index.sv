/*
:name: test_constant_primary_type_cast_pattern_and_generated_index
:description: Type references, assignment patterns and local generate indices contribute to constant expressions
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 6.23 6.24.1 27.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constant_primary_type_cast_pattern_and_generated_index.expected
*/
`timescale 1ns/1ns
module test_constant_primary_type_cast_pattern_and_generated_index;
  typedef bit [5:0] six_t;
  typedef struct packed {
    bit [2:0] high_bits;
    bit flag;
  } packed_t;

  localparam logic [7:0] MASK = 8'hb6;
  localparam six_t SAMPLE = 6'd0;
  localparam bit SAME = type(SAMPLE) == type(six_t);
  localparam bit DIFFERENT = type(SAMPLE) != type(logic [5:0]);
  localparam six_t NARROWED = type(SAMPLE)'(8'hd5);
  localparam packed_t VALUE = '{high_bits:3'h5, flag:1'b1};
  localparam bit [2:0] FILL = '1;
  localparam time INTERVAL = 4ns;

  wire [3:0] from_loop [2];
  for (genvar g = 0; g < 2; g++) begin : generated
    localparam bit [3:0] EXTRACT = MASK[g*4+:4];
    assign from_loop[g] = EXTRACT;
  end

  initial begin
    #1 $display("types=%b/%b cast=%0d pattern=%h fill=%b time=%0d gen=%h/%h",
                SAME, DIFFERENT, NARROWED, VALUE, FILL, INTERVAL, from_loop[0], from_loop[1]);
    $finish(0);
  end
endmodule
