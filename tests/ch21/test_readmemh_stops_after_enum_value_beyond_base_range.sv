/*
:name: test_readmemh_stops_after_enum_value_beyond_base_range
:description: A hexadecimal memory load stops when an enum word exceeds its base range
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_readmemh_stops_after_enum_value_beyond_base_range.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:enum|readmemh))(?=[^\n]*(?:range|width|value))[^\n]+
*/
module test_readmemh_stops_after_enum_value_beyond_base_range;
  typedef enum bit [2:0] {EMPTY = 0, FIRST = 2, KEEP = 4, LATER = 7} word_t;
  word_t words[0:2];

  initial begin
    int file;
    foreach (words[i])
      words[i] = KEEP;
    file = $fopen("enum_h_range.mem", "w");
    if (file == 0)
      $fatal(1, "cannot create enum memory fixture");
    $fdisplay(file, "2 f 7");
    $fclose(file);

    $readmemh("enum_h_range.mem", words);
    $display("first=%0d later stayed=%0d later loaded=%0d",
             words[0] == FIRST, words[2] == KEEP, words[2] == LATER);
  end
endmodule
