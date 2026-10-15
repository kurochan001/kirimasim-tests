/*
:name: test_method_virtual
:description: Virtual methods test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.15
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_method_virtual.expected
*/
// Virtual methods test
module test_method_virtual;

  // Base class with virtual methods
  class Animal;
    string name;

    function new(string n);
      name = n;
    endfunction

    // Virtual method to be overridden
    virtual function string make_sound();
      return "...";
    endfunction

    // Virtual method with parameters
    virtual function int get_legs();
      return 0;
    endfunction

    // Non-virtual method
    function string get_name();
      return name;
    endfunction

    // Virtual method calling other virtual method
    virtual function string describe();
      string result;
      $sformat(result, "%s says %s and has %0d legs", name, make_sound(), get_legs());
      return result;
    endfunction
  endclass

  // Derived class overriding virtual methods
  class Dog extends Animal;
    function new(string n);
      super.new(n);
    endfunction

    virtual function string make_sound();
      return "Woof";
    endfunction

    virtual function int get_legs();
      return 4;
    endfunction
  endclass

  // Another derived class
  class Bird extends Animal;
    function new(string n);
      super.new(n);
    endfunction

    virtual function string make_sound();
      return "Tweet";
    endfunction

    virtual function int get_legs();
      return 2;
    endfunction
  endclass

  // Third level inheritance
  class Parrot extends Bird;
    function new(string n);
      super.new(n);
    endfunction

    virtual function string make_sound();
      return "Hello";
    endfunction
  endclass

  initial begin
    Animal animal;
    Dog dog;
    Bird bird;
    Parrot parrot;
    string sound;
    int legs;
    int pass_count;

    pass_count = 0;

    // Test 1: Virtual method in derived class
    dog = new("Buddy");
    sound = dog.make_sound();
    if (sound == "Woof") begin
      $display("Test 1 PASS: Dog.make_sound() = %s", sound);
      pass_count++;
    end else begin
      $display("Test 1 FAIL: sound = %s, expected Woof", sound);
    end

    // Test 2: Polymorphism - base pointer to derived object
    animal = dog;
    sound = animal.make_sound();
    legs = animal.get_legs();
    if (sound == "Woof" && legs == 4) begin
      $display("Test 2 PASS: Animal=Dog, sound=%s, legs=%0d", sound, legs);
      pass_count++;
    end else begin
      $display("Test 2 FAIL: sound=%s (exp Woof), legs=%0d (exp 4)", sound, legs);
    end

    // Test 3: Different derived class
    bird = new("Tweety");
    animal = bird;
    sound = animal.make_sound();
    legs = animal.get_legs();
    if (sound == "Tweet" && legs == 2) begin
      $display("Test 3 PASS: Animal=Bird, sound=%s, legs=%0d", sound, legs);
      pass_count++;
    end else begin
      $display("Test 3 FAIL: sound=%s (exp Tweet), legs=%0d (exp 2)", sound, legs);
    end

    // Test 4: Third level inheritance
    parrot = new("Polly");
    animal = parrot;
    sound = animal.make_sound();
    legs = animal.get_legs();
    if (sound == "Hello" && legs == 2) begin
      $display("Test 4 PASS: Animal=Parrot, sound=%s, legs=%0d", sound, legs);
      pass_count++;
    end else begin
      $display("Test 4 FAIL: sound=%s (exp Hello), legs=%0d (exp 2)", sound, legs);
    end

    // Test 5: Virtual method calling other virtual methods
    dog = new("Rex");
    animal = dog;
    if (animal.describe() == "Rex says Woof and has 4 legs") begin
      $display("Test 5 PASS: describe() uses virtual methods correctly");
      pass_count++;
    end else begin
      $display("Test 5 FAIL: describe() = %s", animal.describe());
    end

    if (pass_count == 5)
      $display("PASS: All virtual method tests passed");
    else
      $display("FAIL: %0d/5 tests passed", pass_count);

    $finish;
  end

endmodule
