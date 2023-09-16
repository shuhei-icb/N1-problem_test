class EmployeeController < ApplicationController
  def index
    @all_departments = Department.preload(:employees)
  end
end
