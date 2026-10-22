/*
:name: test_integer_atom_defaults_and_widths
:description: Integer atom types have fixed widths and signed default arithmetic (IEEE 1800-2023 Section 6.11.3)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11.3 6.11 6.8
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integer_atom_defaults_and_widths.expected
*/
// IEEE 1800-2023 6.11 6.11.3: Integer atoms have fixed widths and signedness.
// Section 6.8, Table 6-7 fixes the two-state and four-state initial values.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

module test_integer_atom_defaults_and_widths;
  byte b;
  shortint s;
  int i;
  longint l;
  integer j;
  time t;
  initial begin
    $display("bits=%0d,%0d,%0d,%0d,%0d,%0d", $bits(b), $bits(s), $bits(i),
             $bits(l), $bits(j), $bits(t));
    $display("defaults=%0d,%0d,%0d,%0d unknown=%0d,%0d", b, s, i, l,
             $isunknown(j), $isunknown(t));
    b = 8'hff; s = 16'hffff;
    $display("signed=%0d,%0d", b, s);
  end
endmodule
