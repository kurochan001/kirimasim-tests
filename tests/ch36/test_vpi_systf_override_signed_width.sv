/*
:name: test_vpi_systf_override_signed_width
:description: When $unsigned and $signed are overridden by VPI applications, the width of their result is the one sizetf gives, the same at every call whatever the width of the argument, and the result is signed or unsigned as registered (IEEE 1800-2023 Section 36.3.2)
:tags: ch36
:type: simulation
:lrm: 1800-2023 36.3.2 38.37.1 36.8.1 11.7 20.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_systf_override_signed_width.c
:expected_stdout: @test_vpi_systf_override_signed_width.expected
*/
// IEEE 1800-2023 §36.3.2: $signed and $unsigned can be overridden too. The
// built-in ones return a result as wide as their argument (11.7, 20.5), but an
// overriding PLI version has one return width for all its calls, which its
// sizetf routine gives (36.8.1, 38.37.1). The application registers
// $unsigned as a vpiSizedFunc of 12 bits that returns its argument plus 1,
// and $signed as a vpiSizedSignedFunc of 8 bits that returns the lower 8 bits
// of its argument as a signed number. So $unsigned of a 4-bit and of a 16-bit
// variable prints 3 hex digits and makes a concatenation 16 bits wide, and
// $signed gives -1 for 16'h00ff and 15 for 4'hf, assigned to an int.
// Icarus Verilog 13.0 keeps its built-in $signed and $unsigned here, whose
// results are as wide as their arguments.

module test_vpi_systf_override_signed_width;
  bit [3:0] n = 4'hf;
  bit [15:0] w = 16'h0123;
  bit [15:0] h = 16'h00ff;
  int s1, s2;

  initial begin
    $display("$unsigned of a 4-bit value: %h", $unsigned(n));
    $display("$unsigned of a 16-bit value: %h", $unsigned(w));
    $display("in a concatenation: %h", {$unsigned(n), 4'h0});
    s1 = $signed(h);
    s2 = $signed(n);
    $display("$signed of 16'h00ff and 4'hf: %0d %0d", s1, s2);
  end
endmodule
