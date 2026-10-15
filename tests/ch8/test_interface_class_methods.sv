/*
:name: test_interface_class_methods
:description: Interface class method implementation test
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.26
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_interface_class_methods.expected
*/
// IEEE 1800-2023 §8.26: Interface class method implementation test
// Tests pure virtual methods in interface classes

module test_interface_class_methods;
    int pass_count = 0;
    int test_count = 0;

    // Interface class with pure virtual methods
    interface class Printable;
        pure virtual function string to_string();
        pure virtual function int get_id();
    endclass

    // Interface class for comparable objects
    interface class Comparable;
        pure virtual function bit compare(Comparable other);
        pure virtual function int get_value();
    endclass

    // Class implementing single interface
    class Document implements Printable;
        string title;
        int doc_id;

        function new(string t, int id);
            title = t;
            doc_id = id;
        endfunction

        virtual function string to_string();
            return $sformatf("Document[%0d]: %s", doc_id, title);
        endfunction

        virtual function int get_id();
            return doc_id;
        endfunction
    endclass

    // Class implementing multiple interfaces
    class NumberItem implements Printable, Comparable;
        int value;
        int item_id;

        function new(int v, int id);
            value = v;
            item_id = id;
        endfunction

        virtual function string to_string();
            return $sformatf("NumberItem[%0d]: value=%0d", item_id, value);
        endfunction

        virtual function int get_id();
            return item_id;
        endfunction

        virtual function bit compare(Comparable other);
            return value == other.get_value();
        endfunction

        virtual function int get_value();
            return value;
        endfunction
    endclass

    initial begin
        Document doc;
        NumberItem item1, item2;
        Printable p;
        Comparable c;

        // Test 1: Single interface implementation
        test_count++;
        doc = new("Test Document", 1);
        if (doc.to_string() == "Document[1]: Test Document" && doc.get_id() == 1) begin
            pass_count++;
            $display("Test 1 PASS: single interface implementation");
        end else begin
            $display("Test 1 FAIL: %s, id=%0d", doc.to_string(), doc.get_id());
        end

        // Test 2: Multiple interface implementation
        test_count++;
        item1 = new(42, 10);
        if (item1.to_string() == "NumberItem[10]: value=42" &&
            item1.get_id() == 10 &&
            item1.get_value() == 42) begin
            pass_count++;
            $display("Test 2 PASS: multiple interface implementation");
        end else begin
            $display("Test 2 FAIL: unexpected values");
        end

        // Test 3: Interface type polymorphism
        test_count++;
        p = doc;
        if (p.to_string() == "Document[1]: Test Document") begin
            pass_count++;
            $display("Test 3 PASS: interface polymorphism (Printable)");
        end else begin
            $display("Test 3 FAIL: interface polymorphism failed");
        end

        // Test 4: Compare method via interface
        test_count++;
        item2 = new(42, 20);
        c = item1;
        if (c.compare(item2)) begin
            pass_count++;
            $display("Test 4 PASS: compare via Comparable interface");
        end else begin
            $display("Test 4 FAIL: compare failed");
        end

        // Test 5: Different values comparison
        test_count++;
        item2 = new(100, 30);
        if (!c.compare(item2)) begin
            pass_count++;
            $display("Test 5 PASS: different values compare false");
        end else begin
            $display("Test 5 FAIL: different values should not match");
        end

        $display("=== Interface Class Methods Test Results ===");
        $display("Passed: %0d/%0d", pass_count, test_count);

        if (pass_count == test_count) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end

        $finish;
    end

endmodule
