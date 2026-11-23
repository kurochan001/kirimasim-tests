/*
:name: test_dynamic_cast_into_associative_class_element
:description: A successful class downcast creates the target associative array entry (IEEE 1800-2023 Section 6.24.2)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2 8.16 7.8
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_dynamic_cast_into_associative_class_element.expected
:expected_exit: 0
*/
// create returns a base handle to a new child. A successful downcast writes
// that exact object to the previously absent string key.

module test_dynamic_cast_into_associative_class_element;
  class parent;
    virtual function parent create(); return null; endfunction
  endclass
  class child extends parent;
    virtual function parent create();
      child c = new;
      return c;
    endfunction
  endclass
  class container;
    child items[string];
    function void copy_one(container source, string key);
      parent made = source.items[key].create();
      bit ok;
      ok = $cast(items[key], made);
      $display("CHECK cast=%0d exists=%0d identity=%0d",
               ok, items.exists(key), made != null && items[key] == made);
    endfunction
  endclass

  initial begin
    automatic container source = new;
    automatic container dest = new;
    source.items["a"] = new;
    dest.copy_one(source, "a");
    $finish;
  end
endmodule
