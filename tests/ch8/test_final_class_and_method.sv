/*
:name: test_final_class_and_method
:description: A class declared :final can extend another class and be used, and a method declared :final is inherited and called as any other (IEEE 1800-2023 Section 8.13)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.20 8.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_final_class_and_method.expected
*/
// IEEE 1800-2023 §8.13: :final only says that no class may extend the class;
// the class itself can extend a base class and be instantiated. §8.20: a :final
// method cannot be overridden, but the subclass inherits it; :final does not
// make a method virtual, so name, declared virtual :final, is the base method,
// while kind is overridden as usual.
// Icarus Verilog 13.0 does not support this construct of IEEE 1800-2023.

class test_final_class_and_method_base;
  virtual function :final string name();
    return "base name";
  endfunction
  virtual function string kind();
    return "base kind";
  endfunction
endclass

class :final test_final_class_and_method_leaf extends test_final_class_and_method_base;
  virtual function string kind();
    return "leaf kind";
  endfunction
endclass

module test_final_class_and_method;
  test_final_class_and_method_leaf l = new;
  test_final_class_and_method_base b;
  initial begin
    b = l;
    $display("%s, %s", b.name(), b.kind());
  end
endmodule
