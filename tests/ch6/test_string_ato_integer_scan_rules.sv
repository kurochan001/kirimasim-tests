/*
:name: test_string_ato_integer_scan_rules
:description: atoi(), atohex(), atooct() and atobin() scan leading digits and underscores, stop at any other character, return 0 without digits, and do not parse a sign, size, apostrophe or base (IEEE 1800-2023 Section 6.16.9)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.16.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_string_ato_integer_scan_rules.expected
*/
// IEEE 1800-2023 §6.16.9: the conversion scans the digits and underscores
// at the start of the string and stops at the first other character or at
// the end; with no digit the result is 0. It does not parse the parts of an
// integer literal that are not digits: a sign, a size, the apostrophe and a
// base. So "-12" and "+12" give 0, "8'hff" gives 8 for atohex (the scan
// stops at the apostrophe), and "'hff", "hff" and "4'b1010" for atobin give 0.
// A leading underscore is scanned like a digit, a space is not. atohex takes
// both letter cases, atooct stops at 8 and atobin stops at 2.
// Icarus Verilog 13.0 does not know atooct() and atobin() (unsupported
// constructs). Verilator 5.052 skips leading spaces and parses a sign, as C
// strtol does (" 12" gives 12, "-12" gives -12, "-ff" gives -255); the
// standard scans only digits and underscores, so these give 0.

module test_string_ato_integer_scan_rules;
  string dec[11] = '{"1_000abc", "42", "_7_", "12 34", " 12", "abc", "", "___",
                     "-12", "+12", "'d12"};
  string hex[5] = '{"8'hff", "'hff", "hff", "-ff", "fF_0g1"};
  string oct[3] = '{"12'o17", "7_78", "-7"};
  string bin[3] = '{"1_01_2", "4'b1010", "b101"};

  initial begin
    foreach (dec[i]) $display("atoi(\"%s\")=%0d", dec[i], dec[i].atoi());
    foreach (hex[i]) $display("atohex(\"%s\")=%0d", hex[i], hex[i].atohex());
    foreach (oct[i]) $display("atooct(\"%s\")=%0d", oct[i], oct[i].atooct());
    foreach (bin[i]) $display("atobin(\"%s\")=%0d", bin[i], bin[i].atobin());
  end
endmodule
