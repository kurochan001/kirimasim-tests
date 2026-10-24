/*
:name: test_enum_declaration_syntax_forms
:description: an enum declaration has an optional base type, one or more comma-separated names each with an optional range and value, and optional packed dimensions after the braces (IEEE 1800-2023 Section 6.19)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19 6.19.2 7.4.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_declaration_syntax_forms.expected
*/
// IEEE 1800-2023 §6.19, Syntax 6-5: enum, an optional base type, braces with
// one or more names separated by commas, and optional packed dimensions after
// the closing brace. A name may have a range [N] or [N:M] (§6.19.2) and a
// value. one_t has a single name and no base type; pair_t has packed
// dimensions after the braces, which make a packed array of two elements of
// the enum type (§7.4.1 allows packed arrays of enums): element [1] holds
// the upper two bits. grid_t mixes all the name forms.
// Icarus Verilog 13.0 rejects name() on the element p[1] ("has no method"),
// as if the element of the packed array were not of the enum type.

module test_enum_declaration_syntax_forms;
  typedef enum {ONLY} one_t;
  typedef enum bit [1:0] {Z0, Z1, Z2} [1:0] pair_t;
  typedef enum logic [3:0] {G = 4'd1, H[2], J[5:3] = 4'd8, K} grid_t;
  one_t o;
  pair_t p;
  grid_t g;

  initial begin
    $display("one: num=%0d ONLY=%0d bits=%0d", o.num(), ONLY, $bits(o));
    p[1] = Z2;
    p[0] = Z1;
    $display("packed dims: bits=%0d p=%b p[1]=%s p[0]=%s", $bits(p), p, p[1].name(),
             p[0].name());
    g = g.first();
    for (int i = 0; i < g.num(); i++) begin
      $display("grid: %s=%0d", g.name(), g);
      g = g.next();
    end
  end
endmodule
