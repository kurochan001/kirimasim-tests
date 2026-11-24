/*
:name: test_unpacked_tagged_union_read_checks_current_nested_tag
:description: An unpacked tagged union read checks the active member of an inner union
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.3.2 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unpacked_tagged_union_read_checks_current_nested_tag.expected
:expected_stderr_regex: (?im)^(?=[^\n]*\b(?:error|fatal)\b)(?=[^\n]*(?:tagged|tag mismatch|inactive member))(?=[^\n]*(?:\bCount\b|read|access))[^\n]+
*/
module test_unpacked_tagged_union_read_checks_current_nested_tag;
  typedef union tagged {
    int Count;
    string Label;
  } packet;
  typedef union tagged {
    void Empty;
    packet Payload;
  } slot;
  slot active;
  packet item;
  int stale;

  initial begin
    item = tagged Count 42;
    active = tagged Payload item;
    $display("active count=%0d", active.Payload.Count);
    item = tagged Label "ready";
    active = tagged Payload item;
    $display("active label=%s", active.Payload.Label);
    stale = active.Payload.Count;
  end
endmodule
