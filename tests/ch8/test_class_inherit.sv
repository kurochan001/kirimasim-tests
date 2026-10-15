/*
:name: test_class_inherit
:description: Test: extends, super.new, method override, parent reference
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.13 8.15 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_inherit.expected
*/
// Test: extends, super.new, method override, parent reference
module test_class_inherit;

  class Animal;
    string species;
    int legs;

    function new(string s, int l);
      species = s;
      legs = l;
    endfunction

    virtual function string speak();
      return "...";
    endfunction

    function int get_legs();
      return legs;
    endfunction
  endclass

  class Dog extends Animal;
    string breed;

    function new(string b);
      super.new("canine", 4);
      breed = b;
    endfunction

    function string speak();
      return "woof";
    endfunction
  endclass

  class Cat extends Animal;
    function new();
      super.new("feline", 4);
    endfunction

    function string speak();
      return "meow";
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Dog d;
    Cat c;
    Animal a;

    d = new("labrador");
    c = new();

    // Check 1: super.new sets parent fields
    if (d.species == "canine") begin pass_cnt++; $display("PASS: dog species == canine"); end
    else begin fail_cnt++; $display("FAIL: dog species = %s", d.species); end

    // Check 2: child field
    if (d.breed == "labrador") begin pass_cnt++; $display("PASS: dog breed == labrador"); end
    else begin fail_cnt++; $display("FAIL: dog breed = %s", d.breed); end

    // Check 3: overridden method on child
    if (d.speak() == "woof") begin pass_cnt++; $display("PASS: dog speaks woof"); end
    else begin fail_cnt++; $display("FAIL: dog speaks %s", d.speak()); end

    // Check 4: inherited method
    if (d.get_legs() == 4) begin pass_cnt++; $display("PASS: dog has 4 legs"); end
    else begin fail_cnt++; $display("FAIL: dog legs = %0d", d.get_legs()); end

    // Check 5: cat override
    if (c.speak() == "meow") begin pass_cnt++; $display("PASS: cat speaks meow"); end
    else begin fail_cnt++; $display("FAIL: cat speaks %s", c.speak()); end

    // Check 6: parent handle holds child: polymorphic call
    a = d;
    if (a.speak() == "woof") begin pass_cnt++; $display("PASS: polymorphic call via parent handle"); end
    else begin fail_cnt++; $display("FAIL: parent handle call = %s", a.speak()); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
