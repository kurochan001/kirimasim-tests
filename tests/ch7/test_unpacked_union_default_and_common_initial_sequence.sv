/*
:name: test_unpacked_union_default_and_common_initial_sequence
:description: an unpacked union takes the default of its first member and lets the common initial sequence of two member structures be inspected
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unpacked_union_default_and_common_initial_sequence.expected
*/
// IEEE 1800-2023 7.3: a union is unpacked unless qualified packed, and an
// unpacked union has no required member storage representation. Without an
// explicit initializer an unpacked union variable takes the default value of
// the type of its first member in declaration order. When an unpacked union
// contains several unpacked structures that share a common initial sequence
// and currently holds one of them, the common initial part of any of them may
// be inspected. The test declares a union whose first member is a structure
// with an int tag, observes the default x of that int, then writes one member
// structure and reads the shared tag through the other.

typedef struct {
  integer tag;
  integer payload;
} rec_a_t;

typedef struct {
  integer tag;
  byte code;
} rec_b_t;

typedef union {
  rec_a_t a;
  rec_b_t b;
  int raw;
} shared_t;

module test_unpacked_union_default_and_common_initial_sequence;
  shared_t u;

  initial begin
    $display("default_unknown=%0d", $isunknown(u.a.tag));
    u.a.tag = 7;
    u.a.payload = 9;
    $display("common_tag=%0d payload=%0d", u.b.tag, u.a.payload);
    u.b.code = 8'h3C;
    $display("same_tag=%0d", u.a.tag);
  end
endmodule
