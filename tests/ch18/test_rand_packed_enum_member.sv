/*
:name: test_rand_packed_enum_member
:description: An enum member of a rand packed structure or packed union can take values that are not named constants of the enum, unlike a rand enum variable (IEEE 1800-2023 Section 18.4)
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.4 18.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_rand_packed_enum_member.expected
*/
// IEEE 1800-2023 §18.4: a rand packed structure or packed untagged union is
// randomized as an integral value, and the rule of 18.3 that a random enum
// variable takes only the named constants of its type does not apply to an
// enum member of such a structure or union. pem_e names only 2'b00 and
// 2'b11. So the member kind of the packed structure s and of the packed
// union u can be made 2'b01 or 2'b10 by an inline constraint, while the
// same constraint on the rand enum variable e fails (and e keeps its value).
// In 50 calls without inline constraints, e is always one of the two named
// values.
// Icarus Verilog 13.0 does not compile classes with constraints. Verilator
// 5.052 lets the inline constraint give e the unnamed value 2'b01.

typedef enum bit [1:0] {PEM_A = 2'b00, PEM_B = 2'b11} pem_e;

typedef struct packed {
  pem_e kind;
  bit [1:0] tag;
} pem_s;

typedef union packed {
  pem_e kind;
  bit [1:0] raw;
} pem_u;

class pem_obj;
  rand pem_e e;
  rand pem_s s;
  rand pem_u u;
endclass

module test_rand_packed_enum_member;
  pem_obj o;
  int ok;
  int unnamed = 0;

  initial begin
    o = new;
    ok = o.randomize() with { s.kind == pem_e'(2'b01); u.raw == 2'b10; };
    $display("struct member: ok=%0d s.kind=%b, union member: u.kind=%b", ok, o.s.kind,
             o.u.kind);
    ok = o.randomize() with { s.kind == pem_e'(2'b10); u.kind == pem_e'(2'b01); e == PEM_B; };
    $display("struct member: ok=%0d s.kind=%b, union member: u.kind=%b, e=%b", ok, o.s.kind,
             o.u.kind, o.e);
    ok = o.randomize() with { e == pem_e'(2'b01); };
    $display("enum variable 2'b01: ok=%0d e=%b", ok, o.e);
    repeat (50) begin
      void'(o.randomize());
      if (!(o.e inside {PEM_A, PEM_B})) unnamed++;
    end
    $display("50 calls: e not a named value %0d times", unnamed);
  end
endmodule
