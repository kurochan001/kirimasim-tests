/*
:name: test_conditional_generate_named_and_unnamed_scope
:description: A named conditional generate scope is accessible from its parent and an unnamed scope can use its own inner instance
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.5
:oracle: spec iverilog@13.0 verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_conditional_generate_named_and_unnamed_scope.expected
*/
// The named if block is addressed from the parent. The unnamed case
// alternative addresses a named block that it instantiates.
module test_conditional_generate_named_and_unnamed_scope;
  if (1) begin : exposed
    localparam int tag = 17;
  end
  case (2)
    2: begin
      int observed;
      if (1) begin : local_child
        localparam int tag = 29;
      end

      initial begin
        observed = local_child.tag;
        #1 $display("unnamed=%0d", observed);
      end
    end
  endcase

  initial $display("named=%0d", exposed.tag);
endmodule
