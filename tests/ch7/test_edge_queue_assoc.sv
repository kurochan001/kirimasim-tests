/*
:name: test_edge_queue_assoc
:description: Queue push/pop and associative array first(), delete() and exists() with string keys
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.10.2 7.9.4 7.9.2 7.9.3 7.8.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_queue_assoc.expected
*/
module test_edge_queue_assoc;
  int q[$];
  int aa[string];
  string key;

  initial begin
    q.push_back(1);
    q.push_front(2);
    void'(q.pop_back()); // queue now contains only 2
    if (q.size() != 1 || q[0] != 2) $fatal(1, "queue operations failed");

    aa["foo"] = 10;
    aa["bar"] = 20;
    if (!aa.first(key)) $fatal(1, "assoc first should succeed");
    if (key != "bar") $fatal(1, "assoc first should return lexicographically smallest key");
    aa.delete("bar");
    if (aa.exists("bar")) $fatal(1, "assoc delete should remove key");

    $display("PASS: queue and associative array operations verified");
    $finish;
  end
endmodule
