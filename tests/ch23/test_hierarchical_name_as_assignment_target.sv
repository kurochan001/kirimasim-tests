/*
:name: test_hierarchical_name_as_assignment_target
:description: Variables and a net of another instance driven through hierarchical names by continuous assignments and an output port (IEEE 1800-2023 Section 23.6)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.6 10.3 23.3.3
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_hierarchical_name_as_assignment_target.expected
*/
// IEEE 1800-2023 §23.6: a hierarchical name can stand for an object wherever
// its simple name could, also as the target of a continuous assignment
// (10.3) and as the expression connected to an output port (23.3.3). Here
// the top module drives two variables and a net of another instance through
// hierarchical names; that instance never assigns them itself.

module target_holder;
  logic [7:0] by_port;
  logic [7:0] by_assign;
  wire [7:0] net_by_assign;
endmodule

module constant_driver (output logic [7:0] o);
  initial o = 8'h11;
endmodule

module test_hierarchical_name_as_assignment_target;
  logic [7:0] src = 8'h22;
  target_holder h ();
  constant_driver d (.o(h.by_port));
  assign h.by_assign = src;
  assign h.net_by_assign = src + 8'h11;

  initial begin
    #1 $display("by_port=%h by_assign=%h net_by_assign=%h", h.by_port, h.by_assign,
                h.net_by_assign);
    src = 8'h40;
    #1 $display("by_assign=%h net_by_assign=%h", h.by_assign, h.net_by_assign);
  end
endmodule
