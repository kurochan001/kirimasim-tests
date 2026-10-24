/*
:name: test_illegal_package_initial_procedure
:description: A package can contain processes only inside checkers, so an initial procedure directly in a package is illegal, while the package can declare a variable and a function that a module uses in its own initial procedure (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: elaboration
:lrm: 1800-2023 26.2
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the package pip_pkg has an initial procedure among its items
:expected_stderr_regex: test_illegal_package_initial_procedure\.sv:24:
*/
// IEEE 1800-2023 §26.2: packages may contain processes inside checkers only.
// pip_pkg declares the variable count and the function bump, which are legal
// package items, and the module calls bump from its own initial procedure;
// the package also has an initial procedure among its items.

package pip_pkg;
  int count = 0;
  function automatic void bump();
    count++;
  endfunction
  initial count = 1;   // illegal: a process directly in a package
endpackage

module test_illegal_package_initial_procedure;
  initial begin
    pip_pkg::bump();
    $display("%0d", pip_pkg::count);
  end
endmodule
