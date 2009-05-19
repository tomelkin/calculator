class Calculator

  def initialize(parameters, project, current_user)
    @parameters = parameters
    @project = project
    @current_user = current_user
  end

  def execute
    equation = @parameters[:equation]
    @parameters[:terms].each do |term|
      mql_result = @project.execute_mql(term[:mql])
      pattern = Regexp.new('\b' + term[:term] + '\b')
      equation.gsub!(pattern, mql_result.to_s)
    end

    if (is_expression_numeric?(equation))
      eval(equation)
    end
  end


  def can_be_cached?
    false  # if appropriate, switch to true once you move your macro to production
  end

  private

  def is_expression_numeric?(expression)
    expression.match(/^[\s\+\*\-\/0123456789\.\(\)]*$/) != nil
  end

end