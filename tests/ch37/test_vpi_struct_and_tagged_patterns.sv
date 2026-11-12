/*
:name: test_vpi_struct_and_tagged_patterns
:description: A case matches gives a struct pattern or a tagged pattern from vpiExpr of its case items; a struct pattern leads to a member pattern with vpiPattern, and a tagged pattern gives its member name, its nested any pattern and a typespec (IEEE 1800-2023 Section 37.72)
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
// the struct pattern and the expr. The diagram draws one arrow from the
// struct pattern to a pattern, and one from the tagged pattern to a pattern
// and to a typespec; the clause has no detail about them. §12.6 gives the
// syntax: a struct pattern is ' { pattern { , pattern } } and a tagged union
// pattern is tagged member_identifier pattern.
//
// Two case matches statements in the never-called task stmts each hold only
// patterns of one kind, so the application knows what to expect: the first
// matches the tagged union u with tagged Wide .w and tagged Narrow .n, and
// the second matches the struct p with the two positional struct patterns
// '{1, 2} and '{3, 4}. For each pattern the application prints the case
// condition and the kind it finds. For a struct pattern it prints whether
// vpiPattern gives a member pattern, by vpi_handle or by an iteration. For a
// tagged pattern it prints the name of its union member, the name of the
// nested any pattern and whether vpiTypespec gives a typespec. A tool that
// does not put the struct pattern in the pattern group gives another kind,
// and one without the relations prints 0 or none.
// Corrected on 2026-11-12: the test required an iteration of all member
// patterns of a struct pattern with their constants, and the typespec of the
// union member (int or byte) for a tagged pattern. The diagram, which is all
// that §37.72 says about these relations, fixes neither.
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
