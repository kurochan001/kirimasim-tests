/*
:name: test_wide_stream_unpack_inverts_short_chunk_permutation
:description: Packing and unpacking a wide stream with a short final chunk use opposite permutations
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.2 11.4.14.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_wide_stream_unpack_inverts_short_chunk_permutation.expected
*/
`timescale 1ns/1ns
module wide_stream_permutation(input logic [96:0] seed,
                              output logic [96:0] packed_once, packed_twice,
                              output logic [96:0] unpacked, check_round_trip,
                              output logic [96:0] rightwards, oversized);
  always_comb begin
    packed_once = {<<7{seed}};
    packed_twice = {<<7{packed_once}};
    {<<7{unpacked}} = seed;
    check_round_trip = {<<7{unpacked}};
    rightwards = {>>11{seed}};
    oversized = {<<128{seed}};
  end

`ifdef FORMAL
  logic [96:0] forward_reference, inverse_reference, twice_reference;
  function automatic int stream_position(input int original_position);
    int chunk_start, chunk_size;
    chunk_start = 7 * (original_position / 7);
    chunk_size = (chunk_start + 7 <= 97) ? 7 : 97 - chunk_start;
    return 97 - chunk_start - chunk_size + (original_position - chunk_start);
  endfunction

  always_comb begin
    forward_reference = 0;
    inverse_reference = 0;
    twice_reference = 0;
    for (int position = 0; position < 97; position++) begin
      forward_reference[stream_position(position)] = seed[position];
      inverse_reference[position] = seed[stream_position(position)];
    end
    for (int position = 0; position < 97; position++)
      twice_reference[stream_position(position)] = forward_reference[position];

    assert (packed_once == forward_reference);
    assert (packed_twice == twice_reference);
    assert (unpacked == inverse_reference);
    assert (check_round_trip == seed);
    assert (rightwards == seed);
    assert (oversized == seed);
  end
`endif
endmodule

`ifndef FORMAL
module test_wide_stream_unpack_inverts_short_chunk_permutation;
  logic [96:0] seed;
  wire [96:0] packed_once, packed_twice, unpacked, check_round_trip, rightwards, oversized;
  wide_stream_permutation dut(seed, packed_once, packed_twice, unpacked,
                              check_round_trip, rightwards, oversized);
  task automatic sample(input string label_text, input logic [96:0] value);
    seed = value;
    #1;
    $display("%s packed=%h twice=%h unpacked=%h", label_text, packed_once, packed_twice, unpacked);
    $display("%s round=%b right=%b large=%b", label_text,
             check_round_trip === seed, rightwards === seed, oversized === seed);
  endtask

  initial begin
    sample("mixed", 97'h1_1234_5678_9abc_def0_1020_3040);
    sample("ends", 97'h1_8000_0000_0000_0000_0000_0001);
    sample("boundary", 97'h0_7fff_0000_0000_0000_001f_ff80);
    $finish(0);
  end
endmodule
`endif
