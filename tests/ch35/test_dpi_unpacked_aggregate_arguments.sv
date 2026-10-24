/*
:name: test_dpi_unpacked_aggregate_arguments
:description: Unpacked structures and arrays nested in each other pass to an import and from an export with the layout of the same C declarations, an unpacked array of structures with packed members reaches an export through a reference that C forwards, and rand and randc members change nothing for C (IEEE 1800-2023 Section 35.5.6, H.7.8, H.7.4, H.8.4)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.6 H.7.8 H.7.4 H.8.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:dpi_c: @test_dpi_unpacked_aggregate_arguments.c
:expected_stdout: @test_dpi_unpacked_aggregate_arguments.expected
*/
// IEEE 1800-2023 §35.5.6: formal arguments may be built of permitted types
// with struct and unpacked arrays. H.7.8: imports and exports take unpacked
// arrays and structures whose elements are packed or unpacked, including
// nested aggregates; one built only of unpacked elements has the layout that
// the C compiler gives the same declarations. H.8.4: an argument passed by
// reference is a pointer to the data, and C may pass on a reference it got,
// such as its own formal. H.7.4: rand and randc may be on members of a DPI
// structure formal and of its actual, and they do not change what C gets.
//
// tree_t holds an array of two leaf_t structures, an int array and a
// shortint. c_tree reads the input through the C declarations and returns the
// sum of its numbers, 164, and fills the output; c_build_tree builds a tree_t
// in C and passes it to the export sv_tree. mixed_t has packed members, whose
// place in memory the standard leaves open (35.5.6), so C does not read them:
// c_forward gives its formal, an array of two mixed_t, to the export
// sv_mixed, which prints it. chosen_t has rand and randc members; it is
// passed from a variable and from a class property that randomize sets under
// constraints that fix its values, and c_chosen reads the members.
//
// Icarus Verilog 13.0 has no DPI, and Verilator 5.052 does not accept
// unpacked structures as DPI arguments, so :oracle: names no simulator.

module test_dpi_unpacked_aggregate_arguments;
  typedef struct {
    int id;
    real w;
    byte b;
  } leaf_t;
  typedef struct {
    leaf_t pair [2];
    int counts [3];
    shortint s;
  } tree_t;
  typedef struct {
    bit [11:0] code;
    logic [3:0] flags;
    int n;
  } mixed_t;
  typedef struct {
    rand int r;
    randc byte c;
    int plain;
  } chosen_t;

  class holder;
    rand chosen_t s;
    constraint fix {
      s.r == 5;
      s.c == 3;
    }
  endclass

  import "DPI-C" function real c_tree(input tree_t t, output tree_t o);
  import "DPI-C" context function void c_build_tree();
  import "DPI-C" context function void c_forward(input mixed_t m [2]);
  import "DPI-C" function int c_chosen(input chosen_t s);
  export "DPI-C" function sv_tree;
  export "DPI-C" function sv_mixed;

  function void sv_tree(input tree_t t);
    $display("sv_tree: pair[0] %0d %0.2f %0d, pair[1] %0d %0.2f %0d, counts %0d %0d %0d, s %0d",
             t.pair[0].id, t.pair[0].w, t.pair[0].b, t.pair[1].id, t.pair[1].w, t.pair[1].b,
             t.counts[0], t.counts[1], t.counts[2], t.s);
  endfunction

  function void sv_mixed(input mixed_t m [2]);
    $display("sv_mixed: m[0] code %h flags %b n %0d, m[1] code %h flags %b n %0d", m[0].code,
             m[0].flags, m[0].n, m[1].code, m[1].flags, m[1].n);
  endfunction

  tree_t t, o;
  mixed_t m [2];
  chosen_t q;
  holder h;

  initial begin
    t.pair[0] = '{id: 1, w: 0.5, b: 2};
    t.pair[1] = '{id: 3, w: 1.5, b: -4};
    t.counts = '{10, 20, 30};
    t.s = 100;
    $display("c_tree: sum %0.2f", c_tree(t, o));
    $display("c_tree: o.pair[0] %0d %0.2f %0d, o.pair[1] %0d %0.2f %0d, counts %0d %0d %0d, s %0d",
             o.pair[0].id, o.pair[0].w, o.pair[0].b, o.pair[1].id, o.pair[1].w, o.pair[1].b,
             o.counts[0], o.counts[1], o.counts[2], o.s);
    c_build_tree();
    m[0] = '{code: 12'habc, flags: 4'b10xz, n: 5};
    m[1] = '{code: 12'h123, flags: 4'b0101, n: 6};
    c_forward(m);
    q = '{r: 1, c: 2, plain: 3};
    $display("c_chosen of a variable: %0d", c_chosen(q));
    h = new;
    h.s.plain = 9;
    $display("randomize: %0d", h.randomize());
    $display("c_chosen of a randomized property: %0d", c_chosen(h.s));
  end
endmodule
