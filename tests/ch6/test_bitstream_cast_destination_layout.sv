/*
:name: test_bitstream_cast_destination_layout
:description: a bit-stream cast fills destination items left to right, gives the remaining bits to the first unbounded dynamic item, and includes all dynamic source items
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitstream_cast_destination_layout.expected
*/
// IEEE 1800-2023 6.24.3: data are extracted into the destination in
// left-to-right order, so a dynamic item between fixed items takes bits from
// the middle. When the destination has unbounded dynamic items, the fixed
// size is subtracted from the source size and the first dynamic item gets the
// rest; later dynamic items stay empty. All dynamically sized items of the
// source are included wherever they stand. The first cast fills a, a two-byte
// middle array d and b from 32'h11223344; the second gives all four bytes to
// d1 and leaves d2 empty; the third packs a struct with a queue in the middle.
// A tool that fills the dynamic item last, or from the right, differs.

typedef struct {
  byte a;
  byte d[];
  byte b;
} dst_t;
typedef struct {
  byte d1[];
  byte d2[];
} greedy_t;
typedef struct {
  byte h;
  int q[$];
  shortint t;
} src_t;
typedef bit [87:0] b88_t;

module test_bitstream_cast_destination_layout;
  dst_t dst;
  greedy_t g;
  src_t src;
  b88_t v;

  initial begin
    dst = dst_t'(32'h11223344);
    $display("dst a=%02x d=%02x,%02x b=%02x size=%0d", dst.a, dst.d[0], dst.d[1],
             dst.b, dst.d.size());
    g = greedy_t'(32'h11223344);
    $display("greedy n1=%0d n2=%0d d=%02x%02x%02x%02x", g.d1.size(), g.d2.size(),
             g.d1[0], g.d1[1], g.d1[2], g.d1[3]);
    src.h = 8'h5a;
    src.q.push_back(32'h00000001);
    src.q.push_back(32'h00000002);
    src.t = 16'hbeef;
    v = b88_t'(src);
    $display("src=%022x", v);
  end
endmodule
