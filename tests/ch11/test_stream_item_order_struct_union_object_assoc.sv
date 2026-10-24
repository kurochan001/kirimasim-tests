/*
:name: test_stream_item_order_struct_union_object_assoc
:description: streaming packs structures member by member in declaration order, associative arrays in index order and other unpacked arrays in foreach order, an untagged union by its first member, an object by its data members with the base class first, and skips a null handle (IEEE 1800-2023 Section 11.4.14.1)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.14.1
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_stream_item_order_struct_union_object_assoc.expected
*/
// IEEE 1800-2023 §11.4.14.1: each stream expression is turned into bits and
// appended on the right of the stream, recursively: a structure member by
// member in declaration order; an associative array element by element in
// index order, other unpacked arrays in the order of a foreach loop with one
// index; an untagged union by its first declared member; an object by its
// data members in declaration order, the members of a base class before
// those of the class extending it, and not by the handle; a null handle is
// skipped. A nested stream, and an item of bit-stream type, is first cast to
// a packed array of bits, 4-state when needed, and then appended.
// un holds 5a in its first member m (a byte), so un adds 8 bits, not the 32
// bits of n. An unpacked union is not a bit-stream type (§6.24.3), so a
// structure or an array holding unions is streamed by the member and element
// rules: su gives 0a, its union's 0b, 0c; the associative array au, written
// at keys 7 then 2, gives 22 77; un2, declared [1:0], gives un2[1] first. The
// bit-stream structure st gives 01 0203 04, the byte associative array aa
// (keys written 5, 1, 3) 11 33 55, and fd, declared [3:0], d3 d2 d1 d0. The
// derived object gives 11 22 (base members a, b) before 33 (its own c). A
// null handle between two bytes adds nothing. A 2-state item, a nested
// stream and a 4-state item with x and z are joined in order, keeping x, z.
// Icarus Verilog 13.0 does not support unpacked structures or streaming;
// associative arrays and objects are not streamed by Verilator 5.052.

class base_c;
  byte a = 8'h11;
  byte b = 8'h22;
endclass

class der_c extends base_c;
  byte c = 8'h33;
endclass

module test_stream_item_order_struct_union_object_assoc;
  typedef struct { byte p; shortint q; byte r; } st_t;
  typedef union { byte m; int n; } un_t;
  typedef struct { byte p; un_t u; byte r; } su_t;
  st_t st = '{8'h01, 16'h0203, 8'h04};
  un_t un;
  su_t su;
  un_t au [int];
  un_t un2 [1:0];
  byte aa [int];
  byte fd [3:0] = '{8'hd3, 8'hd2, 8'hd1, 8'hd0};
  der_c h = new;
  base_c nul = null;
  bit [3:0] b2s = 4'b1010;
  logic [3:0] l4s = 4'b1x0z;
  logic [31:0] r32;
  logic [23:0] r24;
  logic [15:0] r16;
  logic [11:0] r12;

  initial begin
    r32 = {>>{st}};
    $display("struct: %h", r32);
    aa[5] = 8'h55;
    aa[1] = 8'h11;
    aa[3] = 8'h33;
    r24 = {>>{aa}};
    $display("associative: %h", r24);
    r32 = {>>{fd}};
    $display("fixed [3:0]: %h", r32);
    un.m = 8'h5a;
    r16 = {>>{un, 8'hc3}};
    $display("union: %h", r16);
    su.p = 8'h0a;
    su.u.m = 8'h0b;
    su.r = 8'h0c;
    r24 = {>>{su}};
    $display("struct with a union member: %h", r24);
    au[7].m = 8'h77;
    au[2].m = 8'h22;
    r16 = {>>{au}};
    $display("associative array of unions: %h", r16);
    un2[1].m = 8'he1;
    un2[0].m = 8'he0;
    r16 = {>>{un2}};
    $display("unions [1:0]: %h", r16);
    r24 = {>>{h}};
    $display("object: %h", r24);
    r16 = {>>{8'h11, nul, 8'h22}};
    $display("null handle: %h", r16);
    r12 = {>>{b2s, {<<{b2s}}, l4s}};
    $display("2-state, nested, 4-state: %b", r12);
  end
endmodule
