/*
:name: test_power_signed_base
:description: The result of the power operator is signed when its left operand is signed (IEEE 1800-2023 Section 11.4.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.3 11.6.1 11.8.1
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_power_signed_base.expected
*/
// IEEE 1800-2023 §11.4.3, §11.6.1, §11.8.1: the power operator takes its width
// and its signedness from the left operand (the base); the exponent does not
// affect them. So (-2)**3 is a signed -8 also where the expression is
// self-determined, as an argument of $sformatf, an operand of >>> or %, or of a
// relational operator, while an unsigned base gives an unsigned result.

module test_power_signed_base;
  int fails = 0;

  initial begin
    static int b = -2;
    static int e = 3;
    static int p = (-2)**3;

    if ($sformatf("%0d", (-2)**3) != "-8") begin
      $display("FAIL const fmt = %s (exp -8)", $sformatf("%0d", (-2)**3)); fails++; end
    if ($sformatf("%0d", b**3) != "-8") begin
      $display("FAIL var-base fmt = %s (exp -8)", $sformatf("%0d", b**3)); fails++; end
    if ($sformatf("%0d", b**e) != "-8") begin
      $display("FAIL var-base var-exp fmt = %s (exp -8)", $sformatf("%0d", b**e)); fails++; end

    // >>> is an arithmetic shift on a signed result
    if ((((-2)**3) >>> 1) != -4) begin
      $display("FAIL inline ashr = %0d (exp -4)", ((-2)**3) >>> 1); fails++; end
    if ((((-2)**3) >>> 1) != (p >>> 1)) begin
      $display("FAIL inline %0d != via-var %0d", ((-2)**3) >>> 1, p >>> 1); fails++; end

    if ((((-2)**3) % 100) != -8) begin
      $display("FAIL mod = %0d (exp -8)", ((-2)**3) % 100); fails++; end
    if (!(((-2)**3) < 0)) begin
      $display("FAIL relational not < 0"); fails++; end

    // a wider target sign-extends the result
    begin static longint l = (-2)**3; if (l != -8) begin $display("FAIL longint = %0d (exp -8)", l); fails++; end end

    if ($sformatf("%0d", (-3)**2) != "9") begin
      $display("FAIL (-3)**2 = %s (exp 9)", $sformatf("%0d", (-3)**2)); fails++; end
    if ($sformatf("%0d", (-3)**3) != "-27") begin
      $display("FAIL (-3)**3 = %s (exp -27)", $sformatf("%0d", (-3)**3)); fails++; end

    if ((b**0) != 1) begin
      $display("FAIL b**0 = %0d (exp 1)", b**0); fails++; end

    // an unsigned base gives an unsigned result
    begin
      static bit [31:0] ub = 2;
      if ($sformatf("%0d", ub**3) != "8") begin
        $display("FAIL unsigned base = %s (exp 8)", $sformatf("%0d", ub**3)); fails++; end
    end
    if ($sformatf("%0d", 2**3) != "8") begin
      $display("FAIL positive signed base = %s (exp 8)", $sformatf("%0d", 2**3)); fails++; end

    if (fails == 0)
      $display("TEST PASSED: the sign of a power follows its base");
    else
      $display("TEST FAILED: %0d check(s) failed", fails);
    $finish;
  end
endmodule
