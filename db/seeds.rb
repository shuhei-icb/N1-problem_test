# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Department.create(name: "人事部")
Department.create(name: "経理部")
Department.create(name: "総務部")
Department.create(name: "法務部")
Department.create(name: "情報システム部")
Department.create(name: "技術部")
Department.create(name: "営業部")
Department.create(name: "マーケティング部")

100.times do
  sample_name = Gimei.kanji

  Employee.create(
    name: sample_name,
    department_id: rand(1..8)
  )
end