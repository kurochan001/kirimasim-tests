/*
:name: test_identifier_leading_underscore
:description: Identifiers that start with an underscore and contain digits, such as _133_ and _1e5 (IEEE 1800-2023 Section 5.6)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6 5.7.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_identifier_leading_underscore.expected
*/
// IEEE 1800-2023 §5.6: a simple identifier may start with a letter or an
// underscore, and digits may follow. A number may not start with an underscore
// (5.7.1), so _133_, _7_ and _1e5 are names of nets and variables, not numbers,
// in every place a name can appear: operands, concatenations, assignment targets
// and port connections.

module identifier_underscore_leaf(input logic [8:0] d, output logic [8:0] q);
  assign q = d;
endmodule

module test_identifier_leading_underscore;
  wire  [8:0] _133_;
  logic [8:0] src = 9'd0;
  logic [8:0] _7_ = 9'd1;
  logic [8:0] _1e5 = 9'd4;         // would be a real number without the underscore
  logic [8:0] _a1 = 9'd2;          // control: underscore and a letter
  logic [8:0] n_5 = 9'd3;          // control: a letter first
  wire  [8:0] _42_;
  wire  [8:0] q;
  logic [21:0] r;
  int errors = 0;
  assign _133_ = src;
  assign _42_ = src + 9'd8;
  identifier_underscore_leaf u(.d(_42_), .q(q));

  task automatic check(string what, int got, int exp);
    if (got !== exp) begin
      $display("WRONG %s = %0d, expected %0d", what, got, exp);
      errors++;
    end
  endtask

  initial begin
    #1;
    check("A _133_ (wire)", _133_, 0);
    check("B _133_ + 1", _133_ + 1, 1);
    r = {4'h0, _133_, 9'h0};
    check("C {4'h0, _133_, 9'h0}", r, 0);
    check("D _7_ (variable)", _7_, 1);
    _7_ = 9'd5;
    check("E _7_ after write", _7_, 5);
    check("F _1e5", _1e5, 4);
    check("G port connection of _42_", q, 8);
    check("H -_7_ in 9 bits", 9'(-_7_), 507);
    check("ctl _a1", _a1, 2);
    check("ctl n_5", n_5, 3);
    if (errors == 0) begin
      $display("TEST PASSED: identifiers starting with an underscore");
    end else begin
      $display("TEST FAILED: %0d errors", errors);
    end
    $finish;
  end
endmodule
