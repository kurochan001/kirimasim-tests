/*
:name: test_enum_methods
:description: Test for enum extension methods
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.5
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_methods.expected
*/
// Test for enum extension methods
module test_enum_methods;
    typedef enum {RED, GREEN, BLUE, YELLOW} color_t;
    color_t color;

    initial begin
        // Test first()
        color = color.first();
        if (color != RED) $display("first() failed: expected RED, got %s", color.name());
        else $display("PASS: first() = %s", color.name());

        // Test last()
        color = color.last();
        if (color != YELLOW) $display("last() failed: expected YELLOW, got %s", color.name());
        else $display("PASS: last() = %s", color.name());

        // Test next()
        color = GREEN;
        color = color.next();
        if (color != BLUE) $display("next() failed: expected BLUE, got %s", color.name());
        else $display("PASS: next(GREEN) = %s", color.name());

        // Test prev()
        color = BLUE;
        color = color.prev();
        if (color != GREEN) $display("prev() failed: expected GREEN, got %s", color.name());
        else $display("PASS: prev(BLUE) = %s", color.name());

        // Test next() at boundary
        color = YELLOW;
        color = color.next();
        if (color != RED) $display("next(YELLOW) failed: expected RED, got %s", color.name());
        else $display("PASS: next(YELLOW) wraps to %s", color.name());

        // Test prev() at boundary
        color = RED;
        color = color.prev();
        if (color != YELLOW) $display("prev(RED) failed: expected YELLOW, got %s", color.name());
        else $display("PASS: prev(RED) wraps to %s", color.name());

        $display("All enum method tests passed!");
        $finish;
    end
endmodule
