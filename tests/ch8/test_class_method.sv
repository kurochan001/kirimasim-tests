/*
:name: test_class_method
:description: Class methods that read and change a property, with a default constructor argument
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.6 8.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_method.expected
*/
// IEEE 1800-2023 Section 8: Classes
module test_class_method;
    class Counter;
        int value;

        function new(int init = 0);
            value = init;
        endfunction

        function int get();
            return value;
        endfunction

        function void increment();
            value++;
        endfunction

        function void add(int n);
            value += n;
        endfunction
    endclass

    Counter c;
    int result;

    initial begin
        // Constructor with default
        c = new();
        if (c.get() == 0)
            $display("PASS: new() default = 0");
        else
            $display("FAIL: default = %0d", c.get());

        // Constructor with argument
        c = new(10);
        if (c.get() == 10)
            $display("PASS: new(10) = 10");
        else
            $display("FAIL: new(10) = %0d", c.get());

        // Method call
        c.increment();
        if (c.get() == 11)
            $display("PASS: increment()");
        else
            $display("FAIL: increment = %0d", c.get());

        // Method with argument
        c.add(5);
        if (c.get() == 16)
            $display("PASS: add(5)");
        else
            $display("FAIL: add = %0d", c.get());

        $display("TEST PASSED: class method tests completed");
        $finish;
    end
endmodule
