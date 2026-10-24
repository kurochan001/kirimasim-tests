/*
:name: test_stream_unpack_consumes_left_converts_state_keeps_objects
:description: an unpack takes the bits it needs from the left end of a longer source, converts between 2-state and 4-state like a cast, skips null handles without creating objects, and writes only declared properties of existing objects, leaving their random modes (IEEE 1800-2023 Section 11.4.14.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stream_unpack_consumes_left_converts_state_keeps_objects.expected
*/
// IEEE 1800-2023 §11.4.14.3: with a streaming concatenation as the target,
// the source bits are unpacked into the variables. When the source has more
// bits than needed, they are taken from its left (most significant) end.
// Unpacking a 4-state stream into a 2-state variable converts like a cast to
// a 2-state type (x and z become 0), and a 2-state stream into a 4-state
// variable the other way. Null handles are skipped, so no object is created;
// the objects to fill must exist, and only their explicitly declared
// properties are written, not implicit state such as the random mode.
// 24'habcdef into two bytes gives ab and cd (ef is left over). The 16 bits
// 1x0z1010 01xz0110 go to a bit [7:0] (10001010) and a logic [7:0] (keeps
// 01xz0110); b2 unpacked back into l4 gives 10001010. In the last unpack the
// null handle hn takes no bits, so the existing object he takes a5 and 3c in
// f and g, and t takes 7e; hn stays null, he is still the object that keep
// refers to, and f keeps the random mode 0 set before.
// Icarus Verilog 13.0 does not support streaming concatenations, and the C++
// code that Verilator 5.052 generates for objects in an unpack does not
// compile.

class pk_c;
  rand byte f;
  byte g;
endclass

module test_stream_unpack_consumes_left_converts_state_keeps_objects;
  logic [7:0] a8, b8;
  bit [7:0] b2;
  logic [7:0] l4;
  pk_c hn = null;
  pk_c he = new;
  pk_c keep;
  byte t;

  initial begin
    {>>{a8, b8}} = 24'habcdef;
    $display("from 24 bits: a8=%h b8=%h", a8, b8);
    {>>{b2, l4}} = 16'b1x0z_1010_01xz_0110;
    $display("4-state stream: b2=%b l4=%b", b2, l4);
    {>>{l4}} = b2;
    $display("2-state stream: l4=%b", l4);
    keep = he;
    he.f.rand_mode(0);
    {>>{hn, he, t}} = 24'ha5_3c_7e;
    $display("objects: hn null=%0d same=%0d f=%h g=%h t=%h rand_mode=%0d", hn == null,
             he == keep, he.f, he.g, t, he.f.rand_mode());
  end
endmodule
