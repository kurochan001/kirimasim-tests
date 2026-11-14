/*
:name: test_stream_four_state_when_any_item_is_four_state
:description: a pack with a streaming concatenation gives a 4-state stream when any packed data is 4-state, so x and z bits survive next to 2-state items, and a 2-state stream otherwise (IEEE 1800-2023 Section 11.4.14)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stream_four_state_when_any_item_is_four_state.expected
*/
// IEEE 1800-2023 §11.4.14: if the data packed by a streaming concatenation
// contain any 4-state type, the stream is 4-state; otherwise it is 2-state.
// §11.4.14.1 casts each item to bits, 2-state items to 4-state ones when
// needed. Every target here is a logic vector exactly as wide as its stream,
// so the printed bits are the stream itself.
// A logic item holding 1x0z between two bit items gives a 4-state stream in
// which the x and z keep their places, also with the order of 4-bit slices
// reversed and with the bit order reversed. A 4-state element of an unpacked
// array or a 4-state member of a structure makes the stream 4-state in the
// same way. With only bit items, or an array or structure of bit data, the
// stream is 2-state and its bits are the 0 and 1 of the items. A tool that
// made a mixed stream 2-state would print 0 in place of each x and z.
// Icarus Verilog 13.0 does not support streaming concatenations.

module test_stream_four_state_when_any_item_is_four_state;
  typedef struct {
    bit [1:0] p;
    logic [1:0] q;
  } mix_t;
  typedef struct {
    bit [1:0] p;
    bit [1:0] q;
  } two_t;

  bit [3:0] b4 = 4'b1010;
  bit [3:0] c4 = 4'b0110;
  logic [3:0] l4 = 4'b1x0z;
  logic [1:0] la [2] = '{2'bx1, 2'b0z};
  bit [1:0] ba [2] = '{2'b11, 2'b01};
  mix_t ms = '{p: 2'b10, q: 2'bz1};
  two_t ts = '{p: 2'b10, q: 2'b01};
  logic [11:0] t12;
  logic [7:0] t8;
  logic [3:0] t4;

  initial begin
    t12 = {>>{b4, l4, c4}};
    $write("bit logic bit: %b", t12);
    t12 = {<<4{b4, l4, c4}};
    $write(" %b", t12);
    t8 = {<<{b4, l4}};
    $display(" %b", t8);
    t8 = {>>{b4, c4}};
    $display("bit bit: %b", t8);
    t4 = {>>{la}};
    $write("logic array: %b", t4);
    t4 = {>>{ba}};
    $display(" bit array: %b", t4);
    t4 = {>>{ms}};
    $write("mixed struct: %b", t4);
    t4 = {>>{ts}};
    $display(" bit struct: %b", t4);
  end
endmodule
