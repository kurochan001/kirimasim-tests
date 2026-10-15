/*
:name: test_unit_root_name_collision
:description: Name collisions between $unit, a module and its child, resolved with $unit:: and $root
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 23.9 23.6
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_unit_root_name_collision.expected
*/
// Name collisions between $unit, a module and its child, resolved with
// $unit:: and $root (IEEE 1800-2023 3.12.1, 23.9)

int value = 1; // compilation-unit scope

module child_naming;
  int value = 3; // local to the child
  initial begin
    // The local declaration hides the $unit one
    assert(value == 3) else $fatal(1, "local shadowing failed");
    // Explicit reference to $unit
    assert($unit::value == 1) else $fatal(1, "$unit::value mismatch");
    // The top-level value through $root (the top instance is named after its module)
    assert($root.top_name_collision.value == 2) else $fatal(1, "$root.top_name_collision.value mismatch");
  end
endmodule

module top_name_collision;
  int value = 2; // local to the top, same name as in $unit
  child_naming u_child();
  initial begin
    // In the top scope its own declaration wins
    assert(value == 2) else $fatal(1, "top local shadowing failed");
    // Explicit reference to $unit
    assert($unit::value == 1) else $fatal(1, "$unit::value mismatch @top");
    // Wait so that the child's checks at time 0 have run (4.7)
    #1;
    $display("TEST PASSED");
    $finish;
  end
endmodule
