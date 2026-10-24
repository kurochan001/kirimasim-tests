/*
:name: test_generate_scheme_instances
:description: a loop generate instantiates its block once per genvar value, and if and case generates instantiate at most one of their blocks, none when no alternative is chosen (IEEE 1800-2023 Section 27.3)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.3 27.4 27.5
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_scheme_instances.expected
*/
// IEEE 1800-2023 §27.3: a loop generate construct instantiates its generate
// block as many times as its loop control gives, and a conditional
// generate construct, if or case, instantiates at most one block of its
// alternatives. The generate scheme, that is the conditions, case items and
// loop control, decides which and how many blocks there are.
// Every generate block below holds an initial procedure that prints a line
// at a time of its own, so the output lists exactly the blocks that exist,
// in time order. The loop runs three times; the if generate without else
// has a false condition and the last case generate has neither a matching
// item nor a default, so they instantiate nothing; the if-else and the
// other case generate instantiate one block each.

module test_generate_scheme_instances;
  localparam int N = 3;
  localparam int MODE = 2;

  for (genvar i = 0; i < N; i++) begin : rep
    initial #(1 + i) $display("loop block %0d", i);
  end

  if (MODE == 1) begin : lone
    initial #10 $display("if without else: then block");
  end

  if (MODE == 2) begin : ie
    initial #11 $display("if-else: then block");
  end else begin : ie
    initial #11 $display("if-else: else block");
  end

  case (MODE)
    1: begin : cs
      initial #12 $display("case: item 1");
    end
    2: begin : cs
      initial #12 $display("case: item 2");
    end
    default: begin : cs
      initial #12 $display("case: default");
    end
  endcase

  case (MODE)
    0: begin : nomatch
      initial #13 $display("case without match: item 0");
    end
    5: begin : nomatch
      initial #13 $display("case without match: item 5");
    end
  endcase

  initial #20 $display("end");
endmodule
