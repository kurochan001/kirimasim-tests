/*
:name: test_name_spaces
:description: the same identifier can name a module, a package, a text macro, a variable of a module and a variable of a block, because they belong to different name spaces (IEEE 1800-2023 Section 3.13)
:tags: ch3
:type: simulation
:lrm: 1800-2023 3.13 26.3 22.5.1 23.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_name_spaces.expected
*/
// IEEE 1800-2023 §3.13: module identifiers belong to the definitions name
// space, package identifiers to the package name space, text macro names to
// the text macro name space, and the variables and instances of a module to
// its module name space; a block has its own block name space. A redeclaration
// is illegal only within one name space, so widget names a module, a package,
// a macro (§22.5.1), a variable of the test module and a variable of a block
// in it, which hides the module's variable; the module's variable is still
// reached by its hierarchical name (§23.6). The function of the package is
// imported (§26.3).

package widget;
  function automatic int get();
    return 5;
  endfunction
endpackage

module widget(output int o);
  assign o = 3;
endmodule

`define widget 7

module test_name_spaces;
  import widget::get;
  int widget;
  int o;

  widget u(o);

  initial begin
    widget = `widget + 1;
    #1;
    $display("variable widget = %0d", widget);
    $display("macro widget = %0d", `widget);
    $display("package widget: get() = %0d", get());
    $display("instance of module widget: o = %0d", o);
    begin : inner
      int widget;
      widget = 100;
      $display("block variable widget = %0d, module variable = %0d", widget,
               test_name_spaces.widget);
    end
  end
endmodule
