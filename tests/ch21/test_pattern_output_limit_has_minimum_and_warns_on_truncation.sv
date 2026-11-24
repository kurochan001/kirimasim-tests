/*
:name: test_pattern_output_limit_has_minimum_and_warns_on_truncation
:description: Large assignment-pattern formatting preserves at least 1024 characters and warns if distinct elements are truncated
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6 21.3.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_pattern_output_limit_has_minimum_and_warns_on_truncation.expected
:expected_stderr_regex: \A(?:(?=[\s\S]*^PATTERN_RESULT_COMPLETE$)|(?=[\s\S]*^PATTERN_RESULT_TRUNCATED$)(?=[\s\S]*(?im:^[^\n]*warn[^\n]*(?:truncat|too long|(?:pattern|format|output)[^\n]*limit))))
*/
module test_pattern_output_limit_has_minimum_and_warns_on_truncation;
  localparam int STDERR_FD = 32'h8000_0002;
  string items[48];
  string rendered = "";
  string line_text;
  bit all_elements;
  int pattern_file;
  int bytes_read;

  function automatic bit contains(string text, string label_text);
    for (int i = 0; i + label_text.len() <= text.len(); ++i)
      if (text[i] == label_text[0] && text.substr(i, i + label_text.len() - 1) == label_text)
        return 1;
    return 0;
  endfunction

  initial begin
    foreach (items[i]) items[i] = $sformatf("entry_%03d_a1b2c3d4e5f6g7h8k9m0n1p2r3s4", i);
    items[0] = "first_entry_unique_payload";
    items[47] = "last_entry_unique_payload";
    pattern_file = $fopen("pattern_limit.txt", "w");
    if (pattern_file == 0) $fatal(1, "cannot open pattern output");
    $fwrite(pattern_file, "%p", items);
    $fclose(pattern_file);
    pattern_file = $fopen("pattern_limit.txt", "r");
    if (pattern_file == 0) $fatal(1, "cannot read pattern output");
    while ($fgets(line_text, pattern_file) > 0) begin
      rendered = {rendered, line_text};
      bytes_read += line_text.len();
    end
    $fclose(pattern_file);
    // Check membership instead of ordering so explicit index keys or a
    // default key remain valid. Distinct payload values prevent compaction
    // through a shared default.
    all_elements = 1;
    foreach (items[i]) all_elements &= contains(rendered, items[i]);
    if (all_elements)
      $fdisplay(STDERR_FD, "PATTERN_RESULT_COMPLETE");
    else
      $fdisplay(STDERR_FD, "PATTERN_RESULT_TRUNCATED");
    $display("pattern=%b minimum=%b", contains(rendered, "'{"), bytes_read >= 1024);
  end
endmodule
