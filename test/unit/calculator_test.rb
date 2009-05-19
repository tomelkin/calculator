require File.join(File.dirname(__FILE__), 'unit_test_helper')

class CalculatorTest < Test::Unit::TestCase

  FIXTURE = 'sample'

  #{{
  #  calculator
  #    equation:  (x + y) / (a * 2)
  #    terms:
  #    - term: x
  #      mql: select MAX('estimate') where 'type' = story and 'iteration' = ('current iteration')
  #    - term: y
  #      mql: select COUNT(*) where 'type' = 'iteration'
  #    - term: a
  #      mql: select 'velocity' where 'type' = 'release' and numbers in (72)
  #}}


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

  def test_cannot_use_equations_to_run_arbitary_ruby_code
    params = {:equation => 'naughty',
            :terms => [ {:term => 'naughty', :mql => "select table_value"}]}
    project = project(FIXTURE)
    project.expects(:execute_mql).with("select table_value").returns("Dir.pwd")
    Dir.expects(:pwd).never
    calculator = Calculator.new(params, project, nil)
    calculator.execute
  end
end