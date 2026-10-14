/*
:name: test_edge_class_null_handle
:description: Class handles and null
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.8
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_edge_class_null_handle.expected
*/
// IEEE 1800-2023 Section 8.4: Class handles and null
// Tests that uninitialized class handles are properly detected as null

class MyClass;
    int value = 42;
endclass

module test;
    initial begin
        MyClass obj;  // Uninitialized - should be null

        // IEEE 1800-2023: Uninitialized class handles shall be null
        if (obj == null) begin
            $display("PASS: Uninitialized class handle is null");
        end else begin
            $display("FAIL: Uninitialized class handle should be null");
        end

        // Now initialize and verify it's not null
        obj = new();
        if (obj != null) begin
            $display("PASS: Initialized class handle is not null");
        end else begin
            $display("FAIL: Initialized class handle should not be null");
        end

        // Verify member access works
        if (obj.value == 42) begin
            $display("PASS: Class member has correct initial value");
        end else begin
            $display("FAIL: Expected value=42, got %0d", obj.value);
        end

        $finish;
    end
endmodule
