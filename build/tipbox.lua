function Div(el)
	if el.classes:includes("tipbox") then
		local title = el.attributes["data-title"] or "Tip"
		local begin_cmd = "\\begin{tipbox}{" .. title .. "}"
		local end_cmd = "\\end{tipbox}"
		local new_content = pandoc.List:new()
		new_content:insert(pandoc.RawBlock("latex", begin_cmd))
		new_content:extend(el.content)
		new_content:insert(pandoc.RawBlock("latex", end_cmd))
		return new_content
	end
end
