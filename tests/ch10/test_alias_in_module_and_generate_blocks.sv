/*
:name: test_alias_in_module_and_generate_blocks
:description: alias statements are allowed wherever module instances are, in the module body and in the blocks of loop, if and case generate constructs (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_alias_in_module_and_generate_blocks.expected
*/
// IEEE 1800-2023 §10.11: an alias statement can be written wherever a module
// instance can, which includes the module body and the blocks of loop, if and
// case generate constructs.
// In each place an alias joins two nets x and y declared there, y is driven
// and x is read, with a different nonzero value in each place; in the loop
// each iteration joins its own pair and passes a different bit of src, so dst
// shows that every iteration's alias took effect. Only the selected branch of
// the case construct exists. Without the connection, x would read z.
// Icarus Verilog 13.0 does not parse alias statements.

module test_alias_in_module_and_generate_blocks;
  localparam int SEL = 2;
  wire [1:0] m_x, m_y;
  wire [3:0] src = 4'b1101;
  wire [3:0] dst;

  alias m_x = m_y;
  assign m_y = 2'b01;

  for (genvar i = 0; i < 4; i++) begin : g_loop
    wire x, y;
    alias x = y;
    assign y = src[i];
    assign dst[i] = x;
  end

  if (SEL == 2) begin : g_if
    wire [1:0] x, y;
    alias x = y;
    assign y = 2'b10;
  end

  case (SEL)
    1: begin : g_case_one
      wire x;
    end
    2: begin : g_case_two
      wire [1:0] x, y;
      alias x = y;
      assign y = 2'b11;
    end
  endcase

  initial begin
    #1;
    $display("module: m_x=%b", m_x);
    $display("loop: dst=%b", dst);
    $display("if: x=%b", g_if.x);
    $display("case: x=%b", g_case_two.x);
  end
endmodule
