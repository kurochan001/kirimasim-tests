/*
:name: test_tagged_union_keywords_and_members
:description: The four struct and union keyword forms, a tagged union with a void member and a value member that is read only through its tag, a soft union, a packed struct inside a struct, and structure members with an attribute, a random qualifier and packed and unpacked types (IEEE 1800-2023 Sections 7.2, 7.3 and 7.3.2)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3 7.3.2 7.2 A.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_tagged_union_keywords_and_members.expected
*/
// IEEE 1800-2023 A.2.2.1: struct_union is struct, or union with an optional
// soft or tagged keyword; a member is optional attributes, an optional random
// qualifier, a data type or void, a list of variable declarations and a
// semicolon. Clarification 20: a void member is legal only in a tagged
// union, and a random qualifier only in an unpacked structure.
//   - su_t is an unpacked struct whose first member has an attribute and the
//     rand qualifier, and whose second member is a byte,
//   - tu_t is a tagged union with the void member Invalid and the int member
//     Valid; only the member of the current tag is read,
//   - us_t is a soft union, u_t an untagged union and sp_t a packed struct,
//   - all_t is a struct whose member has the packed struct type sp_t.
// su.r + su.b = 11, u.a written as 4'hA is read through u.b, us.a is 4'hB,
// tu.Valid is 9 after the assignment with the Valid tag, and the packed
// struct inside all_t reads back as 2'b10.
//
// Icarus Verilog 13.0 does not support unpacked structures. Verilator 5.052
// does not support tagged unions.

typedef struct {
  (* attr *) rand int r;
  byte b;
} su_t;

typedef union tagged {
  void Invalid;
  int Valid;
} tu_t;

typedef union soft {
  logic [3:0] a;
  logic [3:0] b;
} us_t;

typedef union {
  logic [3:0] a;
  logic [3:0] b;
} u_t;

typedef struct packed {
  logic [1:0] hi;
  logic [1:0] lo;
} sp_t;

typedef struct {
  sp_t inner;
  int n;
} all_t;

module test_tagged_union_keywords_and_members;
  su_t su = '{r: 5, b: 6};
  tu_t tu;
  us_t us;
  u_t u;
  all_t all = '{inner: 4'b1010, n: 3};

  initial begin
    us.a = 4'hB;
    u.a = 4'hA;
    tu = tagged Valid 9;
    $display("struct=%0d union=%h soft=%h tagged=%0d packed=%b",
             su.r + su.b, u.b, us.b, tu.Valid, all.inner);
  end
endmodule
