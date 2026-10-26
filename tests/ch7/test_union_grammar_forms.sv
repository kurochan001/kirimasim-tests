/*
:name: test_union_grammar_forms
:description: a union uses the struct/union member grammar and takes soft, tagged, packed, signed and packed-dimension forms where permitted
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_union_grammar_forms.expected
*/
// IEEE 1800-2023 7.3: struct_union is struct, union, union soft or union
// tagged; a union may also be packed, signed when packed, and followed by
// packed dimensions. Footnote 17 allows a packed dimension with a union when
// the soft and/or packed keyword is present, and footnote 20 allows a void
// member only in a tagged union. The test declares each permitted form, writes
// and reads a packed member through its overlapping view, indexes the two
// packed dimensions, reads a soft-union member, and constructs and
// pattern-matches a tagged union and a packed tagged union. A tool that mixes
// up the member layout or rejects one of the forms prints other values or
// cannot elaborate the design.

typedef union packed signed {
  logic [7:0] a;
  byte b;
} pu_t;
typedef union packed { byte a; } parr_t [1:0];
typedef union soft {
  int i;
  shortreal f;
} su_t;
typedef union soft { byte a; } sarr_t [1:0];
typedef union tagged {
  int v;
  void none;
} tu_t;
typedef union tagged packed { byte v; } tpu_t;

module test_union_grammar_forms;
  initial begin
    pu_t p;
    parr_t pa;
    su_t s;
    sarr_t sa;
    tu_t t;
    tpu_t tp;

    p.b = 8'hA5;
    $display("packed=%b %h", p.a, p.b);
    pa[0].a = 8'h11;
    pa[1].a = 8'h22;
    $display("parr=%h %h", pa[0].a, pa[1].a);
    s.f = 1.5;
    $display("soft=%0.1f", s.f);
    sa[1].a = 8'h33;
    $display("sarr=%h", sa[1].a);
    t = tagged v(9);
    if (t matches tagged v .x) $display("tagged=%0d", x);
    tp = tagged v(8'h44);
    if (tp matches tagged v .y) $display("tpacked=%h", y);
  end
endmodule
