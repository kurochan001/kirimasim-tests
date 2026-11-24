/*
:name: test_dpi_open_array_pointer_and_size_distinguish_native_and_packed
:description: The DPI reports byte size and pointer access only for an array in C layout
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.3.2 I.3 H.7.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_dpi_open_array_pointer_and_size_distinguish_native_and_packed.expected
:dpi_c: @test_dpi_open_array_pointer_and_size_distinguish_native_and_packed.c
*/
module test_dpi_open_array_pointer_and_size_distinguish_native_and_packed;
  import "DPI-C" function void inspect_layout(input int native_values[],
                                              input logic [5:0] packed_words[]);

  int native_values [2:4];
  logic [5:0] packed_words [4:2];

  initial begin
    native_values = '{31, 47, 59};
    packed_words[2] = 6'b01x0z1;
    packed_words[3] = 6'b110011;
    packed_words[4] = 6'b0z10x1;
    inspect_layout(native_values, packed_words);
  end
endmodule
