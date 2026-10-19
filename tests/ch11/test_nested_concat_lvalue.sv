/*
:name: test_nested_concat_lvalue
:description: Nested concatenations, with part-selects inside, as the target of blocking and nonblocking assignments (IEEE 1800-2023 Section 11.4.12)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.12 10.4.2 11.5.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nested_concat_lvalue.expected
*/
// IEEE 1800-2023 §11.4.12: a concatenation used as the target of an assignment
// may contain further concatenations and part-selects. The right-hand side is
// split among all the innermost operands from the most significant end, however
// deeply they are nested, for blocking and nonblocking assignments alike.

module test_nested_concat_lvalue;
  int fails = 0;

  initial begin
    logic [3:0] a, b, c, d;
    logic [7:0] e;

    // (1) three levels, identifiers only
    a = '0; b = '0; c = '0; d = '0;
    {a, {b, {c, d}}} = 16'h1234;
    if (a !== 4'h1) begin $display("FAIL nest a=%h (want 1)", a); fails++; end
    if (b !== 4'h2) begin $display("FAIL nest b=%h (want 2)", b); fails++; end
    if (c !== 4'h3) begin $display("FAIL nest c=%h (want 3)", c); fails++; end
    if (d !== 4'h4) begin $display("FAIL nest d=%h (want 4)", d); fails++; end

    // (2) a part-select inside a nested concatenation
    c = 4'hF; e = 8'h5A;
    {a, {c[3:0]}} = e;
    if (a !== 4'h5) begin $display("FAIL psel a=%h (want 5)", a); fails++; end
    if (c !== 4'hA) begin $display("FAIL psel c=%h (want A)", c); fails++; end

    // (3) three levels with a part-select in the middle level
    a = '0; b = '0; c = '0; d = '0;
    {a, {b[3:0], {c, d}}} = 16'hABCD;
    if (a !== 4'hA) begin $display("FAIL t a=%h (want A)", a); fails++; end
    if (b !== 4'hB) begin $display("FAIL t b=%h (want B)", b); fails++; end
    if (c !== 4'hC) begin $display("FAIL t c=%h (want C)", c); fails++; end
    if (d !== 4'hD) begin $display("FAIL t d=%h (want D)", d); fails++; end

    // (4) nonblocking assignment to a nested concatenation
    a = '0; b = '0; c = '0; d = '0;
    #1 {a, {b, {c, d}}} <= 16'h1234;
    #1;
    if (a !== 4'h1 || b !== 4'h2 || c !== 4'h3 || d !== 4'h4) begin
      $display("FAIL nba a=%h b=%h c=%h d=%h (want 1 2 3 4)", a, b, c, d); fails++;
    end

    // (5) control: nonblocking assignment to a flat concatenation
    a = '0; b = '0;
    #1 {a, b} <= 8'h56;
    #1;
    if (a !== 4'h5 || b !== 4'h6) begin
      $display("FAIL nba-flat a=%h b=%h (want 5 6)", a, b); fails++;
    end

    if (fails == 0)
      $display("TEST PASSED: nested concatenation as an assignment target");
    else
      $display("TEST FAILED: %0d check(s) failed", fails);
    $finish;
  end
endmodule
