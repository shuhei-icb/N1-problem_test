# N+1問題の検証
### N+1問題とは
大量のSQLが発行されてしまい、パフォーマンスが低下してしまうこと

### 実例
対策なし
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

対策あり
```
SQL (3.2ms)  SELECT `employees`.`id` AS t0_r0, `employees`.`name` AS t0_r1, `employees`.`department_id` AS t0_r2, `employees`.`created_at` AS t0_r3, `employees`.`updated_at` AS t0_r4, `departments`.`id` AS t1_r0, `departments`.`name` AS t1_r1, `departments`.`created_at` AS t1_r2, `departments`.`updated_at` AS t1_r3 FROM `employees` LEFT OUTER JOIN `departments` ON `departments`.`id` = `employees`.`department_id`
```

