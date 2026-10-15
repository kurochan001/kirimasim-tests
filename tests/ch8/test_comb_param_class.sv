/*
:name: test_comb_param_class
:description: Test: Parameterized class specialization
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_comb_param_class.expected
*/
// Test: Parameterized class specialization
// Verifies IEEE 1800-2023 §8.25 parameterized classes
module test_comb_param_class;
    int pass_count = 0;

    class Stack #(type T = int, int SIZE = 8);
        T data[$];

        function void push(T val);
            if (data.size() < SIZE)
                data.push_back(val);
        endfunction

        function T pop();
            T val;
            if (data.size() > 0)
                val = data.pop_back();
            return val;
        endfunction

        function int size();
            return data.size();
        endfunction

        function bit is_full();
            return data.size() >= SIZE;
        endfunction
    endclass

    class Pair #(type T1 = int, type T2 = int);
        T1 first;
        T2 second;

        function new(T1 f, T2 s);
            first = f;
            second = s;
        endfunction
    endclass

    initial begin
        // T1: Default parameterization (int, SIZE=8)
        begin
            static Stack #() s = new();
            s.push(10);
            s.push(20);
            s.push(30);
            if (s.size() == 3 && s.pop() == 30) begin
                $display("T1: PASS - default Stack#() works");
                pass_count++;
            end else
                $display("T1: FAIL");
        end

        // T2: Explicit int specialization
        begin
            static Stack #(int, 4) s = new();
            s.push(1); s.push(2); s.push(3); s.push(4);
            s.push(5); // should be rejected (full)
            if (s.is_full() && s.size() == 4) begin
                $display("T2: PASS - Stack#(int,4) full at 4");
                pass_count++;
            end else
                $display("T2: FAIL - size=%0d", s.size());
        end

        // T3: String specialization
        begin
            static Stack #(string, 3) s = new();
            s.push("hello");
            s.push("world");
            if (s.pop() == "world" && s.size() == 1) begin
                $display("T3: PASS - Stack#(string) works");
                pass_count++;
            end else
                $display("T3: FAIL");
        end

        // T4: Pair with int, string
        begin
            static Pair #(int, string) p = new(42, "answer");
            if (p.first == 42 && p.second == "answer") begin
                $display("T4: PASS - Pair#(int,string)");
                pass_count++;
            end else
                $display("T4: FAIL");
        end

        // T5: Pair with string, string
        begin
            static Pair #(string, string) p = new("key", "value");
            if (p.first == "key" && p.second == "value") begin
                $display("T5: PASS - Pair#(string,string)");
                pass_count++;
            end else
                $display("T5: FAIL");
        end

        // T6: Multiple Stack instances with different types
        begin
            static Stack #(int, 2) si = new();
            static Stack #(string, 2) ss = new();
            si.push(100); si.push(200);
            ss.push("a"); ss.push("b");
            if (si.is_full() && ss.is_full() &&
                si.pop() == 200 && ss.pop() == "b") begin
                $display("T6: PASS - multiple specializations coexist");
                pass_count++;
            end else
                $display("T6: FAIL");
        end

        // Summary
        $display("pass_count = %0d", pass_count);
        if (pass_count == 6)
            $display("PASS: test_comb_param_class");
        else
            $display("FAIL: test_comb_param_class (pass_count=%0d)", pass_count);
        $finish;
    end
endmodule
