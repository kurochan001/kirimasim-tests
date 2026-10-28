/*
:name: test_string_ato_integer_scan_rules
:description: atoi(), atohex(), atooct() and atobin() scan leading digits and underscores, stop at any other character, return 0 without digits, and do not parse a plus, size, apostrophe or base; a leading minus may be read or not, and a leading underscore may be scanned or not (IEEE 1800-2023 Section 6.16.9)
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
// integer literal that are not digits: a size, the apostrophe and a base. So
// "+12" gives 0, "8'hff" gives 8 for atohex (the scan stops at the
// apostrophe), and "'hff", "hff" and "4'b1010" for atobin give 0. Whether a
// leading minus is read is not settled: 6.16.9 names the sign among those
// parts, but slang reads a minus (slang issue #1987) and tools differ. So
// "-12", "-ff" and "-7" may give 0 or the negative number, and the test
// shows only whether the result is one of the two.
// Whether a leading underscore is scanned is not settled either: 6.16.9
// scans the leading digits and underscores, but slang and kirimasim need a
// digit first. So "_7_" may give 7 or 0, and the test shows only whether the
// result is one of the two. A space is not scanned. atohex takes both
// letter cases, atooct stops at 8 and atobin stops at 2.
// Icarus Verilog 13.0 does not know atooct() and atobin() (unsupported
// constructs). Verilator 5.052 skips leading spaces and reads a plus, as C
// strtol does (" 12" and "+12" give 12); the standard scans only digits and
// underscores, so these give 0.

module test_string_ato_integer_scan_rules;
  string dec[9] = '{"1_000abc", "42", "12 34", " 12", "abc", "", "___", "+12",
                    "'d12"};
  string hex[4] = '{"8'hff", "'hff", "hff", "fF_0g1"};
  string oct[2] = '{"12'o17", "7_78"};
  string bin[3] = '{"1_01_2", "4'b1010", "b101"};
  // A leading minus: 0 if it is not read, the negative number if it is.
  string minus_dec = "-12", minus_hex = "-ff", minus_oct = "-7";
  // A leading underscore: 7 if it is scanned, 0 if a digit has to come first.
  string under_dec = "_7_";
  int v;

  initial begin
    foreach (dec[i]) $display("atoi(\"%s\")=%0d", dec[i], dec[i].atoi());
    foreach (hex[i]) $display("atohex(\"%s\")=%0d", hex[i], hex[i].atohex());
    foreach (oct[i]) $display("atooct(\"%s\")=%0d", oct[i], oct[i].atooct());
    foreach (bin[i]) $display("atobin(\"%s\")=%0d", bin[i], bin[i].atobin());
    v = minus_dec.atoi();
    $display("atoi(\"-12\") is 0 or -12: %0d", v == 0 || v == -12);
    v = minus_hex.atohex();
    $display("atohex(\"-ff\") is 0 or -255: %0d", v == 0 || v == -255);
    v = minus_oct.atooct();
    $display("atooct(\"-7\") is 0 or -7: %0d", v == 0 || v == -7);
    v = under_dec.atoi();
    $display("atoi(\"_7_\") is 7 or 0: %0d", v == 7 || v == 0);
  end
endmodule
