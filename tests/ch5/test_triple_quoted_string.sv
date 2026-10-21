/*
:name: test_triple_quoted_string
:description: A triple-quoted string holds newlines and double quotes as they are written, and an escaped newline in it continues the line (IEEE 1800-2023 Section 5.9)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.9 5.9.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_triple_quoted_string.expected
*/
// IEEE 1800-2023 §5.9: a triple-quoted string, between three double quotes, can
// hold a newline and a double quote character without escapes. An escaped
// newline in it is treated as in a quoted string: the line goes on without the
// newline. §5.9.1: the escape sequences, such as \t for a tab, still work in
// it.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023.

module test_triple_quoted_string;
  string s;
  initial begin
    $display("""first line with "quotes"
second line""");
    s = """a\tb \
joined""";
    $display("%s", s);
    $display("length=%0d", s.len());
  end
endmodule
