/*
:name: test_sscanf_fields_whitespace_percent
:description: $sscanf ends an input field at a character outside it or at the maximum field width, skips white space before every field except one read by %c, skips any amount of input white space, null characters included, where the format has white space, and matches %% with one percent sign without assigning (IEEE 1800-2023 Section 21.3.4.3)
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.3.4.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sscanf_fields_whitespace_percent.expected
*/
// IEEE 1800-2023 §21.3.4.3: white space in the format of $sscanf reads the
// input up to the next character that is not white space; for $sscanf a null
// character counts as white space. An ordinary character has to match the next
// input character. An input field ends at the first character that does not
// belong to it or when the maximum field width is used up, and white space
// before it is skipped, except for %c, which reads the next character whatever
// it is. %% matches a single % in the input and assigns nothing. The result
// counts the items assigned. Each line prints the result and the values; a
// value that was not assigned keeps -1. The source with a null character is an
// integral variable (21.3.4.3 allows one). The 5.052 release of Verilator
// ignores the field widths, matches the comma after a space without format
// white space, stops at the null character and returns -1 instead of 1 after
// the percent mismatch.

module test_sscanf_fields_whitespace_percent;
  int n, a, b, c;
  string s, t;
  logic [8*3-1:0] src_nul;

  task automatic clear();
    a = -1; b = -1; c = -1; s = "-"; t = "-";
  endtask

  initial begin
    clear(); n = $sscanf("12345", "%3d%d", a, b);
    $display("width: n=%0d a=%0d b=%0d", n, a, b);
    clear(); n = $sscanf("abcd", "%2s%s", s, t);
    $display("string width: n=%0d s=%s t=%s", n, s, t);
    clear(); n = $sscanf("12ab", "%d%s", a, s);
    $display("end at letter: n=%0d a=%0d s=%s", n, a, s);
    clear(); n = $sscanf(" \t\n 7", "%d", a);
    $display("leading white space: n=%0d a=%0d", n, a);
    clear(); n = $sscanf("5 x", "%d%c", a, c);
    $display("%%c after %%d: n=%0d a=%0d c=%0d", n, a, c);
    clear(); n = $sscanf("  q", "%c", c);
    $display("%%c first: n=%0d c=%0d", n, c);

    clear(); n = $sscanf("5 \t\n x", "%d %c", a, c);
    $display("format space before %%c: n=%0d a=%0d c=%0d", n, a, c);
    clear(); n = $sscanf("3 \t ,4", "%d ,%d", a, b);
    $display("format space before comma: n=%0d a=%0d b=%0d", n, a, b);
    clear(); n = $sscanf("3 ,4", "%d,%d", a, b);
    $display("no format space: n=%0d a=%0d b=%0d", n, a, b);
    src_nul = {"1", 8'h00, "2"};
    clear(); n = $sscanf(src_nul, "%d %d", a, b);
    $display("null as white space: n=%0d a=%0d b=%0d", n, a, b);

    clear(); n = $sscanf("50%60", "%d%%%d", a, b);
    $display("percent: n=%0d a=%0d b=%0d", n, a, b);
    clear(); n = $sscanf("50x60", "%d%%%d", a, b);
    $display("percent mismatch: n=%0d a=%0d b=%0d", n, a, b);
    clear(); n = $sscanf("%7", "%%%d", a);
    $display("leading percent: n=%0d a=%0d", n, a);
  end
endmodule
