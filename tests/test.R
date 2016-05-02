mypkg <- tempfile()
dir.create(mypkg)
test <- data_package(mypkg)
test$name("My test")
test$license("Public domain")
test$homepage("www.jeroen.nl")
test$description("This is a test package")
test$resources$find()

test$resources$add(iris)
test$json()

test$resources$find()
test$resources$info("iris")
test$resources$find(folder = "data")
test$resources$find(folder = "nothing")
test$resources$find("iris")
test$resources$find("bla")

test$resources$add(cars)
test$resources$add(mtcars)
test$resources$remove("iris")
test$json()


test$contributors$find()
test$contributors$add("Jeroen", "jeroenooms@gmail.com", "www.jeroen.nl")
test$contributors$add("Karthik")
test$contributors$remove("Karthik")

test$sources$find()
test$sources$add("NASA", web = "www.nasa.gov")
test$sources$add("blabla", "bla@blabla.com")
test$sources$find("bla")
test$sources$find("bla", exact = TRUE)
test$sources$remove("blabla")

test$json()
list.files(mypkg, recursive = T)
