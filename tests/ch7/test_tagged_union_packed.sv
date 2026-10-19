/*
:name: test_tagged_union_packed
:description: a packed tagged union has the minimum number of tag bits for its members at the most significant end and each member right-justified, tagged union expressions set the tag and the member together, and the member of the current tag can be read and written with dot notation (IEEE 1800-2023 Sections 7.3.2, 11.9)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9 20.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_packed.expected
*/
// IEEE 1800-2023 §7.3.2: a packed tagged union is as wide as its tag plus its
// widest member; the tag is the minimum number of bits that codes all member
// names and is left-justified, each member is right-justified, and the bits in
// between are undefined. Three members need two tag bits, so pk_t is 2 + 8
// bits wide ($bits, §20.6.2), and the tags of Off, Small and Big are 0, 1 and
// 2, in declaration order. §11.9: tagged Member value sets the tag and the
// member together; the member of the current tag is read and written with dot
// notation. The test prints only the tag bits and the bits of the member.

module test_tagged_union_packed;
  typedef union tagged packed {
    void Off;
    logic [3:0] Small;
    logic [7:0] Big;
  } pk_t;

  typedef union tagged {
    int Count;
    struct { byte r, g, b; } Color;
  } item_t;

  pk_t p;
  logic [9:0] bits;
  item_t it;

  initial begin
    $display("$bits(pk_t) = %0d", $bits(pk_t));
    p = tagged Off;
    bits = p;
    $display("Off: tag %b", bits[9:8]);
    p = tagged Small 4'h9;
    bits = p;
    $display("Small: tag %b, member %h, p.Small %h", bits[9:8], bits[3:0], p.Small);
    p = tagged Big 8'ha5;
    bits = p;
    $display("Big: tag %b, member %h, p.Big %h", bits[9:8], bits[7:0], p.Big);
    p.Big = 8'h3c;
    bits = p;
    $display("after p.Big = 3c: tag %b, member %h", bits[9:8], bits[7:0]);

    it = tagged Count (40 + 2);
    $display("it.Count = %0d", it.Count);
    it = tagged Color '{b: 3, r: 1, g: 2};
    $display("it.Color = %0d %0d %0d", it.Color.r, it.Color.g, it.Color.b);
    it.Color.g = 20;
    $display("after it.Color.g = 20: %0d %0d %0d", it.Color.r, it.Color.g, it.Color.b);
  end
endmodule
