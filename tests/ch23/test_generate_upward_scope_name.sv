/*
:name: test_generate_upward_scope_name
:description: A hierarchical name inside a generate block is resolved from the nearest enclosing scope that has its first name (IEEE 1800-2023 Section 23.8)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.8 23.6 27.4
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generate_upward_scope_name.expected
*/
// IEEE 1800-2023 §23.8: for a name of the form scope.item, the first name is
// looked up in the current scope and then in each enclosing scope in turn. In
// generate block outer, inner.b names outer.inner.b; in outer.inner.deeper,
// sib.c is not found in deeper or inner and names outer.sib.c. The same names
// work in always_comb procedures and continuous assignments.

module generate_upward_scope_dut(input logic [7:0] in_i,
                                 output logic [7:0] relay_o, cont_o, sib_o, direct_o, a_o);
  if (1) begin : outer
    logic [7:0] a, b_up, b_cont, sib_up;
    always_comb a = in_i + 8'd1;
    if (1) begin : inner
      logic [7:0] b;
      always_comb b = in_i + 8'd3;
      if (1) begin : deeper
        logic [7:0] s;
        always_comb s = sib.c;      // C: sib is found in outer
      end
    end
    if (1) begin : sib
      logic [7:0] c;
      always_comb c = in_i + 8'd5;
    end
    always_comb b_up = inner.b;     // A: always_comb, one level down
    assign b_cont = inner.b;        // B: continuous assignment, one level down
    always_comb sib_up = inner.deeper.s;
  end
  always_comb relay_o  = outer.b_up;
  always_comb cont_o   = outer.b_cont;
  always_comb sib_o    = outer.sib_up;
  always_comb direct_o = outer.inner.b;  // control: from the module, two levels
  always_comb a_o      = outer.a;        // control: from the module, one level
endmodule

module test_generate_upward_scope_name;
  logic [7:0] in = 8'h10;
  logic [7:0] relay, cont, sib, direct, a;
  int errors = 0;
  generate_upward_scope_dut u(.in_i(in), .relay_o(relay), .cont_o(cont), .sib_o(sib),
                              .direct_o(direct), .a_o(a));

  task automatic check(string what, logic [7:0] got, logic [7:0] exp);
    if (got !== exp) begin
      $display("WRONG %s = %h, expected %h", what, got, exp);
      errors++;
    end
  endtask

  task automatic check_all(logic [7:0] v);
    check("A always_comb reads inner.b", relay, v + 8'd3);
    check("B assign reads inner.b", cont, v + 8'd3);
    check("C sib.c found in an enclosing generate block", sib, v + 8'd5);
    check("ctl outer.inner.b from the module", direct, v + 8'd3);
    check("ctl outer.a from the module", a, v + 8'd1);
  endtask

  initial begin
    #1;
    check_all(8'h10);
    in = 8'hFD;
    #1;
    check_all(8'hFD);
    if (errors == 0) begin
      $display("TEST PASSED: hierarchical names inside generate blocks");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
