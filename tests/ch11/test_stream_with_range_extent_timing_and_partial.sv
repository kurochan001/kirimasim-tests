/*
:name: test_stream_with_range_extent_timing_and_partial
:description: without a with range the first dynamic array of an unpack takes all spare bits; a with range sets the extent of an array, is evaluated just before that array is streamed, resizes an empty dynamic array, leaves the rest of a larger array unchanged, and on the packing side streams a slice padded with nonexistent-entry values (IEEE 1800-2023 Section 11.4.14.4)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stream_with_range_extent_timing_and_partial.expected
*/
// IEEE 1800-2023 §11.4.14.4: an unpack into dynamically sized arrays without
// a with range is greedy: the first one takes all bits that the fixed-size
// items after it do not need, and the others stay empty. A with range gives
// the extent of an array explicitly. It is evaluated just before its array
// is streamed, so it sees a variable unpacked earlier in the same operation
// with its new value and one unpacked later with its old value. A dynamic
// array is resized for the range; when the range covers fewer elements than
// the array has, fixed-size or dynamic, only those elements are written. On
// the packing side the range acts as a slice, and elements past the end of
// the array are the nonexistent-entry value of Table 7-1 (0 for byte, x for
// logic).
// Greedy: 48 bits into hdr, d1, d2, tail give d1 the four middle bytes and d2
// none. With ranges: len (old value 1) is unpacked first as 2, so d1 gets
// two bytes; the range of d2 uses n2 before n2 is unpacked (old value 2), so
// d2 gets two bytes and n2 then becomes 05. fa and dp keep elements 0 and 3.
// Packing: [1:2] and [3 -: 2] of fa2 give 2030 and 3040; dp2 has two bytes,
// so [0:3] adds two zero bytes; lq has one logic element, so [0 +: 2] adds xx.
// Icarus Verilog 13.0 does not support streaming concatenations, and with
// ranges are not supported by Verilator 5.052.

module test_stream_with_range_extent_timing_and_partial;
  byte hdr, tail, len, n2;
  byte d1 [], d2 [];
  byte fa [4] = '{8'h01, 8'h02, 8'h03, 8'h04};
  byte dp [] = '{8'h01, 8'h02, 8'h03, 8'h04};
  byte fa2 [4] = '{8'h10, 8'h20, 8'h30, 8'h40};
  byte dp2 [] = '{8'h51, 8'h52};
  logic [7:0] lq [$] = '{8'h61};
  logic [15:0] r16a, r16b, r16c;
  logic [31:0] r32;

  task automatic show(string label, byte a []);
    string s = $sformatf("%s: size=%0d", label, a.size());
    foreach (a[i]) s = {s, $sformatf(" %h", a[i])};
    $display("%s", s);
  endtask

  initial begin
    {>>{hdr, d1, d2, tail}} = 48'h01_a1a2a3a4_ff;
    $display("greedy: hdr=%h tail=%h", hdr, tail);
    show("greedy d1", d1);
    show("greedy d2", d2);
    d1.delete();
    d2.delete();
    len = 1;
    n2 = 2;
    {>>{len, d1 with [0 +: len], d2 with [0 +: n2], n2}} = 48'h02_b1b2_c1c2_05;
    $display("with: len=%h n2=%h", len, n2);
    show("with d1", d1);
    show("with d2", d2);
    {>>{fa with [1:2]}} = 16'haabb;
    $display("fixed [1:2]: %h %h %h %h", fa[0], fa[1], fa[2], fa[3]);
    {>>{dp with [1:2]}} = 16'hccdd;
    show("dynamic [1:2]", dp);
    r16a = {>>{fa2 with [1:2]}};
    r16b = {>>{fa2 with [3 -: 2]}};
    r32 = {>>{dp2 with [0:3]}};
    r16c = {>>{lq with [0 +: 2]}};
    $display("pack: %h %h %h %h", r16a, r16b, r32, r16c);
  end
endmodule
