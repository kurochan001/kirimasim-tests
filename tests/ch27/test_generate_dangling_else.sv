/*
:name: test_generate_dangling_else
:description: in nested if generates the else belongs to the nearest if, and begin-end around the inner if makes the else belong to the outer one while adding a level of hierarchy (IEEE 1800-2023 Section 27.5)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_dangling_else.expected
*/
// IEEE 1800-2023 §27.5: when if generates are nested, an else belongs to the
// nearest if. Putting the inner if inside begin-end makes a following else
// belong to the outer if instead; the inner if is then no longer directly
// nested, so the begin-end block is a scope of its own, one more level of
// hierarchy.
// Constructs n1 and n2 nest an if without begin-end: with the outer
// condition false (n1) nothing is instantiated, since the else is the
// inner one; with the outer condition true and the inner false (n2) the
// else block is. Constructs n3 and n4 wrap the inner if in a block named
// wrap3 or wrap4: with the outer condition false (n3) the else block is
// instantiated; with both true (n4) the inner block is reached as
// wrap4.n4, one level down. The blocks print at times of their own.

module test_generate_dangling_else;
  localparam bit OFF = 0;
  localparam bit ON = 1;

  if (OFF)
    if (ON) begin : n1
      initial #1 $display("n1: inner then");
    end else begin : n1
      initial #1 $display("n1: else");
    end

  if (ON)
    if (OFF) begin : n2
      initial #2 $display("n2: inner then");
    end else begin : n2
      initial #2 $display("n2: else");
    end

  if (OFF) begin : wrap3
    if (ON) begin : n3
      initial #3 $display("n3: inner then");
    end
  end else begin : n3
    initial #3 $display("n3: else");
  end

  if (ON) begin : wrap4
    if (ON) begin : n4
      int v = 4;
    end
  end else begin : n4
    int v = 40;
  end

  initial #4 $display("wrap4.n4.v=%0d", wrap4.n4.v);
endmodule
