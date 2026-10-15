/*
:name: test_class_factory
:description: Test: Factory pattern
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.10 8.21 8.20
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_factory.expected
*/
// Test: Factory pattern
// IEEE 1800-2023 - Factory design pattern implementation

module test_class_factory;

  // Product interface
  virtual class Product;
    pure virtual function string get_name();
    pure virtual function int get_cost();
  endclass

  // Concrete products
  class ProductA extends Product;
    virtual function string get_name();
      return "Product A";
    endfunction

    virtual function int get_cost();
      return 100;
    endfunction
  endclass

  class ProductB extends Product;
    virtual function string get_name();
      return "Product B";
    endfunction

    virtual function int get_cost();
      return 200;
    endfunction
  endclass

  class ProductC extends Product;
    virtual function string get_name();
      return "Product C";
    endfunction

    virtual function int get_cost();
      return 300;
    endfunction
  endclass

  // Simple Factory
  class ProductFactory;
    static int products_created = 0;

    static function Product create(string product_type);
      Product p;
      case (product_type)
        "A": begin
          ProductA pa = new();
          p = pa;
        end
        "B": begin
          ProductB pb = new();
          p = pb;
        end
        "C": begin
          ProductC pc = new();
          p = pc;
        end
        default: p = null;
      endcase
      if (p != null)
        products_created++;
      return p;
    endfunction

    static function int get_count();
      return products_created;
    endfunction
  endclass

  class Shape;
    string shape_type;
    int size;

    function new(string t, int s);
      shape_type = t;
      size = s;
    endfunction

    virtual function string describe();
      return $sformatf("%s (size=%0d)", shape_type, size);
    endfunction
  endclass

  class Circle extends Shape;
    function new(int radius);
      super.new("Circle", radius);
    endfunction

    virtual function string describe();
      return $sformatf("Circle with radius %0d", size);
    endfunction
  endclass

  class Square extends Shape;
    function new(int side);
      super.new("Square", side);
    endfunction

    virtual function string describe();
      return $sformatf("Square with side %0d", size);
    endfunction
  endclass

  // Abstract Factory
  virtual class AbstractFactory;
    pure virtual function Product create_product();
  endclass

  class FactoryA extends AbstractFactory;
    virtual function Product create_product();
      ProductA p = new();
      return p;
    endfunction
  endclass

  class FactoryB extends AbstractFactory;
    virtual function Product create_product();
      ProductB p = new();
      return p;
    endfunction
  endclass

  initial begin
    Product p1, p2, p3;
    Shape s1, s2;
    AbstractFactory af;
    FactoryA fa;
    FactoryB fb;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Simple factory creates Product A
    p1 = ProductFactory::create("A");
    if (p1 != null && p1.get_name() == "Product A" && p1.get_cost() == 100) begin
      $display("PASS: Test 1 - Factory creates Product A");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - Product A creation failed");
      fail_count++;
    end

    // Test 2: Factory creates different products
    p2 = ProductFactory::create("B");
    p3 = ProductFactory::create("C");
    if (p2.get_name() == "Product B" && p3.get_name() == "Product C") begin
      $display("PASS: Test 2 - Factory creates different product types");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - Different products failed");
      fail_count++;
    end

    // Test 3: Factory tracks creation count
    if (ProductFactory::get_count() == 3) begin
      $display("PASS: Test 3 - Factory tracks creation count");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - Count wrong: %0d", ProductFactory::get_count());
      fail_count++;
    end

    // Test 4: Factory returns null for unknown type
    p1 = ProductFactory::create("X");
    if (p1 == null) begin
      $display("PASS: Test 4 - Factory returns null for unknown type");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Should return null for unknown type");
      fail_count++;
    end

    // Test 5: Abstract Factory pattern
    fa = new();
    fb = new();
    af = fa;
    p1 = af.create_product();
    af = fb;
    p2 = af.create_product();
    if (p1.get_name() == "Product A" && p2.get_name() == "Product B") begin
      $display("PASS: Test 5 - Abstract Factory creates correct products");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Abstract Factory failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All factory pattern tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
