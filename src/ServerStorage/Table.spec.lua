--!nocheck
return function()
	local Table = require(script.Parent.Table)

	describe("count without predicate", function()
		local testList = { "1", "1", "2", "2", "6", "2", "3" }
		local result = Table.Count(testList)

		it("should return 7", function()
			expect(result).to.equal(7)
		end)
	end)

	describe("count with predicate", function()
		local testList = { "1", "1", "2", "2", "6", "2", "3" }
		local result = Table.Count(testList, function(item)
			return item == "2"
		end)

		it("should return 3", function()
			expect(result).to.equal(3)
		end)
	end)

	describe("filter by where", function()
		local testList = { "1", "2", "3" }
		local result = Table.Where(testList, function(item)
			return item == "2"
		end)

		it("should return a table", function()
			expect(type(result)).to.equal("table")
		end)

		it("should contain the filtered item", function()
			expect(type(result)).to.equal("table")
			expect(result[1]).to.equal("2")
		end)

		it("should be of length 1", function()
			expect(#result).to.equal(1)
		end)
	end)

	describe("filter by distinct", function()
		local testList = { "1", "2", "1", "3", "5", "2" }
		local result = Table.Distinct(testList)

		it("should return a table", function()
			expect(type(result)).to.equal("table")
		end)

		it("should have item 1 be '1'", function()
			expect(result[1]).to.equal("1")
		end)

		it("should have item 2 be '2'", function()
			expect(result[2]).to.equal("2")
		end)

		it("should have item 3 be '3'", function()
			expect(result[3]).to.equal("3")
		end)

		it("should have item 4 be '5'", function()
			expect(result[4]).to.equal("5")
		end)

		it("should be of length 4", function()
			expect(#result).to.equal(4)
		end)
	end)

	describe("filter by distinct with selector", function()
		local classList = { }
		table.insert(classList, { Teacher = "Teacher 1", Grade = 1})
		table.insert(classList, { Teacher = "Teacher 2", Grade = 3})
		table.insert(classList, { Teacher = "Teacher 2", Grade = 4})
		table.insert(classList, { Teacher = "Teacher 2", Grade = 3})
		table.insert(classList, { Teacher = "Teacher 1", Grade = 2})
		table.insert(classList, { Teacher = "Teacher 2", Grade = 5})
		table.insert(classList, { Teacher = "Teacher 1", Grade = 2})
		table.insert(classList, { Teacher = "Teacher 3", Grade = 9})
		local result = Table.Distinct(classList, function(class)
			return class.Teacher
		end)

		it("should have item 1 be 'Teacher 1'", function()
			expect(result[1].Teacher).to.equal("Teacher 1")
		end)

		it("should have item 2 be '2'", function()
			expect(result[2].Teacher).to.equal("Teacher 2")
		end)

		it("should have item 3 be '3'", function()
			expect(result[3].Teacher).to.equal("Teacher 3")
		end)

		it("should be of length 3", function()
			expect(#result).to.equal(3)
		end)
	end)
end