/*
:name: test_associative_event_key_identity
:description: Compare event identity and use the same event handles as associative indices
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5 11.4.5 15.5.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_event_key_identity.expected
*/
module test_associative_event_key_identity;
  typedef event event_key;
  event_key original, alias_handle, other;
`ifndef COMPARE_ONLY
  int indexed[event_key];
`endif

  initial begin
    alias_handle = original;
    $display("equality=%b%b%b/%b%b%b/%b%b%b",
             original == original, original == alias_handle, original == other,
             alias_handle == original, alias_handle == alias_handle, alias_handle == other,
             other == original, other == alias_handle, other == other);
`ifndef COMPARE_ONLY
    indexed[original] = 13;
    indexed[other] = 59;
    $display("alias-value=%0d other-value=%0d entries=%0d",
             indexed[alias_handle], indexed[other], indexed.num());
    indexed[alias_handle] += 4;
    $display("updated-original=%0d unchanged-other=%0d entries=%0d",
             indexed[original], indexed[other], indexed.num());
`endif
    $finish(0);
  end
endmodule
