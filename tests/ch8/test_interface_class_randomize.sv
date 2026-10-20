/*
:name: test_interface_class_randomize
:description: randomize() can be called through an interface class handle; interface classes have built-in pre_randomize and post_randomize methods that the class can override, without a name conflict between two interface classes (IEEE 1800-2023 Section 8.26.9)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26.9 18.6.2 18.6.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_randomize.expected
*/
// IEEE 1800-2023 §8.26.9: randomize() is legal with an interface class
// handle. Interface classes have built-in, empty virtual pre_randomize() and
// post_randomize() methods, which an implementing class can override (18.6.2),
// and these never cause a method name conflict, so dice can implement two
// interface classes. The constraint fixes the random value, so the output
// does not depend on the random generator.

module test_interface_class_randomize;
  interface class roll_if;
    pure virtual function int value();
  endclass

  interface class name_if;
    pure virtual function string label();
  endclass

  class dice implements roll_if, name_if;
    rand int face;
    constraint fixed { face == 4; }
    virtual function int value();
      return face;
    endfunction
    virtual function string label();
      return "dice";
    endfunction
    function void pre_randomize();
      $display("pre_randomize, face=%0d", face);
    endfunction
    function void post_randomize();
      $display("post_randomize, face=%0d", face);
    endfunction
  endclass

  dice d;
  roll_if r;
  int ok;

  initial begin
    d = new();
    r = d;
    ok = r.randomize();
    $display("%s: randomize()=%0d value=%0d", d.label(), ok, r.value());
  end
endmodule
