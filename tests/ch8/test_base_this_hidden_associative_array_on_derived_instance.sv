/*
:name: test_base_this_hidden_associative_array_on_derived_instance
:description: A base method inserts into its own hidden associative array on a derived object (IEEE 1800-2023 Section 8.14)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.14 8.18 7.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_base_this_hidden_associative_array_on_derived_instance.expected
:expected_exit: 0
*/
// The base method names its local array through this. A derived queue with
// the same name has separate storage. Check both objects and the untouched
// queue.

module test_base_this_hidden_associative_array_on_derived_instance;
  class base;
    local bit entries[int];
    function void add();
      this.entries[17] = 1;
    endfunction
    function int count();
      return entries.num();
    endfunction
  endclass
  class child extends base;
    int entries[$];
    function int queue_size();
      return entries.size();
    endfunction
  endclass

  initial begin
    automatic base normal = new;
    automatic child derived = new;
    normal.add();
    derived.add();
    $display("CHECK base=%0d inherited=%0d queue=%0d",
             normal.count(), derived.count(), derived.queue_size());
    $finish;
  end
endmodule
