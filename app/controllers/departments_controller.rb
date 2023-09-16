class DepartmentsController < ApplicationController
  def index
    @all_departments = Department.all
  end
end
