/*
:name: test_class_virtual_param
:description: Virtual method override and a parameterized class with a type parameter
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.20 8.25
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_virtual_param.expected
*/
`timescale 1ns/1ps

class BaseClass;
    int value;

    function new(int v = 0);
        value = v;
    endfunction

    virtual function int get_value();
        return value;
    endfunction

    virtual function void set_value(int v);
        value = v;
    endfunction
endclass

class DerivedClass extends BaseClass;
    int extra;

    function new(int v = 0, int e = 0);
        super.new(v);
        extra = e;
    endfunction

    virtual function int get_value();
        return value + extra;
    endfunction
endclass

class ParameterizedClass #(type T = int);
    T data;

    function new(T d);
        data = d;
    endfunction

    function T get_data();
        return data;
    endfunction
endclass

module test_class_virtual_param;
    int fails = 0;

    initial begin
        BaseClass base;
        DerivedClass derived;
        ParameterizedClass #(int) param_int;
        ParameterizedClass #(string) param_str;

        // Base class
        base = new(10);
        if (base.get_value() != 10) begin fails++; $display("FAIL: base"); end

        // Derived class
        derived = new(10, 5);
        if (derived.get_value() != 15) begin fails++; $display("FAIL: derived"); end

        // Parameterized
        param_int = new(42);
        if (param_int.get_data() != 42) begin fails++; $display("FAIL: param int"); end

        param_str = new("test");
        if (param_str.get_data() != "test") begin fails++; $display("FAIL: param str"); end

        if (fails == 0) $display("TEST PASSED");
        else $display("FAIL: %0d checks failed", fails);
        $finish;
    end
endmodule
