/*
:name: test_bitstream_cast_source_domain
:description: a bit-stream cast is four-state when any source part is four-state and the recursive bit-stream types include string, class, dynamic, associative and queue data
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_bitstream_cast_source_domain.expected
*/
// IEEE 1800-2023 6.24.3: the generic packed value is four-state if any part
// of the source is four-state, and a four-state value assigned to a 2-state
// destination part is assigned as if cast to 2-state, that is x and z become
// 0. A bit-stream type is defined recursively to include integral, packed and
// string types, unpacked arrays, structures and classes of those, and dynamic,
// associative and queue arrays of them. The test casts a struct that contains
// a queue, a string and an unpacked array, casts a class handle, a dynamic
// array and an associative array, and casts a four-state vector to both a
// four-state and a two-state destination. A tool that makes the whole stream
// two-state, or that drops a dynamic part, differs.

typedef struct {
  byte h;
  int q[$];
  string s;
  byte a[2];
} rec_t;
typedef bit [103:0] b104_t;
typedef bit [31:0] b32_t;
typedef bit [7:0] b8_t;
typedef logic [7:0] l8_t;

class c_t;
  byte b;
endclass

module test_bitstream_cast_source_domain;
  rec_t rec;
  c_t c = new;
  int da[];
  int aa[int];
  logic [7:0] s4 = 8'b1x0z0011;
  bit [7:0] two = 8'b1010_0101;
  b104_t v;

  initial begin
    rec.h = 8'h5a;
    rec.q.push_back(32'h0000_0001);
    rec.q.push_back(32'h0000_0002);
    rec.s = "AB";
    rec.a[0] = 8'h11;
    rec.a[1] = 8'h22;
    v = b104_t'(rec);
    $display("rec=%026x", v);
    c.b = 8'h77;
    $display("class=%02x", b8_t'(c));
    da = new[1];
    da[0] = 32'hdead_beef;
    aa[5] = 32'hfeed_face;
    $display("dyn=%08x assoc=%08x", b32_t'(da), b32_t'(aa));
    $display("b=%b l=%b l2=%b", b8_t'(s4), l8_t'(s4), l8_t'(two));
  end
endmodule
