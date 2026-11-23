/*
:name: test_package_virtual_calls_preserve_module_string_updates
:description: Three successive virtual methods append to the same module string (IEEE 1800-2023 Section 8.20)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 23.9 10.4.1
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_virtual_calls_preserve_module_string_updates.expected
:expected_exit: 0
*/
// The package calls three methods on the same object in order. Each override
// appends to one module variable. Consuming the return value of the second
// call must preserve its append.

package observer_api;
  class observer;
    virtual function void first(); endfunction
    virtual function bit middle(); return 0; endfunction
    virtual function void last(); endfunction
  endclass
  class caller;
    function bit visit(observer o);
      bit ok;
      o.first();
      ok = o.middle();
      o.last();
      return ok;
    endfunction
  endclass
endpackage

module test_package_virtual_calls_preserve_module_string_updates;
  import observer_api::*;
  string trace = "";
  class recorder extends observer;
    virtual function void first(); trace = {trace, "E"}; endfunction
    virtual function bit middle();
      trace = {trace, "U"};
      return 1;
    endfunction
    virtual function void last(); trace = {trace, "X"}; endfunction
  endclass

  initial begin
    automatic recorder r = new;
    automatic caller c = new;
    automatic bit ok = c.visit(r);
    $display("CHECK trace=%s result=%0d", trace, ok);
    $finish;
  end
endmodule
