# N+1問題の検証
## N+1問題とは
大量のSQLが発行されてしまい、パフォーマンスが低下してしまうこと

## テーブル構成  
Department(部署)テーブル(8レコード)  
Employee(社員)テーブル(100レコード)  
![ER](https://github.com/shuhei-icb/N1-problem_test/assets/82928805/0e62b0df-8b06-42bb-8b74-261331f2918c)

## 実例1
**Departmentテーブルから全てのレコードを取得後、department_idに紐づくEmployeeテーブルのレコードを取得する**

### 対策なし  
models/department.rb
```
  def self.cause_problem
    all_departments = self.all
    all_departments.each do | department |
      department.employees.each do | employee |
        puts "#{employee.department.name} | #{employee.name}"
      end
    end
  end
```
部署の数だけSQLが発行されてしまう
```
Department Load (28.6ms)  SELECT `departments`.* FROM `departments`
Employee Load (2.6ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 1
Employee Load (0.8ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 2
Employee Load (0.6ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 3
Employee Load (0.9ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 4
Employee Load (0.7ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 5
Employee Load (0.8ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 6
Employee Load (0.6ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 7
Employee Load (0.9ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` = 8
```

### 対策あり（eager_load）  
models/department.rb
```
  def self.use_eager_load
    all_employees = Employee.eager_load(:department)
    all_employees.each do | employee |
      puts "#{employee.department.name} | #{employee.name}"
    end
  end
```
eager_loadを使用すると左外部結合（LEFT OUTER JOIN）でキャッシュするのでSQLの発行が一つで済む  
belongs_toの関連を持つ親データ（Department）の事前読み込みを行う場合はeager_loadを使用する
```
SQL (3.2ms)  SELECT `employees`.`id` AS t0_r0, `employees`.`name` AS t0_r1, `employees`.`department_id` AS t0_r2, `employees`.`created_at` AS t0_r3, `employees`.`updated_at` AS t0_r4, `departments`.`id` AS t1_r0, `departments`.`name` AS t1_r1, `departments`.`created_at` AS t1_r2, `departments`.`updated_at` AS t1_r3 FROM `employees` LEFT OUTER JOIN `departments` ON `departments`.`id` = `employees`.`department_id`
```
## 実例2  
**Employeeテーブルから全てのレコードを取得後、department_idに紐づくDepartmentテーブルのレコードを取得する**
### 対策なし  
models/employee.rb  
```
  def self.cause_problem
    all_departments = self.all
    all_departments.each do | department |
      department.employees.each do | employee |
        puts "#{employee.department.name} | #{employee.name}"
      end
    end
  end
```
社員の数だけSQLが発行されてしまう  
```
Employee Load (2.9ms)  SELECT `employees`.* FROM `employees`
Department Load (1.3ms)  SELECT `departments`.* FROM `departments` WHERE `departments`.`id` = 2 LIMIT 1
Department Load (0.6ms)  SELECT `departments`.* FROM `departments` WHERE `departments`.`id` = 1 LIMIT 1
Department Load (0.5ms)  SELECT `departments`.* FROM `departments` WHERE `departments`.`id` = 1 LIMIT 1
‥‥
```

### 対策あり（preload） 
models/employee.rb  
```
  def self.use_preload
    all_departments = Department.preload(:employees)
    all_departments.each do | department |
      department.employees.each do | employee |
        puts "#{employee.department.name} | #{employee.name}"
      end
    end
  end
```
指定したアソシエーションを別クエリで IN 句を使用してキャッシュする  
has_manyの関連を持つ子データ（employee）の事前読み込みを行う場合にpreloadを使用する(eager_loadを使用するとレコードが増えることがある)
```
Department Load (34.7ms)  SELECT `departments`.* FROM `departments`
Employee Load (3.5ms)  SELECT `employees`.* FROM `employees` WHERE `employees`.`department_id` IN (1, 2, 3, 4, 5, 6, 7, 8)
```

## 検証方法
1. railsコンソールから下記クラスメソッドを呼び出す
2. 発行されたSQLを比べる

* 実例1の対策なし -> Department.cause_problem
* 実例1の対策あり -> Department.use_eager_load
* 実例2の対策なし -> Employee.cause_problem
* 実例2の対策あり -> Employee.use_preload

# bulletでアラート表示  
gem「bullet」を使用すると、N＋1問題を検知時にアラート表示する  

## 検証方法  
1.下記URLにアクセスして、アラートが表示されることを確認する  
http://localhost:3000/departments/index  
2. 下記URLにアクセスして、アラートが表示されないことを確認する  
http://localhost:3000/employee/index  


### ブラウザにアラートを表示する  
config/environments/development.rb
```
Bullet.alert = true
```
<img width="440" alt="スクリーンショット 2023-09-16 20 26 54" src="https://github.com/shuhei-icb/N1-problem_test/assets/82928805/1349777c-effd-4d05-96b1-b379e5ae3d61">  

### console.logにアラートを表示する
config/environments/development.rb
```
Bullet.console = true
```
<img width="821" alt="スクリーンショット 2023-09-16 20 32 32" src="https://github.com/shuhei-icb/N1-problem_test/assets/82928805/ea3685d6-b8d3-43fe-a14c-588aa62da809">  

### ターミナルのログにアラート表示する
config/environments/development.rb
```
Bullet.rails_logger = true
```

```
user: root
2023-09-16 20:26:34 GET /departments/index
2023-09-16 20:26:34 USE eager loading detected
2023-09-16 20:26:34   Department => [:employees]
2023-09-16 20:26:34   Add to your query: .includes([:employees])
2023-09-16 20:26:34 Call stack
2023-09-16 20:26:34   /app/app/views/departments/index.html.erb:8:in `block in _app_views_departments_index_html_erb___1559360149445397035_21460'
2023-09-16 20:26:34   /app/app/views/departments/index.html.erb:7:in `_app_views_departments_index_html_erb___1559360149445397035_21460'
```


