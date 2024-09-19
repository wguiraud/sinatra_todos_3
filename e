
[1mFrom:[0m /home/launchschool/Documents/LS/LS175_2/6_project_todos/todo.rb:37 self.POST /lists:

    [1;34m32[0m: 
    [1;34m33[0m: post [31m[1;31m"[0m[31m/lists[1;31m"[0m[31m[0m [32mdo[0m
    [1;34m34[0m:   list_name = params[[33m:list_name[0m].strip
    [1;34m35[0m:   [32mif[0m valid_list_name?(list_name)
    [1;34m36[0m:     session[[33m:lists[0m] << { [35mname[0m: list_name, [35mtodos[0m: [] }
 => [1;34m37[0m:     binding.pry
    [1;34m38[0m:     session[[33m:success[0m] = [31m[1;31m"[0m[31m#{list_name}[0m[31m was successfully created[1;31m"[0m[31m[0m
    [1;34m39[0m:     redirect [31m[1;31m"[0m[31m/lists[1;31m"[0m[31m[0m
    [1;34m40[0m:   [32melse[0m
    [1;34m41[0m:     session[[33m:error[0m] = [31m[1;31m"[0m[31mPlease enter a valid input. The input must be between 1 and 100 characters long and contain only alphanumeric and common punctuation characters.[1;31m"[0m[31m[0m
    [1;34m42[0m:     erb [33m:new_list[0m

