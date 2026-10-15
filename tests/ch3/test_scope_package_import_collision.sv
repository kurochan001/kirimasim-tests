/*
:name: test_scope_package_import_collision
:description: The same name in $unit, a wildcard-imported package and a module, resolved locally, by package, by $unit and by $root
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.12.1 26.3 23.7 26.5
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_scope_package_import_collision.expected
*/
// The same name declared in $unit, in a wildcard-imported package and in the module (3.12.1, 26.3, 23.7)
package p;
  int value = 100;
endpackage

int value = 1; // $unit::value

module test_scope_package_import_collision;
  import p::*;
  int value = 2; // local
  initial begin
    // the local declaration wins over the wildcard import
    assert(value==2) else $fatal(1, "local shadowing failed");
    // package-qualified name
    assert(p::value==100) else $fatal(1, "pkg value mismatch");
    // explicit $unit
    assert($unit::value==1) else $fatal(1, "unit value mismatch");
    // the module's own value through $root
    assert($root.test_scope_package_import_collision.value==2) else $fatal(1, "$root value mismatch");
    $display("scope package/import collision PASS");
    $finish;
  end
endmodule
