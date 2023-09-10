class Department < ApplicationRecord
  has_many :employees

  def self.cause_problem
    all_departments = self.all
    all_departments.each do | department |
      department.employees.each do | employee |
        puts employee.name
      end
    end
  end

  def self.use_eager_load
    all_employees = Employee.eager_load(:department)
    all_employees.each do | employee |
      puts employee.name
    end
  end

end
