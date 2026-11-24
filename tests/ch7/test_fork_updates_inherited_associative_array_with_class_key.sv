/*
:name: test_fork_updates_inherited_associative_array_with_class_key
:description: Background fork updates the inherited associative array at its class key (IEEE 1800-2023 Section 7.8.3)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.8.3 7.9 9.3.2 13.4.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_fork_updates_inherited_associative_array_with_class_key.expected
:expected_exit: 0
*/
// A background fork in the base function adds a class-keyed element to
// the derived instance and removes the same element after a delay.

module test_fork_updates_inherited_associative_array_with_class_key;
  class token;
  endclass

  class registry_base;
    token active[token];

    function void schedule(token key, token value);
      fork
        begin
          active[key] = value;
          #5;
          active.delete(key);
        end
      join_none
    endfunction
  endclass

  class registry extends registry_base;
  endclass

  initial begin
    automatic registry r = new;
    automatic token key = new;
    automatic token other = new;
    automatic token value = new;
    r.schedule(key, value);
    #1;
    $display("CHECK registered=%0d count=%0d", r.active.exists(key), r.active.num());
    if (r.active.num() != 1 || !r.active.exists(key) || r.active.exists(other))
      $fatal(1, "entry was not registered under the supplied key");
    if (r.active[key] != value)
      $fatal(1, "entry has the wrong value");
    #5;
    $display("CHECK cleared=%0d", r.active.num() == 0);
    if (r.active.num() != 0)
      $fatal(1, "the scheduled removal was not visible to the caller");
    $display("CHECK pass");
    $finish;
  end
endmodule
