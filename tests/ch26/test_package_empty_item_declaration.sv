/*
:name: test_package_empty_item_declaration
:description: A package item may be an empty declaration, a lone semicolon among the declarations of a package, and the package's other items keep their values and order (IEEE 1800-2023 Section 26.2)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.2 A.1.11
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_empty_item_declaration.expected
*/
// IEEE 1800-2023 §26.2 with A.1.11: a package item is a package or generate
// item declaration (among others), and that production includes the empty
// declaration, a lone semicolon. Such an item declares nothing and does not
// end the package. Here the package holds a parameter before and after two
// empty declarations, a function between them, and one more empty item after
// the last declaration; the module reads the two parameters and calls the
// function, whose result depends on the value declared after the first empty
// item. Icarus Verilog 13.0 rejects the empty item; Verilator 5.052 accepts it
// and reproduces the output.

package pkg_empty_item;
  localparam int BASE = 3;
  ;
  localparam int TOTAL = BASE + 4;
  function automatic int twice(int x);
    return 2 * x;
  endfunction
  ;
endpackage : pkg_empty_item

module test_package_empty_item_declaration;
  initial begin
    $display("base=%0d total=%0d twice=%0d", pkg_empty_item::BASE,
             pkg_empty_item::TOTAL, pkg_empty_item::twice(pkg_empty_item::TOTAL));
  end
endmodule
