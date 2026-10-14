/*
:name: test_class_basics
:description: Chapter 8: Classes
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.3 8.4 8.12
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_basics.expected
*/
// IEEE 1800-2023 Chapter 8: Classes
// §8.3 Syntax and §8.4 Objects

module test_class_basics;
    // §8.3 Class declaration
    class Packet;
        int id;
        bit [7:0] data;

        function new(int i, bit [7:0] d);
            id = i;
            data = d;
        endfunction

        function int getId();
            return id;
        endfunction

        function void setData(bit [7:0] d);
            data = d;
        endfunction
    endclass

    Packet p1, p2;

    int test_count;
    int pass_count;

    initial begin
        test_count = 0;
        pass_count = 0;

        // Test 1: Object creation
        p1 = new(1, 8'hAA);
        test_count++;
        if (p1 != null) pass_count++;
        else $display("FAIL: Object creation failed");

        // Test 2: Member access
        test_count++;
        if (p1.id == 1 && p1.data == 8'hAA) pass_count++;
        else $display("FAIL: Member access - id=%0d, data=0x%0h", p1.id, p1.data);

        // Test 3: Method call
        test_count++;
        if (p1.getId() == 1) pass_count++;
        else $display("FAIL: Method call - getId()=%0d", p1.getId());

        // Test 4: Method with side effect
        p1.setData(8'hBB);
        test_count++;
        if (p1.data == 8'hBB) pass_count++;
        else $display("FAIL: setData - data=0x%0h", p1.data);

        // Test 5: Multiple objects
        p2 = new(2, 8'hCC);
        test_count++;
        if (p1.id != p2.id && p1.data != p2.data) pass_count++;
        else $display("FAIL: Multiple objects - p1.id=%0d, p2.id=%0d", p1.id, p2.id);

        // Test 6: Object assignment (reference)
        p2 = p1;
        p1.id = 99;
        test_count++;
        if (p2.id == 99) pass_count++;  // Should see change through reference
        else $display("FAIL: Reference - p2.id=%0d (expected 99)", p2.id);

        $display("Chapter 8.3-4 Class Basics: %0d/%0d tests passed", pass_count, test_count);
        if (pass_count == test_count) begin
            $display("PASS");
        end else begin
            $display("FAIL");
        end
        $finish;
    end
endmodule
