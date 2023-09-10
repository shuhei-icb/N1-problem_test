class Employee < ApplicationRecord
  belongs_to :department

  def self.cause_problem
    all_employees = self.all
    all_employees.each do | employee |
      puts "#{employee.department.name} | #{employee.name}"
    end
  end

  def self.use_preload
    all_departments = Department.preload(:employees)
    all_departments.each do | department |
      department.employees.each do | employee |
        puts "#{employee.department.name} | #{employee.name}"
      end
    end
  end

end
