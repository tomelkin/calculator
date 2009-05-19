require File.join(File.dirname(__FILE__), 'unit_test_helper')

class CalculatorTest < Test::Unit::TestCase

  FIXTURE = 'sample'

  def test_macro_contents
    params = {:equation => '1 + 1',
            :terms => []}
    calculator = Calculator.new(params, project(FIXTURE), nil)
    result = calculator.execute
    assert result
  end

  def test_add_mql_results
    params = {:equation => 'a + b',
            :terms => [ {:term => 'a', :mql => "select 2"},
                    {:term => 'b', :mql => "select 3"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select 2").returns(2)
    project.expects(:execute_mql).with("select 3").returns(3)
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 5

  end

  def test_add_mql_results
    params = {:equation => 'a / (b - c)',
            :terms => [ {:term => 'a', :mql => "select 99"},
                    {:term => 'b', :mql => "select 17"},
                    {:term => 'c', :mql => "select 6"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select 99").returns(99)
    project.expects(:execute_mql).with("select 17").returns(17)
    project.expects(:execute_mql).with("select 6").returns(6)
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 9
  end

  def test_adds_numbers
    params = {:equation => '1 + 2',
            :terms => []}
    calculator = Calculator.new(params, project(FIXTURE), nil)
    result = calculator.execute
    assert result == 3
  end

  def test_copes_with_terms_containing_numbers
    params = {:equation => 'a1 * a2',
            :terms => [ {:term => 'a1', :mql => "select 2"},
                        {:term => 'a2', :mql => "select 3"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select 2").returns(2)
    project.expects(:execute_mql).with("select 3").returns(3)
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 6
  end

  def test_calculates_with_similar_variable_names
    params = {:equation => 'art + dart + artistic',
            :terms => [ {:term => 'art', :mql => "select 2"},
                    {:term => 'dart', :mql => "select 3"},
                    {:term => 'artistic', :mql => "select 4"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select 2").returns(2)
    project.expects(:execute_mql).with("select 3").returns(3)
    project.expects(:execute_mql).with("select 4").returns(4)
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 9
  end

  def test_works_with_brackets
    params = {:equation => '(art + dart) * dart',
            :terms => [ {:term => 'art', :mql => "select 2"},
                    {:term => 'dart', :mql => "select 3"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select 2").returns(2)
    project.expects(:execute_mql).with("select 3").returns(3)
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 15
  end

  def test_throws_exception_if_equation_contains_non_numeric_expressions
    params = {:equation => 'naughty',
            :terms => [ {:term => 'naughty', :mql => "select table_value"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select table_value").returns("Dir.pwd")

    Dir.expects(:pwd).never

    exception = assert_raise(RuntimeError) do
      calculator = Calculator.new(params, project, nil)
      calculator.execute
    end
    assert_equal("Equation to run contains non-numeric values: 'Dir.pwd'", exception.message)
  end
end