/*
:name: test_forward_typedef_forms_and_repeats
:description: forward typedefs of the enum, struct, union, class and interface class kinds and without a kind are legal before the final definition, may be repeated, and may also follow it (IEEE 1800-2023 Section 6.18)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.18 8.26 8.27
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_forward_typedef_forms_and_repeats.expected
*/
// IEEE 1800-2023 §6.18: a forward typedef may name the basic kind of the
// type (enum, struct, union, class or interface class) or leave it out. It
// may come before or after the final definition in the same scope, and the
// same name may be declared forward several times. Each type below is
// declared forward, some names twice, one only after its definition, and
// then used: the printed sizes and values come from the final definitions.
// The class a_c holds a handle of b_c, which is defined later (§8.27).
// Icarus Verilog 13.0 does not parse interface classes (unsupported
// construct).

module test_forward_typedef_forms_and_repeats;
  typedef enum color_t;
  typedef struct pair_t;
  typedef struct pair_t;
  typedef union word_t;
  typedef class b_c;
  typedef interface class shape_ic;
  typedef any_t;
  typedef any_t;

  class a_c;
    b_c peer;
  endclass

  typedef enum bit [1:0] {RED, GREEN = 2, BLUE} color_t;
  typedef struct packed { byte hi; byte lo; } pair_t;
  typedef union packed { shortint s; pair_t p; } word_t;
  typedef logic [11:0] any_t;

  interface class shape_ic;
    pure virtual function int sides();
  endclass

  class b_c implements shape_ic;
    int id = 7;
    virtual function int sides();
      return 4;
    endfunction
  endclass

  typedef enum color_t;
  typedef class b_c;
  typedef any_t;

  color_t c = BLUE;
  word_t w;
  any_t v = 12'hfff;
  a_c a;
  shape_ic sh;

  initial begin
    $display("enum: bits=%0d BLUE=%0d name=%s", $bits(c), c, c.name());
    w.s = 16'h12ab;
    $display("struct/union: bits=%0d,%0d hi=%h lo=%h", $bits(pair_t), $bits(w), w.p.hi, w.p.lo);
    $display("untyped forward: bits=%0d v=%h", $bits(v), v);
    a = new;
    a.peer = new;
    sh = a.peer;
    $display("class: id=%0d sides=%0d", a.peer.id, sh.sides());
  end
endmodule
