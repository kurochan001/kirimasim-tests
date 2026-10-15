/*
:name: test_class_cast
:description: Test: Class casting $cast
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2 8.20
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_cast.expected
*/
// Test: Class casting $cast
// IEEE 1800-2023 Section 8.16 - $cast

module test_class_cast;

  // Base class hierarchy
  class Animal;
    string name;

    function new(string n);
      name = n;
    endfunction

    virtual function string speak();
      return "...";
    endfunction
  endclass

  class Dog extends Animal;
    string breed;

    function new(string n, string b);
      super.new(n);
      breed = b;
    endfunction

    virtual function string speak();
      return "Woof!";
    endfunction

    function string fetch();
      return $sformatf("%s fetches the ball!", name);
    endfunction
  endclass

  class Cat extends Animal;
    int lives;

    function new(string n);
      super.new(n);
      lives = 9;
    endfunction

    virtual function string speak();
      return "Meow!";
    endfunction

    function void lose_life();
      if (lives > 0) lives--;
    endfunction
  endclass

  // Deeper hierarchy
  class GermanShepherd extends Dog;
    bit is_police_dog;

    function new(string n, bit police);
      super.new(n, "German Shepherd");
      is_police_dog = police;
    endfunction

    function string work();
      if (is_police_dog)
        return $sformatf("%s is on patrol!", name);
      else
        return $sformatf("%s is playing!", name);
    endfunction
  endclass

  initial begin
    Animal a;
    Dog d;
    Cat c;
    GermanShepherd gs;
    Dog d_cast;
    Cat c_cast;
    GermanShepherd gs_cast;
    bit cast_result;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Successful downcast from Animal to Dog
    d = new("Rex", "Labrador");
    a = d;  // Implicit upcast
    cast_result = $cast(d_cast, a);
    if (cast_result && d_cast.breed == "Labrador") begin
      $display("PASS: Test 1 - Downcast Animal to Dog succeeds");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Downcast to Dog failed");
      fail_count++;
    end

    // Test 2: Failed downcast - Cat to Dog
    c = new("Whiskers");
    a = c;
    cast_result = $cast(d_cast, a);
    if (!cast_result) begin
      $display("PASS: Test 2 - Invalid cast Cat->Dog correctly fails");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Invalid cast should have failed");
      fail_count++;
    end

    // Test 3: Multi-level downcast
    gs = new("Max", 1);
    a = gs;  // Upcast to Animal
    cast_result = $cast(gs_cast, a);
    if (cast_result && gs_cast.is_police_dog && gs_cast.work() == "Max is on patrol!") begin
      $display("PASS: Test 3 - Multi-level downcast Animal->GermanShepherd");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Multi-level downcast failed");
      fail_count++;
    end

    // Test 4: Intermediate cast (Animal->Dog when actually GermanShepherd)
    a = gs;
    cast_result = $cast(d_cast, a);
    if (cast_result && d_cast.breed == "German Shepherd") begin
      $display("PASS: Test 4 - Cast to intermediate class succeeds");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Intermediate cast failed");
      fail_count++;
    end

    // Test 5: Cast and use derived class methods
    c = new("Mittens");
    a = c;
    cast_result = $cast(c_cast, a);
    if (cast_result) begin
      c_cast.lose_life();
      c_cast.lose_life();
      if (c_cast.lives == 7) begin
        $display("PASS: Test 5 - Cast allows access to derived methods");
        pass_count++;
      end else begin
        $display("FAIL: Test 5 - Derived method didn't work");
        fail_count++;
      end
    end else begin
      $display("FAIL: Test 5 - Cast to Cat failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All class cast tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
