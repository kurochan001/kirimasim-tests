/*
:name: test_wire_array_ports_preserve_positions_with_different_bounds
:description: Array input and output ports preserve element order with either matching or different index labels
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3.3 7.6 6.22.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wire_array_ports_preserve_positions_with_different_bounds.expected
*/
`timescale 1ns/1ns
module ordinal_port_writer(input wire [7:0] left, right,
                          output wire [7:0] bus [3:2], output wire [15:0] local_word);
  assign bus[3] = left;
  assign bus[2] = right;
  assign local_word = {bus[3], bus[2]};
endmodule

module ordinal_port_reader(input wire [7:0] bus [3:2], output wire [15:0] word_value);
  assign word_value = {bus[3], bus[2]};
endmodule

module test_wire_array_ports_preserve_positions_with_different_bounds;
  logic [7:0] left = 8'h25, right = 8'hd1;
  wire [7:0] matching [3:2], reversed [8:9], inputs_only [0:1];
  wire [15:0] local_match, local_reversed, received_match, received_reverse, direct_input;

  ordinal_port_writer first(left, right, matching, local_match);
  ordinal_port_writer second(left, right, reversed, local_reversed);
  ordinal_port_reader first_reader(matching, received_match);
  ordinal_port_reader second_reader(reversed, received_reverse);
  ordinal_port_reader input_reader(inputs_only, direct_input);
  assign inputs_only[0] = left;
  assign inputs_only[1] = right;

  task automatic sample(input string label_text);
    $display("%s inside=%h/%h outputs=%h%h/%h%h readers=%h/%h/%h",
             label_text, local_match, local_reversed, matching[3], matching[2],
             reversed[8], reversed[9], received_match, received_reverse, direct_input);
  endtask

  initial begin
    #1 sample("initial");
    left = 8'h6e;
    right = 8'h17;
    #1 sample("changed");
    $finish(0);
  end
endmodule
