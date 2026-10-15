/*
:name: test_class_abstract
:description: Abstract Classes (§8.21)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_abstract.expected
*/
// IEEE 1800-2023 Abstract Classes (§8.21)
// Tests virtual class and pure virtual methods

virtual class Shape;
    pure virtual function int get_area();
    pure virtual function string get_name();
endclass

class Rectangle extends Shape;
    int width, height;

    function new(int w, int h);
        width = w;
        height = h;
    endfunction

    virtual function int get_area();
        return width * height;
    endfunction

    virtual function string get_name();
        return "Rectangle";
    endfunction
endclass

class Circle extends Shape;
    int radius;

    function new(int r);
        radius = r;
    endfunction

    virtual function int get_area();
        // Approximate with pi = 3
        return 3 * radius * radius;
    endfunction

    virtual function string get_name();
        return "Circle";
    endfunction
endclass

module test_class_abstract;
    initial begin
        Shape shapes[2];
        Rectangle rect;
        Circle circ;
        static int pass_count = 0;
        static int fail_count = 0;

        // Create concrete instances
        rect = new(10, 5);
        circ = new(7);

        // Store in base class array
        shapes[0] = rect;
        shapes[1] = circ;

        // Test 1: Rectangle area
        if (shapes[0].get_area() == 50) begin
            $display("PASS: Rectangle area = %0d", shapes[0].get_area());
            pass_count++;
        end else begin
            $display("FAIL: Rectangle area = %0d, expected 50", shapes[0].get_area());
            fail_count++;
        end

        // Test 2: Circle area
        if (shapes[1].get_area() == 147) begin  // 3 * 7 * 7 = 147
            $display("PASS: Circle area = %0d", shapes[1].get_area());
            pass_count++;
        end else begin
            $display("FAIL: Circle area = %0d, expected 147", shapes[1].get_area());
            fail_count++;
        end

        // Test 3: Rectangle name
        if (shapes[0].get_name() == "Rectangle") begin
            $display("PASS: Rectangle name = %s", shapes[0].get_name());
            pass_count++;
        end else begin
            $display("FAIL: Rectangle name = %s, expected Rectangle", shapes[0].get_name());
            fail_count++;
        end

        // Test 4: Circle name
        if (shapes[1].get_name() == "Circle") begin
            $display("PASS: Circle name = %s", shapes[1].get_name());
            pass_count++;
        end else begin
            $display("FAIL: Circle name = %s, expected Circle", shapes[1].get_name());
            fail_count++;
        end

        // Test 5: Direct access
        if (rect.width == 10 && rect.height == 5) begin
            $display("PASS: Direct member access works");
            pass_count++;
        end else begin
            $display("FAIL: Direct member access failed");
            fail_count++;
        end

        $display("");
        $display("=== Abstract Class Test Results ===");
        $display("PASS: %0d", pass_count);
        $display("FAIL: %0d", fail_count);

        if (fail_count == 0)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end
endmodule
