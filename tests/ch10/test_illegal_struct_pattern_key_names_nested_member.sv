/*
:name: test_illegal_struct_pattern_key_names_nested_member
:description: a member key in a structure assignment pattern names a member at the top level of the structure, not a member of a nested structure (IEEE 1800-2023 Section 10.9.2)
:tags: ch10
:type: elaboration
:lrm: 1800-2023 10.9.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the pattern uses the key y, which is a member of the nested structure inner and not of outer_t itself
:expected_stderr_regex: test_illegal_struct_pattern_key_names_nested_member\.sv:35:
*/
// IEEE 1800-2023 §10.9.2: a member:value names a member at the top level of
// the structure; a member with the same name in a substructure shall not be
// set by it. The patterns that name inner and give it its own pattern are
// legal; the key y names a member of inner from the outer pattern.
// Icarus Verilog 13.0 does not support unpacked structures, so its errors do
// not count.

module test_illegal_struct_pattern_key_names_nested_member;
  typedef struct {
    int y;
    int z;
  } inner_t;
  typedef struct {
    int x;
    inner_t inner;
  } outer_t;
  outer_t o;

  initial begin
    o = '{x:1, inner:'{y:2, z:3}};
    o = '{x:1, inner:'{default:0}};
    o = '{x:1, y:2, default:0};   // illegal: y is not a member of outer_t
    $display("%p", o);
  end
endmodule
