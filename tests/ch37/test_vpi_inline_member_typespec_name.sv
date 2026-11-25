/*
:name: test_vpi_inline_member_typespec_name
:description: An inline struct member has an unnamed typespec while a structurally identical typedef member retains its typedef name
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_inline_member_typespec_name.c
:expected_stdout: @test_vpi_inline_member_typespec_name.expected
*/
// IEEE 1800-2023 37.25 details 1 and 3-5: the member and its
// typespec have separate names. The inline typespec can report NULL or
// an empty string. Both nested typespecs contain the same int member.
`timescale 1ns/1ns
module test_vpi_inline_member_typespec_name;
  typedef struct { int value; } named_t;
  typedef struct {
    struct { int value; } inline_field;
    named_t named_field;
  } container_t;
  container_t specimen;

  initial begin
    specimen.inline_field.value = 19;
    specimen.named_field.value = 41;
    #1 $display("HDL fields=%0d,%0d", specimen.inline_field.value, specimen.named_field.value);
  end
endmodule
