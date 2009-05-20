class Calculator

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
  end

  def execute
    equation = generate_equation

    if (is_expression_numeric?(equation))
      eval(equation)
    else
      raise RuntimeError.new("Equation to run contains non-numeric values: '#{equation}'")
    end
  end

  def can_be_cached?
    false  # if appropriate, switch to true once you move your macro to production
  end

  private

  def generate_equation
    equation = @parameters['equation']
    @parameters['terms'].each do |term|
      substitute_term_for_mql_result equation, term
    end
    equation
  end

  def substitute_term_for_mql_result(equation, term)
    mql_result = get_singular_mql_result term['mql']
    pattern = Regexp.new('\b' + term['term'] + '\b')
    equation.gsub!(pattern, mql_result)
  end

  def get_singular_mql_result(mql)
    mql_result = @project.execute_mql(mql)

    if (mql_result.length > 1)
      raise RuntimeError.new("Equation term evaluated to give more than one result, should just evaluate to a number: '#{mql}'")
    end
     mql_result.first.values.first
  end

  def is_expression_numeric?(expression)
    expression.match(/^[\s\+\*\-\/%0123456789\.\(\)]*$/) != nil
  end

end