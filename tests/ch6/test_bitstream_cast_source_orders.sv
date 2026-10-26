/*
:name: test_bitstream_cast_source_orders
:description: a bit-stream cast packs an associative array in index order and a dynamic array, queue or string with index zero at the most significant end
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bitstream_cast_source_orders.expected
*/
// IEEE 1800-2023 6.24.3: when a dynamically sized item is converted to the
// packed representation, the item at index 0 occupies the MSBs and later
// indices follow; an associative array is packed in index-sorted order with
// the first indexed element in the MSBs. The test casts a 3-entry int
// associative array with keys 1, 2 and 10, a 3-entry dynamic array, a byte
// queue and two strings to packed vectors. The associative array therefore
// begins with the value at key 1, and each other source begins with index 0.
// A tool that uses insertion order or puts index 0 at the LSB prints another
// value.

typedef bit [95:0] b96_t;
typedef bit [15:0] b16_t;
typedef bit [7:0] b8_t;

module test_bitstream_cast_source_orders;
  int aa[int];
  int d[];
  byte q[$];
  string s2 = "AB";
  string s1 = "A";
  b96_t va;
  b96_t vd;
  b16_t vq;
  b16_t vs;
  b8_t vs1;

  initial begin
    aa[2] = 32'h11111111;
    aa[10] = 32'h22222222;
    aa[1] = 32'h33333333;
    va = b96_t'(aa);
    d = new[3];
    d[0] = 32'hAAAA0001;
    d[1] = 32'hAAAA0002;
    d[2] = 32'hAAAA0003;
    vd = b96_t'(d);
    q.push_back(8'h12);
    q.push_back(8'h34);
    vq = b16_t'(q);
    vs = b16_t'(s2);
    vs1 = b8_t'(s1);
    $display("assoc=%024x", va);
    $display("dyn=%024x", vd);
    $display("queue=%04x", vq);
    $display("str=%04x str1=%02x", vs, vs1);
  end
endmodule
