/*
:name: test_compact_pattern_formats_aggregate
:description: Exercise both aggregate format specifiers on short and long records
:tags: ch21
:type: simulation
:lrm: 1800-2023 21.2.1.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_compact_pattern_formats_aggregate.expected
*/
module test_compact_pattern_formats_aggregate;
  typedef struct {
    string first;
    string second;
  } record_t;

  record_t sample = '{first: "caliper", second: "stencil"};
  string short_full, short_compact, long_full, long_compact;
  bit short_values_present;

  function automatic bit contains_value(string text, string value);
    for (int start = 0; start + value.len() <= text.len(); start++)
      if (text.substr(start, start + value.len() - 1) == value)
        return 1;
    return 0;
  endfunction

  initial begin
    $display("singular=%0p", sample.second);
    short_full = $sformatf("%p", sample);
    short_compact = $sformatf("%0p", sample);
    short_values_present = contains_value(short_full, sample.first) &&
                           contains_value(short_full, sample.second) &&
                           contains_value(short_compact, sample.first) &&
                           contains_value(short_compact, sample.second);

    sample.first = "";
    sample.second = "";
    repeat (600) begin
      sample.first = {sample.first, "R"};
      sample.second = {sample.second, "S"};
    end
    long_full = $sformatf("%p", sample);
    long_compact = $sformatf("%0p", sample);
    $display("aggregate results=%0d", short_values_present &&
                                      long_full.len() != 0 && long_compact.len() != 0);

    if ($test$plusargs("observe_patterns")) begin
      $display("short full=%s", short_full);
      $display("short compact=%s", short_compact);
      $display("long lengths=%0d,%0d", long_full.len(), long_compact.len());
      $display("long full=%s", long_full);
      $display("long compact=%s", long_compact);
    end
    $finish(0);
  end
endmodule
