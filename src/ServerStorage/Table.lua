local Table = {}

function Table.Count(source: table, predicate: (any) -> boolean): number
	local count = 0
	if not source then
		return 0
	end

	for _, value in ipairs(source) do
		if not predicate or predicate(value) then
			count = count + 1
		end
	end

	return count
end

function Table.Any(source: table, predicate: (any) -> boolean): boolean
	if not source or not predicate then
		error("Table source and selector are both required to select values.")
	end

	for _, value in ipairs(source) do
		if predicate(value) then
			return true
		end
	end

	return false
end

function Table.Distinct(source: table, selector: (any) -> any): table
	if not source then
		error("Table source is required to get distinct values.")
	end

	local indexTable = {}
	local newTable = {}
	for _, value in ipairs(source) do
		local selected = value
		if selector then
			selected = selector(value)
		end
		if not table.find(indexTable, selected) then
			table.insert(indexTable, selected)
			table.insert(newTable, value)
		end
	end

	return newTable
end

function Table.Select(source: table, selector: (any) -> any): table
	if not source or not selector then
		error("Table source and selector are both required to select values.")
	end

	local newTable = {}
	for _, value in ipairs(source) do
		table.insert(newTable, selector(value))
	end

	return newTable
end

function Table.FirstOrDefault(source: table, predicate: (any) -> boolean): any
	if not source then
		error("Table source is required.")
	end

	for _, value in ipairs(source) do
		if not predicate(value) then
			continue
		end

		return value
	end

	return nil
end

function Table.Where(source: table, predicate: (any) -> boolean): table
	if not source or not predicate then
		error("Table source and selector are both required to select values.")
	end

	local newTable = {}
	for _, value in ipairs(source) do
		if not predicate(value) then
			continue
		end

		table.insert(newTable, value)
	end

	return newTable
end

return Table
