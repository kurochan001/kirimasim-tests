/*
:name: test_increment_member_through_associative_handle
:description: Increment and decrement update the object reached via an associative array (IEEE 1800-2023 Section 11.4.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.2 7.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_increment_member_through_associative_handle.expected
:expected_exit: 0
*/
// Both expressions designate the same object. Incrementing through the array
// element is visible through an alias and decrementing after setting three
// leaves two.

module test_increment_member_through_associative_handle;
  class entry;
    int count = 0;
  endclass
  class key; endclass
  class pool;
    entry items[key];
    function void check(key k);
      entry alias_handle;
      items[k] = new;
      alias_handle = items[k];
      items[k].count++;
      $display("CHECK increment=%0d/%0d", items[k].count, alias_handle.count);
      alias_handle.count = 3;
      items[k].count--;
      $display("CHECK decrement=%0d/%0d", items[k].count, alias_handle.count);
    endfunction
  endclass

  initial begin
    automatic pool p = new;
    automatic key k = new;
    p.check(k);
    $finish;
  end
endmodule
