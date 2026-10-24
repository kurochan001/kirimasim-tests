/*
:name: test_stream_dynamic_target_resize_and_bitstream_types
:description: a dynamic array or queue that receives a stream is resized to the fewest elements that hold it, padded with zeros on the right, and streaming packs integral types of every kind as well as unpacked arrays and structures, queues and strings (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14 11.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stream_dynamic_target_resize_and_bitstream_types.expected
*/
// IEEE 1800-2023 §11.4.14: when the target of a stream is a dynamic array
// or a queue, it is first resized to the smallest number of elements that is
// at least as wide as the stream, and the stream is then padded with zeros on
// the right to that width. 12 bits fill two bytes (ab c0), although the array
// had five elements before; 16 bits fill exactly two bytes; 40 bits fill two
// ints (the second one 55000000).
// Table 11-1 (§11.3) lists integral operands for the stream operators, and
// §11.4.14 packs any bit-stream type (§6.24.3). A packed structure, an
// enumeration and a packed array are packed left to right, and so are an
// unpacked array, an unpacked structure (members in declaration order), a
// queue (index 0 first) and a string (first character first). {<<8{...}}
// reverses the bytes of the stream of the unpacked array and structure.
// Icarus Verilog 13.0 does not support unpacked structures or streaming,
// and Verilator 5.052 does not stream strings or compile streams into
// dynamically sized targets.

module test_stream_dynamic_target_resize_and_bitstream_types;
  typedef struct packed { logic [3:0] hi, lo; } ps_t;
  typedef enum logic [7:0] { E0 = 8'h0f, E1 = 8'he1 } en_t;
  typedef struct { byte x; byte y; } us_t;
  logic [31:0] r32;
  byte d [];
  int q [$];
  ps_t ps = 8'h3c;
  en_t en = E1;
  logic [1:0][3:0] pa = 8'h96;
  byte ua [2] = '{8'ha1, 8'hb2};
  us_t us = '{8'h01, 8'h02};
  byte qq [$] = '{8'h77, 8'h88};
  string s = "Hi";

  initial begin
    d = new[5];
    d = {>>{12'habc}};
    $display("byte d[] from 12 bits: size=%0d %h %h", d.size(), d[0], d[1]);
    d = {>>{16'h1234}};
    $display("byte d[] from 16 bits: size=%0d %h %h", d.size(), d[0], d[1]);
    q = {>>{40'h11_2233_4455}};
    $display("int q[$] from 40 bits: size=%0d %h %h", q.size(), q[0], q[1]);
    r32 = {>>{ps, en, pa, 8'h55}};
    $display("integral kinds: %h", r32);
    r32 = {<<8{ua, us}};
    $display("unpacked array and structure: %h", r32);
    r32 = {>>{qq, s}};
    $display("queue and string: %h", r32);
  end
endmodule
