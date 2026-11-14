/*
:name: test_dist_integral_operand_kinds
:description: dist takes integral operands of every kind: 2-state and 4-state vectors, signed values with negative ranges, enums, packed structures and an integral expression of random variables (IEEE 1800-2023 Section 11.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3 18.5.3
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dist_integral_operand_kinds.expected
*/
// IEEE 1800-2023 §11.3, Table 11-1: the operands of dist are integral.
// §18.5.3: in a constraint, dist is also a membership test, and a value that
// the list leaves out or gives a total weight of zero is excluded, so each
// dist here, whose only value of nonzero weight is one value, fixes its
// expression. The left operands are a bit vector, a logic vector, a signed
// int with negative ranges, an enum, a packed structure and the expression
// x ^ y, where x is fixed by its own dist; the right operands are integral
// constants, ranges of them and enum names, with := and :/ weights. A tool
// that mishandled one kind, for example the sign of the int ranges, would
// fail the randomization or print another value. The solution is unique, so
// the two calls print the same line.
// Icarus Verilog 13.0 does not support randomize.

typedef enum bit [1:0] {A, B, C} kind_t;
typedef struct packed {
  bit [3:0] hi;
  bit [3:0] lo;
} pk_t;

class item_c;
  rand bit [7:0] b8;
  rand logic [3:0] l4;
  rand int si;
  rand kind_t e;
  rand pk_t p;
  rand bit [3:0] x, y;
  constraint k {
    b8 dist {[0:199] := 0, 200 := 1, [201:255] :/ 0};
    l4 dist {4'ha := 2};
    si dist {[-10:-6] :/ 0, -5 := 1, [-4:10] := 0};
    e dist {A := 0, B := 3, C := 0};
    p dist {8'h3c := 1};
    x dist {4'h5 := 1};
    (x ^ y) dist {4'hf := 1};
  }
endclass

module test_dist_integral_operand_kinds;
  item_c it = new;

  initial begin
    repeat (2) begin
      if (it.randomize())
        $display("b8=%0d l4=%h si=%0d e=%s p.hi=%h p.lo=%h x=%h y=%h", it.b8, it.l4, it.si,
                 it.e.name(), it.p.hi, it.p.lo, it.x, it.y);
      else $display("randomize failed");
    end
  end
endmodule
