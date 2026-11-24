/*
:name: test_packed_tagged_union_reads_only_defined_bits_of_small_or_void_member
:description: A packed tagged union preserves its tag and selected payload without testing unspecified bits
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_packed_tagged_union_reads_only_defined_bits_of_small_or_void_member.expected
*/
module test_packed_tagged_union_reads_only_defined_bits_of_small_or_void_member;
  typedef union tagged packed {
    void Empty;
    logic [2:0] Small;
    logic [11:0] Big;
  } packet;
  packet value;
  logic [13:0] before_small, after_small, before_void, after_void;

  initial begin
    value = tagged Big 12'hfff;
    value = tagged Small 3'b101;
    before_small = value;
    value = tagged Empty;
    before_void = value;

    value = tagged Big 12'h000;
    value = tagged Small 3'b010;
    after_small = value;
    value = tagged Empty;
    after_void = value;

    // The slice between the tag and Small is unspecified. For Empty,
    // all payload bits are unspecified. No assertion uses those bits.
    $display("small tags agree=%0d payloads=%b,%b", before_small[13:12] == after_small[13:12],
             before_small[2:0], after_small[2:0]);
    $display("void tags agree=%0d differ from small=%0d", before_void[13:12] == after_void[13:12],
             before_void[13:12] != before_small[13:12]);
  end
endmodule
