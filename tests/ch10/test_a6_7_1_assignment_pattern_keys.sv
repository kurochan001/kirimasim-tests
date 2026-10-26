/*
:name: test_a6_7_1_assignment_pattern_keys
:description: An assignment pattern uses member identifiers, constant index expressions, the simple type int and the default keyword as keys, and each key sets the members or elements that its rule selects (IEEE 1800-2023 Section 10.9.2, A.6.7.1)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.9.2 A.6.7.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_a6_7_1_assignment_pattern_keys.expected
*/
// IEEE 1800-2023 A.6.7.1: a structure pattern key is a member identifier or an
// assignment pattern key; an array pattern key is a constant expression or an
// assignment pattern key; an assignment pattern key is a simple type or the
// keyword default. §10.9.2: a type key sets each member whose type matches,
// default sets the members that no name or type key set, and a later member
// key overrides default.
//
// s_members names every member, so it is 1, 2, 3 and 4.0. s_types uses the
// int key for the two int members a and c and default for the byte and the
// real, so it is 5, 9, 5 and 9.0. s_over gives default 1 and then the key c
// with 6, so a, b and r are 1 and c is 6. The array pattern gives 10 to index
// 0, 40 to index 3 and default 7 to the other two elements.

`timescale 1ns/1ns
module test_a6_7_1_assignment_pattern_keys;
  typedef struct {
    int a;
    byte unsigned b;
    int c;
    real r;
  } rec_t;

  rec_t s_members = '{a: 1, b: 8'd2, c: 3, r: 4.0};
  rec_t s_types = '{int: 5, default: 9};
  rec_t s_over = '{default: 1, c: 6};
  int arr [4] = '{0: 10, 3: 40, default: 7};

  initial begin
    $display("members %0d %0d %0d %0.1f",
             s_members.a, s_members.b, s_members.c, s_members.r);
    $display("types %0d %0d %0d %0.1f",
             s_types.a, s_types.b, s_types.c, s_types.r);
    $display("override %0d %0d %0d %0.1f",
             s_over.a, s_over.b, s_over.c, s_over.r);
    $display("array %0d %0d %0d %0d", arr[0], arr[1], arr[2], arr[3]);
  end
endmodule
