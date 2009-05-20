require File.join(File.dirname(__FILE__), 'unit_test_helper')

class CalculatorTest < Test::Unit::TestCase

  FIXTURE = 'sample'

  def test_add
    verify_count_calculator('a + b', {'a' => 96, 'b' => 6}, 102)
  end

  def test_subtract
    verify_count_calculator('a - b', {'a' => 96, 'b' => 6}, 90)
  end

  def test_divide
    verify_count_calculator('a / b', {'a' => 96, 'b' => 6}, 16)
  end

  def test_multiply
    verify_count_calculator('a * b', {'a' => 96, 'b' => 6}, 576)
  end

  def test_modulus
    verify_count_calculator('a % b', {'a' => 17, 'b' => 5}, 2)
  end

  def test_adds_numbers
    verify_count_calculator('20 + 5', {}, 25)
  end

  def test_copes_with_terms_containing_numbers
    verify_count_calculator('a1 * a2', {'a1' => 2, 'a2' => 3}, 6)
  end

  def test_calculates_with_similar_variable_names
    verify_count_calculator('art + dart + artistic', {'art' => 2, 'dart' => 3, 'artistic' => 4}, 9)
  end

  def test_works_with_brackets
    verify_count_calculator('(art + dart) * dart', {'art' => 2, 'dart' => 3}, 15)
  end

  def test_throws_exception_if_mql_returns_more_than_one_result
    query = "select 'planning estimate' where type='story'"
    params = {'equation' => 'a',
            'terms' => [ {'term' => 'a', 'mql' => query}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with(query).returns([{'Planning Estimate' => '2'}, {'Planning Estimate' => '3'}])
    calculator = Calculator.new(params, project, nil)
    exception = assert_raise(RuntimeError) do
      calculator.execute
    end
    assert_equal("Equation term evaluated to give more than one result, should just evaluate to a number: '#{query}'", exception.message)
  end

  def test_gets_first_returned_value_for_mql_queries
    query = "Select SUM('planning estimate') where type = 'story'"
    params = {'equation' => 'x * 2',
            'terms' => [ {'term' => 'x', 'mql' => query}]
    }
    project = project(FIXTURE)
    project.expects(:execute_mql).with(query).returns([{'Sum Planning Estimate' => '76.0000000000'}])
    calculator = Calculator.new(params, project, nil)
    result = calculator.execute
    assert result == 152
  end

  def test_throws_exception_if_equation_contains_non_numeric_expressions
    params = {'equation' => 'naughty',
            'terms' => [ {'term' => 'naughty', 'mql' => "Select 'name' where number = 123"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("Select 'name' where number = 123").returns([{"name" => "Dir.pwd"}])

    Dir.expects(:pwd).never

    exception = assert_raise(RuntimeError) do
      calculator = Calculator.new(params, project, nil)
      calculator.execute
    end
    assert_equal("Equation to run contains non-numeric values: 'Dir.pwd'", exception.message)
  end

  private

  def verify_count_calculator(equation, terms, expected_result)
    project = project(FIXTURE)
    params = {'equation' => equation, 'terms' => []}
    terms.each do |term, value|
      mql_statement = "select count(*) where name = '#{term}'"
      project.expects(:execute_mql).with(mql_statement).returns([{'Count ' => "#{value}"}])
      params['terms'] << {'term' => term, 'mql' => mql_statement}
    end

    calculator = Calculator.new(params, project, nil)
    assert calculator.execute == expected_result
  end
end