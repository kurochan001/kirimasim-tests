/*
:name: test_vpi_struct_and_tagged_patterns
:description: A case matches gives a struct pattern from vpiExpr, the struct pattern iterates its member patterns with vpiPattern and they carry the matched constants, and a tagged pattern gives the typespec of its union member, int or byte (IEEE 1800-2023 Section 37.72)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.72 12.6 37.25
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_struct_and_tagged_patterns.c
:expected_stdout: @test_vpi_struct_and_tagged_patterns.expected
*/
// IEEE 1800-2023 §37.72: in a case matches the expressions of an item are
// patterns, and the pattern group has the any pattern, the tagged pattern,
// the struct pattern and the expr. The struct pattern leads to its member
// patterns with vpiPattern (one to many), and a tagged pattern leads to the
// typespec of its union member with vpiTypespec (one to one). §12.6 gives the
// syntax: a struct pattern is ' { pattern { , pattern } } and a tagged union
// pattern is tagged member_identifier pattern.
//
// Two case matches statements in the never-called task stmts each hold only
// patterns of one kind, so the application knows what to expect: the first
// matches the tagged union u with tagged Wide .w and tagged Narrow .n, whose
// members are declared int and byte, and the second matches the struct p with
// the two positional struct patterns '{1, 2} and '{3, 4}. For each pattern the
// application prints the case condition, the kind it finds, the name of its
// union member or the constants of its members, and the vpiType of the
// typespec of a tagged pattern. A tool that does not put the struct pattern in
// the pattern group gives another kind, one that does not iterate its members
// gives other member patterns, and one that returns the union typespec or no
// typespec gives another type here.
// Neither release produces this output: Icarus Verilog 13.0 cannot build the
// application, as its headers lack vpiStructPattern, and Verilator 5.052 does
// not build a VPI application for a case matches.

module test_vpi_struct_and_tagged_patterns;
  typedef union tagged {
    int Wide;
    byte Narrow;
  } u_t;

  typedef struct {
    int a;
    int b;
  } pair_t;

  u_t u;
  pair_t p;
  int out;

  task stmts;
    case (u) matches
      tagged Wide .w: out = w;
      tagged Narrow .n: out = n + 1;
    endcase
    case (p) matches
      '{ 1, 2 }: out = 12;
      '{ 3, 4 }: out = 34;
    endcase
  endtask
endmodule
