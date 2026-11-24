/*
:name: test_weak_reference_clear_has_void_function_signature_in_nested_scope
:description: Weak clear is callable without arguments from an automatic function and leaves a strong alias valid
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.4 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stderr_regex: \A(?![\s\S]*(?i:\bwarn(?:ing)?\b))[\s\S]*\Z
:expected_stdout: @test_weak_reference_clear_has_void_function_signature_in_nested_scope.expected
*/
module test_weak_reference_clear_has_void_function_signature_in_nested_scope;
  class token;
    int value = 67;
  endclass
  typedef std::weak_reference #(token) token_reference;

  function automatic bit clear_reference(ref token_reference reference_handle);
    reference_handle.clear();
    return reference_handle.get() == null;
  endfunction

  initial begin
    token object;
    token_reference first, alias_handle, second;
    bit cleared;
    object = new;
    first = new(object);
    alias_handle = first;
    second = new(object);
    cleared = clear_reference(alias_handle);
    $display("cleared=%0d shared=%0d independent=%0d value=%0d",
             cleared, first.get() == null, second.get() == object, object.value);
  end
endmodule
