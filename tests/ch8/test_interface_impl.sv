/*
:name: test_interface_impl
:description: Test: Interface class implementation
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26 8.26.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_impl.expected
*/
// Test: Interface class implementation
// IEEE 1800-2023 Section 8.26 - Interface class implementation details

module test_interface_impl;

  // Interface classes for different behaviors
  interface class Drawable;
    pure virtual function void draw();
    pure virtual function string get_shape_name();
  endclass

  interface class Resizable;
    pure virtual function void resize(int factor);
    pure virtual function int get_size();
  endclass

  interface class Colorable;
    pure virtual function void set_color(string c);
    pure virtual function string get_color();
  endclass

  // Class implementing multiple interfaces
  class Circle implements Drawable, Resizable, Colorable;
    int radius;
    string color;
    int draw_count;

    function new(int r);
      radius = r;
      color = "black";
      draw_count = 0;
    endfunction

    // Drawable implementation
    virtual function void draw();
      draw_count++;
    endfunction

    virtual function string get_shape_name();
      return "Circle";
    endfunction

    // Resizable implementation
    virtual function void resize(int factor);
      radius = radius * factor;
    endfunction

    virtual function int get_size();
      return radius;
    endfunction

    // Colorable implementation
    virtual function void set_color(string c);
      color = c;
    endfunction

    virtual function string get_color();
      return color;
    endfunction
  endclass

  // Another shape implementing same interfaces
  class Square implements Drawable, Resizable, Colorable;
    int side;
    string color;

    function new(int s);
      side = s;
      color = "white";
    endfunction

    virtual function void draw();
      // Draw square
    endfunction

    virtual function string get_shape_name();
      return "Square";
    endfunction

    virtual function void resize(int factor);
      side = side * factor;
    endfunction

    virtual function int get_size();
      return side * side;  // Area
    endfunction

    virtual function void set_color(string c);
      color = c;
    endfunction

    virtual function string get_color();
      return color;
    endfunction
  endclass

  // Class extending another while implementing interface
  class Base;
    int id;

    function new(int i);
      id = i;
    endfunction

    virtual function int get_id();
      return id;
    endfunction
  endclass

  class Derived extends Base implements Drawable;
    function new(int i);
      super.new(i);
    endfunction

    virtual function void draw();
      // Draw derived
    endfunction

    virtual function string get_shape_name();
      return $sformatf("Derived_%0d", id);
    endfunction
  endclass

  // Test polymorphism with interface references
  function void draw_all(Drawable shapes[$]);
    foreach (shapes[i])
      shapes[i].draw();
  endfunction

  function string list_names(Drawable shapes[$]);
    static string result = "";
    foreach (shapes[i]) begin
      if (i > 0) result = {result, ", "};
      result = {result, shapes[i].get_shape_name()};
    end
    return result;
  endfunction

  initial begin
    Circle c;
    Square s;
    Derived d;
    Drawable draw_ref;
    Resizable resize_ref;
    Colorable color_ref;
    Drawable shapes[$];
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Multiple interface implementation
    c = new(10);
    draw_ref = c;
    resize_ref = c;
    color_ref = c;

    draw_ref.draw();
    resize_ref.resize(2);
    color_ref.set_color("red");

    if (c.draw_count == 1 && c.radius == 20 && c.color == "red") begin
      $display("PASS: Test 1 - Multiple interface access to same object");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Multiple interface access failed");
      fail_count++;
    end

    // Test 2: Different classes through same interface
    s = new(5);
    resize_ref = c;
    if (resize_ref.get_size() == 20) begin
      resize_ref = s;
      if (resize_ref.get_size() == 25) begin  // 5*5 area
        $display("PASS: Test 2 - Different classes through same interface");
        pass_count++;
      end else begin
        $display("FAIL: Test 2 - Square size wrong");
        fail_count++;
      end
    end else begin
      $display("FAIL: Test 2 - Circle size wrong");
      fail_count++;
    end

    // Test 3: Class extending base and implementing interface
    d = new(42);
    draw_ref = d;
    if (draw_ref.get_shape_name() == "Derived_42" && d.get_id() == 42) begin
      $display("PASS: Test 3 - Class extends and implements");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Extends and implements failed");
      fail_count++;
    end

    // Test 4: Polymorphic collection of interface type
    c = new(10);
    s = new(5);
    d = new(1);
    shapes.push_back(c);
    shapes.push_back(s);
    shapes.push_back(d);

    if (list_names(shapes) == "Circle, Square, Derived_1") begin
      $display("PASS: Test 4 - Polymorphic interface collection");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Collection failed: %s", list_names(shapes));
      fail_count++;
    end

    // Test 5: Interface method modifies through reference
    c = new(10);
    color_ref = c;
    color_ref.set_color("blue");
    if (c.get_color() == "blue") begin
      $display("PASS: Test 5 - Interface reference modifies original");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Interface modification failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All interface implementation tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
