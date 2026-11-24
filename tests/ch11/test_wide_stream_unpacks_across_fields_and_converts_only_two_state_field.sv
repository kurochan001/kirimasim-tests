/*
:name: test_wide_stream_unpacks_across_fields_and_converts_only_two_state_field
:description: A stream spans several packed fields and converts unknown bits only where the target field is two state
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.2 11.4.14.3 6.11.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_wide_stream_unpacks_across_fields_and_converts_only_two_state_field.expected
*/
module test_wide_stream_unpacks_across_fields_and_converts_only_two_state_field;
  typedef logic [6:0] chunk_t;
  logic [0:5] header;
  logic [64:0] data_field;
  bit [25:0] tail;

  task automatic observe(input string label_text, input logic [96:0] packed_input);
    logic [96:0] repacked;
    {<<chunk_t{header, data_field, tail}} = packed_input;
    repacked = {<<chunk_t{header, data_field, tail}};
    $display("%s fields=%b/%b/%b", label_text, header, data_field, tail);
    $display("%s repacked=%b", label_text, repacked);
  endtask

  initial begin
    observe("mixed", {33'bx0001z0x0001z010001010x1001111000,
                       32'b1001101010111z001101111011110000,
                       32'b0001z000001000000011000001x0000z});
    observe("stripe", {33'b11z100x1z01001110x001110100111010,
                       32'b01110x0011101001110100111010011z,
                       32'b01001110z00111010011101001110x00});
    $finish(0);
  end
endmodule
