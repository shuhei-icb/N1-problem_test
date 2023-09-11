# N+1問題の検証
### N+1問題とは
大量のSQLが発行されてしまい、パフォーマンスが低下してしまうこと

### テーブル構成
![ER](https://github.com/shuhei-icb/N1-problem_test/assets/82928805/0e62b0df-8b06-42bb-8b74-261331f2918c)

### 実例
1. 部署に紐づく全ての社員を表示する

**対策なし**   
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

**対策あり（eager_load）**  
eager_loadを使用すると左外部結合（LEFT OUTER JOIN）でキャッシュする
SQLの発行が一つで済む
```
SQL (3.2ms)  SELECT `employees`.`id` AS t0_r0, `employees`.`name` AS t0_r1, `employees`.`department_id` AS t0_r2, `employees`.`created_at` AS t0_r3, `employees`.`updated_at` AS t0_r4, `departments`.`id` AS t1_r0, `departments`.`name` AS t1_r1, `departments`.`created_at` AS t1_r2, `departments`.`updated_at` AS t1_r3 FROM `employees` LEFT OUTER JOIN `departments` ON `departments`.`id` = `employees`.`department_id`
```

**対策あり（preload）**  
指定したアソシエーションを別クエリで IN 句を使用してキャッシュする


