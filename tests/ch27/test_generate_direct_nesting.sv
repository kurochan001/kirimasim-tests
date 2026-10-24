/*
:name: test_generate_direct_nesting
:description: a conditional generate block that is only another conditional generate, without begin-end, adds no scope, for if and case in either order, while a loop generate in that place does get a scope of its own (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_direct_nesting.expected
*/
// IEEE 1800-2023 §27.5: when a generate block of an if or case generate is a
// single conditional generate construct without begin-end, it is not a
// scope of its own: the inner construct is directly nested, and its blocks
// count as blocks of the outer construct. They may therefore share one name
// with the outer blocks, and the selected one is reached by that name from
// the enclosing module. If and case generates can be combined this way in
// either order. Direct nesting never applies to loop generates.
// The module has an if-else-if chain whose blocks are all named sel, a case
// generate whose default is an if-else with blocks named mix like its other
// item, and an if generate that holds only a case generate with blocks
// named rev. Their variables are read as sel.v, mix.v and rev.v, which only
// works if no scope was added. Last, an if generate holds only a loop
// generate named lp: here the if block is a scope, so lp may share its name
// with the variable lp of the module, and the loop blocks still print.
// The 5.052 release of Verilator does not find rev: it does not treat a
// case generate directly inside an if generate as directly nested.

module test_generate_direct_nesting;
  localparam int P = 2;
  localparam int Q = 1;
  int lp = 40;

  if (P == 0) begin : sel
    int v = 10;
  end else if (P == 1) begin : sel
    int v = 11;
  end else if (P == 2) begin : sel
    int v = 12;
  end else begin : sel
    int v = 13;
  end

  case (Q)
    0: begin : mix
      int v = 20;
    end
    default:
      if (P > 1) begin : mix
        int v = 21;
      end else begin : mix
        int v = 22;
      end
  endcase

  if (Q == 1)
    case (P)
      2: begin : rev
        int v = 30;
      end
      default: begin : rev
        int v = 31;
      end
    endcase

  if (Q == 1)
    for (genvar i = 0; i < 2; i++) begin : lp
      initial #(2 + i) $display("loop block %0d inside the if", i);
    end

  initial #1 $display("sel.v=%0d mix.v=%0d rev.v=%0d lp=%0d", sel.v, mix.v, rev.v, lp);
endmodule
