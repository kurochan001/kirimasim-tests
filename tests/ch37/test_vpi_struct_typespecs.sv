/*
:name: test_vpi_struct_typespecs
:description: a packed struct variable gives its members with their values and is packed; a packed union variable gives its members; the typespec of a variable declared with a typedef of a typedef has the outer typedef's name and the inner one as its alias, a struct typespec gives its members with their typespecs, and an enum typespec its constants (IEEE 1800-2023 Sections 37.25, 37.26)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.25 37.26 37.17 7.2.1 7.3.1 6.19
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_struct_typespecs.c
:expected_stdout: @test_vpi_struct_typespecs.expected
*/
// IEEE 1800-2023 §37.26: a struct or union variable iterates its members with
// vpiMember, and vpiPacked tells whether it is packed (§7.2.1, §7.3.1); the
// value of a packed one can be read as a whole. §37.25: vpiTypespec of a
// variable gives its typespec; when the type is a typedef its vpiName is that
// name, and a typedef of another typedef has vpiTypedefAlias to it (details 1
// and 6); a struct typespec iterates vpiTypespecMember, each with its name
// and typespec (details 3 and 4); an enum typespec iterates vpiEnumConst with
// names and values (§6.19); a built-in type has no name. Lists are sorted.

module test_vpi_struct_typespecs;
  typedef enum logic [1:0] {IDLE, RUN = 2, STOP} state_t;
  typedef struct packed {
    state_t st;
    logic [5:0] cnt;
  } rec_t;
  typedef rec_t rec_alias_t;

  rec_alias_t rv = '{st: RUN, cnt: 6'd5};
  union packed {
    logic [7:0] raw;
    rec_t rec;
  } uv;

  initial begin
    uv.raw = 8'h81;
    #1 $vt_types;
  end
endmodule
