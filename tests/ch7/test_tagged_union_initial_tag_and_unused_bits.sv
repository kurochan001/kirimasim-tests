/*
:name: test_tagged_union_initial_tag_and_unused_bits
:description: An uninitialized tagged union matches no member and later tags select their payloads
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_tagged_union_initial_tag_and_unused_bits.expected
*/
module test_tagged_union_initial_tag_and_unused_bits;
  typedef union tagged packed {
    void Empty;
    logic [2:0] Short;
    logic [11:0] Long;
  } packet_t;
  packet_t packet;
  logic [13:0] initial_bits, short_ones, short_zeroes, empty_ones, empty_zeroes;
  bit recognized;

  initial begin
    initial_bits = packet;
    case (packet) matches
      tagged Empty: recognized = 1;
      tagged Short .short_member: recognized = 1;
      tagged Long .long_member: recognized = 1;
      default: recognized = 0;
    endcase
    $display("initial tag matches a member=%b", recognized);

    packet = tagged Long 12'hfff;
    packet = tagged Short 3'b110;
    short_ones = packet;
    packet = tagged Long 12'hfff;
    packet = tagged Empty;
    empty_ones = packet;

    packet = tagged Long 12'h000;
    packet = tagged Short 3'b011;
    short_zeroes = packet;
    packet = tagged Long 12'h000;
    packet = tagged Empty;
    empty_zeroes = packet;
    $display("short tags agree=%b payloads=%b,%b", short_ones[13:12] == short_zeroes[13:12],
             short_ones[2:0], short_zeroes[2:0]);
    $display("empty tags agree=%b differ from short=%b", empty_ones[13:12] == empty_zeroes[13:12],
             empty_ones[13:12] != short_ones[13:12]);
    if ($test$plusargs("observe_raw"))
      $display("initial=%b short gaps=%b,%b empty payloads=%b,%b",
               initial_bits, short_ones[11:3], short_zeroes[11:3],
               empty_ones[11:0], empty_zeroes[11:0]);
    $finish(0);
  end
endmodule
