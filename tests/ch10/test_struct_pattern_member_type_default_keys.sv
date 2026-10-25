/*
:name: test_struct_pattern_member_type_default_keys
:description: in a structure assignment pattern a member key beats a type key, a type key fills every member of a matching type (6.22.1) with its last value, evaluated as an assignment to that type, and default fills only the members left (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.2 6.22.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_struct_pattern_member_type_default_keys.expected
*/
// IEEE 1800-2023 §10.9.2: the keys of a structure assignment pattern can be
// member names and data types. A member key gives the value of that member.
// A type key gives the value of every member whose type matches it (6.22.1)
// and that no member key has set; if the same type key appears twice, the
// last value is used, and the value is evaluated as in an assignment to the
// matching type. A default key gives the value of every member that neither
// a member key nor a type key has set.
//
// The members of st and the type keys they match (6.22.1):
//   i1, i2  int            match int
//   m       myint          a typedef of int, matches int
//   w       bit signed [31:0]  matches int (2-state, signed, 32 bits, [31:0])
//   b       byte           matches byte
//   bs      bit signed [7:0]   matches byte
//   l8      logic [7:0]    4-state: does not match byte
//   bu      bit [7:0]      unsigned: does not match byte
//   sh      shortint       matches neither
// In the first pattern the int key 8'd200 + 8'd100 is evaluated as an
// assignment to an int, at 32 bits, so it is 300, not the 8-bit sum 44.
//
// Icarus Verilog 13.0 does not support unpacked structures, nor type keys.
// Release 5.052 of Verilator gives the int key only to i1, i2 and m and the
// byte key only to b, so w and bs, whose types match int and byte by
// 6.22.1, get the default instead.

module test_struct_pattern_member_type_default_keys;
  typedef int myint;
  typedef struct {
    int i1;
    int i2;
    myint m;
    bit signed [31:0] w;
    byte b;
    bit signed [7:0] bs;
    logic [7:0] l8;
    bit [7:0] bu;
    shortint sh;
  } st;

  st s;

  function automatic void show(string tag);
    $display("%s: i1=%0d i2=%0d m=%0d w=%0d b=%0d bs=%0d l8=%h bu=%h sh=%0d",
             tag, s.i1, s.i2, s.m, s.w, s.b, s.bs, s.l8, s.bu, s.sh);
  endfunction

  initial begin
    s = '{i2: 5, int: 8'd200 + 8'd100, default: 3};
    show("member+int+default");
    s = '{int: 1, byte: -1, int: 9, default: 8'haa};
    show("int twice+byte+default");
    s = '{default: 4, sh: 6, byte: 2};
    show("default+member+byte");
  end
endmodule
