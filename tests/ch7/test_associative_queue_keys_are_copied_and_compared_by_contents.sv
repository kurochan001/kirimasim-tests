/*
:name: test_associative_queue_keys_are_copied_and_compared_by_contents
:description: Changing the source queue leaves the stored associative key and its lookup intact
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.5
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_associative_queue_keys_are_copied_and_compared_by_contents.expected
*/
module test_associative_queue_keys_are_copied_and_compared_by_contents;
  typedef int queue_key[$];
  int lookup[queue_key];

  initial begin
    queue_key key, separate;
    key = {3, 8};
    lookup[key] = 15;
    key[0] = 9;
    lookup[key] = 25;
    separate = {3, 8};
    $display("separate=%0d changed=%0d", lookup[separate], lookup[key]);
    separate.push_back(0);
    $display("different length exists=%0d total=%0d", lookup.exists(separate), lookup.num());
    void'(separate.pop_back());
    lookup.delete(separate);
    $display("equal key deleted=%0d other=%0d total=%0d",
             !lookup.exists(separate), lookup[key], lookup.num());
  end
endmodule
